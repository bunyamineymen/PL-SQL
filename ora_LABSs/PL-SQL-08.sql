
DECLARE
  v_num1   INTEGER := &sv_num1;
  v_num2   INTEGER := &sv_num2;
  v_result NUMBER;
BEGIN
  V_RESULT = V_NUM1 / V_NUM2;
  DBMS_OUTPUT.PUT_LINE ('v_result: '|| V_RESULT);
END;

----------------------------------------------------------

DECLARE
  v_num1   INTEGER := &sv_num1;
  v_num2   INTEGER := &sv_num2;
  v_result NUMBER;
BEGIN
  v_result := v_num1 / v_num2;
  DBMS_OUTPUT.PUT_LINE ('v_result: '||v_result);
EXCEPTION
WHEN ZERO_DIVIDE THEN
  DBMS_OUTPUT.PUT_LINE ('A number cannot be divided by zero.');
END;


----------------------------------------------------------


SET SERVEROUTPUT ON;
DECLARE
  v_num NUMBER := &sv_num;
BEGIN
  DBMS_OUTPUT.PUT_LINE ('Square root of '||v_num|| ' is '||SQRT(v_num));
EXCEPTION
WHEN VALUE_ERROR THEN
  DBMS_OUTPUT.PUT_LINE ('An error has occurred');
END;


----------------------------------------------------------

SET SERVEROUTPUT ON;
DECLARE
  v_num NUMBER := &sv_num;
BEGIN
  IF v_num >= 0 THEN
    DBMS_OUTPUT.PUT_LINE ('Square root of '||v_num|| ' is '||SQRT(v_num));
  ELSE
    DBMS_OUTPUT.PUT_LINE ('A number cannot be negative');
  END IF;
END;

------------------------------------------------------------------------------------------------

DECLARE
  v_student_name VARCHAR2(50);
BEGIN
  SELECT first_name
    ||' '
    ||last_name
  INTO v_student_name
  FROM student
  WHERE student_id = 101;
  DBMS_OUTPUT.PUT_LINE ('Student name is '||v_student_name);
EXCEPTION
WHEN NO_DATA_FOUND THEN
  DBMS_OUTPUT.PUT_LINE ('There is no such student');
END;

----------------------------------------------------------

DECLARE
  v_student_id NUMBER      := &sv_student_id;
  v_enrolled   VARCHAR2(3) := 'NO';
BEGIN
  DBMS_OUTPUT.PUT_LINE ('Check if the student is enrolled');
  SELECT 'YES' INTO v_enrolled FROM enrollment WHERE student_id = v_student_id;
  DBMS_OUTPUT.PUT_LINE ('The student is enrolled into one course');
EXCEPTION
WHEN NO_DATA_FOUND THEN
  DBMS_OUTPUT.PUT_LINE ('The student is not enrolled');
WHEN TOO_MANY_ROWS THEN
  DBMS_OUTPUT.PUT_LINE ('The student is enrolled in too many courses');
END;


----------------------------------------------------------

DECLARE
  v_instructor_id   NUMBER := &sv_instructor_id;
  v_instructor_name VARCHAR2(50);
BEGIN
  SELECT first_name
    ||' '
    ||last_name
  INTO v_instructor_name
  FROM instructor
  WHERE instructor_id = v_instructor_id;
  DBMS_OUTPUT.PUT_LINE ('Instructor name is '||v_instructor_name);
EXCEPTION
WHEN OTHERS THEN
  DBMS_OUTPUT.PUT_LINE ('An error has occurred');
END;



----------------------------------------------------------


SET SERVEROUTPUT ON
DECLARE
  v_exists         NUMBER(1);
  v_total_students NUMBER(1);
  v_zip            CHAR(5):= '&sv_zip';
BEGIN
  SELECT COUNT(*) INTO v_exists FROM zipcode WHERE zip = v_zip;
  IF v_exists != 0 THEN
    SELECT COUNT(*) INTO v_total_students FROM student WHERE zip = v_zip;
    DBMS_OUTPUT.PUT_LINE ('There are '||v_total_students||' students');
  ELSE
    DBMS_OUTPUT.PUT_LINE (v_zip||' is not a valid zip');
  END IF;
EXCEPTION
WHEN VALUE_ERROR OR INVALID_NUMBER THEN
  DBMS_OUTPUT.PUT_LINE ('An error has occurred');
END;

----------------------------------------------------------

INSERT
INTO student
  (
    student_id,
    salutation,
    first_name,
    last_name,
    zip,
    registration_date,
    created_by,
    created_date,
    modified_by,
    modified_date
  )
  VALUES
  (
    STUDENT_ID_SEQ.NEXTVAL,
    'Mr.',
    'John',
    'Smith',
    '07024',
    SYSDATE,
    'STUDENT',
    SYSDATE,
    'STUDENT',
    SYSDATE
  );
COMMIT;

----------------------------------------------------------

SET SERVEROUTPUT ON
DECLARE
  v_exists       NUMBER(1);
  v_student_name VARCHAR2(30);
  v_zip          CHAR(5):= '&sv_zip';
BEGIN
  SELECT COUNT(*) INTO v_exists FROM zipcode WHERE zip = v_zip;
  IF V_EXISTS != 0 THEN
    SELECT first_name || ' ' || last_name
    INTO v_student_name
    FROM STUDENT
    WHERE zip  = v_zip
    AND rownum = 1;
    DBMS_OUTPUT.PUT_LINE ('Student name is '||v_student_name);
  ELSE
    DBMS_OUTPUT.PUT_LINE (v_zip||' is not a valid zip');
  END IF;
EXCEPTION
WHEN VALUE_ERROR OR INVALID_NUMBER THEN
  DBMS_OUTPUT.PUT_LINE ('An error has occurred');
WHEN NO_DATA_FOUND THEN
  DBMS_OUTPUT.PUT_LINE ('There are no students for this value of zip code');
END;


----------------------------------------------------------

SET SERVEROUTPUT ON
DECLARE
  v_student_id NUMBER       := &sv_student_id;
  v_first_name VARCHAR2(30) := '&sv_first_name';
  v_last_name  VARCHAR2(30) := '&sv_last_name';
  v_zip        CHAR(5)      := '&sv_zip';
  v_name       VARCHAR2(50);
BEGIN
  SELECT first_name
    ||' '
    ||last_name
  INTO v_name
  FROM student
  WHERE student_id = v_student_id;
  DBMS_OUTPUT.PUT_LINE ('Student '||v_name||' is a valid student');
EXCEPTION
WHEN NO_DATA_FOUND THEN
  DBMS_OUTPUT.PUT_LINE ('This student does not exist, and will be '|| 'added to the STUDENT table');
  INSERT
  INTO student
    (
      student_id,
      first_name,
      last_name,
      zip,
      registration_date,
      created_by,
      created_date,
      modified_by,
      modified_date
    )
    VALUES
    (
      v_student_id,
      v_first_name,
      v_last_name,
      v_zip,
      SYSDATE,
      USER,
      SYSDATE,
      USER,
      SYSDATE
    );
  COMMIT;
END;



----------------------------------------------------------


SET SERVEROUTPUT ON
DECLARE
  v_instructor_id NUMBER := &sv_instructor_id;
  v_name          VARCHAR2(50);
  v_total         NUMBER;
BEGIN
  SELECT first_name
    ||' '
    ||last_name
  INTO v_name
  FROM instructor
  WHERE instructor_id = v_instructor_id;
  -- check how many sections are taught by this instructor
  SELECT COUNT(*)
  INTO v_total
  FROM section
  WHERE instructor_id = v_instructor_id;
  DBMS_OUTPUT.PUT_LINE ('Instructor, '||v_name|| ', teaches '||v_total||' section(s)');
EXCEPTION
WHEN NO_DATA_FOUND THEN
  DBMS_OUTPUT.PUT_LINE ('This is not a valid instructor');
END;



----------------------------------------------------------