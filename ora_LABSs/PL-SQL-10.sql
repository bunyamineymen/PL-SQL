
DECLARE
  v_student_id student.student_id%type := &sv_student_id;
  v_total_courses NUMBER;
BEGIN
  IF v_student_id < 0 THEN
    RAISE_APPLICATION_ERROR (-20000, 'An id cannot be negative');
  ELSE
    SELECT COUNT(*)
    INTO v_total_courses
    FROM enrollment
    WHERE student_id = v_student_id;
    DBMS_OUTPUT.PUT_LINE ('The student is registered for '|| v_total_courses||' courses');
  END IF;
END;


-----------------------------------------------------------------------------------


DECLARE
  v_student_id student.student_id%type := &sv_student_id;
  v_name VARCHAR2(50);
BEGIN
  SELECT first_name
    ||' '
    ||last_name
  INTO v_name
  FROM student
  WHERE student_id = v_student_id;
  DBMS_OUTPUT.PUT_LINE (v_name);
EXCEPTION
WHEN NO_DATA_FOUND THEN
  RAISE_APPLICATION_ERROR (-20001, 'This ID is invalid');
END;




-----------------------------------------------------------------------------------




SET SERVEROUTPUT ON
DECLARE
  v_students NUMBER(3) := 0;
BEGIN
  SELECT COUNT(*)
  INTO v_students
  FROM enrollment e,
    section s
  WHERE e.section_id = s.section_id
  AND s.course_no    = 25
  AND s.section_id   = 89;
  DBMS_OUTPUT.PUT_LINE ('Course 25, section 89 has '||v_students|| ' students');
END;



-----------------------------------------------------------------------------------



SET SERVEROUTPUT ON
DECLARE
  v_students NUMBER(3) := 0;
BEGIN
  SELECT COUNT(*)
  INTO v_students
  FROM enrollment e,
    section s
  WHERE e.section_id = s.section_id
  AND s.course_no    = 25
  AND s.section_id   = 89;
  IF v_students      > 10 THEN
    RAISE_APPLICATION_ERROR (-20002, 'Course 25, section 89 has more than 10 students');
  END IF;
  DBMS_OUTPUT.PUT_LINE ('Course 25, section 89 has '||v_students|| ' students');
END;



-----------------------------------------------------------------------------------------------

DECLARE
  v_zip zipcode.zip%type := '&sv_zip';
BEGIN
  DELETE FROM zipcode WHERE zip = v_zip;
  DBMS_OUTPUT.PUT_LINE ('Zip '||v_zip||' has been deleted');
  COMMIT;
END;


-----------------------------------------------------------------------------------



DECLARE
  v_zip zipcode.zip%type := '&sv_zip';
  e_child_exists EXCEPTION;
  PRAGMA EXCEPTION_INIT(e_child_exists, -2292);
BEGIN
  DELETE FROM zipcode WHERE zip = v_zip;
  DBMS_OUTPUT.PUT_LINE ('Zip '||v_zip||' has been deleted');
  COMMIT;
EXCEPTION
WHEN e_child_exists THEN
  DBMS_OUTPUT.PUT_LINE ('Delete students for this '|| 'zipcode first');
END;



-----------------------------------------------------------------------------------



SET SERVEROUTPUT ON
BEGIN
  INSERT
  INTO course
    (
      course_no,
      description,
      created_by,
      created_date
    )
    VALUES
    (
      COURSE_NO_SEQ.NEXTVAL,
      'TEST COURSE',
      USER,
      SYSDATE
    );
  COMMIT;
  DBMS_OUTPUT.PUT_LINE ('One course has been added');
END;



-----------------------------------------------------------------------------------


SET SERVEROUTPUT ON
DECLARE
  e_constraint_violation EXCEPTION;
  PRAGMA EXCEPTION_INIT(e_constraint_violation, -1400);
BEGIN
  INSERT
  INTO course
    (
      course_no,
      description,
      created_by,
      created_date
    )
    VALUES
    (
      COURSE_NO_SEQ.NEXTVAL,
      'TEST COURSE',
      USER,
      SYSDATE
    );
  COMMIT;
  DBMS_OUTPUT.PUT_LINE ('One course has been added');
EXCEPTION
WHEN e_constraint_violation THEN
  DBMS_OUTPUT.PUT_LINE ('INSERT statement is '|| 'violating a constraint');
END;

---------------------------------------------------------------------------------------


DECLARE
  v_zip   VARCHAR2(5) := '&sv_zip';
  v_city  VARCHAR2(15);
  v_state CHAR(2);
BEGIN
  SELECT city, state INTO v_city, v_state FROM zipcode WHERE zip = v_zip;
  DBMS_OUTPUT.PUT_LINE (v_city||', '||v_state);
EXCEPTION
WHEN OTHERS THEN
  DBMS_OUTPUT.PUT_LINE ('An error has occurred');
END;

-----------------------------------------------------------------------------------

DECLARE
  v_zip      VARCHAR2(5) := '&sv_zip';
  v_city     VARCHAR2(15);
  v_state    CHAR(2);
  V_ERR_CODE NUMBER;
  v_err_msg  VARCHAR2(1500);
BEGIN
  SELECT city, state INTO v_city, v_state FROM zipcode WHERE zip = v_zip;
  DBMS_OUTPUT.PUT_LINE (v_city||', '||v_state);
EXCEPTION
WHEN OTHERS THEN
  v_err_code := SQLCODE;
  v_err_msg  := SQLERRM;
  DBMS_OUTPUT.PUT_LINE ('Error code: '||v_err_code);
  DBMS_OUTPUT.PUT_LINE ('Error message: '||V_ERR_MSG);
END;


-----------------------------------------------------------------------------------

BEGIN
  DBMS_OUTPUT.PUT_LINE ('Error code: '||SQLCODE);
  DBMS_OUTPUT.PUT_LINE ('Error message1: '||SQLERRM(SQLCODE));
  DBMS_OUTPUT.PUT_LINE ('Error message2: '||SQLERRM(100));
  DBMS_OUTPUT.PUT_LINE ('Error message3: '||SQLERRM(200));
  DBMS_OUTPUT.PUT_LINE ('Error message4: '||SQLERRM(-20000));
END;

-----------------------------------------------------------------------------------


-----------------------------------------------------------------------------------


SET SERVEROUTPUT ON
BEGIN
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
      '10027',
      'NEW YORK',
      'NY',
      USER,
      SYSDATE,
      USER,
      SYSDATE
    );
  COMMIT;
EXCEPTION
WHEN OTHERS THEN
  DECLARE
    v_err_code NUMBER        := SQLCODE;
    v_err_msg  VARCHAR2(100) := SUBSTR(SQLERRM, 1, 100);
  BEGIN
    DBMS_OUTPUT.PUT_LINE ('Error code: '||v_err_code);
    DBMS_OUTPUT.PUT_LINE ('Error message: '||v_err_msg);
  END;
END;


-----------------------------------------------------------------------------------


SET SERVEROUTPUT ON
DECLARE
  v_section_id     NUMBER := &sv_section_id;
  v_total_students NUMBER;
BEGIN
  -- Calculate number of students enrolled
  SELECT COUNT(*)
  INTO v_total_students
  FROM enrollment
  WHERE section_id     = v_section_id;
  IF v_total_students >= 10 THEN
    RAISE_APPLICATION_ERROR (-20000, 'There are too many students for '|| 'section '||v_section_id);
  ELSE
    DBMS_OUTPUT.PUT_LINE ('There are '||v_total_students|| ' students for section ID: '||v_section_id);
  END IF;
END;

-----------------------------------------------------------------------------------

DECLARE
  v_first_name instructor.first_name%type := '&sv_first_name';
  v_last_name instructor.last_name%type   := '&sv_last_name';
BEGIN
  INSERT
  INTO instructor
    (
      instructor_id,
      first_name,
      last_name
    )
    VALUES
    (
      INSTRUCTOR_ID_SEQ.NEXTVAL,
      v_first_name,
      v_last_name
    );
  COMMIT;
END;


-----------------------------------------------------------------------------------

SET SERVEROUTPUT ON
DECLARE
  v_first_name instructor.first_name%type := '&sv_first_name';
  v_last_name instructor.last_name%type   := '&sv_last_name';
  e_non_null_value EXCEPTION;
  PRAGMA EXCEPTION_INIT(e_non_null_value, -1400);
BEGIN
  INSERT
  INTO INSTRUCTOR
    (
      instructor_id,
      first_name,
      last_name
    )
    VALUES
    (
      INSTRUCTOR_ID_SEQ.NEXTVAL,
      v_first_name,
      v_last_name
    );
  COMMIT;
EXCEPTION
WHEN e_non_null_value THEN
  DBMS_OUTPUT.PUT_LINE ('A NULL value cannot be '|| 'inserted. Check constraints on the INSTRUCTOR table.');
END;


-----------------------------------------------------------------------------------


SET SERVEROUTPUT ON
DECLARE
  v_first_name instructor.first_name%type := '&sv_first_name';
  v_last_name instructor.last_name%type   := '&sv_last_name';
BEGIN
  INSERT
  INTO INSTRUCTOR
    (
      instructor_id,
      first_name,
      last_name
    )
    VALUES
    (
      INSTRUCTOR_ID_SEQ.NEXTVAL,
      v_first_name,
      v_last_name
    );
  COMMIT;
EXCEPTION
WHEN OTHERS THEN
  DBMS_OUTPUT.PUT_LINE ('Error code: '||SQLCODE);
  DBMS_OUTPUT.PUT_LINE ('Error message: '|| SUBSTR(SQLERRM, 1, 200));
END;












