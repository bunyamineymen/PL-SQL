-----------------------------------------------------------------

SET SERVEROUTPUT ON
DECLARE
  v_average_cost VARCHAR2(10);
BEGIN
  SELECT TO_CHAR(AVG(cost), '$9,999.99') INTO v_average_cost FROM course;
  DBMS_OUTPUT.PUT_LINE('The average cost of a course in the CTA program is '|| V_AVERAGE_COST);
END;


-----------------------------------------------------------------


DECLARE
  v_city zipcode.city%TYPE;
BEGIN
  SELECT 'COLUMBUS' INTO v_city FROM dual;
  UPDATE zipcode SET city = v_city WHERE ZIP = 43224;
END;


-----------------------------------------------------------------

DECLARE
  v_zip zipcode.zip%TYPE;
  v_user zipcode.created_by%TYPE;
  v_date zipcode.created_date%TYPE;
BEGIN
  SELECT 43438, USER, SYSDATE INTO v_zip, v_user, v_date FROM dual;
  INSERT
  INTO zipcode
    (
      ZIP,
      CREATED_BY ,
      CREATED_DATE,
      MODIFIED_BY,
      MODIFIED_DATE
    )
    VALUES
    (
      V_ZIP,
      V_USER,
      V_DATE,
      V_USER,
      V_DATE
    );
END;

-----------------------------------------------------------------

DECLARE 
  v_max_id NUMBER;
BEGIN
  SELECT MAX(student_id) INTO v_max_id FROM student;
  INSERT
  INTO student
    (
      student_id,
      last_name,
      zip,
      created_by,
      created_date,
      modified_by,
      modified_date,
      registration_date
    )
    VALUES
    (
      V_MAX_ID + 1,
      'altintas',
      11238,
      'STUDENT',
      TO_DATE('20130101','YYYYMMDD'),
      'STUDENT',
      '01-JAN-13',
      '01-JAN-13'
    );
END;


-----------------------------------------------------------------

CREATE TABLE test01
  (col1 NUMBER
  );
  
CREATE SEQUENCE test_seq INCREMENT BY 5;
  
  BEGIN
    INSERT INTO test01 VALUES
      (test_seq.NEXTVAL
      );
  END;
  /
  
  
  
  -----------------------------------------------------------------
  

DECLARE
  v_user student.created_by%TYPE;
  v_date student.created_date%TYPE;
BEGIN
  SELECT USER, sysdate INTO v_user, v_date FROM dual;
  INSERT
  INTO student
    (
      student_id,
      last_name,
      zip,
      created_by,
      created_date,
      modified_by,
      modified_date,
      registration_date
    )
    VALUES
    (
      student_id_seq.nextval,
      'Smith',
      11238,
      v_user,
      v_date,
      v_user,
      v_date,
      v_date
    );
END;


-----------------------------------------------------------------------------------

BEGIN
  -- STEP 1
  UPDATE course
  SET cost = cost - (cost * 0.10)
  WHERE prerequisite IS NULL;
  -- STEP 2
  UPDATE COURSE
  SET cost = cost + (cost * 0.10)
  WHERE PREREQUISITE IS NOT NULL;
END;


-----------------------------------------------------------------------------------


BEGIN
INSERT INTO student
( student_id, Last_name, zip, registration_date,
created_by, created_date, modified_by,
modified_date
)
VALUES ( student_id_seq.nextval, 'Tashi', 10015,
'01-JAN-99', 'STUDENTA', '01-JAN-99',
'STUDENTA','01-JAN-99'
);
SAVEPOINT A;
INSERT INTO student
( student_id, Last_name, zip, registration_date,
created_by, created_date, modified_by,
modified_date
)
VALUES (student_id_seq.nextval, 'Sonam', 10015,
'01-JAN-99', 'STUDENTB','01-JAN-99',
'STUDENTB', '01-JAN-99'
);
SAVEPOINT B;
INSERT INTO student
( student_id, Last_name, zip, registration_date,
created_by, created_date, modified_by,
modified_date
)
VALUES (student_id_seq.nextval, 'Norbu', 10015,
'01-JAN-99', 'STUDENTB', '01-JAN-99',
'STUDENTB', '01-JAN-99'
);
SAVEPOINT C;
ROLLBACK TO B;
END;
  
 
-----------------------------------------------------------------------------------
 
CREATE TABLE chap4
(id NUMBER,
name VARCHAR2(20));

CREATE SEQUENCE chap4_seq
NOMAXVALUE
NOMINVALUE
NOCYCLE
NOCACHE;



DECLARE
  v_name student.last_name%TYPE;
  v_id student.student_id%TYPE;
BEGIN
  BEGIN
    -- A second block is used to capture the possibility of
    -- multiple students meeting this requirement.
    -- The exception section handles this situation.
    SELECT s.last_name
    INTO v_name
    FROM student s,
      enrollment e
    WHERE s.student_id = e.student_id
    HAVING COUNT(       *)    =
      (SELECT MAX(COUNT(*))
      FROM student s,
        enrollment e
      WHERE s.student_id = e.student_id
      GROUP BY s.student_id
      )
    GROUP BY s.last_name;
  EXCEPTION
  WHEN TOO_MANY_ROWS THEN
    v_name := 'Multiple Names';
  END;
  INSERT INTO CHAP4 VALUES
    (CHAP4_SEQ.NEXTVAL, v_name
    );
  SAVEPOINT A;
  BEGIN
    SELECT s.last_name
    INTO v_name
    FROM student s,
      enrollment e
    WHERE s.student_id = e.student_id
    HAVING COUNT(       *)    =
      (SELECT MIN(COUNT(*))
      FROM student s,
        enrollment e
      WHERE s.student_id = e.student_id
      GROUP BY s.student_id
      )
    GROUP BY s.last_name;
  EXCEPTION
  WHEN TOO_MANY_ROWS THEN
    v_name := 'Multiple Names';
  END;
  INSERT INTO CHAP4 VALUES
    (CHAP4_SEQ.NEXTVAL, v_name
    );
  SAVEPOINT B;
  BEGIN
    SELECT i.last_name
    INTO v_name
    FROM instructor i,
      section s
    WHERE s.instructor_id = i.instructor_id
    HAVING COUNT(       *)       =
      (SELECT MAX(COUNT(*))
      FROM instructor i,
        section s
      WHERE s.instructor_id = i.instructor_id
      GROUP BY i.instructor_id
      )
    GROUP BY i.last_name;
  EXCEPTION
  WHEN TOO_MANY_ROWS THEN
    v_name := 'Multiple Names';
  END;
  SAVEPOINT C;
  BEGIN
    SELECT instructor_id INTO v_id FROM instructor WHERE last_name = v_name;
  EXCEPTION
  WHEN NO_DATA_FOUND THEN
    v_id := 999;
  END;
  INSERT INTO CHAP4 VALUES
    (v_id, v_name
    );
  ROLLBACK TO SAVEPOINT B;
  BEGIN
    SELECT i.last_name
    INTO v_name
    FROM instructor i,
      section s
    WHERE s.instructor_id = i.instructor_id
    HAVING COUNT(       *)       =
      (SELECT MIN(COUNT(*))
      FROM instructor i,
        section s
      WHERE s.instructor_id = i.instructor_id
      GROUP BY i.instructor_id
      )
    GROUP BY i.last_name;
  EXCEPTION
  WHEN TOO_MANY_ROWS THEN
    v_name := 'Multiple Names';
  END;
  INSERT INTO CHAP4 VALUES
    (v_id, v_name
    );
  BEGIN
    SELECT i.last_name
    INTO v_name
    FROM instructor i,
      section s
    WHERE s.instructor_id = i.instructor_id
    HAVING COUNT(       *)       =
      (SELECT MAX(COUNT(*))
      FROM instructor i,
        section s
      WHERE s.instructor_id = i.instructor_id
      GROUP BY i.instructor_id
      )
    GROUP BY i.last_name;
  EXCEPTION
  WHEN TOO_MANY_ROWS THEN
    v_name := 'Multiple Names';
  END;
  INSERT INTO CHAP4 VALUES
    (CHAP4_SEQ.NEXTVAL, V_NAME
    );
END;









 

  
  
  
  
  
  
  


