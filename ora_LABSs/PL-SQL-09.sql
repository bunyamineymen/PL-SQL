---------------------------------------------------------

DECLARE
  v_student_id NUMBER := &sv_student_id;
  v_name       VARCHAR2(30);
  v_total      NUMBER(1);
  -- outer block
BEGIN
  SELECT RTRIM(first_name)
    ||' '
    ||RTRIM(last_name)
  INTO v_name
  FROM student
  WHERE student_id = v_student_id;
  DBMS_OUTPUT.PUT_LINE ('Student name is '||v_name);
  -- inner block
  BEGIN
    SELECT COUNT(*) INTO v_total FROM enrollment WHERE student_id = v_student_id;
    DBMS_OUTPUT.PUT_LINE ('Student is registered for '|| v_total||' course(s)');
  EXCEPTION
  WHEN VALUE_ERROR OR INVALID_NUMBER THEN
    DBMS_OUTPUT.PUT_LINE ('An error has occurred');
  END;
EXCEPTION
WHEN NO_DATA_FOUND THEN
  DBMS_OUTPUT.PUT_LINE ('There is no such student');
END;

---------------------------------------------------------
DECLARE
  v_student_id NUMBER := &sv_student_id;
  v_name       VARCHAR2(30);
  v_registered CHAR;
  -- outer block
BEGIN
  SELECT RTRIM(first_name)
    ||' '
    ||RTRIM(last_name)
  INTO v_name
  FROM student
  WHERE student_id = v_student_id;
  DBMS_OUTPUT.PUT_LINE ('Student name is '||v_name);
  -- inner block
  BEGIN
    SELECT 'Y' INTO v_registered FROM enrollment WHERE student_id = v_student_id;
    DBMS_OUTPUT.PUT_LINE ('Student is registered');
  EXCEPTION
  WHEN VALUE_ERROR OR INVALID_NUMBER THEN
    DBMS_OUTPUT.PUT_LINE ('An error has occurred');
  END;
EXCEPTION
WHEN NO_DATA_FOUND THEN
  DBMS_OUTPUT.PUT_LINE ('There is no such student');
END;


---------------------------------------------------------


SET SERVEROUTPUT ON
DECLARE
  v_zip   VARCHAR2(5) := '&sv_zip';
  v_total NUMBER(1);
  -- outer block
BEGIN
  DBMS_OUTPUT.PUT_LINE ('Check if provided zipcode is valid');
  SELECT zip INTO v_zip FROM zipcode WHERE zip = v_zip;
  -- inner block
  BEGIN
    SELECT COUNT(*) INTO v_total FROM student WHERE zip = v_zip;
    DBMS_OUTPUT.PUT_LINE ('There are '||v_total|| ' students for zipcode '||v_zip);
  END;
  DBMS_OUTPUT.PUT_LINE ('Done...');
END;

---------------------------------------------------------

INSERT
INTO student
  (
    student_id,
    salutation,
    first_name,
    last_name,
    street_address,
    zip,
    phone,
    employer,
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
    '100 Main St.',
    '07024',
    '718-555-5555',
    'ABC Co.',
    SYSDATE,
    USER,
    SYSDATE,
    USER,
    SYSDATE
  );
COMMIT;


---------------------------------------------------------

DECLARE
  v_student_id student.student_id%type := &sv_student_id;
  v_total_courses NUMBER;
  e_invalid_id    EXCEPTION;
BEGIN
  IF v_student_id < 0 THEN
    RAISE e_invalid_id;
  ELSE
    SELECT COUNT(*)
    INTO v_total_courses
    FROM enrollment
    WHERE student_id = v_student_id;
    DBMS_OUTPUT.PUT_LINE ('The student is registered for '|| v_total_courses||' courses');
  END IF;
  DBMS_OUTPUT.PUT_LINE ('No exception has been raised');
EXCEPTION
WHEN e_invalid_id THEN
  DBMS_OUTPUT.PUT_LINE ('An id cannot be negative');
END;


---------------------------------------------------------
BEGIN
  DBMS_OUTPUT.PUT_LINE ('Outer block');
  -- inner block
  DECLARE
    e_my_exception EXCEPTION;
  BEGIN
    DBMS_OUTPUT.PUT_LINE ('Inner block');
  EXCEPTION
  WHEN e_my_exception THEN
    DBMS_OUTPUT.PUT_LINE ('An error has occurred');
  END;
  IF 10 > &sv_number THEN
    RAISE e_my_exception;
  END IF;
END;

---------------------------------------------------------
SET SERVEROUTPUT ON
DECLARE
  v_instructor_id     NUMBER := &sv_instructor_id;
  v_tot_sections      NUMBER;
  v_name              VARCHAR2(30);
  e_too_many_sections EXCEPTION;
BEGIN
  SELECT COUNT(*)
  INTO v_tot_sections
  FROM section
  WHERE instructor_id = v_instructor_id;
  IF v_tot_sections  >= 10 THEN
    RAISE e_too_many_sections;
  ELSE
    SELECT RTRIM(first_name)
      ||' '
      ||RTRIM(last_name)
    INTO v_name
    FROM instructor
    WHERE instructor_id = v_instructor_id;
    DBMS_OUTPUT.PUT_LINE ('Instructor, '||v_name||', teaches '|| v_tot_sections||' sections');
  END IF;
EXCEPTION
WHEN e_too_many_sections THEN
  DBMS_OUTPUT.PUT_LINE ('This instructor teaches too much');
END;


---------------------------------------------------------

DECLARE
  v_test_var CHAR(3):= 'ABCDE';
BEGIN
  DBMS_OUTPUT.PUT_LINE ('This is a test');
EXCEPTION
WHEN INVALID_NUMBER OR VALUE_ERROR THEN
  DBMS_OUTPUT.PUT_LINE ('An error has occurred');
END;

---------------------------------------------------------

BEGIN
  -- inner block
  DECLARE
    v_test_var CHAR(3):= 'ABCDE';
  BEGIN
    DBMS_OUTPUT.PUT_LINE ('This is a test');
  EXCEPTION
  WHEN INVALID_NUMBER OR VALUE_ERROR THEN
    DBMS_OUTPUT.PUT_LINE ('An error has occurred in '|| 'the inner block');
  END;
EXCEPTION
WHEN INVALID_NUMBER OR VALUE_ERROR THEN
  DBMS_OUTPUT.PUT_LINE ('An error has occurred in the '|| 'program');
END;


---------------------------------------------------------

DECLARE
  v_test_var CHAR(3) := 'ABC';
BEGIN
  v_test_var := '1234';
  DBMS_OUTPUT.PUT_LINE ('v_test_var: '||v_test_var);
EXCEPTION
WHEN INVALID_NUMBER OR VALUE_ERROR THEN
  v_test_var := 'ABCD';
  DBMS_OUTPUT.PUT_LINE ('An error has occurred');
END;

---------------------------------------------------------

BEGIN
  -- inner block
  DECLARE
    v_test_var CHAR(3) := 'ABC';
  BEGIN
    v_test_var := '1234';
    DBMS_OUTPUT.PUT_LINE ('v_test_var: '||v_test_var);
  EXCEPTION
  WHEN INVALID_NUMBER OR VALUE_ERROR THEN
    v_test_var := 'ABCD';
    DBMS_OUTPUT.PUT_LINE ('An error has occurred in '|| 'the inner block');
  END;
EXCEPTION
WHEN INVALID_NUMBER OR VALUE_ERROR THEN
  DBMS_OUTPUT.PUT_LINE ('An error has occurred in the '|| 'program');
END;

---------------------------------------------------------
DECLARE
  e_exception1 EXCEPTION;
  e_exception2 EXCEPTION;
BEGIN
  -- inner block
  BEGIN
    RAISE e_exception1;
  EXCEPTION
  WHEN e_exception1 THEN
    RAISE e_exception2;
  WHEN e_exception2 THEN
    DBMS_OUTPUT.PUT_LINE ('An error has occurred in '|| 'the inner block');
  END;
EXCEPTION
WHEN e_exception2 THEN
  DBMS_OUTPUT.PUT_LINE ('An error has occurred in '|| 'the program');
END;


---------------------------------------------------------


DECLARE
  e_exception EXCEPTION;
BEGIN
  -- inner block
  BEGIN
    RAISE e_exception;
  EXCEPTION
  WHEN e_exception THEN
    RAISE;
  END;
EXCEPTION
WHEN e_exception THEN
  DBMS_OUTPUT.PUT_LINE ('An error has occurred');
END;


---------------------------------------------------------


SET SERVEROUTPUT ON
DECLARE
  v_my_name VARCHAR2(15) := 'ELENA SILVESTROVA';
BEGIN
  DBMS_OUTPUT.PUT_LINE ('My name is '||v_my_name);
  DECLARE
    v_your_name VARCHAR2(15);
  BEGIN
    v_your_name := '&sv_your_name';
    DBMS_OUTPUT.PUT_LINE ('Your name is '||v_your_name);
  EXCEPTION
  WHEN VALUE_ERROR THEN
    DBMS_OUTPUT.PUT_LINE ('Error in the inner block');
    DBMS_OUTPUT.PUT_LINE ('This name is too long');
  END;
EXCEPTION
WHEN VALUE_ERROR THEN
  DBMS_OUTPUT.PUT_LINE ('Error in the outer block');
  DBMS_OUTPUT.PUT_LINE ('This name is too long');
END;


---------------------------------------------------------


SET SERVEROUTPUT ON
DECLARE
  v_course_no   NUMBER := 430;
  v_total       NUMBER;
  e_no_sections EXCEPTION;
BEGIN
  BEGIN
    SELECT COUNT(*) INTO v_total FROM section WHERE course_no = v_course_no;
    IF v_total = 0 THEN
      RAISE e_no_sections;
    ELSE
      DBMS_OUTPUT.PUT_LINE ('Course, '||v_course_no|| ' has '||v_total||' sections');
    END IF;
  EXCEPTION
  WHEN e_no_sections THEN
    DBMS_OUTPUT.PUT_LINE ('There are no sections for course '|| v_course_no);
  END;
  DBMS_OUTPUT.PUT_LINE ('Done...');
END;


---------------------------------------------------------


SET SERVEROUTPUT ON
DECLARE
  v_course_no   NUMBER := 430;
  v_total       NUMBER;
  e_no_sections EXCEPTION;
BEGIN
  BEGIN
    SELECT COUNT(*) INTO v_total FROM section WHERE course_no = v_course_no;
    IF v_total = 0 THEN
      RAISE e_no_sections;
    ELSE
      DBMS_OUTPUT.PUT_LINE ('Course, '||v_course_no|| ' has '||v_total||' sections');
    END IF;
  EXCEPTION
  WHEN e_no_sections THEN
    RAISE;
  END;
  DBMS_OUTPUT.PUT_LINE ('Done...');
EXCEPTION
WHEN e_no_sections THEN
  DBMS_OUTPUT.PUT_LINE ('There are no sections for course '|| V_COURSE_NO);
END;


---------------------------------------------------------


SET SERVEROUTPUT ON
DECLARE
  v_section_id        NUMBER := &sv_section_id;
  v_total_students    NUMBER;
  e_too_many_students EXCEPTION;
BEGIN
  -- Calculate number of students enrolled
  SELECT COUNT(*)
  INTO v_total_students
  FROM enrollment
  WHERE section_id     = v_section_id;
  IF v_total_students >= 10 THEN
    RAISE e_too_many_students;
  ELSE
    DBMS_OUTPUT.PUT_LINE ('There are '||v_total_students|| ' students for section ID: '||v_section_id);
  END IF;
EXCEPTION
WHEN e_too_many_students THEN
  DBMS_OUTPUT.PUT_LINE ('There are too many '|| 'students for section '||v_section_id);
END;


---------------------------------------------------------


SET SERVEROUTPUT ON
DECLARE
  v_section_id        NUMBER := &sv_section_id;
  v_total_students    NUMBER;
  e_too_many_students EXCEPTION;
BEGIN
  -- Add inner block
  BEGIN
    -- Calculate number of students enrolled
    SELECT COUNT(*)
    INTO v_total_students
    FROM enrollment
    WHERE section_id     = v_section_id;
    IF v_total_students >= 10 THEN
      RAISE e_too_many_students;
    ELSE
      DBMS_OUTPUT.PUT_LINE ('There are '||v_total_students|| ' students for section ID: '||v_section_id);
    END IF;
    -- Re-raise exception
  EXCEPTION
  WHEN e_too_many_students THEN
    RAISE;
  END;
EXCEPTION
WHEN e_too_many_students THEN
  DBMS_OUTPUT.PUT_LINE ('There are too many '|| 'students for section '||v_section_id);
END;








