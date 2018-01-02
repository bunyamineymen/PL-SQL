--MODULE 14
------------


--Compound Triggers
--------------------


--Mutating Table Issues

--section tablosu mutating oluyor. 10 veya daha fazla section da ders veren e?itmen için uyar? hatas? veriliyor
CREATE OR REPLACE TRIGGER section_biu
BEFORE INSERT OR UPDATE ON section
FOR EACH ROW
DECLARE
  v_total NUMBER;
  v_name  VARCHAR2(30);
BEGIN
  SELECT COUNT(*)
  INTO v_total
  FROM section -- SECTION is MUTATING
  WHERE instructor_id = :NEW. instructor_id;
  -- check if the current instructor is overbooked
  IF v_total >= 10 THEN
    SELECT first_name
      ||' '
      ||last_name
    INTO v_name
    FROM instructor
    WHERE instructor_id = :NEW.instructor_id;
    RAISE_APPLICATION_ERROR (-20000, 'Instructor, '||v_name||', is overbooked');
  END IF;
EXCEPTION
WHEN NO_DATA_FOUND THEN
  RAISE_APPLICATION_ERROR (-20001, 'This is not a valid instructor');
END;


--section tablosu mutating oluyor. update edilerek. üzerinde de update edildi?inde tan?ml? olan trigger var
--dolay?s?yla bu update i?leminde mutating table hatas? al?nacak
UPDATE section
SET INSTRUCTOR_ID = 101
WHERE section_id = 80;


--11g öncesi mutating table hatas?n?n çözümü

1)--global de?i?kenlerin tutulaca?? package tan?mla

CREATE OR REPLACE PACKAGE instructor_adm AS
v_instructor_id instructor.instructor_id%TYPE;
V_INSTRUCTOR_NAME VARCHAR2(50);
END;

2)--var olan triggeri güncelle. global de?i?kenleri initialize et

CREATE OR REPLACE TRIGGER section_biu
BEFORE INSERT OR UPDATE ON section
FOR EACH ROW
BEGIN
  IF :NEW. instructor_id IS NOT NULL THEN
    BEGIN
      instructor_adm.v_instructor_id := :NEW.INSTRUCTOR_ID;
      SELECT first_name
        ||' '
        ||last_name
      INTO instructor_adm.v_instructor_name
      FROM instructor
      WHERE instructor_id = instructor_adm.v_instructor_id;
    EXCEPTION
    WHEN NO_DATA_FOUND THEN
      RAISE_APPLICATION_ERROR (-20001, 'This is not a valid instructor');
    END;
  END IF;
END;

3)--yeni bir after statement level trigger tan?mla

CREATE OR REPLACE TRIGGER section_aiu
AFTER INSERT OR UPDATE ON section
DECLARE
  v_total INTEGER;
BEGIN
  SELECT COUNT(*)
  INTO v_total
  FROM section
  WHERE instructor_id = instructor_adm.v_instructor_id;
  -- check if the current instructor is overbooked
  IF v_total >= 10 THEN
    RAISE_APPLICATION_ERROR (-20000, 'Instructor, '||instructor_adm.v_instructor_name|| ', is overbooked');
  END IF;
END;

--sonucunu test et
UPDATE section
SET INSTRUCTOR_ID = 110
WHERE section_id = 80;



--14.1.1 Understand Mutating Tables

--mutating table hatas? al?nacak trigger olu?turulur
-- ch14_1a.sql, version 1.0
CREATE OR REPLACE TRIGGER enrollment_biu
BEFORE INSERT OR UPDATE ON enrollment
FOR EACH ROW
DECLARE
  v_total NUMBER;
  v_name  VARCHAR2(30);
BEGIN
  SELECT COUNT(*)
  INTO v_total
  FROM enrollment
  WHERE student_id = :NEW. student_id;
  -- check if the current student is enrolled in too
  -- many courses
  IF v_total >= 3 THEN
    SELECT first_name
      ||' '
      ||last_name
    INTO v_name
    FROM student
    WHERE student_id = :NEW.STUDENT_ID;
    RAISE_APPLICATION_ERROR (-20000, 'Student, '||v_name|| ', is registered for 3 courses already');
  END IF;
EXCEPTION
WHEN NO_DATA_FOUND THEN
  RAISE_APPLICATION_ERROR (-20001, 'This is not a valid student');
END;


--çal??t?rmay? dene

--ORA -20000 kullan?c? tan?ml? hata
INSERT INTO ENROLLMENT
(student_id, section_id, enroll_date, created_by, created_date,
modified_by, modified_date)
VALUES (184, 98, SYSDATE, USER, SYSDATE, USER, SYSDATE);

--hata yok
INSERT INTO ENROLLMENT
(student_id, section_id, enroll_date, created_by, created_date,
modified_by, modified_date)
VALUES (399, 98, SYSDATE, USER, SYSDATE, USER, SYSDATE);

--mutating table hatas? al?n?r
UPDATE ENROLLMENT
SET STUDENT_ID = 399
WHERE student_id = 283;


/*
B) Explain why two of the statements did not succeed.


C) Modify the trigger so that it does not cause a mutating table error when an UPDATE statement is
issued against the ENROLLMENT table.
*/

1)

CREATE OR REPLACE PACKAGE student_adm AS
v_student_id student.student_id%TYPE;
V_STUDENT_NAME VARCHAR2(50);
END;


2)

CREATE OR REPLACE TRIGGER enrollment_biu
BEFORE INSERT OR UPDATE ON enrollment
FOR EACH ROW
BEGIN
  IF :NEW.STUDENT_ID IS NOT NULL THEN
    BEGIN
      student_adm.v_student_id := :NEW. student_id;
      SELECT first_name
        ||' '
        ||last_name
      INTO student_adm.v_student_name
      FROM student
      WHERE student_id = student_adm.v_student_id;
    EXCEPTION
    WHEN NO_DATA_FOUND THEN
      RAISE_APPLICATION_ERROR (-20001, 'This is not a valid student');
    END;
  END IF;
END;

3)

CREATE OR REPLACE TRIGGER enrollment_aiu
AFTER INSERT OR UPDATE ON enrollment
DECLARE
  v_total INTEGER;
BEGIN
  SELECT COUNT(*)
  INTO v_total
  FROM enrollment
  WHERE student_id = student_adm.v_student_id;
  -- check if the current student is enrolled in too
  -- many courses
  IF v_total >= 3 THEN
    RAISE_APPLICATION_ERROR (-20000, 'Student, '|| student_adm.v_student_name|| ', is registered for 3 courses already ');
  END IF;
END;

---------------------------------------------------------------------------------------------


--Compound Triggers

--Sadece before statement ve before each row tan?ml? compound trigger
--i? günlerinde insert edilmesini sa?layan ve insert edilmeden önce initialize eden triggerlar yaz?l?yor

CREATE OR REPLACE TRIGGER student_compound
FOR INSERT ON STUDENT
COMPOUND TRIGGER
-- Declaration section
v_day  VARCHAR2(10);
v_date DATE;
v_user VARCHAR2(30);
BEFORE STATEMENT
IS
BEGIN
  v_day := RTRIM(TO_CHAR(SYSDATE, 'DAY'));
  IF v_day LIKE ('S%') THEN
    RAISE_APPLICATION_ERROR (-20000, 'A table cannot be modified during off hours');
  END IF;
  v_date := SYSDATE;
  v_user := USER;
END BEFORE STATEMENT;
BEFORE EACH ROW
IS
BEGIN
  :NEW.student_id    := STUDENT_ID_SEQ.NEXTVAL;
  :NEW.created_by    := v_user;
  :NEW.created_date  := v_date;
  :NEW.modified_by   := v_user;
  :NEW.modified_date := v_date;
END BEFORE EACH ROW;
END student_compound;



--önceki modülde yaz?lan mutating table hatas? veren trigger

CREATE OR REPLACE TRIGGER section_biu
BEFORE INSERT OR UPDATE ON section
FOR EACH ROW
DECLARE
  v_total NUMBER;
  v_name  VARCHAR2(30);
BEGIN
  SELECT COUNT(*)
  INTO v_total
  FROM section -- SECTION is MUTATING
  WHERE instructor_id = :NEW.instructor_id;
  -- check if the current instructor is overbooked
  IF v_total >= 10 THEN
    SELECT first_name
      ||' '
      ||last_name
    INTO v_name
    FROM instructor
    WHERE instructor_id = :NEW.instructor_id;
    RAISE_APPLICATION_ERROR (-20000, 'Instructor, '||v_name||', is overbooked');
  END IF;
EXCEPTION
WHEN NO_DATA_FOUND THEN
  RAISE_APPLICATION_ERROR (-20001, 'This is not a valid instructor');
END;



--COMPOUND TRIGGER ile çözümü

CREATE OR REPLACE TRIGGER section_compound
FOR INSERT OR UPDATE ON SECTION
COMPOUND TRIGGER
-- Declaration Section
v_instructor_id INSTRUCTOR.INSTRUCTOR_ID%TYPE;
v_instructor_name VARCHAR2(50);
v_total           INTEGER;
BEFORE EACH ROW
IS
BEGIN
  IF :NEW. instructor_id IS NOT NULL THEN
    BEGIN
      v_instructor_id := :NEW. instructor_id;
      SELECT first_name
        ||' '
        ||last_name
      INTO instructor_adm.v_instructor_name
      FROM instructor
      WHERE instructor_id = instructor_adm.v_instructor_id;
    EXCEPTION
    WHEN NO_DATA_FOUND THEN
      RAISE_APPLICATION_ERROR (-20001, 'This is not a valid instructor');
    END;
  END IF;
END BEFORE EACH ROW;
AFTER STATEMENT
IS
BEGIN
  SELECT COUNT(*)
  INTO v_total
  FROM section
  WHERE instructor_id = v_instructor_id;
  -- check if the current instructor is overbooked
  IF v_total >= 10 THEN
    RAISE_APPLICATION_ERROR (-20000, 'Instructor, '||instructor_adm.v_instructor_name|| ', is overbooked');
  END IF;
END AFTER STATEMENT;
END section_compound;


--test et, kullan?c? hatas? al?n?r
UPDATE section
SET INSTRUCTOR_ID = 101
WHERE section_id = 80;


--14.2.1 Understand Compound Triggers

--önceki lab da yap?lan de?i?iklikler kald?r?l?yor
DROP TRIGGER enrollment_biu;
DROP TRIGGER enrollment_aiu;
DROP PACKAGE student_adm;
DELETE FROM enrollment
WHERE STUDENT_ID = 399;
COMMIT;


--yine ayn? DML cümlelerini çal??t?rmay? dene
--user defined error al?n?r
INSERT INTO ENROLLMENT
(student_id, section_id, enroll_date, created_by, created_date,
modified_by, modified_date)
VALUES (184, 98, SYSDATE, USER, SYSDATE, USER, SYSDATE);

--hata al?nmaz
INSERT INTO ENROLLMENT
(student_id, section_id, enroll_date, created_by, created_date,
modified_by, modified_date)
VALUES (399, 98, SYSDATE, USER, SYSDATE, USER, SYSDATE);

--mutating table hatas? al?n?r
UPDATE ENROLLMENT
SET STUDENT_ID = 399
WHERE student_id = 283;



/*
A) Create a new compound trigger so that it does not cause a mutating table error when an UPDATE
statement is issued against the ENROLLMENT table.
*/


CREATE OR REPLACE TRIGGER enrollment_compound
FOR INSERT OR UPDATE ON enrollment
COMPOUND TRIGGER
v_student_id STUDENT.STUDENT_ID%TYPE;
v_student_name VARCHAR2(50);
v_total        INTEGER;
BEFORE EACH ROW
IS
BEGIN
  IF :NEW. student_id IS NOT NULL THEN
    BEGIN
      v_student_id := :NEW.student_id;
      SELECT first_name
        ||' '
        ||last_name
      INTO v_student_name
      FROM student
      WHERE student_id = v_student_id;
    EXCEPTION
    WHEN NO_DATA_FOUND THEN
      RAISE_APPLICATION_ERROR (-20001, 'This is not a valid student');
    END;
  END IF;
END BEFORE EACH ROW;
AFTER STATEMENT
IS
BEGIN
  SELECT COUNT(*) INTO v_total FROM enrollment WHERE student_id = v_student_id;
  -- check if the current student is enrolled in too
  -- many courses
  IF v_total >= 3 THEN
    RAISE_APPLICATION_ERROR (-20000, 'Student, '||v_student_name|| ', is registered for 3 courses already ');
  END IF;
END AFTER STATEMENT;
END enrollment_compound;

/*
B) Run the UPDATE statement listed in the exercise text again. Explain the output produced.
*/

--farkl? bir hata al?n?r. integrity constraint hatas?
UPDATE ENROLLMENT
SET student_id = 399
WHERE student_id = 283;


/*
C) MODIFY THE COMPOUND TRIGGER SO THAT THE TRIGGER POPULATES THE VALUES FOR THE CREATED_BY,
CREATED_DATE, MODIFIED_BY, and MODIFIED_DATE columns.
*/

-- ch14_2b.sql, version 2.0
CREATE OR REPLACE TRIGGER enrollment_compound
FOR INSERT OR UPDATE ON enrollment
COMPOUND TRIGGER
v_student_id STUDENT.STUDENT_ID%TYPE;
v_student_name VARCHAR2(50);
v_total        INTEGER;
v_date         DATE;
v_user STUDENT.CREATED_BY%TYPE;
BEFORE STATEMENT
IS
BEGIN
  v_date := SYSDATE;
  v_user := USER;
END BEFORE STATEMENT;
BEFORE EACH ROW
IS
BEGIN
  IF INSERTING THEN
    :NEW.created_date := v_date;
    :NEW.created_by   := v_user;
  ELSIF UPDATING THEN
    :NEW.created_date := :OLD.created_date;
    :NEW.created_by   := :OLD.created_by;
  END IF;
  :NEW.MODIFIED_DATE := v_date;
  :NEW.MODIFIED_BY   := v_user;
  IF :NEW.STUDENT_ID IS NOT NULL THEN
    BEGIN
      v_student_id := :NEW.STUDENT_ID;
      SELECT first_name
        ||' '
        ||last_name
      INTO v_student_name
      FROM student
      WHERE student_id = v_student_id;
    EXCEPTION
    WHEN NO_DATA_FOUND THEN
      RAISE_APPLICATION_ERROR (-20001, 'This is not a valid student');
    END;
  END IF;
END BEFORE EACH ROW;
AFTER STATEMENT
IS
BEGIN
  SELECT COUNT(*) INTO v_total FROM enrollment WHERE student_id = v_student_id;
  -- check if the current student is enrolled in too
  -- many courses
  IF v_total >= 3 THEN
    RAISE_APPLICATION_ERROR (-20000, 'Student, '||v_student_name|| ', is registered for 3 courses already ');
  END IF;
END AFTER STATEMENT;
END enrollment_compound;


--test et

--user defined error
INSERT INTO enrollment
(student_id, section_id, enroll_date, final_grade)
VALUES (102, 155, sysdate, null);

--hata yok
INSERT INTO enrollment
(student_id, section_id, enroll_date, final_grade)
VALUES (103, 155, sysdate, null);

--hata yok
UPDATE ENROLLMENT
SET final_grade = 85
WHERE student_id = 105
AND section_id = 155;


ROLLBACK;






--MODULE 14 TRY IT YOURSELF
----------------------------


--Chapter 14,“Compound Triggers”

/*
1) Create a compound trigger on the INSTRUCTOR table that fires on the INSERT and UPDATE statements.
The trigger should not allow an insert or update on the INSTRUCTOR table during off
hours.Off hours are weekends and times of day outside the 9 a.m. to 5 p.m. window.The trigger
should also populate the INSTRUCTOR_ID, CREATED_BY, CREATED_DATE, MODIFIED_BY, and
MODIFIED_DATE columns with their default values.

ANSWER: The trigger should look similar to the following:
*/

CREATE OR REPLACE TRIGGER instructor_compound
FOR INSERT OR UPDATE ON instructor
COMPOUND TRIGGER
v_date DATE;
v_user VARCHAR2(30);
BEFORE STATEMENT
IS
BEGIN
  IF RTRIM(TO_CHAR(SYSDATE, 'DAY')) NOT LIKE 'S%' AND RTRIM(TO_CHAR(SYSDATE, 'HH24:MI')) BETWEEN '09:00' AND '17:00' THEN
    v_date := SYSDATE;
    v_user := USER;
  ELSE
    RAISE_APPLICATION_ERROR (-20000, 'A table cannot be modified during off hours');
  END IF;
END BEFORE STATEMENT;
BEFORE EACH ROW
IS
BEGIN
  IF INSERTING THEN
    :NEW.instructor_id := INSTRUCTOR_ID_SEQ.NEXTVAL;
    :NEW.created_by    := v_user;
    :NEW.created_date  := v_date;
  ELSIF UPDATING THEN
    :NEW.created_by   := :OLD.created_by;
    :NEW.created_date := :OLD.created_date;
  END IF;
  :NEW.modified_by   := v_user;
  :NEW.modified_date := v_date;
END BEFORE EACH ROW;
END instructor_compound;


/*
This compound trigger has two executable sections, BEFORE STATEMENT and BEFORE EACH ROW.
The BEFORE STATEMENT portion prevents any updates to the INSTRUCTOR table during off hours.
In addition, it populates the v_date and v_user variables that are used to populate the
CREATED_BY, CREATED_DATE, MODIFIED_BY, and MODIFIED_DATE columns.The BEFORE EACH
ROW section populates these columns. In addition, it assigns a value to the INSTRUCTOR_ID
column from INSTRUCTOR_ID_SEQ.
Note the use of the INSERTING and UPDATING functions in the BEFORE EACH ROW section.The
INSERTING function is used because the INSTRUCTOR_ID, CREATED_BY, and CREATED_DATE
columns are populated with new values only if a record is being inserted in the INSTRUCTOR
table.This is not so when a record is being updated. In this case, the CREATED_BY and
CREATED_DATE columns are populated with the values copied from the OLD pseudorecord.
However, the MODIFIED_BY and MODIFIED_DATE columns need to be populated with the new
values regardless of the INSERT or UPDATE operation.
The newly created trigger may be tested as follows:
SET SERVEROUTPUT ON
DECLARE
v_date VARCHAR2(20);
BEGIN
v_date := TO_CHAR(SYSDATE, 'DD/MM/YYYY HH24:MI');
DBMS_OUTPUT.PUT_LINE ('Date: '||v_date);
INSERT INTO instructor
(salutation, first_name, last_name, street_address, zip, phone)
VALUES
('Mr.', 'Test', 'Instructor', '123 Main Street', '07112',
'2125555555');
ROLLBACK;
END;
/
The output is as follows:
Date: 25/04/2008 15:47
PL/SQL procedure successfully completed.
Here’s the second test:
SET SERVEROUTPUT ON
DECLARE
v_date VARCHAR2(20);
BEGIN
v_date := TO_CHAR(SYSDATE, 'DD/MM/YYYY HH24:MI');
DBMS_OUTPUT.PUT_LINE ('Date: '||v_date);
UPDATE instructor
SET phone = '2125555555'
WHERE instructor_id = 101;
ROLLBACK;
END;
/
The output is as follows:
Date: 26/04/2008 19:50
DECLARE
*
ERROR at line 1:
ORA-20000: A table cannot be modified during off hours
ORA-06512: at "STUDENT.INSTRUCTOR_COMPOUND", line 15
ORA-04088: error during execution of trigger 'STUDENT.INSTRUCTOR_COMPOUND'
ORA-06512: at line 7



2) Create a compound trigger on the ZIPCODE table that fires on the INSERT and UPDATE statements.
The trigger should populate the CREATED_BY, CREATED_DATE, MODIFIED_BY, and
MODIFIED_DATE columns with their default values. In addition, it should record in the STATISTICS
table the type of the transaction, the name of the user who issued the transaction, and the date
of the transaction. Assume that the STATISTICS table has the following structure:
Name Null? Type
------------------------------- -------- ----
TABLE_NAME VARCHAR2(30)
TRANSACTION_NAME VARCHAR2(10)
TRANSACTION_USER VARCHAR2(30)
TRANSACTION_DATE DATE


ANSWER: The trigger should look similar to the following:
*/


CREATE OR REPLACE TRIGGER zipcode_compound
FOR INSERT OR UPDATE ON zipcode
COMPOUND TRIGGER
v_date DATE;
v_user VARCHAR2(30);
v_type VARCHAR2(10);
BEFORE STATEMENT
IS
BEGIN
  v_date := SYSDATE;
  v_user := USER;
END BEFORE STATEMENT;
BEFORE EACH ROW
IS
BEGIN
  IF INSERTING THEN
    :NEW.created_by   := v_user;
    :NEW.created_date := v_date;
  ELSIF UPDATING THEN
    :NEW.created_by   := :OLD.created_by;
    :NEW.created_date := :OLD.created_date;
  END IF;
  :NEW.modified_by   := v_user;
  :NEW.modified_date := v_date;
END BEFORE EACH ROW;
AFTER STATEMENT
IS
BEGIN
  IF INSERTING THEN
    v_type := 'INSERT';
  ELSIF UPDATING THEN
    v_type := 'UPDATE';
  END IF;
  INSERT
  INTO statistics
    (
      table_name,
      transaction_name,
      transaction_user,
      transaction_date
    )
    VALUES
    (
      'ZIPCODE',
      v_type,
      v_user,
      v_date
    );
END AFTER STATEMENT;
END ZIPCODE_COMPOUND;


UPDATE zipcode
SET city = 'Test City'
WHERE zip = '01247';


SELECT *
FROM statistics
WHERE TRANSACTION_DATE >= TRUNC(SYSDATE);

/*
TABLE_NAME TRANSACTION_NAME TRANSACTION_USER TRANSACTION_DATE
---------- ---------------- ---------------- ----------------
ZIPCODE UPDATE STUDENT 24-APR-08

*/
ROLLBACK;

















