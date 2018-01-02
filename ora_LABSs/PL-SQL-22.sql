--MODULE 22
------------



--Stored Code
--------------



--Gathering Information About Stored Code


--22.1.1 GET STORED CODE INFORMATION FROM THE DATA DICTIONARY


/*
A) Query the data dictionary to determine all the stored procedures, functions, and packages in the
current schema of the database. Also include the current status of the stored code.Write the
SELECT statement.

ANSWER: You can use the USER_OBJECTS view you learned about in Chapter 19.This view has
information about all database objects in the schema of the current user. Remember, if you want
to see all the objects in other schemas that the current user has access to, use the ALL_OBJECTS
view.There is also a DBA_OBJECTS view for a list of all objects in the database, regardless of privilege.
The STATUS is either VALID or INVALID. An object can change status from VALID to INVALID if
an underlying table is altered or privileges on a referenced object have been revoked from the
creator of the function, procedure, or package.The following SELECT statement produces the
answer you are looking for:
*/


SELECT OBJECT_TYPE,
  OBJECT_NAME,
  STATUS
FROM USER_OBJECTS
WHERE OBJECT_TYPE IN ('FUNCTION', 'PROCEDURE', 'PACKAGE', 'PACKAGE_BODY')
ORDER BY OBJECT_TYPE;


/*
B) Type the following script into a text file, and run the script in SQL*Plus. It creates the function
scode_at_line. Explain the purpose of this function. What is accomplished by running it?
When does a developer find it useful?
*/



-- ch22_1a.sql
CREATE OR REPLACE
  FUNCTION scode_at_line(
      i_name_in IN VARCHAR2,
      i_line_in IN INTEGER  := 1,
      i_type_in IN VARCHAR2 := NULL)
    RETURN VARCHAR2
  IS
    CURSOR scode_cur
    IS
      SELECT text
      FROM user_source
      WHERE name    = UPPER (i_name_in)
      AND (type     = UPPER (i_type_in)
      OR i_type_in IS NULL)
      AND line      = i_line_in;
    scode_rec scode_cur%ROWTYPE;
  BEGIN
    OPEN scode_cur;
    FETCH scode_cur INTO scode_rec;
    IF scode_cur%NOTFOUND THEN
      CLOSE scode_cur;
      RETURN NULL;
    ELSE
      CLOSE scode_cur;
      RETURN scode_rec.text;
    END IF;
  END;


/*
ANSWER: The scode_at_line function provides an easy mechanism for retrieving the text
from a stored program for a specified line number.This is useful if a developer receives a compilation
error message referring to a particular line number in an object.The developer can then use
this function to find the text that is in error.
The function uses three parameters:
. name_in:The name of the stored object.
. line_in: The line number of the line you want to retrieve.The default value is 1.
. type_in: The type of object you want to view.The default for type_in is NULL.
The default values are designed to make this function as easy as possible to use.
*/


/*
C) Enter desc user_errors.What do you see? In what way do you think this view is useful
for you?
*/

desc user_errors;


/*
ANSWER: This view stores current errors on the user’s stored objects.The text file contains the
text of the error.This is useful in determining the details of a compilation error.The next exercise
walks you through using this view.
*/

/*
D) Enter the following script to force an error:
*/

--SQL*Plus ile dene
CREATE OR REPLACE PROCEDURE FORCE_ERROR
as
BEGIN
SELECT course_no
INTO v_temp
FROM course;
END;
/

SHO ERR;


/*
E) How can you retrieve information from the USER_ERRORS view?
*/

--SQL Developer ile dene
SELECT line||'/'||position "LINE/COL", TEXT "ERROR"
FROM USER_ERRORS
WHERE name = 'FORCE_ERROR';


/*
F) Enter desc user_dependencies.What do you see? How can you make use of this view?

ANSWER: The USER_DEPENDENCIES view is useful for analyzing the impact of table changes or
changes to other stored procedures. If tables are about to be redesigned, an impact assessment
can be made from the information in USER_DEPENDENCIES. ALL_DEPENDENCIES and DBA_
DEPENDENCIES show all dependencies for procedures, functions, package specifications, and
package bodies.
*/


/*
G) Enter the following:
*/


SELECT referenced_name
FROM user_dependencies
WHERE NAME = 'SCHOOL_API';

/*
This list of dependencies for the school_api package lists all objects referenced in the
package.This includes tables, sequences, and procedures (even Oracle-supplied packages).This
information is very useful when you are planning a change to the database structure.You can
easily pinpoint the ramifications of any database changes.
*/


/*
H) Enter desc school_api.What do you see?
*/


desc SCHOOL_API;


/*
I) Explain what you are seeing.How is this different from the USER_DEPENDENCIES view?

ANSWER: The desc command you have been using to describe the columns in a table is also
used for procedures, packages, and functions.The desc command shows all the parameters, with
their default values and an indication of whether they are IN or OUT. If the object is a function, the
return datatype is displayed.This is very different from the USER_DEPENDENCIES view, which has
information on all the objects that are referenced in a package, function, or procedure.
*/


--UTLDEPTREE kullan?m?

Rem 
Rem $Header: utldtree.sql,v 1.2 1992/10/26 16:24:44 RKOOI Stab $ 
Rem 
Rem  Copyright (c) 1991 by Oracle Corporation 
Rem    NAME
Rem      deptree.sql - Show objects recursively dependent on given object
Rem    DESCRIPTION
Rem      This procedure, view and temp table will allow you to see all
Rem      objects that are (recursively) dependent on the given object.
Rem      Note: you will only see objects for which you have permission.
Rem      Examples:
Rem        execute deptree_fill('procedure', 'scott', 'billing');
Rem        select * from deptree order by seq#;
Rem
Rem        execute deptree_fill('table', 'scott', 'emp');
Rem        select * from deptree order by seq#;
Rem
Rem        execute deptree_fill('package body', 'scott', 'accts_payable');
Rem        select * from deptree order by seq#;
Rem
Rem        A prettier way to display this information than
Rem		select * from deptree order by seq#;
Rem	   is
Rem             select * from ideptree;
Rem        This shows the dependency relationship via indenting.  Notice
Rem        that no order by clause is needed with ideptree.
Rem    RETURNS
Rem 
Rem    NOTES
Rem      Run this script once for each schema that needs this utility.
Rem      
Rem    MODIFIED   (MM/DD/YY)
Rem     rkooi      10/26/92 -  owner -> schema for SQL2 
Rem     glumpkin   10/20/92 -  Renamed from DEPTREE.SQL 
Rem     rkooi      09/02/92 -  change ORU errors 
Rem     rkooi      06/10/92 -  add rae errors 
Rem     rkooi      01/13/92 -  update for sys vs. regular user 
Rem     rkooi      01/10/92 -  fix ideptree 
Rem     rkooi      01/10/92 -  Better formatting, add ideptree view 
Rem     rkooi      12/02/91 -  deal with cursors 
Rem     rkooi      10/19/91 -  Creation 

drop sequence deptree_seq
/
create sequence deptree_seq cache 200 /* cache 200 to make sequence faster */
/
drop table deptree_temptab
/
create table deptree_temptab
(
  object_id            number,
  referenced_object_id number,
  nest_level           number,
  seq#                 number      
)
/
create or replace procedure deptree_fill (type char, schema char, name char) is
  obj_id number;
begin
  delete from deptree_temptab;
  commit;
  select object_id into obj_id from all_objects
    where owner        = upper(deptree_fill.schema)
    and   object_name  = upper(deptree_fill.name)
    and   object_type  = upper(deptree_fill.type);
  insert into deptree_temptab
    values(obj_id, 0, 0, 0);
  insert into deptree_temptab
    select object_id, referenced_object_id,
        level, deptree_seq.nextval
      from public_dependency
      connect by prior object_id = referenced_object_id
      start with referenced_object_id = deptree_fill.obj_id;
exception
  when no_data_found then
    raise_application_error(-20000, 'ORU-10013: ' ||
      type || ' ' || schema || '.' || name || ' was not found.');
end;
/

drop view deptree
/

set echo on

REM This view will succeed if current user is sys.  This view shows 
REM which shared cursors depend on the given object.  If the current
REM user is not sys, then this view get an error either about lack
REM of privileges or about the non-existence of table x$kglxs.

set echo off
create view sys.deptree
  (nested_level, type, schema, name, seq#)
as
  select d.nest_level, o.object_type, o.owner, o.object_name, d.seq#
  from deptree_temptab d, dba_objects o
  where d.object_id = o.object_id (+)
union all
  select d.nest_level+1, 'CURSOR', '<shared>', '"'||c.kglnaobj||'"', d.seq#+.5
  from deptree_temptab d, x$kgldp k, x$kglob g, obj$ o, user$ u, x$kglob c,
      x$kglxs a
    where d.object_id = o.obj#
    and   o.name = g.kglnaobj
    and   o.owner# = u.user#
    and   u.name = g.kglnaown
    and   g.kglhdadr = k.kglrfhdl
    and   k.kglhdadr = a.kglhdadr   /* make sure it is not a transitive */
    and   k.kgldepno = a.kglxsdep   /* reference, but a direct one */
    and   k.kglhdadr = c.kglhdadr
    and   c.kglhdnsp = 0 /* a cursor */
/

set echo on

REM This view will succeed if current user is not sys.  This view
REM does *not* show which shared cursors depend on the given object.
REM If the current user is sys then this view will get an error 
REM indicating that the view already exists (since prior view create
REM will have succeeded).

set echo off
create view deptree
  (nested_level, type, schema, name, seq#)
as
  select d.nest_level, o.object_type, o.owner, o.object_name, d.seq#
  from deptree_temptab d, all_objects o
  where d.object_id = o.object_id (+)
/

drop view ideptree
/
create view ideptree (dependencies)
as
  select lpad(' ',3*(max(nested_level))) || max(nvl(type, '<no permission>')
    || ' ' || schema || decode(type, NULL, '', '.') || name)
  from deptree
  group by seq# /* So user can omit sort-by when selecting from ideptree */
/

--
--
--
exec DEPTREE_FILL('TABLE', USER, 'COURSE');
--
--
--
SELECT * FROM ideptree;



--22.1.2 Enforce the Purity Level with the RESTRICT_REFERENCES Pragma



/*
A) Add the following function to the school_api package specification you created in
Chapter 21,“Packages”:
*/


-- ch22_2a.sql
CREATE OR REPLACE
PACKAGE school_api
AS
  v_current_date DATE;
  PROCEDURE Discount_Cost;
  FUNCTION new_instructor_id
    RETURN instructor.instructor_id%TYPE;
  FUNCTION total_cost_for_student(
      i_student_id IN student.student_id%TYPE)
    RETURN COURSE.COST%TYPE;
END school_api;




-- ch22_2a.sql
CREATE OR REPLACE
PACKAGE school_api
AS
  v_current_date DATE;
  PROCEDURE Discount_Cost;
  FUNCTION new_instructor_id
    RETURN instructor.instructor_id%TYPE;
  FUNCTION total_cost_for_student(
      i_student_id IN student.student_id%TYPE)
    RETURN course.cost%TYPE;
END school_api;




-- ch22_2b.sql
CREATE OR REPLACE
PACKAGE BODY school_api
AS
PROCEDURE discount_cost
IS
  CURSOR c_group_discount
  IS
    SELECT DISTINCT s.course_no,
      c.description
    FROM section s,
      enrollment e,
      course c
    WHERE s.section_id = e.section_id
    GROUP BY s.course_no,
      c.description,
      e.section_id,
      s.section_id
    HAVING COUNT(*) >=8;
BEGIN
  FOR r_group_discount IN c_group_discount
  LOOP
    UPDATE course
    SET cost        = cost * .95
    WHERE course_no = r_group_discount.course_no;
    DBMS_OUTPUT.PUT_LINE ('A 5% discount has been given to' ||r_group_discount.course_no||' 
'||r_group_discount.description);
  END LOOP;
END discount_cost;
FUNCTION new_instructor_id
  RETURN instructor.instructor_id%TYPE
IS
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
FUNCTION total_cost_for_student(
    i_student_id IN student.student_id%TYPE)
  RETURN course.cost%TYPE
IS
  v_cost course.cost%TYPE;
BEGIN
  SELECT SUM(cost)
  INTO v_cost
  FROM course c,
    section s,
    enrollment e
  WHERE c.course_no = s.course_no
  AND e.section_id  = s.section_id
  AND e.student_id  = i_student_id;
  RETURN v_cost;
EXCEPTION
WHEN OTHERS THEN
  RETURN NULL;
END total_cost_for_student;
BEGIN
  SELECT TRUNC(sysdate, 'DD') INTO v_current_date FROM DUAL;
END school_api;



--test et, 11g ile hata ç?kmaz
SELECT school_api.total_cost_for_student(student_id),
STUDENT_ID
FROM student;



/*
B) Alter the package specification for school_api as follows:
*/

-- ch22_2c.sql
CREATE OR REPLACE
PACKAGE school_api
AS
  v_current_date DATE;
  PROCEDURE Discount_Cost;
  FUNCTION new_instructor_id
    RETURN instructor.instructor_id%TYPE;
  FUNCTION total_cost_for_student(
      i_student_id IN student.student_id%TYPE)
    RETURN course.cost%TYPE;
  PRAGMA RESTRICT_REFERENCES (TOTAL_COST_FOR_STUDENT, WNDS, WNPS, RNPS);
END school_api;



/*
ANSWER: The pragma restriction is added to the package specification. It ensures that the function
total_cost_for_student meets the required purity restriction for a function to be
in a SELECT statement.The SELECT statement now functions properly; it projects a list of the total
cost for each student and the student’s ID.
*/



--22.1.3 Overload Modules


/*
A) Add the following lines to the package specification of school_api.Then recompile the
package specification. Explain what you have created.
*/

-- ch22_3a.sql
CREATE OR REPLACE
PACKAGE school_api
AS
  v_current_date DATE;
  PROCEDURE Discount_Cost;
  FUNCTION new_instructor_id
    RETURN instructor.instructor_id%TYPE;
  FUNCTION total_cost_for_student(
      i_student_id IN student.student_id%TYPE)
    RETURN course.cost%TYPE;
  PRAGMA RESTRICT_REFERENCES (total_cost_for_student, WNDS, WNPS, RNPS);
  PROCEDURE get_student_info(
      i_student_id IN student.student_id%TYPE,
      o_last_name OUT student.last_name%TYPE,
      o_first_name OUT student.first_name%TYPE,
      o_zip OUT student.zip%TYPE,
      o_return_code OUT NUMBER);
  PROCEDURE get_student_info(
      i_last_name  IN student.last_name%TYPE,
      i_first_name IN student.first_name%TYPE,
      o_student_id OUT student.student_id%TYPE,
      o_zip OUT student.zip%TYPE,
      O_RETURN_CODE OUT NUMBER);
END school_api;



/*
B) Add the following code to the body of the package school_api. Explain what is
accomplished.
*/


-- ch22_4a.sql
CREATE OR REPLACE
PACKAGE BODY school_api
AS
PROCEDURE discount_cost
IS
  CURSOR c_group_discount
  IS
    SELECT DISTINCT s.course_no,
      c.description
    FROM section s,
      enrollment e,
      course c
    WHERE s.section_id = e.section_id
    GROUP BY s.course_no,
      c.description,
      e.section_id,
      s.section_id
    HAVING COUNT(*) >=8;
BEGIN
  FOR r_group_discount IN c_group_discount
  LOOP
    UPDATE course
    SET cost        = cost * .95
    WHERE course_no = r_group_discount.course_no;
    DBMS_OUTPUT.PUT_LINE ('A 5% discount has been given to' ||r_group_discount.course_no||' 
'||r_group_discount.description);
  END LOOP;
END discount_cost;
FUNCTION new_instructor_id
  RETURN instructor.instructor_id%TYPE
IS
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
FUNCTION total_cost_for_student(
    i_student_id IN student.student_id%TYPE)
  RETURN course.cost%TYPE
IS
  v_cost course.cost%TYPE;
BEGIN
  SELECT SUM(cost)
  INTO v_cost
  FROM course c,
    section s,
    enrollment e
  WHERE c.course_no = s.course_no
  AND e.section_id  = s.section_id
  AND e.student_id  = i_student_id;
  RETURN v_cost;
EXCEPTION
WHEN OTHERS THEN
  RETURN NULL;
END total_cost_for_student;
PROCEDURE get_student_info(
    i_student_id IN student.student_id%TYPE,
    o_last_name OUT student.last_name%TYPE,
    o_first_name OUT student.first_name%TYPE,
    o_zip OUT student.zip%TYPE,
    o_return_code OUT NUMBER)
IS
BEGIN
  SELECT last_name,
    first_name,
    zip
  INTO o_last_name,
    o_first_name,
    o_zip
  FROM student
  WHERE student.student_id = i_student_id;
  o_return_code           := 0;
EXCEPTION
WHEN NO_DATA_FOUND THEN
  DBMS_OUTPUT.PUT_LINE ('Student ID is not valid.');
  o_return_code := -100;
  o_last_name   := NULL;
  o_first_name  := NULL;
  o_zip         := NULL;
WHEN OTHERS THEN
  DBMS_OUTPUT.PUT_LINE ('Error in procedure get_student_info');
END get_student_info;
PROCEDURE get_student_info(
    i_last_name  IN student.last_name%TYPE,
    i_first_name IN student.first_name%TYPE,
    o_student_id OUT student.student_id%TYPE,
    o_zip OUT student.zip%TYPE,
    o_return_code OUT NUMBER)
IS
BEGIN
  SELECT student_id,
    zip
  INTO o_student_id,
    o_zip
  FROM student
  WHERE UPPER(last_name) = UPPER(i_last_name)
  AND UPPER(first_name)  = UPPER(i_first_name);
  o_return_code         := 0;
EXCEPTION
WHEN NO_DATA_FOUND THEN
  DBMS_OUTPUT.PUT_LINE ('Student name is not valid.');
  o_return_code := -100;
  o_student_id  := NULL;
  o_zip         := NULL;
WHEN OTHERS THEN
  DBMS_OUTPUT.PUT_LINE ('Error in procedure get_student_info');
END get_student_info;
BEGIN
  SELECT TRUNC(sysdate, 'DD') INTO v_current_date FROM DUAL;
END school_api;



/*
ANSWER: A single function name, get_student_info, accepts either a single IN parameter
of student_id or two parameters consisting of a student’s last_name and first_name.
If a number is passed in, the procedure looks for the student’s name and zip code. If it finds them,
they are returned, as well as a return code of 0. If they cannot be found, null values are returned, as
well as a return code of 100. If two VARCHAR2 parameters are passed in, the procedure searches
for the student_id corresponding to the names passed in. As with the other version of this
procedure, if a match is found, the procedure returns a student_id, the student’s zip code, and
a return code of 0. If a match is not found, the values returned are null and an exit code of –100.
*/


/*
C) Write a PL/SQL block using the overloaded function you just created.
*/

--Enter value for p_id: 149
--ENTER VALUE FOR P_LAST_NAME: 'Prochaska'
--Enter value for p_first_name: 'Judith'
--
--149  vs gir

DECLARE
  v_student_ID student.student_id%TYPE;
  v_last_name student.last_name%TYPE;
  v_first_name student.first_name%TYPE;
  v_zip student.zip%TYPE;
  v_return_code NUMBER;
BEGIN
  school_api.get_student_info (&&p_id, v_last_name, v_first_name, v_zip,v_return_code);
  IF v_return_code = 0 THEN
    DBMS_OUTPUT.PUT_LINE ('Student with ID '||&&p_id||' is '||v_first_name ||' '||v_last_name );
  ELSE
    DBMS_OUTPUT.PUT_LINE ('The ID '||&&p_id||'is not in the database' );
  END IF;
  school_api.get_student_info (&&p_last_name , &&p_first_name, v_student_id, v_zip , v_return_code);
  IF v_return_code = 0 THEN
    DBMS_OUTPUT.PUT_LINE (&&p_first_name||' '|| &&p_last_name|| ' has an ID of '||v_student_id );
  ELSE
    DBMS_OUTPUT.PUT_LINE (&&p_first_name||' '|| &&p_last_name|| 'is not in the database' );
  END IF;
END;









--MODULE 22 TRY IT YOURSELF
----------------------------



--Chapter 22,“Stored Code”

/*
1) Add a function to the student_api package specification called get_course_
descript.The caller takes a course.cnumber%TYPE parameter, and it returns a
course.description%TYPE.

ANSWER: The package should look similar to the following:
*/


CREATE OR REPLACE
PACKAGE student_api
AS
  v_current_date DATE;
  PROCEDURE discount;
  FUNCTION new_instructor_id
    RETURN instructor.instructor_id%TYPE;
  FUNCTION total_cost_for_student(
      p_student_id IN student.student_id%TYPE)
    RETURN course.cost%TYPE;
  PRAGMA RESTRICT_REFERENCES (total_cost_for_student, WNDS, WNPS, RNPS);
  PROCEDURE get_student_info(
      p_student_id IN student.student_id%TYPE,
      p_last_name OUT student.last_name%TYPE,
      p_first_name OUT student.first_name%TYPE,
      p_zip OUT student.zip%TYPE,
      p_return_code OUT NUMBER);
  PROCEDURE get_student_info(
      p_last_name  IN student.last_name%TYPE,
      p_first_name IN student.first_name%TYPE,
      p_student_id OUT student.student_id%TYPE,
      p_zip OUT student.zip%TYPE,
      p_return_code OUT NUMBER);
  PROCEDURE remove_student(
      p_studid IN student.student_id%TYPE,
      p_ri     IN VARCHAR2 DEFAULT 'R');
  FUNCTION get_course_descript(
      p_cnumber course.course_no%TYPE)
    RETURN course.description%TYPE;
END student_api;



/*
2) Create a function in the student_api package body called get_course_description.
A caller passes in a course number, and it returns the course description. Instead of searching for
the description itself, it makes a call to get_course_descript_private. It passes its
course number to get_course_descript_private. It passes back to the caller the
description it gets back from get_course_descript_private.

ANSWER: The package body should look similar to the following:
*/



CREATE OR REPLACE
PACKAGE BODY student_api
AS
PROCEDURE discount
IS
  CURSOR c_group_discount
  IS
    SELECT DISTINCT s.course_no,
      c.description
    FROM section s,
      enrollment e,
      course c
    WHERE s.section_id = e.section_id
    GROUP BY s.course_no,
      c.description,
      e.section_id,
      s.section_id
    HAVING COUNT(*) >=8;
BEGIN
  FOR r_group_discount IN c_group_discount
  LOOP
    UPDATE course
    SET cost        = cost * .95
    WHERE course_no = r_group_discount.course_no;
    DBMS_OUTPUT.PUT_LINE ('A 5% discount has been given to'|| r_group_discount.course_no||' '|| r_group_discount.description);
  END LOOP;
END discount;
FUNCTION new_instructor_id
  RETURN instructor.instructor_id%TYPE
IS
  v_new_instid instructor.instructor_id%TYPE;
BEGIN
  SELECT INSTRUCTOR_ID_SEQ.NEXTVAL INTO v_new_instid FROM dual;
  RETURN v_new_instid;
EXCEPTION
WHEN OTHERS THEN
  DECLARE
    v_sqlerrm VARCHAR2(250) := SUBSTR(SQLERRM,1,250);
  BEGIN
    RAISE_APPLICATION_ERROR (-20003, 'Error in instructor_id: '||v_sqlerrm);
  END;
END new_instructor_id;
FUNCTION get_course_descript_private(
    p_course_no course.course_no%TYPE)
  RETURN course.description%TYPE
IS
  v_course_descript course.description%TYPE;
BEGIN
  SELECT description
  INTO v_course_descript
  FROM course
  WHERE course_no = p_course_no;
  RETURN v_course_descript;
EXCEPTION
WHEN OTHERS THEN
  RETURN NULL;
END get_course_descript_private;
FUNCTION total_cost_for_student(
    p_student_id IN student.student_id%TYPE)
  RETURN course.cost%TYPE
IS
  v_cost course.cost%TYPE;
BEGIN
  SELECT SUM(cost)
  INTO v_cost
  FROM course c,
    section s,
    enrollment e
  WHERE c.course_no = c.course_no
  AND e.section_id  = s.section_id
  AND e.student_id  = p_student_id;
  RETURN v_cost;
EXCEPTION
WHEN OTHERS THEN
  RETURN NULL;
END total_cost_for_student;
PROCEDURE get_student_info(
    p_student_id IN student.student_id%TYPE,
    p_last_name OUT student.last_name%TYPE,
    p_first_name OUT student.first_name%TYPE,
    p_zip OUT student.zip%TYPE,
    p_return_code OUT NUMBER)
IS
BEGIN
  SELECT last_name,
    first_name,
    zip
  INTO p_last_name,
    p_first_name,
    p_zip
  FROM student
  WHERE student.student_id = p_student_id;
  p_return_code           := 0;
EXCEPTION
WHEN NO_DATA_FOUND THEN
  DBMS_OUTPUT.PUT_LINE ('Student ID is not valid.');
  p_return_code := -100;
  p_last_name   := NULL;
  p_first_name  := NULL;
  p_zip         := NULL;
WHEN OTHERS THEN
  DBMS_OUTPUT.PUT_LINE ('Error in procedure get_student_info');
END get_student_info;
PROCEDURE get_student_info(
    p_last_name  IN student.last_name%TYPE,
    p_first_name IN student.first_name%TYPE,
    p_student_id OUT student.student_id%TYPE,
    p_zip OUT student.zip%TYPE,
    p_return_code OUT NUMBER)
IS
BEGIN
  SELECT student_id,
    zip
  INTO p_student_id,
    p_zip
  FROM student
  WHERE UPPER(last_name) = UPPER(p_last_name)
  AND UPPER(first_name)  = UPPER(p_first_name);
  p_return_code         := 0;
EXCEPTION
WHEN NO_DATA_FOUND THEN
  DBMS_OUTPUT.PUT_LINE ('Student name is not valid.');
  p_return_code := -100;
  p_student_id  := NULL;
  p_zip         := NULL;
WHEN OTHERS THEN
  DBMS_OUTPUT.PUT_LINE ('Error in procedure get_student_info');
END get_student_info;
PROCEDURE remove_student
  -- The parameters student_id and p_ri give the user an
  -- option of cascade delete or restrict delete for
  -- the given student's records
  (
    p_studid IN student.student_id%TYPE,
    p_ri     IN VARCHAR2 DEFAULT 'R')
IS
  -- Declare exceptions for use in procedure
  enrollment_present EXCEPTION;
  bad_pri            EXCEPTION;
BEGIN
  -- The R value is for restrict delete option
  IF p_ri = 'R' THEN
    DECLARE
      -- A variable is needed to test if the student
      -- is in the enrollment table
      v_dummy CHAR(1);
    BEGIN
      -- This is a standard existence check.
      -- If v_dummy is assigned a value via the
      -- SELECT INTO, the exception
      -- enrollment_present will be raised.
      -- If the v_dummy is not assigned a value, the
      -- exception no_data_found will be raised.
      SELECT NULL
      INTO v_dummy
      FROM enrollment e
      WHERE e.student_id = p_studid
      AND ROWNUM         = 1;
      -- The rownum set to 1 prevents the SELECT
      -- INTO statement raise to_many_rows exception.
      -- If there is at least one row in the enrollment
      -- table with a corresponding student_id, the
      -- restrict delete parameter will disallow
      -- the deletion of the student by raising
      -- the enrollment_present exception.
      RAISE enrollment_present;
    EXCEPTION
    WHEN NO_DATA_FOUND THEN
      -- The no_data_found exception is raised
      -- when no students are found in the
      -- enrollment table.
      -- Since the p_ri indicates a restrict
      -- delete user choice, the delete operation
      -- is permitted.
      DELETE
      FROM student
      WHERE student_id = p_studid;
    END;
    -- When the user enters "C" for the p_ri
    -- he/she indicates a cascade delete choice
  ELSIF p_ri = 'C' THEN
    -- Delete the student from the enrollment and
    -- grade tables
    DELETE
    FROM enrollment
    WHERE student_id = p_studid;
    DELETE FROM grade WHERE student_id = p_studid;
    -- Delete from student table only after
    -- corresponding records have been removed from
    -- the other tables because the student table is
    -- the parent table
    DELETE
    FROM student
    WHERE student_id = p_studid;
  ELSE
    RAISE bad_pri;
  END IF;
EXCEPTION
WHEN bad_pri THEN
  RAISE_APPLICATION_ERROR (-20231, 'An incorrect p_ri value was '|| 'entered. The remove_student procedure can '|| 'only accept a C or R for the p_ri parameter.');
WHEN enrollment_present THEN
  RAISE_APPLICATION_ERROR (-20239, 'The student with ID'||p_studid|| ' exists in the enrollment table thus records'|| ' will not be removed.');
END remove_student;
FUNCTION get_course_descript(
    p_cnumber course.course_no%TYPE)
  RETURN course.description%TYPE
IS
BEGIN
  RETURN get_course_descript_private(p_cnumber);
END get_course_descript;
BEGIN
  SELECT TRUNC(sysdate, 'DD') INTO v_current_date FROM dual;
END student_api;


/*
3) Add a PRAGMA RESTRICT_REFERENCES to student_api for get_course_description
specifying the following: It writes no database state, it writes no package state, and it reads no
package state.

ANSWER: The package should look similar to the following:
*/


CREATE OR REPLACE
PACKAGE student_api
AS
  v_current_date DATE;
  PROCEDURE discount;
  FUNCTION new_instructor_id
    RETURN instructor.instructor_id%TYPE;
  FUNCTION total_cost_for_student(
      p_student_id IN student.student_id%TYPE)
    RETURN course.cost%TYPE;
  PRAGMA RESTRICT_REFERENCES (total_cost_for_student, WNDS, WNPS, RNPS);
  PROCEDURE get_student_info(
      p_student_id IN student.student_id%TYPE,
      p_last_name OUT student.last_name%TYPE,
      p_first_name OUT student.first_name%TYPE,
      p_zip OUT student.zip%TYPE,
      p_return_code OUT NUMBER);
  PROCEDURE get_student_info(
      p_last_name  IN student.last_name%TYPE,
      p_first_name IN student.first_name%TYPE,
      p_student_id OUT student.student_id%TYPE,
      p_zip OUT student.zip%TYPE,
      p_return_code OUT NUMBER);
  PROCEDURE remove_student(
      p_studid IN student.student_id%TYPE,
      p_ri     IN VARCHAR2 DEFAULT 'R');
  FUNCTION get_course_descript(
      p_cnumber course.course_no%TYPE)
    RETURN course.description%TYPE;
  PRAGMA RESTRICT_REFERENCES (get_course_descript,WNDS, WNPS, RNPS);
END STUDENT_API;
/











