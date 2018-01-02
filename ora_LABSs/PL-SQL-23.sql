--MODULE 23
------------


--Object Types in Oracle
--------------------------


--Object Types


CREATE OR REPLACE TYPE zipcode_obj_type
AS
  OBJECT
  (
    zip           VARCHAR2(5),
    city          VARCHAR2(25),
    state         VARCHAR2(2),
    created_by    VARCHAR2(30),
    created_date  DATE,
    MODIFIED_BY   VARCHAR2(30),
    modified_date DATE);


--çal??t?r?lmas?
SET SERVEROUTPUT ON
DECLARE
  v_zip_obj zipcode_obj_type;
BEGIN
  SELECT zipcode_obj_type(zip, city, state, NULL, NULL, NULL, NULL)
  INTO v_zip_obj
  FROM ZIPCODE
  WHERE zip = '07024';
  DBMS_OUTPUT.PUT_LINE ('Zip: '||v_zip_obj.zip);
  DBMS_OUTPUT.PUT_LINE ('City: '||v_zip_obj.city);
  DBMS_OUTPUT.PUT_LINE ('State: '||V_ZIP_OBJ.STATE);
END;


--uninitialize object type NULL olur

DECLARE
  v_zip_obj zipcode_obj_type;
BEGIN
  DBMS_OUTPUT.PUT_LINE ('Object instance has not been initialized');
  IF v_zip_obj IS NULL THEN
    DBMS_OUTPUT.PUT_LINE ('v_zip_obj instance is null');
  ELSE
    DBMS_OUTPUT.PUT_LINE ('v_zip_obj instance is not null');
  END IF;
  IF v_zip_obj.zip IS NULL THEN
    DBMS_OUTPUT.PUT_LINE ('v_zip_obj.zip is null');
  END IF;
  -- Initialize v_zip_obj_instance
  v_zip_obj := zipcode_obj_type(NULL, NULL, NULL, NULL, NULL, NULL, NULL);
  DBMS_OUTPUT.PUT_LINE ('Object instance has been initialized');
  IF v_zip_obj IS NULL THEN
    DBMS_OUTPUT.PUT_LINE ('v_zip_obj instance is null');
  ELSE
    DBMS_OUTPUT.PUT_LINE ('v_zip_obj instance is not null');
  END IF;
  IF v_zip_obj.zip IS NULL THEN
    DBMS_OUTPUT.PUT_LINE ('v_zip_obj.zip is null');
  END IF;
END;



--initialize edilmemi? bir type ?n attribute üne eri?ilemez
DECLARE
v_zip_obj zipcode_obj_type;
BEGIN
V_ZIP_OBJ.ZIP := '12345';
END;



--bir type olu?turuluyor

CREATE OR REPLACE TYPE obj_type
AS
  OBJECT
  (
    attribute1 NUMBER(3) ,
    ATTRIBUTE2 VARCHAR2(3));
  /


--kullan?m?, hatal?

DECLARE
  v_obj obj_type;
BEGIN
  v_obj.attribute1 := 123;
  DBMS_OUTPUT.PUT_LINE ('v_obj.attribute1: '|| v_obj.attribute1);
END;
/


DECLARE
  v_obj obj_type;
BEGIN
  v_obj.attribute1 := 123;
  v_obj.attribute2 := 'ABC';
  DBMS_OUTPUT.PUT_LINE ('v_obj.attribute1: '|| v_obj.attribute1);
  DBMS_OUTPUT.PUT_LINE ('v_obj.attribute2: '|| v_obj.attribute2);
END;
/


--collection ile kullan?m?, nested

DECLARE
TYPE v_zip_type
IS
  TABLE OF zipcode_obj_type INDEX BY BINARY_INTEGER;
  v_zip_tab v_zip_type;
BEGIN
  SELECT zipcode_obj_type(zip, city, state, NULL, NULL, NULL, NULL) BULK COLLECT
  INTO v_zip_tab
  FROM zipcode
  WHERE rownum <= 5;
  FOR i IN 1..v_zip_tab.count
  LOOP
    DBMS_OUTPUT.PUT_LINE ('Zip: '||v_zip_tab(i).zip);
    DBMS_OUTPUT.PUT_LINE ('City: '||v_zip_tab(i).city);
    DBMS_OUTPUT.PUT_LINE ('State: '||v_zip_tab(i).state);
    DBMS_OUTPUT.PUT_LINE ('-----------------------');
  END LOOP;
END;



CREATE OR REPLACE TYPE v_zip_tab_type
IS
  TABLE OF zipcode_obj_type;
  /
  
  
  
DECLARE
  v_zip_tab v_zip_tab_type := v_zip_tab_type();
  v_zip   VARCHAR2(5);
  v_city  VARCHAR2(20);
  v_state VARCHAR2(2);
BEGIN
  SELECT zipcode_obj_type(zip, city, state, NULL, NULL, NULL, NULL) BULK COLLECT
  INTO v_zip_tab
  FROM zipcode
  WHERE rownum <= 5;
  SELECT zip,
    city,
    state
  INTO v_zip,
    v_city,
    v_state
  FROM TABLE(CAST(v_zip_tab AS v_zip_tab_type))
  WHERE rownum < 2;
  DBMS_OUTPUT.PUT_LINE ('Zip: '||v_zip);
  DBMS_OUTPUT.PUT_LINE ('City: '||v_city);
  DBMS_OUTPUT.PUT_LINE ('State: '||V_STATE);
END;



--23.1.1 Use Object Types


/*
A) Create object type ENROLLMENT_OBJ_TYPE, which has the following attributes:
ATTRIBUTE NAME DATA TYPE PRECISION
-------------- --------- ---------
student_id NUMBER 8
first_name VARCHAR2 25
last_name VARCHAR2 25
course_no NUMBER 8
section_no NUMBER 3
enroll_date DATE
final_grade NUMBER 3
*/


-- ch23_1a.sql, version 1.0
CREATE OR REPLACE TYPE ENROLLMENT_OBJ_TYPE
AS
  OBJECT
  (
    student_id  NUMBER(8),
    first_name  VARCHAR2(25),
    last_name   VARCHAR2(25),
    course_no   NUMBER(8),
    section_no  NUMBER(3),
    ENROLL_DATE DATE,
    final_grade NUMBER(3));


/*
B) The following script uses the newly created object type. Execute it and explain the output
produced.
*/


-- ch23_2a.sql, version 1.0
SET SERVEROUTPUT ON
DECLARE
  v_enrollment_obj enrollment_obj_type;
BEGIN
  v_enrollment_obj.student_id := 102;
  v_enrollment_obj.first_name := 'Fred';
  v_enrollment_obj.last_name  := 'Crocitto';
  V_ENROLLMENT_OBJ.COURSE_NO  := 25;
END;



/*
C) Modify the script created in the preceding exercise (ch23_2a.sql) so that it does not produce an
ORA-06530 error.
*/


-- ch23_2b.sql, version 2.0
SET SERVEROUTPUT ON
DECLARE
  v_enrollment_obj enrollment_obj_type;
BEGIN
  v_enrollment_obj := enrollment_obj_type(102, 'Fred', 'Crocitto', 25, NULL, NULL, NULL);
END;


/*
D) Modify this script (ch23_2b.sql) so that all object attributes are populated with corresponding
values selected from the appropriate tables.
*/


-- ch23_2c.sql, version 3.0
SET SERVEROUTPUT ON
DECLARE
  v_enrollment_obj enrollment_obj_type;
BEGIN
  SELECT enrollment_obj_type(st.student_id, st.first_name, st.last_name, c.course_no, se.section_no, e.enroll_date, e.final_grade)
  INTO v_enrollment_obj
  FROM student st,
    course c,
    section se,
    enrollment e
  WHERE st.student_id = e.student_id
  AND c.course_no     = se.course_no
  AND se.section_id   = e.section_id
  AND st.student_id   = 102
  AND c.course_no     = 25
  AND SE.SECTION_NO   = 2;
END;


--Bu ?ekilde de yaz?labilir, Cursor kullan?larak
-- ch23_2d.sql, version 4.0
SET SERVEROUTPUT ON
DECLARE
v_enrollment_obj enrollment_obj_type;
BEGIN
FOR REC IN (SELECT st.student_id, st.first_name, st.last_name,
c.course_no, se.section_no, e.enroll_date,
e.final_grade
FROM student st, course c, section se, enrollment e
WHERE st.student_id = e.student_id
AND c.course_no = se.course_no
AND se.section_id = e.section_id
AND st.student_id = 102
AND c.course_no = 25)
LOOP
v_enrollment_obj :=
enrollment_obj_type(rec.student_id, rec.first_name,
rec.last_name, rec.course_no,
rec.section_no, rec.enroll_date,
rec.final_grade);
END LOOP;
END;


/*
E) Modify one of the scripts created in the previous exercises (use either ch23_2c.sql or ch23_2d.sql)
so that attribute values are displayed on the screen.
*/


-- ch23_2e.sql, version 5.0
SET SERVEROUTPUT ON
DECLARE
  v_enrollment_obj enrollment_obj_type;
BEGIN
  FOR REC IN
  (SELECT st.student_id,
    st.first_name,
    st.last_name,
    c.course_no,
    se.section_no,
    e.enroll_date,
    e.final_grade
  FROM student st,
    course c,
    section se,
    enrollment e
  WHERE st.student_id = e.student_id
  AND c.course_no     = se.course_no
  AND se.section_id   = e.section_id
  AND st.student_id   = 102
  AND c.course_no     = 25
  )
  LOOP
    v_enrollment_obj := enrollment_obj_type(rec.student_id, rec.first_name, rec.last_name, rec.course_no, rec.section_no, rec.enroll_date, rec.final_grade);
    DBMS_OUTPUT.PUT_LINE ('student_id: '|| v_enrollment_obj.student_id);
    DBMS_OUTPUT.PUT_LINE ('first_name: '|| v_enrollment_obj.first_name);
    DBMS_OUTPUT.PUT_LINE ('last_name: '|| v_enrollment_obj.last_name);
    DBMS_OUTPUT.PUT_LINE ('course_no: '|| v_enrollment_obj.course_no);
    DBMS_OUTPUT.PUT_LINE ('section_no: '|| v_enrollment_obj.section_no);
    DBMS_OUTPUT.PUT_LINE ('enroll_date: '|| v_enrollment_obj.enroll_date);
    DBMS_OUTPUT.PUT_LINE ('final_grade: '|| v_enrollment_obj.final_grade);
  END LOOP;
END;



--di?er ?ekilde ekranda gösterimi
SET SERVEROUTPUT ON
DECLARE
  v_enrollment_obj enrollment_obj_type;
BEGIN
  SELECT enrollment_obj_type(st.student_id, st.first_name, st.last_name, c.course_no, se.section_no, e.enroll_date, e.final_grade)
  INTO v_enrollment_obj
  FROM student st,
    course c,
    section se,
    enrollment e
  WHERE st.student_id = e.student_id
  AND c.course_no     = se.course_no
  AND se.section_id   = e.section_id
  AND st.student_id   = 102
  AND c.course_no     = 25
  AND SE.SECTION_NO   = 2;

    DBMS_OUTPUT.PUT_LINE(V_ENROLLMENT_OBJ.course_no);
  dbms_output.put_line(v_enrollment_obj.student_id);
  dbms_output.put_line(v_enrollment_obj.first_name);
  dbms_output.put_line(v_enrollment_obj.last_name);
  dbms_output.put_line(v_enrollment_obj.section_no);
  dbms_output.put_line(v_enrollment_obj.enroll_date);
  dbms_output.put_line(v_enrollment_obj.final_grade);
  
END;



--23.1.2 Use Object Types with Collections


/*
A) Modify script ch23_2e.sql, created in the preceding exercise. In the new version of the script,
populate an associative array of objects.Use multiple student IDs for this exercise—102, 103,
and 104.
*/


-- ch23_3a.sql, version 1.0
SET SERVEROUTPUT ON
DECLARE
TYPE enroll_tab_type
IS
  TABLE OF enrollment_obj_type INDEX BY BINARY_INTEGER;
  v_enrollment_tab enroll_tab_type;
  v_counter INTEGER := 0;
BEGIN
  FOR REC IN
  (SELECT st.student_id,
    st.first_name,
    st.last_name,
    c.course_no,
    se.section_no,
    e.enroll_date,
    e.final_grade
  FROM student st,
    course c,
    section se,
    enrollment e
  WHERE st.student_id = e.student_id
  AND c.course_no     = se.course_no
  AND se.section_id   = e.section_id
  AND st.student_id  IN (102, 103, 104)
  )
  LOOP
    v_counter                   := v_counter + 1;
    v_enrollment_tab(v_counter) := enrollment_obj_type(rec.student_id, rec.first_name, rec.last_name, rec.course_no, rec.section_no, rec.enroll_date, rec.final_grade);
    DBMS_OUTPUT.PUT_LINE ('student_id: '|| v_enrollment_tab(v_counter).student_id);
    DBMS_OUTPUT.PUT_LINE ('first_name: '|| v_enrollment_tab(v_counter).first_name);
    DBMS_OUTPUT.PUT_LINE ('last_name: '|| v_enrollment_tab(v_counter).last_name);
    DBMS_OUTPUT.PUT_LINE ('course_no: '|| v_enrollment_tab(v_counter).course_no);
    DBMS_OUTPUT.PUT_LINE ('section_no: '|| v_enrollment_tab(v_counter).section_no);
    DBMS_OUTPUT.PUT_LINE ('enroll_date: '|| v_enrollment_tab(v_counter).enroll_date);
    DBMS_OUTPUT.PUT_LINE ('final_grade: '|| v_enrollment_tab(v_counter).final_grade);
    DBMS_OUTPUT.PUT_LINE ('------------------');
  END LOOP;
END;


/*
B) Modify the script so that the table of objects is populated using the BULK SELECT INTO statement.
*/


-- ch23_3b.sql, version 2.0
SET SERVEROUTPUT ON
DECLARE
TYPE enroll_tab_type
IS
  TABLE OF enrollment_obj_type INDEX BY BINARY_INTEGER;
  v_enrollment_tab enroll_tab_type;
BEGIN
  SELECT enrollment_obj_type(st.student_id, st.first_name, st.last_name, c.course_no, se.section_no, e.enroll_date, e.final_grade) BULK COLLECT
  INTO v_enrollment_tab
  FROM student st,
    course c,
    section se,
    enrollment e
  WHERE st.student_id = e.student_id
  AND c.course_no     = se.course_no
  AND se.section_id   = e.section_id
  AND st.student_id  IN (102, 103, 104);
  FOR i              IN 1..v_enrollment_tab.COUNT
  LOOP
    DBMS_OUTPUT.PUT_LINE ('student_id: '|| v_enrollment_tab(i).student_id);
    DBMS_OUTPUT.PUT_LINE ('first_name: '|| v_enrollment_tab(i).first_name);
    DBMS_OUTPUT.PUT_LINE ('last_name: '|| v_enrollment_tab(i).last_name);
    DBMS_OUTPUT.PUT_LINE ('course_no: '|| v_enrollment_tab(i).course_no);
    DBMS_OUTPUT.PUT_LINE ('section_no: '|| v_enrollment_tab(i).section_no);
    DBMS_OUTPUT.PUT_LINE ('enroll_date: '|| v_enrollment_tab(i).enroll_date);
    DBMS_OUTPUT.PUT_LINE ('final_grade: '|| v_enrollment_tab(i).final_grade);
    DBMS_OUTPUT.PUT_LINE ('------------------');
  END LOOP;
END;



/*
C) Modify the script so that data stored in the table of objects can be retrieved using the SELECT
INTO statement as well.
*/

/*
ANSWER: As mentioned previously, for you to select data from a table of objects, the underlying
table type must be either a nested table or a varray that is created and stored in the database
schema.This is accomplished by the following statement:
*/


CREATE OR REPLACE TYPE enroll_tab_type AS TABLE OF
enrollment_obj_type;
/


/*
After the nested table type is created, the script is modified as follows. Changes are shown in bold.
*/


-- ch23_3c.sql, version 3.0
SET SERVEROUTPUT ON
DECLARE
  v_enrollment_tab enroll_tab_type;
BEGIN
  SELECT enrollment_obj_type(st.student_id, st.first_name, st.last_name, c.course_no, se.section_no, e.enroll_date, e.final_grade) BULK COLLECT
  INTO v_enrollment_tab
  FROM student st,
    course c,
    section se,
    enrollment e
  WHERE st.student_id = e.student_id
  AND c.course_no     = se.course_no
  AND se.section_id   = e.section_id
  AND st.student_id  IN (102, 103, 104);
  FOR rec            IN
  (SELECT * FROM TABLE(CAST(v_enrollment_tab AS enroll_tab_type))
  )
  LOOP
    DBMS_OUTPUT.PUT_LINE ('student_id: '||rec.student_id);
    DBMS_OUTPUT.PUT_LINE ('first_name: '||rec.first_name);
    DBMS_OUTPUT.PUT_LINE ('last_name: '||rec.last_name);
    DBMS_OUTPUT.PUT_LINE ('course_no: '||rec.course_no);
    DBMS_OUTPUT.PUT_LINE ('section_no: '||rec.section_no);
    DBMS_OUTPUT.PUT_LINE ('enroll_date: '||rec.enroll_date);
    DBMS_OUTPUT.PUT_LINE ('final_grade: '||rec.final_grade);
    DBMS_OUTPUT.PUT_LINE ('------------------');
  END LOOP;
END;

----------------------------------------------------------------------------------------------

--Object Type Methods



DROP TYPE v_zip_tab_type;



CREATE OR REPLACE TYPE zipcode_obj_type
AS
  OBJECT
  (
    zip           VARCHAR2(5),
    city          VARCHAR2(25),
    state         VARCHAR2(2),
    created_by    VARCHAR2(30),
    created_date  DATE,
    modified_by   VARCHAR2(30),
    modified_date DATE,
    CONSTRUCTOR
  FUNCTION zipcode_obj_type(
      SELF IN OUT NOCOPY ZIPCODE_OBJ_TYPE,
      zip VARCHAR2)
    RETURN SELF
  AS
    RESULT,
    CONSTRUCTOR
  FUNCTION zipcode_obj_type(
      SELF IN OUT NOCOPY ZIPCODE_OBJ_TYPE,
      zip   VARCHAR2,
      city  VARCHAR2,
      state VARCHAR2)
    RETURN SELF
  AS
    RESULT);
  /



CREATE OR REPLACE TYPE BODY zipcode_obj_type
AS
  CONSTRUCTOR
FUNCTION zipcode_obj_type(
    SELF IN OUT NOCOPY zipcode_obj_type,
    zip VARCHAR2)
  RETURN SELF
AS
  RESULT
IS
BEGIN
  SELF.zip := zip;
  SELECT city,
    state
  INTO SELF.city,
    SELF.state
  FROM zipcode
  WHERE zip = SELF.zip;
  RETURN;
EXCEPTION
WHEN NO_DATA_FOUND THEN
  RETURN;
END;
CONSTRUCTOR
FUNCTION zipcode_obj_type(
    SELF IN OUT NOCOPY ZIPCODE_OBJ_TYPE,
    zip   VARCHAR2,
    city  VARCHAR2,
    state VARCHAR2)
  RETURN SELF
AS
  RESULT
IS
BEGIN
  SELF.zip   := zip;
  SELF.city  := city;
  SELF.state := state;
  RETURN;
END;
END;
/



--MEMBER METHOD

CREATE OR REPLACE TYPE zipcode_obj_type
AS
  OBJECT
  (
    zip           VARCHAR2(5),
    city          VARCHAR2(25),
    state         VARCHAR2(2),
    created_by    VARCHAR2(30),
    created_date  DATE,
    modified_by   VARCHAR2(30),
    modified_date DATE,
    CONSTRUCTOR
  FUNCTION zipcode_obj_type(
      SELF IN OUT NOCOPY ZIPCODE_OBJ_TYPE,
      zip VARCHAR2)
    RETURN SELF
  AS
    RESULT,
    CONSTRUCTOR
  FUNCTION zipcode_obj_type(
      SELF IN OUT NOCOPY ZIPCODE_OBJ_TYPE,
      zip   VARCHAR2,
      city  VARCHAR2,
      state VARCHAR2)
    RETURN SELF
  AS
    RESULT,
    MEMBER PROCEDURE get_zipcode_info(
      out_zip OUT VARCHAR2,
      out_city OUT VARCHAR2,
      out_state OUT VARCHAR2) );
  /



CREATE OR REPLACE TYPE BODY zipcode_obj_type
AS
  CONSTRUCTOR
FUNCTION zipcode_obj_type(
    SELF IN OUT NOCOPY zipcode_obj_type,
    zip VARCHAR2)
  RETURN SELF
AS
  RESULT
IS
BEGIN
  SELF.zip := zip;
  SELECT city,
    state
  INTO SELF.city,
    SELF.state
  FROM zipcode
  WHERE zip = SELF.zip;
  RETURN;
EXCEPTION
WHEN NO_DATA_FOUND THEN
  RETURN;
END;
CONSTRUCTOR
FUNCTION zipcode_obj_type(
    SELF IN OUT NOCOPY ZIPCODE_OBJ_TYPE,
    zip   VARCHAR2,
    city  VARCHAR2,
    state VARCHAR2)
  RETURN SELF
AS
  RESULT
IS
BEGIN
  SELF.zip   := zip;
  SELF.city  := city;
  SELF.state := state;
  RETURN;
END;
MEMBER PROCEDURE get_zipcode_info(
    out_zip OUT VARCHAR2,
    out_city OUT VARCHAR2,
    out_state OUT VARCHAR2)
IS
BEGIN
  out_zip   := SELF.zip;
  out_city  := SELF.city;
  out_state := SELF.state;
END;
END;
/


--STATIC METHODS

CREATE OR REPLACE TYPE zipcode_obj_type
AS
  OBJECT
  (
    zip           VARCHAR2(5),
    city          VARCHAR2(25),
    state         VARCHAR2(2),
    created_by    VARCHAR2(30),
    created_date  DATE,
    modified_by   VARCHAR2(30),
    modified_date DATE,
    CONSTRUCTOR
  FUNCTION zipcode_obj_type(
      SELF IN OUT NOCOPY ZIPCODE_OBJ_TYPE,
      zip VARCHAR2)
    RETURN SELF
  AS
    RESULT,
    CONSTRUCTOR
  FUNCTION zipcode_obj_type(
      SELF IN OUT NOCOPY ZIPCODE_OBJ_TYPE,
      zip   VARCHAR2,
      city  VARCHAR2,
      state VARCHAR2)
    RETURN SELF
  AS
    RESULT,
    MEMBER PROCEDURE get_zipcode_info(
      out_zip OUT VARCHAR2,
      out_city OUT VARCHAR2,
      out_state OUT VARCHAR2),
    STATIC
  PROCEDURE display_zipcode_info(
      in_zip_obj IN ZIPCODE_OBJ_TYPE) );
/




CREATE OR REPLACE TYPE BODY zipcode_obj_type
AS
  CONSTRUCTOR
FUNCTION zipcode_obj_type(
    SELF IN OUT NOCOPY zipcode_obj_type,
    zip VARCHAR2)
  RETURN SELF
AS
  RESULT
IS
BEGIN
  SELF.zip := zip;
  SELECT city,
    state
  INTO SELF.city,
    SELF.state
  FROM zipcode
  WHERE zip = SELF.zip;
  RETURN;
EXCEPTION
WHEN NO_DATA_FOUND THEN
  RETURN;
END;
CONSTRUCTOR
FUNCTION zipcode_obj_type(
    SELF IN OUT NOCOPY ZIPCODE_OBJ_TYPE,
    zip   VARCHAR2,
    city  VARCHAR2,
    state VARCHAR2)
  RETURN SELF
AS
  RESULT
IS
BEGIN
  SELF.zip   := zip;
  SELF.city  := city;
  SELF.state := state;
  RETURN;
END;
MEMBER PROCEDURE get_zipcode_info(
    out_zip OUT VARCHAR2,
    out_city OUT VARCHAR2,
    out_state OUT VARCHAR2)
IS
BEGIN
  out_zip   := SELF.zip;
  out_city  := SELF.city;
  out_state := SELF.state;
END;
STATIC
PROCEDURE display_zipcode_info(
    in_zip_obj IN ZIPCODE_OBJ_TYPE)
IS
BEGIN
  DBMS_OUTPUT.PUT_LINE ('Zip: ' ||in_zip_obj.zip);
  DBMS_OUTPUT.PUT_LINE ('City: ' ||in_zip_obj.city);
  DBMS_OUTPUT.PUT_LINE ('State: '||in_zip_obj.state);
END;
END;
/



--MAP Member METHODS



CREATE OR REPLACE TYPE zipcode_obj_type
AS
  OBJECT
  (
    zip           VARCHAR2(5),
    city          VARCHAR2(25),
    state         VARCHAR2(2),
    created_by    VARCHAR2(30),
    created_date  DATE,
    modified_by   VARCHAR2(30),
    modified_date DATE,
    CONSTRUCTOR
  FUNCTION zipcode_obj_type(
      SELF IN OUT NOCOPY ZIPCODE_OBJ_TYPE,
      zip VARCHAR2)
    RETURN SELF
  AS
    RESULT,
    CONSTRUCTOR
  FUNCTION zipcode_obj_type(
      SELF IN OUT NOCOPY ZIPCODE_OBJ_TYPE,
      zip   VARCHAR2,
      city  VARCHAR2,
      state VARCHAR2)
    RETURN SELF
  AS
    RESULT,
    MEMBER PROCEDURE get_zipcode_info(
      out_zip OUT VARCHAR2,
      out_city OUT VARCHAR2,
      out_state OUT VARCHAR2),
    STATIC
  PROCEDURE display_zipcode_info(
      in_zip_obj IN ZIPCODE_OBJ_TYPE),
    MAP MEMBER FUNCTION zipcode
    RETURN VARCHAR2 );
  /



CREATE OR REPLACE TYPE BODY zipcode_obj_type
AS
  CONSTRUCTOR
FUNCTION zipcode_obj_type(
    SELF IN OUT NOCOPY zipcode_obj_type,
    zip VARCHAR2)
  RETURN SELF
AS
  RESULT
IS
BEGIN
  SELF.zip := zip;
  SELECT city,
    state
  INTO SELF.city,
    SELF.state
  FROM zipcode
  WHERE zip = SELF.zip;
  RETURN;
EXCEPTION
WHEN NO_DATA_FOUND THEN
  RETURN;
END;
CONSTRUCTOR
FUNCTION zipcode_obj_type(
    SELF IN OUT NOCOPY ZIPCODE_OBJ_TYPE,
    zip   VARCHAR2,
    city  VARCHAR2,
    state VARCHAR2)
  RETURN SELF
AS
  RESULT
IS
BEGIN
  SELF.zip   := zip;
  SELF.city  := city;
  SELF.state := state;
  RETURN;
END;
MEMBER PROCEDURE get_zipcode_info(
    out_zip OUT VARCHAR2,
    out_city OUT VARCHAR2,
    out_state OUT VARCHAR2)
IS
BEGIN
  out_zip   := SELF.zip;
  out_city  := SELF.city;
  out_state := SELF.state;
END;
STATIC
PROCEDURE display_zipcode_info(
    in_zip_obj IN ZIPCODE_OBJ_TYPE)
IS
BEGIN
  DBMS_OUTPUT.PUT_LINE ('Zip: ' ||in_zip_obj.zip);
  DBMS_OUTPUT.PUT_LINE ('City: ' ||in_zip_obj.city);
  DBMS_OUTPUT.PUT_LINE ('State: '||in_zip_obj.state);
END;
MAP MEMBER FUNCTION zipcode
  RETURN VARCHAR2
IS
BEGIN
  RETURN (zip);
END;
END;
/



--kar??la?t?rmay? test edelim


DECLARE
  v_zip_obj1 zipcode_obj_type;
  v_zip_obj2 zipcode_obj_type;
BEGIN
  -- Initialize object instances with user-defined constructor
  -- methods
  v_zip_obj1 := zipcode_obj_type (zip => '12345', city => 'Some City', state => 'AB');
  v_zip_obj2 := zipcode_obj_type (zip => '48104');
  -- Compare object instances via map methods
  IF v_zip_obj1 > v_zip_obj2 THEN
    DBMS_OUTPUT.PUT_LINE ('v_zip_obj1 is greater than v_zip_obj2');
  ELSE
    DBMS_OUTPUT.PUT_LINE ('v_zip_obj1 is not greater than v_zip_obj2');
  END IF;
END;




--23.2.1 Use Object Type Methods


DROP TYPE enroll_tab_type;



CREATE OR REPLACE TYPE ENROLLMENT_OBJ_TYPE
AS
  OBJECT
  (
    student_id  NUMBER(8),
    first_name  VARCHAR2(25),
    last_name   VARCHAR2(25),
    course_no   NUMBER(8),
    section_no  NUMBER(3),
    ENROLL_DATE DATE,
    FINAL_GRADE NUMBER(3));
    
    

/*
A) Create a user-defined constructor method that populates object type attributes by selecting data
from the corresponding tables based on the incoming values for student ID, course, and section
numbers.
*/


-- ch23_4a.sql, version 1.0
CREATE OR REPLACE TYPE enrollment_obj_type
AS
  OBJECT
  (
    student_id  NUMBER(8),
    first_name  VARCHAR2(25),
    last_name   VARCHAR2(25),
    course_no   NUMBER(8),
    section_no  NUMBER(3),
    enroll_date DATE,
    final_grade NUMBER(3),
    CONSTRUCTOR
  FUNCTION enrollment_obj_type(
      SELF IN OUT NOCOPY enrollment_obj_type,
      in_student_id NUMBER,
      in_course_no  NUMBER,
      in_section_no NUMBER)
    RETURN SELF
  AS
    RESULT);
  /



CREATE OR REPLACE TYPE BODY enrollment_obj_type
AS
  CONSTRUCTOR
FUNCTION enrollment_obj_type(
    SELF IN OUT NOCOPY enrollment_obj_type,
    in_student_id NUMBER,
    in_course_no  NUMBER,
    in_section_no NUMBER)
  RETURN SELF
AS
  RESULT
IS
BEGIN
  SELECT st.student_id,
    st.first_name,
    st.last_name,
    c.course_no,
    se.section_no,
    e.enroll_date,
    e.final_grade
  INTO SELF.student_id,
    SELF.first_name,
    SELF.last_name,
    SELF.course_no,
    SELF.section_no,
    SELF.enroll_date,
    SELF.final_grade
  FROM student st,
    course c,
    section se,
    enrollment e
  WHERE st.student_id = e.student_id
  AND c.course_no     = se.course_no
  AND se.section_id   = e.section_id
  AND st.student_id   = in_student_id
  AND c.course_no     = in_course_no
  AND se.section_no   = in_section_no;
  RETURN;
EXCEPTION
WHEN NO_DATA_FOUND THEN
  RETURN;
END;
END;
/



--test edelim

SET SERVEROUTPUT ON;
DECLARE
  v_enrollment_obj enrollment_obj_type;
BEGIN
  v_enrollment_obj := enrollment_obj_type(102, 25, 2);
  DBMS_OUTPUT.PUT_LINE ('student_id:
'||v_enrollment_obj.student_id);
  DBMS_OUTPUT.PUT_LINE ('first_name:
'||v_enrollment_obj.first_name);
  DBMS_OUTPUT.PUT_LINE ('last_name:
'||v_enrollment_obj.last_name);
  DBMS_OUTPUT.PUT_LINE ('course_no:
'||v_enrollment_obj.course_no);
  DBMS_OUTPUT.PUT_LINE ('section_no:
'||v_enrollment_obj.section_no);
  DBMS_OUTPUT.PUT_LINE ('enroll_date:
'||v_enrollment_obj.enroll_date);
  DBMS_OUTPUT.PUT_LINE ('final_grade:
'||v_enrollment_obj.final_grade);
END;




/*
B) Add a member procedure method, GET_ENROLLMENT_INFO, that returns attribute values.
*/


-- ch23_4b.sql, version 2.0
CREATE OR REPLACE TYPE enrollment_obj_type
AS
  OBJECT
  (
    student_id  NUMBER(8),
    first_name  VARCHAR2(25),
    last_name   VARCHAR2(25),
    course_no   NUMBER(8),
    section_no  NUMBER(3),
    enroll_date DATE,
    final_grade NUMBER(3),
    CONSTRUCTOR
  FUNCTION enrollment_obj_type(
      SELF IN OUT NOCOPY enrollment_obj_type,
      in_student_id NUMBER,
      in_course_no  NUMBER,
      in_section_no NUMBER)
    RETURN SELF
  AS
    RESULT,
    MEMBER PROCEDURE get_enrollment_ifo(
      out_student_id OUT NUMBER,
      out_first_name OUT VARCHAR2,
      out_last_name OUT VARCHAR2,
      out_course_no OUT NUMBER,
      out_section_no OUT NUMBER,
      out_enroll_date OUT DATE,
      OUT_FINAL_GRADE OUT NUMBER))
      
/





CREATE OR REPLACE TYPE BODY enrollment_obj_type
AS
  CONSTRUCTOR
FUNCTION enrollment_obj_type(
    SELF IN OUT NOCOPY enrollment_obj_type,
    in_student_id NUMBER,
    in_course_no  NUMBER,
    in_section_no NUMBER)
  RETURN SELF
AS
  RESULT
IS
BEGIN
  SELECT st.student_id,
    st.first_name,
    st.last_name,
    c.course_no,
    se.section_no,
    e.enroll_date,
    e.final_grade
  INTO SELF.student_id,
    SELF.first_name,
    SELF.last_name,
    SELF.course_no,
    SELF.section_no,
    SELF.enroll_date,
    SELF.final_grade
  FROM student st,
    course c,
    section se,
    enrollment e
  WHERE st.student_id = e.student_id
  AND c.course_no     = se.course_no
  AND se.section_id   = e.section_id
  AND st.student_id   = in_student_id
  AND c.course_no     = in_course_no
  AND se.section_no   = in_section_no;
  RETURN;
EXCEPTION
WHEN NO_DATA_FOUND THEN
  RETURN;
END;
MEMBER PROCEDURE get_enrollment_ifo(
    out_student_id OUT NUMBER,
    out_first_name OUT VARCHAR2,
    out_last_name OUT VARCHAR2,
    out_course_no OUT NUMBER,
    out_section_no OUT NUMBER,
    out_enroll_date OUT DATE,
    out_final_grade OUT NUMBER)
IS
BEGIN
  out_student_id  := student_id;
  out_first_name  := first_name;
  out_last_name   := last_name;
  out_course_no   := course_no;
  out_section_no  := section_no;
  out_enroll_date := enroll_date;
  out_final_grade := final_grade;
END;
END;
/



/*
C) Add a static method to the enrollment_obj_type object type that displays values of individual
attributes on the screen.
*/



-- ch23_4c.sql, version 3.0
CREATE OR REPLACE TYPE enrollment_obj_type
AS
  OBJECT
  (
    student_id  NUMBER(8),
    first_name  VARCHAR2(25),
    last_name   VARCHAR2(25),
    course_no   NUMBER(8),
    section_no  NUMBER(3),
    enroll_date DATE,
    final_grade NUMBER(3),
    CONSTRUCTOR
  FUNCTION enrollment_obj_type(
      SELF IN OUT NOCOPY enrollment_obj_type,
      in_student_id NUMBER,
      in_course_no  NUMBER,
      in_section_no NUMBER)
    RETURN SELF
  AS
    RESULT,
    MEMBER PROCEDURE get_enrollment_ifo(
      out_student_id OUT NUMBER,
      out_first_name OUT VARCHAR2,
      out_last_name OUT VARCHAR2,
      out_course_no OUT NUMBER,
      out_section_no OUT NUMBER,
      out_enroll_date OUT DATE,
      out_final_grade OUT NUMBER),
    STATIC
  PROCEDURE display_enrollment_info(
      ENROLLMENT_OBJ ENROLLMENT_OBJ_TYPE)) 
/




CREATE OR REPLACE TYPE BODY enrollment_obj_type
AS
  CONSTRUCTOR
FUNCTION enrollment_obj_type(
    SELF IN OUT NOCOPY enrollment_obj_type,
    in_student_id NUMBER,
    in_course_no  NUMBER,
    in_section_no NUMBER)
  RETURN SELF
AS
  RESULT
IS
BEGIN
  SELECT st.student_id,
    st.first_name,
    st.last_name,
    c.course_no,
    se.section_no,
    e.enroll_date,
    e.final_grade
  INTO SELF.student_id,
    SELF.first_name,
    SELF.last_name,
    SELF.course_no,
    SELF.section_no,
    SELF.enroll_date,
    SELF.final_grade
  FROM student st,
    course c,
    section se,
    enrollment e
  WHERE st.student_id = e.student_id
  AND c.course_no     = se.course_no
  AND se.section_id   = e.section_id
  AND st.student_id   = in_student_id
  AND c.course_no     = in_course_no
  AND se.section_no   = in_section_no;
  RETURN;
EXCEPTION
WHEN NO_DATA_FOUND THEN
  RETURN;
END;
MEMBER PROCEDURE get_enrollment_ifo(
    out_student_id OUT NUMBER,
    out_first_name OUT VARCHAR2,
    out_last_name OUT VARCHAR2,
    out_course_no OUT NUMBER,
    out_section_no OUT NUMBER,
    out_enroll_date OUT DATE,
    out_final_grade OUT NUMBER)
IS
BEGIN
  out_student_id  := student_id;
  out_first_name  := first_name;
  out_last_name   := last_name;
  out_course_no   := course_no;
  out_section_no  := section_no;
  out_enroll_date := enroll_date;
  out_final_grade := final_grade;
END;
STATIC
PROCEDURE display_enrollment_info(
    enrollment_obj enrollment_obj_type)
IS
BEGIN
  DBMS_OUTPUT.PUT_LINE ('student_id: '||enrollment_obj.student_id);
  DBMS_OUTPUT.PUT_LINE ('first_name: '||enrollment_obj.first_name);
  DBMS_OUTPUT.PUT_LINE ('last_name: '||enrollment_obj.last_name);
  DBMS_OUTPUT.PUT_LINE ('course_no: '||enrollment_obj.course_no);
  DBMS_OUTPUT.PUT_LINE ('section_no: '||enrollment_obj.section_no);
  DBMS_OUTPUT.PUT_LINE ('enroll_date: '||enrollment_obj.enroll_date);
  DBMS_OUTPUT.PUT_LINE ('final_grade: '||enrollment_obj.final_grade);
END;
END;
/




--test edelim

SET SERVEROUTPUT ON;
DECLARE
  v_enrollment_obj enrollment_obj_type;
BEGIN
  v_enrollment_obj := enrollment_obj_type(102, 25, 2);
  ENROLLMENT_OBJ_TYPE.DISPLAY_ENROLLMENT_INFO (V_ENROLLMENT_OBJ);
END;



/*
D) Add the method to the object type enrollment_obj_type so that its instances may be
compared and/or sorted.The object instances should be compared based on the values of the
COURSE_NO, SECTION_NO, AND STUDENT_ID ATTRIBUTES.
*/

--specification a ekle
MAP MEMBER FUNCTION enrollment RETURN VARCHAR2)


--body e ekle
MAP MEMBER FUNCTION enrollment RETURN VARCHAR2
IS
BEGIN
RETURN (COURSE_NO||'-'||SECTION_NO||'-'||STUDENT_ID);
END;



--test edebiliriz

SET SERVEROUTPUT ON;
DECLARE
  v_enrollment_obj1 enrollment_obj_type;
  v_enrollment_obj2 enrollment_obj_type;
BEGIN
  v_enrollment_obj1 := enrollment_obj_type(102, 25, 2);
  v_enrollment_obj2 := enrollment_obj_type(104, 20, 2);
  enrollment_obj_type.display_enrollment_info (v_enrollment_obj1);
  DBMS_OUTPUT.PUT_LINE ('--------------------');
  enrollment_obj_type.display_enrollment_info (v_enrollment_obj2);
  IF v_enrollment_obj1 > v_enrollment_obj2 THEN
    DBMS_OUTPUT.PUT_LINE ('Instance 1 is greater than instacne2');
  ELSE
    DBMS_OUTPUT.PUT_LINE ('Instance 1 is not greater than instance 2');
  END IF;
END;

















--MODULE 23 TRY IT YOURSELF
----------------------------


--Chapter 23,“Object Types in Oracle”

/*


1) Create the object type student_obj_type with attributes derived from the STUDENT table.

ANSWER: The object type should look similar to the following:
*/


CREATE OR REPLACE TYPE student_obj_type
AS
  OBJECT
  (
    student_id        NUMBER(8),
    salutation        VARCHAR2(5),
    first_name        VARCHAR2(25),
    last_name         VARCHAR2(25),
    street_address    VARCHAR2(50),
    zip               VARCHAR2(5),
    phone             VARCHAR2(15),
    employer          VARCHAR2(50),
    registration_date DATE,
    created_by        VARCHAR2(30),
    created_date      DATE,
    modified_by       VARCHAR2(30),
    modified_date     DATE);
  /



/*
After this object type is created, it can be used as follows:
*/


SET SERVEROUTPUT ON
DECLARE
  v_student_obj student_obj_type;
BEGIN
  -- Use default contructor method to initialize student object
  SELECT student_obj_type(student_id, salutation, first_name, last_name, street_address, zip, phone, employer, registration_date, NULL, NULL, NULL, NULL)
  INTO v_student_obj
  FROM student
  WHERE student_id = 103;
  DBMS_OUTPUT.PUT_LINE ('Student ID: '||v_student_obj.student_id);
  DBMS_OUTPUT.PUT_LINE ('Salutation: '||v_student_obj.salutation);
  DBMS_OUTPUT.PUT_LINE ('First Name: '||v_student_obj.first_name);
  DBMS_OUTPUT.PUT_LINE ('Last Name: ' ||v_student_obj.last_name);
  DBMS_OUTPUT.PUT_LINE ('Street Address: '||v_student_obj.street_address);
  DBMS_OUTPUT.PUT_LINE ('Zip: ' ||v_student_obj. zip);
  DBMS_OUTPUT.PUT_LINE ('Phone: ' ||v_student_obj.phone);
  DBMS_OUTPUT.PUT_LINE ('Employer: '||v_student_obj.employer);
  DBMS_OUTPUT.PUT_LINE ('Registration Date: '||v_student_obj.registration_date);
END;
/


/*
The output is as follows:
Student ID: 103
Salutation: Ms.
First Name: J.
Last Name: Landry
Street Address: 7435 Boulevard East #45
Zip: 07047
Phone: 201-555-5555
Employer: Albert Hildegard Co.
Registration Date: 22-JAN-03
PL/SQL procedure successfully completed.




2) Add user-defined constructor function, member procedure, static procedure, and order function
methods.You should determine on your own how these methods should be structured.

ANSWER: The newly modified student object should be similar to the following:
*/


CREATE OR REPLACE TYPE student_obj_type
AS
  OBJECT
  (
    student_id        NUMBER(8),
    salutation        VARCHAR2(5),
    first_name        VARCHAR2(25),
    last_name         VARCHAR2(25),
    street_address    VARCHAR2(50),
    zip               VARCHAR2(5),
    phone             VARCHAR2(15),
    employer          VARCHAR2(50),
    registration_date DATE,
    created_by        VARCHAR2(30),
    created_date      DATE,
    modified_by       VARCHAR2(30),
    modified_date     DATE,
    CONSTRUCTOR
  FUNCTION student_obj_type(
      SELF           IN OUT NOCOPY STUDENT_OBJ_TYPE,
      in_student_id  IN NUMBER,
      in_salutation  IN VARCHAR2,
      in_first_name  IN VARCHAR2,
      in_last_name   IN VARCHAR2,
      in_street_addr IN VARCHAR2,
      in_zip         IN VARCHAR2,
      in_phone       IN VARCHAR2,
      in_employer    IN VARCHAR2,
      in_reg_date    IN DATE,
      in_cr_by       IN VARCHAR2,
      in_cr_date     IN DATE,
      in_mod_by      IN VARCHAR2,
      in_mod_date    IN DATE)
    RETURN SELF
  AS
    RESULT,
    CONSTRUCTOR
  FUNCTION student_obj_type(
      SELF          IN OUT NOCOPY STUDENT_OBJ_TYPE,
      in_student_id IN NUMBER)
    RETURN SELF
  AS
    RESULT,
    MEMBER PROCEDURE get_student_info(
      student_id OUT NUMBER,
      salutation OUT VARCHAR2,
      first_name OUT VARCHAR2,
      last_name OUT VARCHAR2,
      street_addr OUT VARCHAR2,
      zip OUT VARCHAR2,
      phone OUT VARCHAR2,
      employer OUT VARCHAR2,
      reg_date OUT DATE,
      cr_by OUT VARCHAR2,
      cr_date OUT DATE,
      mod_by OUT VARCHAR2,
      mod_date OUT DATE),
    STATIC
  PROCEDURE display_student_info(
      student_obj IN STUDENT_OBJ_TYPE),
    ORDER MEMBER FUNCTION student(
      student_obj STUDENT_OBJ_TYPE)
    RETURN INTEGER);
  /




CREATE OR REPLACE TYPE BODY student_obj_type
AS
  CONSTRUCTOR
FUNCTION student_obj_type(
    SELF           IN OUT NOCOPY STUDENT_OBJ_TYPE,
    in_student_id  IN NUMBER,
    in_salutation  IN VARCHAR2,
    in_first_name  IN VARCHAR2,
    in_last_name   IN VARCHAR2,
    in_street_addr IN VARCHAR2,
    in_zip         IN VARCHAR2,
    in_phone       IN VARCHAR2,
    in_employer    IN VARCHAR2,
    in_reg_date    IN DATE,
    in_cr_by       IN VARCHAR2,
    in_cr_date     IN DATE,
    in_mod_by      IN VARCHAR2,
    in_mod_date    IN DATE)
  RETURN SELF
AS
  RESULT
IS
BEGIN
  -- Validate incoming value of zip
  SELECT zip
  INTO SELF.zip
  FROM zipcode
  WHERE zip = in_zip;
  -- Check incoming value of student ID
  -- If it is not populated, get it from the sequence
  IF in_student_id IS NULL THEN
    student_id     := STUDENT_ID_SEQ. NEXTVAL;
  ELSE
    student_id := in_student_id;
  END IF;
  salutation        := in_salutation;
  first_name        := in_first_name;
  last_name         := in_last_name;
  street_address    := in_street_addr;
  phone             := in_phone;
  employer          := in_employer;
  registration_date := in_reg_date;
  IF in_cr_by       IS NULL THEN
    created_by      := USER;
  ELSE
    created_by := in_cr_by;
  END IF;
  IF in_cr_date  IS NULL THEN
    created_date := SYSDATE;
  ELSE
    created_date := in_cr_date;
  END IF;
  IF in_mod_by  IS NULL THEN
    modified_by := USER;
  ELSE
    modified_by := in_mod_by;
  END IF;
  IF in_mod_date  IS NULL THEN
    modified_date := SYSDATE;
  ELSE
    modified_date := in_mod_date;
  END IF;
  RETURN;
EXCEPTION
WHEN NO_DATA_FOUND THEN
  RETURN;
END;
CONSTRUCTOR
FUNCTION student_obj_type(
    SELF          IN OUT NOCOPY STUDENT_OBJ_TYPE,
    in_student_id IN NUMBER)
  RETURN SELF
AS
  RESULT
IS
BEGIN
  SELECT student_id,
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
  INTO SELF.student_id,
    SELF.salutation,
    SELF.first_name,
    SELF.last_name,
    SELF.street_address,
    SELF.zip,
    SELF.phone,
    SELF.employer,
    SELF.registration_date,
    SELF.created_by,
    SELF.created_date,
    SELF.modified_by,
    SELF.modified_date
  FROM student
  WHERE student_id = in_student_id;
  RETURN;
EXCEPTION
WHEN NO_DATA_FOUND THEN
  RETURN;
END;
MEMBER PROCEDURE get_student_info(
    student_id OUT NUMBER,
    salutation OUT VARCHAR2,
    first_name OUT VARCHAR2,
    last_name OUT VARCHAR2,
    street_addr OUT VARCHAR2,
    zip OUT VARCHAR2,
    phone OUT VARCHAR2,
    employer OUT VARCHAR2,
    reg_date OUT DATE,
    cr_by OUT VARCHAR2,
    cr_date OUT DATE,
    mod_by OUT VARCHAR2,
    mod_date OUT DATE)
IS
BEGIN
  student_id  := SELF.student_id;
  salutation  := SELF.salutation;
  first_name  := SELF.first_name;
  last_name   := SELF.last_name;
  street_addr := SELF.street_address;
  zip         := SELF.zip;
  phone       := SELF.phone;
  employer    := SELF.employer;
  reg_date    := SELF.registration_date;
  cr_by       := SELF.created_by;
  cr_date     := SELF.created_date;
  mod_by      := SELF.modified_by;
  mod_date    := SELF.modified_date;
END;
STATIC
PROCEDURE display_student_info(
    student_obj IN STUDENT_OBJ_TYPE)
IS
BEGIN
  DBMS_OUTPUT.PUT_LINE ('Student ID: '||student_obj.student_id);
  DBMS_OUTPUT.PUT_LINE ('Salutation: '||student_obj.salutation);
  DBMS_OUTPUT.PUT_LINE ('First Name: '||student_obj.first_name);
  DBMS_OUTPUT.PUT_LINE ('Last Name: ' ||student_obj.last_name);
  DBMS_OUTPUT.PUT_LINE ('Street Address: '||student_obj.street_address);
  DBMS_OUTPUT.PUT_LINE ('Zip: ' ||student_obj.zip);
  DBMS_OUTPUT.PUT_LINE ('Phone: ' ||student_obj.phone);
  DBMS_OUTPUT.PUT_LINE ('Employer: '||student_obj.employer);
  DBMS_OUTPUT.PUT_LINE ('Registration Date: '||student_obj.registration_date);
END;
ORDER MEMBER FUNCTION student(
    student_obj STUDENT_OBJ_TYPE)
  RETURN INTEGER
IS
BEGIN
  IF student_id < student_obj.student_id THEN
    RETURN -1;
  ELSIF student_id = student_obj.student_id THEN
    RETURN 0;
  ELSIF student_id > student_obj.student_id THEN
    RETURN 1;
  END IF;
END;
END;
/


/*
This student object type has two overloaded constructor functions, member procedure, static
procedure, and order function methods.
Both constructor functions have the same name as the object type.The first constructor function
evaluates incoming values of student ID, zip code, created and modified users, and dates.
Specifically, it checks to see if the incoming student ID is null and then populates it from
STUDENT_ID_SEQ. Take a closer look at the statement that assigns a sequence value to the
STUDENT_ID attribute.The ability to access a sequence via a PL/SQL expression is a new feature in
Oracle 11g. Previously, sequences could be accessed only by queries. It also validates that the
incoming value of zip exists in the ZIPCODE table. Finally, it checks to see if incoming values of the
created and modified user and date are null. If any of these incoming values are null, the constructor
function populates the corresponding attributes with the default values based on the system
functions USER and SYSDATE.The second constructor function initializes the object instance
based on the incoming value of student ID using the SELECT INTO statement.
The member procedure GET_STUDENT_INFO populates out parameters with corresponding
values of object attributes.The static procedure DISPLAY_STUDENT_INFO displays values of the
incoming student object on the screen. Recall that static methods do not have access to the data
associated with a particular object type instance. As a result, they may not reference the default
parameter SELF.The order member function compares two instances of the student object type
based on values of the student_id attribute.

The newly created object type may be tested as follows:
*/


DECLARE
  v_student_obj1 student_obj_type;
  v_student_obj2 student_obj_type;
  v_result INTEGER;
BEGIN
  -- Populate student objects via user-defined constructor method
  v_student_obj1 := student_obj_type (in_student_id => NULL, in_salutation => 'Mr.', in_first_name => 'John', in_last_name => 'Smith', in_street_addr => '123 Main Street', in_zip => '00914', in_phone => '555-555-5555', in_employer => 'ABC Company', in_reg_date => TRUNC(sysdate), in_cr_by => NULL, in_cr_date => NULL, in_mod_by => NULL, in_mod_date => NULL);
  v_student_obj2 := student_obj_type(103);
  -- Display student information for both objects
  student_obj_type.display_student_info (v_student_obj1);
  DBMS_OUTPUT.PUT_LINE ('================================');
  student_obj_type.display_student_info (v_student_obj2);
  DBMS_OUTPUT.PUT_LINE ('================================');
  -- Compare student objects
  v_result := v_student_obj1.student(v_student_obj2);
  DBMS_OUTPUT.PUT_LINE ('The result of comparison is '||v_result);
  IF v_result = 1 THEN
    DBMS_OUTPUT.PUT_LINE ('v_student_obj1 is greater than v_student_obj2');
  ELSIF v_result = 0 THEN
    DBMS_OUTPUT.PUT_LINE ('v_student_obj1 is equal to v_student_obj2');
  ELSIF v_result = -1 THEN
    DBMS_OUTPUT.PUT_LINE ('v_student_obj1 is less than v_student_obj2');
  END IF;
END;
/


/*
The output is as follows:
Student ID: 403
Salutation: Mr.
First Name: John
Last Name: Smith
Street Address: 123 Main Street
Zip: 00914
Phone: 555-555-5555
Employer: ABC Company
Registration Date: 24-APR-08
================================
Student ID: 103
Salutation: Ms.
First Name: J.
Last Name: Landry
Street Address: 7435 Boulevard East #45
Zip: 07047
Phone: 201-555-5555
Employer: Albert Hildegard Co.
Registration Date: 22-JAN-03
================================
The result of comparison is 1
V_STUDENT_OBJ1 IS GREATER THAN V_STUDENT_OBJ2
PL/SQL procedure successfully completed.
*/



