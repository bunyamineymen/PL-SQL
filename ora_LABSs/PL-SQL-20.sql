--MODULE 20
-----------



--Functions
------------


--Creating and Using Functions


-- ch20_01a.sql ver 1.0
CREATE OR REPLACE
  FUNCTION show_description(
      i_course_no course.course_no%TYPE)
    RETURN VARCHAR2
  AS
    v_description VARCHAR2(50);
  BEGIN
    SELECT description
    INTO v_description
    FROM course
    WHERE course_no = i_course_no;
    RETURN v_description;
  EXCEPTION
  WHEN NO_DATA_FOUND THEN
    RETURN('The Course IS NOT IN the DATABASE');
  WHEN OTHERS THEN
    RETURN('Error in running show_description');
  END;


--test et
DECLARE
  v_desc VARCHAR2(100);
BEGIN
  V_DESC := SHOW_DESCRIPTION(100);
  DBMS_OUTPUT.PUT_LINE(v_desc);

END;



--20.1.1 Create Stored Functions


/*
B) Create another function using the following script. Explain what is happening in this function. Pay
close attention to the method of creating the Boolean return.
*/

-- ch20_01b.sql, version 1.0
CREATE OR REPLACE
  FUNCTION id_is_good(
      i_student_id IN NUMBER)
    RETURN BOOLEAN
  AS
    v_id_cnt NUMBER;
  BEGIN
    SELECT COUNT(*) INTO v_id_cnt FROM student WHERE student_id = i_student_id;
    RETURN 1 = v_id_cnt;
  EXCEPTION
  WHEN OTHERS THEN
    RETURN FALSE;
  END id_is_good;


DECLARE
  v_id boolean;
BEGIN
  V_ID := ID_IS_GOOD(102);
  IF V_ID = TRUE THEN
  DBMS_OUTPUT.PUT_LINE('Do?ru');
  ELSE
  DBMS_OUTPUT.PUT_LINE('Yanl??');
  END IF;
END;


---------------------------

SET SERVEROUTPUT ON
DECLARE
  v_description VARCHAR2(50);
BEGIN
  v_description := show_description(&sv_cnumber);
  DBMS_OUTPUT.PUT_LINE(V_DESCRIPTION);
END;
---------------------------

DECLARE
  v_id NUMBER;
BEGIN
  v_id := &id;
  IF id_is_good(v_id) THEN
    DBMS_OUTPUT.PUT_LINE ('Student ID: '||v_id||' is a valid.');
  ELSE
    DBMS_OUTPUT.PUT_LINE ('Student ID: '||v_id||' is not valid.');
  END IF;
END;


---------------------------


SELECT COURSE_NO, SHOW_DESCRIPTION(COURSE_NO)
FROM course;


---------------------------
CREATE OR REPLACE
  FUNCTION new_instructor_id
    RETURN instructor.instructor_id%TYPE
  AS
    v_new_instid instructor.instructor_id%TYPE;
  BEGIN
    SELECT INSTRUCTOR_ID_SEQ.NEXTVAL INTO v_new_instid FROM dual;
    RETURN v_new_instid;
  EXCEPTION
  WHEN OTHERS THEN
    DECLARE
      v_sqlerrm VARCHAR2(250) := SUBSTR(SQLERRM,1,250);
    BEGIN
      RAISE_APPLICATION_ERROR(-20003, 'Error in instructor_id: '||v_sqlerrm);
    END;
  END new_instructor_id;


---------------------------

CREATE OR REPLACE
  FUNCTION new_student_id
    RETURN student.student_id%TYPE
  AS
    v_student_id student.student_id%TYPE;
  BEGIN
    SELECT student_id_seq.NEXTVAL INTO v_student_id FROM dual;
    RETURN(v_student_id);
  END;


---------------------------


DECLARE
  cons_zip               CONSTANT zipcode.zip%TYPE := '&sv_zipcode';
  e_zipcode_is_not_valid EXCEPTION;
BEGIN
  IF zipcode_does_not_exist(cons_zip) THEN
    RAISE e_zipcode_is_not_valid;
  ELSE
    -- An insert of an instructor's record which
    -- makes use of the checked zipcode might go here.
    NULL;
  END IF;
EXCEPTION
WHEN e_zipcode_is_not_valid THEN
  RAISE_APPLICATION_ERROR (-20003, 'Could not find zipcode '||cons_zip||'.');
END;


---------------------------



CREATE OR REPLACE
  FUNCTION zipcode_does_not_exist(
      i_zipcode IN zipcode.zip%TYPE)
    RETURN BOOLEAN
  AS
    v_dummy CHAR(1);
  BEGIN
    SELECT NULL INTO v_dummy FROM zipcode WHERE zip = i_zipcode;
    -- Meaning the zipcode does exit
    RETURN FALSE;
  EXCEPTION
  WHEN OTHERS THEN
    -- The select statement above will cause an exception
    -- to be raised if the zipcode is not in the database.
    RETURN TRUE;
  END zipcode_does_not_exist;


---------------------------


CREATE OR REPLACE
  FUNCTION instructor_status(
      i_first_name IN instructor.first_name%TYPE,
      i_last_name  IN instructor.last_name%TYPE)
    RETURN VARCHAR2
  AS
    v_instructor_id instructor.instructor_id%TYPE;
    v_section_count NUMBER;
    v_status        VARCHAR2(100);
  BEGIN
    SELECT instructor_id
    INTO v_instructor_id
    FROM instructor
    WHERE first_name = i_first_name
    AND last_name    = i_last_name;
    SELECT COUNT(*)
    INTO v_section_count
    FROM section
    WHERE instructor_id = v_instructor_id;
    IF v_section_count >= 3 THEN
      v_status         := 'The instructor '||i_first_name||' '|| i_last_name||' is teaching '||v_section_count|| ' and needs a vaction.';
    ELSE
      v_status := 'The instructor '||i_first_name||' '|| i_last_name||' is teaching '||v_section_count|| ' courses.';
    END IF;
    RETURN v_status;
  EXCEPTION
  WHEN NO_DATA_FOUND THEN
    -- Note that either of the SELECT statements can raise
    -- this exception
    v_status := 'The instructor '||i_first_name||' '|| i_last_name||' is not shown to be teaching'|| ' any courses.';
    RETURN v_status;
  WHEN OTHERS THEN
    v_status := 'There has been in an error in the function.';
    RETURN v_status;
  END;


---------------------------
SELECT instructor_status(first_name, last_name)
FROM INSTRUCTOR;
/










