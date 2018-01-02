

------------------------------------

CREATE OR REPLACE TRIGGER STUDENT_BI 
BEFORE INSERT
ON STUDENT 
FOR EACH ROW
BEGIN 
  :NEW.student_id       := STUDENT_ID_SEQ.NEXTVAL;
  :NEW.created_by       := USER;
  :NEW.created_date     := SYSDATE;
  :NEW.modified_by      := USER;
  :NEW.MODIFIED_DATE    := SYSDATE;
END;



--trigger öncesi insert cümlesi
INSERT INTO student (student_id, first_name, last_name, zip,
registration_date, created_by, created_date, modified_by,
modified_date)
VALUES (STUDENT_ID_SEQ.NEXTVAL, 'John', 'Smith', '00914', SYSDATE,
USER, SYSDATE, USER, SYSDATE);


--trigger sonras? insert cümlesi
INSERT INTO STUDENT (FIRST_NAME, LAST_NAME, ZIP, REGISTRATION_DATE)
VALUES ('John', 'Smith', '00914', SYSDATE);



--11g öncesi sequence kullan?m?
CREATE OR REPLACE TRIGGER student_bi
BEFORE INSERT ON student
FOR EACH ROW
DECLARE
  v_student_id STUDENT.STUDENT_ID%TYPE;
BEGIN
  SELECT STUDENT_ID_SEQ.NEXTVAL INTO v_student_id FROM dual;
  :NEW.student_id    := v_student_id;
  :NEW.created_by    := USER;
  :NEW.created_date  := SYSDATE;
  :NEW.modified_by   := USER;
  :NEW.MODIFIED_DATE := SYSDATE;
END;



--After trigger, statistics tablosunun create edilmesi gerekiyor

CREATE OR REPLACE TRIGGER instructor_aud
AFTER UPDATE OR DELETE ON INSTRUCTOR
DECLARE
  v_type VARCHAR2(10);
BEGIN
  IF UPDATING THEN
    v_type := 'UPDATE';
  ELSIF DELETING THEN
    v_type := 'DELETE';
  END IF;
  UPDATE statistics
  SET transaction_user = USER,
    transaction_date   = SYSDATE
  WHERE table_name     = 'INSTRUCTOR'
  AND transaction_name = v_type;
  IF SQL%NOTFOUND THEN
    INSERT INTO statistics VALUES
      ('INSTRUCTOR', v_type, USER, SYSDATE
      );
  END IF;
END;



--AUTONOMOUS_TRANSACTION kullan?m?

CREATE OR REPLACE TRIGGER instructor_aud
AFTER UPDATE OR DELETE ON INSTRUCTOR
DECLARE
  v_type VARCHAR2(10);
  PRAGMA AUTONOMOUS_TRANSACTION;
BEGIN
  IF UPDATING THEN
    v_type := 'UPDATE';
  ELSIF DELETING THEN
    v_type := 'DELETE';
  END IF;
  UPDATE statistics
  SET transaction_user = USER,
    transaction_date   = SYSDATE
  WHERE table_name     = 'INSTRUCTOR'
  AND transaction_name = v_type;
  IF SQL%NOTFOUND THEN
    INSERT INTO statistics VALUES
      ('INSTRUCTOR', v_type, USER, SYSDATE
      );
  END IF;
  COMMIT;
END;


--ard?ndan çal??t?rarak dene

UPDATE instructor
SET phone = '7181234567'
WHERE instructor_id = 101;

ROLLBACK;

SELECT *
FROM statistics;



--13.1.1 Understand What a Trigger Is

CREATE TRIGGER student_au
AFTER UPDATE ON STUDENT
FOR EACH ROW
WHEN (NVL(NEW.ZIP, ' ') <> OLD.ZIP)
Trigger Body...

/
------------------------------------
CREATE OR REPLACE TRIGGER instructor_bi
BEFORE INSERT ON INSTRUCTOR
FOR EACH ROW
DECLARE
  v_work_zip CHAR(1);
BEGIN
  :NEW.CREATED_BY    := USER;
  :NEW.CREATED_DATE  := SYSDATE;
  :NEW.MODIFIED_BY   := USER;
  :NEW.MODIFIED_DATE := SYSDATE;
  SELECT 'Y' INTO v_work_zip FROM zipcode WHERE zip = :NEW.ZIP;
EXCEPTION
WHEN NO_DATA_FOUND THEN
  RAISE_APPLICATION_ERROR (-20001, 'Zip code is not valid!');
END;


------------------------------------
CREATE OR REPLACE TRIGGER instructor_bi
BEFORE INSERT ON INSTRUCTOR
FOR EACH ROW
DECLARE
  v_work_zip CHAR(1);
BEGIN
  :NEW.CREATED_BY    := USER;
  :NEW.CREATED_DATE  := SYSDATE;
  :NEW.MODIFIED_BY   := USER;
  :NEW.MODIFIED_DATE := SYSDATE;
  IF :NEW.ZIP        IS NULL THEN
    RAISE_APPLICATION_ERROR (-20002, 'Zip code is missing!');
  ELSE
    SELECT 'Y' INTO v_work_zip FROM zipcode WHERE zip = :NEW.ZIP;
  END IF;
EXCEPTION
WHEN NO_DATA_FOUND THEN
  RAISE_APPLICATION_ERROR (-20001, 'Zip code is not valid!');
END;


------------------------------------
CREATE OR REPLACE TRIGGER instructor_biud
BEFORE INSERT OR UPDATE OR DELETE ON INSTRUCTOR
DECLARE
  v_day VARCHAR2(10);
BEGIN
  v_day := RTRIM(TO_CHAR(SYSDATE, 'DAY'));
  IF v_day LIKE ('S%') THEN
    RAISE_APPLICATION_ERROR (-20000, 'A table cannot be modified during off hours');
  END IF;
END;


--yetkileri kontrol et yoksa sys ile yetki atamas? yap?lacak
CREATE VIEW INSTRUCTOR_SUMMARY_VIEW
AS
SELECT i.instructor_id, COUNT(s.section_id) total_courses
FROM instructor i
LEFT OUTER JOIN section s
ON (I.INSTRUCTOR_ID = S.INSTRUCTOR_ID)
GROUP BY i.instructor_id;



DELETE FROM INSTRUCTOR_SUMMARY_VIEW
WHERE instructor_id = 109;



CREATE OR REPLACE TRIGGER instructor_summary_del
INSTEAD OF DELETE ON instructor_summary_view
FOR EACH ROW
BEGIN
  DELETE FROM instructor WHERE INSTRUCTOR_ID = :OLD.INSTRUCTOR_ID;
END;



DELETE FROM INSTRUCTOR_SUMMARY_VIEW
WHERE instructor_id = 109;


--13.2.1 Use Row and Statement Triggers


-- ch13_2a.sql, version 1.0
CREATE OR REPLACE TRIGGER course_bi
BEFORE INSERT ON COURSE
FOR EACH ROW
BEGIN
  :NEW.COURSE_NO     := COURSE_NO_SEQ.NEXTVAL;
  :NEW.CREATED_BY    := USER;
  :NEW.CREATED_DATE  := SYSDATE;
  :NEW.MODIFIED_BY   := USER;
  :NEW.MODIFIED_DATE := SYSDATE;
END;


------------------------------------
CREATE OR REPLACE TRIGGER course_bi
BEFORE INSERT ON COURSE
FOR EACH ROW
DECLARE
  v_prerequisite COURSE.COURSE_NO%TYPE;
BEGIN
  IF :NEW.PREREQUISITE IS NOT NULL THEN
    SELECT course_no
    INTO v_prerequisite
    FROM course
    WHERE course_no = :NEW.PREREQUISITE;
  END IF;
  :NEW.COURSE_NO     := COURSE_NO_SEQ.NEXTVAL;
  :NEW.CREATED_BY    := USER;
  :NEW.CREATED_DATE  := SYSDATE;
  :NEW.MODIFIED_BY   := USER;
  :NEW.MODIFIED_DATE := SYSDATE;
EXCEPTION
WHEN NO_DATA_FOUND THEN
  RAISE_APPLICATION_ERROR (-20002, 'Prerequisite is not
valid!');
END;

--test için dene
INSERT INTO COURSE (DESCRIPTION, COST, PREREQUISITE)
VALUES ('Test Course', 0, 999);



--13.2.2 Use INSTEAD OF Triggers


CREATE VIEW student_address AS
SELECT s.student_id,
  s.first_name,
  s.last_name,
  s.street_address,
  z.city,
  z.state,
  z.zip
FROM student s
JOIN ZIPCODE Z
ON (s.zip = z.zip);



-- ch13_3a.sql, version 1.0
CREATE OR REPLACE TRIGGER student_address_ins
INSTEAD OF INSERT ON student_address
FOR EACH ROW
BEGIN
  INSERT
  INTO STUDENT
    (
      student_id,
      first_name,
      last_name,
      street_address,
      zip,
      registration_date,
      created_by,
      created_date,
      modified_by,
      modified_date
    )
    VALUES
    (
      :NEW.student_id,
      :NEW.first_name,
      :NEW.last_name,
      :NEW.street_address,
      :NEW.zip,
      SYSDATE,
      USER,
      SYSDATE,
      USER,
      SYSDATE
    );
END;



--test için ikisini de dene
INSERT INTO student_address
VALUES (STUDENT_ID_SEQ.NEXTVAL, 'John', 'Smith', '123 Main Street',
'New York', 'NY', '10019');

INSERT INTO student_address
VALUES (STUDENT_ID_SEQ.NEXTVAL, 'John', 'Smith', '123 Main Street',
'New York', 'NY', '12345');


------------------------------------
CREATE OR REPLACE TRIGGER student_address_ins
INSTEAD OF INSERT ON student_address
FOR EACH ROW
DECLARE
  v_zip VARCHAR2(5);
BEGIN
  SELECT zip INTO v_zip FROM zipcode WHERE zip = :NEW.ZIP;
  INSERT
  INTO STUDENT
    (
      student_id,
      first_name,
      last_name,
      street_address,
      zip,
      registration_date,
      created_by,
      created_date,
      modified_by,
      modified_date
    )
    VALUES
    (
      :NEW.student_id,
      :NEW.first_name,
      :NEW.last_name,
      :NEW.street_address,
      :NEW.zip,
      SYSDATE,
      USER,
      SYSDATE,
      USER,
      SYSDATE
    );
EXCEPTION
WHEN NO_DATA_FOUND THEN
  RAISE_APPLICATION_ERROR (-20002, 'Zip code is not valid!');
END;


------------------------------------
CREATE OR REPLACE TRIGGER student_address_ins
INSTEAD OF INSERT ON student_address
FOR EACH ROW
DECLARE
  v_zip VARCHAR2(5);
BEGIN
  BEGIN
    SELECT zip INTO v_zip FROM zipcode WHERE zip = :NEW.zip;
  EXCEPTION
  WHEN NO_DATA_FOUND THEN
    INSERT
    INTO ZIPCODE
      (
        zip,
        city,
        state,
        created_by,
        created_date,
        modified_by,
        modified_date
      )
      VALUES
      (
        :NEW.zip,
        :NEW.city,
        :NEW.state,
        USER,
        SYSDATE,
        USER,
        SYSDATE
      );
  END;
  INSERT
  INTO STUDENT
    (
      student_id,
      first_name,
      last_name,
      street_address,
      zip,
      registration_date,
      created_by,
      created_date,
      modified_by,
      modified_date
    )
    VALUES
    (
      :NEW.student_id,
      :NEW.first_name,
      :NEW.last_name,
      :NEW.street_address,
      :NEW.zip,
      SYSDATE,
      USER,
      SYSDATE,
      USER,
      SYSDATE
    );
END;



------------------------------------

CREATE OR REPLACE TRIGGER enrollment_bi
BEFORE INSERT ON ENROLLMENT
FOR EACH ROW
DECLARE
  v_valid NUMBER := 0;
BEGIN
  SELECT COUNT(*) INTO v_valid FROM student WHERE student_id = :NEW.STUDENT_ID;
  IF v_valid = 0 THEN
    RAISE_APPLICATION_ERROR (-20000, 'This is not a valid student');
  END IF;
  SELECT COUNT(*) INTO v_valid FROM section WHERE section_id = :NEW.SECTION_ID;
  IF v_valid = 0 THEN
    RAISE_APPLICATION_ERROR (-20001, 'This is not a valid section');
  END IF;
  :NEW.ENROLL_DATE   := SYSDATE;
  :NEW.CREATED_BY    := USER;
  :NEW.CREATED_DATE  := SYSDATE;
  :NEW.MODIFIED_BY   := USER;
  :NEW.MODIFIED_DATE := SYSDATE;
END;



------------------------------------


CREATE OR REPLACE TRIGGER section_bu
BEFORE UPDATE ON SECTION
FOR EACH ROW
DECLARE
  v_valid NUMBER := 0;
BEGIN
  IF :NEW.INSTRUCTOR_ID IS NOT NULL THEN
    SELECT COUNT(*)
    INTO v_valid
    FROM instructor
    WHERE instructor_id = :NEW.instructor_ID;
    IF v_valid          = 0 THEN
      RAISE_APPLICATION_ERROR (-20000, 'This is not a valid instructor');
    END IF;
  END IF;
  :NEW.MODIFIED_BY   := USER;
  :NEW.MODIFIED_DATE := SYSDATE;
END;

















