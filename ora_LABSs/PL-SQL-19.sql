--MODULE 19
------------



--Procedures
-------------


--Creating Procedures
-------------------------------------------------------------------------------------------------

CREATE OR REPLACE
PROCEDURE Discount
AS
  CURSOR c_group_discount
  IS
    SELECT DISTINCT s.course_no,
      c.description
    FROM section s,
      enrollment e,
      course c
    WHERE s.section_id = e.section_id
    AND c.course_no    = s.course_no
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
    DBMS_OUTPUT.PUT_LINE ('A 5% discount has been given to '|| r_group_discount.course_no||' '|| r_group_discount.description );
  END LOOP;
END;

-------------------------------------------------------------------------------------------------


BEGIN
  Discount;
END;

-------------------------------------------------------------------------------------------------


SELECT *--object_name, object_type, status
FROM USER_OBJECTS
WHERE object_name = 'DISCOUNT';


/*
B) Write a SELECT statement to display the source code from the USER_SOURCE view for the
Discount procedure.
*/
-------------------------------------------------------------------------------------------------


select * 
FROM USER_SOURCE
WHERE name = 'DISCOUNT';


SELECT TO_CHAR(line, 99)||'>', text
FROM USER_SOURCE
WHERE name = 'DISCOUNT';

------------------------------------------------------------------------------------------------------
--Passing Parameters into and out of Procedures
--19.2.1 Use IN and OUT Parameters with Procedures
-------------------------------------------------------------------------------------------------

CREATE OR REPLACE
PROCEDURE find_sname(
    i_student_id IN NUMBER,
    o_first_name OUT VARCHAR2,
    o_last_name OUT VARCHAR2 )
AS
BEGIN
  SELECT first_name,
    last_name
  INTO o_first_name,
    o_last_name
  FROM student
  WHERE student_id = i_student_id;
EXCEPTION
WHEN OTHERS THEN
  DBMS_OUTPUT.PUT_LINE('Error in finding student_id:
'||i_student_id);
END find_sname;
-------------------------------------------------------------------------------------------------

DECLARE
  v_local_first_name student.first_name%TYPE;
  v_local_last_name student.last_name%TYPE;
BEGIN
  find_sname (145, v_local_first_name, v_local_last_name);
  DBMS_OUTPUT.PUT_LINE ('Student 145 is: '||v_local_first_name|| ' '|| v_local_last_name||'.' );
END;

-------------------------------------------------------------------------------------------------
--MODULE 19 TRY IT YOURSELF
----------------------------
--Chapter 19,“Procedures”
-------------------------------------------------------------------------------------------------

CREATE OR REPLACE
PROCEDURE current_status
AS
  v_day_type CHAR(1);
  v_user     VARCHAR2(30);
  v_valid    NUMBER;
  v_invalid  NUMBER;
BEGIN
  SELECT SUBSTR(TO_CHAR(sysdate, 'DAY'), 0, 1) INTO v_day_type FROM dual;
  IF v_day_type = 'S' THEN
    DBMS_OUTPUT.PUT_LINE ('Today is a weekend.');
  ELSE
    DBMS_OUTPUT.PUT_LINE ('Today is a weekday.');
  END IF;
  --
  DBMS_OUTPUT.PUT_LINE('The time is: '|| TO_CHAR(sysdate, 'HH:MI AM'));
  --
  SELECT USER INTO v_user FROM dual;
  DBMS_OUTPUT.PUT_LINE ('The current user is '||v_user);
  --
  SELECT NVL(COUNT(*), 0)
  INTO v_valid
  FROM user_objects
  WHERE status    = 'VALID'
  AND object_type = 'PROCEDURE';
  DBMS_OUTPUT.PUT_LINE ('There are '||v_valid||' valid procedures.');
  --
  SELECT NVL(COUNT(*), 0)
  INTO v_invalid
  FROM user_objects
  WHERE status    = 'INVALID'
  AND object_type = 'PROCEDURE';
  DBMS_OUTPUT.PUT_LINE ('There are '||v_invalid||' invalid procedures.');
END;



SET SERVEROUTPUT ON
EXEC current_status;


-------------------------------------------------------------------------------------------------



CREATE OR REPLACE
PROCEDURE insert_zip(
    I_ZIPCODE IN zipcode.zip%TYPE,
    I_CITY    IN zipcode.city%TYPE,
    I_STATE   IN zipcode.state%TYPE)
AS
  v_zipcode zipcode.zip%TYPE;
  v_city zipcode.city%TYPE;
  v_state zipcode.state%TYPE;
  v_dummy zipcode.zip%TYPE;
BEGIN
  v_zipcode := i_zipcode;
  v_city    := i_city;
  v_state   := i_state;
  --
  SELECT zip INTO v_dummy FROM zipcode WHERE zip = v_zipcode;
  --
  DBMS_OUTPUT.PUT_LINE('The zipcode '||v_zipcode|| ' is already in the database and cannot be'|| ' reinserted.');
  --
EXCEPTION
WHEN NO_DATA_FOUND THEN
  INSERT
  INTO ZIPCODE VALUES
    (
      v_zipcode,
      v_city,
      v_state,
      USER,
      sysdate,
      USER,
      sysdate
    );
WHEN OTHERS THEN
  DBMS_OUTPUT.PUT_LINE ('There was an unknown error '|| 'in insert_zip.');
END;


SET SERVEROUTPUT ON
BEGIN
insert_zip (10035, 'No Where', 'ZZ');
END;


BEGIN
insert_zip (99999, 'No Where', 'ZZ');
END;


ROLLBACK;


-------------------------------------------------------------------------------------------------




CREATE OR REPLACE
PROCEDURE get_name_address(
    table_name_in IN VARCHAR2 ,
    id_in         IN NUMBER ,
    first_name_out OUT VARCHAR2 ,
    last_name_out OUT VARCHAR2 ,
    street_out OUT VARCHAR2 ,
    city_out OUT VARCHAR2 ,
    state_out OUT VARCHAR2 ,
    zip_out OUT VARCHAR2)
AS
  sql_stmt VARCHAR2(200);
BEGIN
  sql_stmt := 'SELECT a.first_name, a.last_name, a.street_address'|| ' ,b.city, b.state, b.zip' || ' FROM '||table_name_in||' a, zipcode b' || ' WHERE a.zip = b.zip' || ' AND '||table_name_in||'_id = :1';
  EXECUTE IMMEDIATE sql_stmt INTO first_name_out, last_name_out, street_out, city_out, state_out, zip_out USING id_in;
END get_name_address;


-------------------------------------------------------------------------------------------------




SET SERVEROUTPUT ON
DECLARE
  v_table_name VARCHAR2(20) := '&sv_table_name';
  v_id         NUMBER       := &sv_id;
  v_first_name VARCHAR2(25);
  v_last_name  VARCHAR2(25);
  v_street     VARCHAR2(50);
  v_city       VARCHAR2(25);
  v_state      VARCHAR2(2);
  v_zip        VARCHAR2(5);
BEGIN
  get_name_address (v_table_name, v_id, v_first_name, v_last_name, v_street, v_city, v_state, v_zip);
  DBMS_OUTPUT.PUT_LINE ('First Name: '||v_first_name);
  DBMS_OUTPUT.PUT_LINE ('Last Name: '||v_last_name);
  DBMS_OUTPUT.PUT_LINE ('Street: '||v_street);
  DBMS_OUTPUT.PUT_LINE ('City: '||v_city);
  DBMS_OUTPUT.PUT_LINE ('State: '||v_state);
  DBMS_OUTPUT.PUT_LINE ('Zip Code: '||v_zip);
END;


-------------------------------------------------------------------------------------------------


CREATE OR REPLACE
PACKAGE dynamic_sql_pkg
AS
  -- Create user-defined record type
TYPE name_addr_rec_type
IS
  RECORD
  (
    first_name VARCHAR2(25),
    last_name  VARCHAR2(25),
    street     VARCHAR2(50),
    city       VARCHAR2(25),
    state      VARCHAR2(2),
    zip        VARCHAR2(5));
  PROCEDURE get_name_address(
      table_name_in IN VARCHAR2 ,
      id_in         IN NUMBER ,
      name_addr_rec OUT name_addr_rec_type);
END dynamic_sql_pkg;
/

-------------------------------------------------------------------------------------------------


CREATE OR REPLACE
PACKAGE BODY dynamic_sql_pkg
AS
PROCEDURE get_name_address(
    table_name_in IN VARCHAR2 ,
    id_in         IN NUMBER ,
    name_addr_rec OUT name_addr_rec_type)
IS
  sql_stmt VARCHAR2(200);
BEGIN
  sql_stmt := 'SELECT a.first_name, a.last_name, a.street_address'|| ' ,b.city, b.state, b.zip' || ' FROM '||table_name_in||' a, zipcode b' || ' WHERE a.zip = b.zip' || ' AND '||table_name_in||'_id = :1';
  EXECUTE IMMEDIATE sql_stmt INTO name_addr_rec USING id_in;
END get_name_address;
END dynamic_sql_pkg;
/

-------------------------------------------------------------------------------------------------



SET SERVEROUTPUT ON
DECLARE
  v_table_name VARCHAR2(20) := '&sv_table_name';
  v_id         NUMBER       := &sv_id;
  name_addr_rec DYNAMIC_SQL_PKG.NAME_ADDR_REC_TYPE;
BEGIN
  dynamic_sql_pkg.get_name_address (v_table_name, v_id, name_addr_rec);
  DBMS_OUTPUT.PUT_LINE ('First Name: '||name_addr_rec.first_name);
  DBMS_OUTPUT.PUT_LINE ('Last Name: '||name_addr_rec.last_name);
  DBMS_OUTPUT.PUT_LINE ('Street: '||name_addr_rec.street);
  DBMS_OUTPUT.PUT_LINE ('City: '||name_addr_rec.city);
  DBMS_OUTPUT.PUT_LINE ('State: '||name_addr_rec.state);
  DBMS_OUTPUT.PUT_LINE ('Zip Code: '||name_addr_rec.zip);
END;

-------------------------------------------------------------------------------------------------








