
SET SERVEROUTPUT ON;
DECLARE
first&last_names VARCHAR2(30);
BEGIN
first&last_names := 'TEST NAME';
DBMS_OUTPUT.PUT_LINE(FIRST&LAST_NAMES);
END;

--------------------------------------------------------------------------

SET SERVEROUTPUT ON
DECLARE
  v_name       VARCHAR2(30);
  v_dob        DATE;
  v_us_citizen BOOLEAN;
BEGIN
  DBMS_OUTPUT.PUT_LINE(V_NAME||'born on'||V_DOB);
END;

--------------------------------------------------------------------------

DECLARE
    ex_custom       EXCEPTION;
BEGIN
    RAISE ex_custom;
EXCEPTION
    WHEN ex_custom THEN
        DBMS_OUTPUT.PUT_LINE(SQLERRM);
END;
/

--------------------------------------------------------------------------

DECLARE
    ex_custom       EXCEPTION;
BEGIN
    RAISE ex_custom;
EXCEPTION
    WHEN ex_custom THEN
        DBMS_OUTPUT.PUT_LINE(SQLERRM);
END;
/

--------------------------------------------------------------------------------------

DECLARE
    l_table_status      VARCHAR2(8);
    l_index_status      VARCHAR2(8);
    l_table_name        VARCHAR2(30) := 'TEST';
    l_index_name        VARCHAR2(30) := 'IDX_TEST';
    ex_no_metadata      EXCEPTION;
BEGIN

    BEGIN
        SELECT  STATUS
        INTO    l_table_status
        FROM    USER_TABLES
        WHERE   TABLE_NAME      = l_table_name;
    EXCEPTION
        WHEN NO_DATA_FOUND THEN
            -- raise exception here with message saying
            -- "Table metadata does not exist."
            RAISE ex_no_metadata;
    END;

    BEGIN
        SELECT  STATUS
        INTO    l_index_status
        FROM    USER_INDEXES
        WHERE   INDEX_NAME      = l_index_name;
    EXCEPTION
        WHEN NO_DATA_FOUND THEN
            -- raise exception here with message saying
            -- "Index metadata does not exist."
            RAISE ex_no_metadata;
    END;

EXCEPTION
    WHEN ex_no_metadata THEN
        DBMS_OUTPUT.PUT_LINE('Exception will be handled by handle_no_metadata_exception(SQLERRM) procedure here.');
        DBMS_OUTPUT.PUT_LINE(SQLERRM);
END;
/

-------------------------------------------------------------------------------------

SET SERVEROUTPUT ON;
DECLARE
  v_var1 VARCHAR2(20);
  v_var2 VARCHAR2(6);
  v_var3 NUMBER(5,3);
BEGIN
  v_var1 := 'string literal';
  v_var2 := '12.345';
  v_var3 := 12.345;
  DBMS_OUTPUT.PUT_LINE('v_var1: '||v_var1);
  DBMS_OUTPUT.PUT_LINE('v_var2: '||v_var2);
  DBMS_OUTPUT.PUT_LINE('v_var3: '||V_VAR3);
END;


--------------------------------------------------------------------------

DECLARE
  v_var1 NUMBER(3)   := 123;
  v_var2 NUMBER(3)   := 123;
  v_var3 NUMBER(9,3) := 123456.123;
BEGIN
  DBMS_OUTPUT.PUT_LINE('v_var1: '||v_var1);
  DBMS_OUTPUT.PUT_LINE('v_var2: '||v_var2);
  DBMS_OUTPUT.PUT_LINE('v_var3: '||V_VAR3);
END;


--------------------------------------------------------------------------


SET SERVEROUTPUT ON
DECLARE
  v_name student.first_name%TYPE;
  v_grade grade.numeric_grade%TYPE;
BEGIN
  DBMS_OUTPUT.PUT_LINE(NVL(v_name, 'No Name ')|| ' has grade of '||NVL(V_GRADE, 0));
END;


--------------------------------------------------------------------------


SET SERVEROUTPUT ON
DECLARE
  v_cookies_amt         NUMBER          := 2;
  v_calories_per_cookie CONSTANT NUMBER := 300;
BEGIN
  DBMS_OUTPUT.PUT_LINE('I ate ' || v_cookies_amt || ' cookies with ' || v_cookies_amt * v_calories_per_cookie || ' calories.');
  v_cookies_amt := 3;
  DBMS_OUTPUT.PUT_LINE('I really ate ' || v_cookies_amt || ' cookies with ' || v_cookies_amt * v_calories_per_cookie || ' calories.');
  v_cookies_amt := v_cookies_amt + 5;
  DBMS_OUTPUT.PUT_LINE('The truth is, I actually ate ' || v_cookies_amt || ' cookies with ' || v_cookies_amt * v_calories_per_cookie || ' calories.');
END;

--------------------------------------------------------------------------

SET SERVEROUTPUT ON
DECLARE
  v_lname   VARCHAR2(30);
  v_regdate DATE;
  v_pctincr CONSTANT NUMBER(4,2) := 1.50;
  v_counter NUMBER               := 0;
  v_new_cost course.cost%TYPE;
  v_YorN BOOLEAN := TRUE;
BEGIN
  v_counter  := NVL(v_counter, 0) + 1;
  v_new_cost := 800               * v_pctincr;
  DBMS_OUTPUT.PUT_LINE(v_counter);
  DBMS_OUTPUT.PUT_LINE(v_new_cost);
  v_counter  := ((v_counter + 5)*2) / 2;
  v_new_cost := (v_new_cost * v_counter)/4;
  DBMS_OUTPUT.PUT_LINE(v_counter);
  DBMS_OUTPUT.PUT_LINE(V_NEW_COST);
END;


--------------------------------------------------------------------------


DECLARE
  v_test NUMBER := 123;
BEGIN
  DBMS_OUTPUT.PUT_LINE ('Outer Block, v_test: '||v_test);
  DECLARE
    v_test NUMBER := 456;
  BEGIN
    DBMS_OUTPUT.PUT_LINE ('Inner Block, v_test: '||v_test);
    DBMS_OUTPUT.PUT_LINE ('Inner Block, outer_block.v_test: '|| v_test);
  END ;
END ;


--------------------------------------------------------------------------


SET SERVEROUTPUT ON
DECLARE
  e_show_exception_scope EXCEPTION;
  v_student_id           NUMBER := 123;
BEGIN
  DBMS_OUTPUT.PUT_LINE('outer student id is ' ||v_student_id);
  DECLARE
    v_student_id VARCHAR2(8) := 125;
  BEGIN
    DBMS_OUTPUT.PUT_LINE('inner student id is ' ||v_student_id);
    RAISE e_show_exception_scope;
  END;
EXCEPTION
WHEN e_show_exception_scope THEN
  DBMS_OUTPUT.PUT_LINE('When am I displayed?');
  DBMS_OUTPUT.PUT_LINE('outer student id is ' ||v_student_id);
END;



--------------------------------------------------------------------------


SET SERVEROUTPUT ON
DECLARE
  V_DESCRIPT     VARCHAR2(35);
  v_number_test  NUMBER(8,2);
  v_location     CONSTANT VARCHAR2(4) := '603D';
  v_boolean_test BOOLEAN;
  v_start_date   DATE := TRUNC(SYSDATE) + 7;
BEGIN
  DBMS_OUTPUT.PUT_LINE ('The location is: '||v_location||'.');
  DBMS_OUTPUT.PUT_LINE ('The starting date is: '||v_start_date||'.');
END;



--------------------------------------------------------------------------

SET SERVEROUTPUT ON
DECLARE
  v_descript     VARCHAR2(35);
  v_number_test  NUMBER(8,2);
  v_location     CONSTANT VARCHAR2(4) := '603D';
  v_boolean_test BOOLEAN;
  v_start_date   DATE := TRUNC(SYSDATE) + 7;
BEGIN
  IF v_descript = 'Introduction to Underwater Basketweaving' THEN
    DBMS_OUTPUT.PUT_LINE ('This course is '||v_descript||'.');
  ELSIF v_location = '603D' THEN
    IF v_descript IS NOT NULL THEN
      DBMS_OUTPUT.PUT_LINE ('The course is '||v_descript ||'.'||' The location is '||v_location||'.');
    ELSE
      DBMS_OUTPUT.PUT_LINE ('The course is unknown.'|| ' The location is '||v_location||'.');
    END IF;
  ELSE
    DBMS_OUTPUT.PUT_LINE ('The course and location '|| 'could not be determined.');
  END IF;
EXCEPTION
WHEN OTHERS THEN
  DBMS_OUTPUT.PUT_LINE ('An error occurred.');
END;




---------------------------------------------


SET SERVEROUTPUT ON

CREATE OR REPLACE PACKAGE errors AS
  invalid_foo_err EXCEPTION;
  invalid_foo_num NUMBER := -20123;
  invalid_foo_msg VARCHAR2(32767) := 'Invalid Foo!';
  PRAGMA EXCEPTION_INIT(invalid_foo_err, -20123);  -- can't use var >:O

  illegal_bar_err EXCEPTION;
  illegal_bar_num NUMBER := -20156;
  illegal_bar_msg VARCHAR2(32767) := 'Illegal Bar!';
  PRAGMA EXCEPTION_INIT(illegal_bar_err, -20156);  -- can't use var >:O

  PROCEDURE raise_err(p_err NUMBER, p_msg VARCHAR2 DEFAULT NULL);
END;
/

CREATE OR REPLACE PACKAGE BODY errors AS
  unknown_err EXCEPTION;
  unknown_num NUMBER := -20001;
  unknown_msg VARCHAR2(32767) := 'Unknown Error Specified!';

  PROCEDURE raise_err(p_err NUMBER, p_msg VARCHAR2 DEFAULT NULL) AS
    v_msg VARCHAR2(32767);
  BEGIN
    IF p_err = unknown_num THEN
      v_msg := unknown_msg;
    ELSIF p_err = invalid_foo_num THEN
      v_msg := invalid_foo_msg;
    ELSIF p_err = illegal_bar_num THEN
      v_msg := illegal_bar_msg;
    ELSE
      raise_err(unknown_num, 'USR' || p_err || ': ' || p_msg);
    END IF;

    IF p_msg IS NOT NULL THEN
      v_msg := v_msg || ' - '||p_msg;
    END IF;

    RAISE_APPLICATION_ERROR(p_err, v_msg);
  END;
END;
/



---------------------------------------


BEGIN
  BEGIN
    errors.raise_err(errors.invalid_foo_num, 'Insufficient Foo-age!');
  EXCEPTION
    WHEN errors.invalid_foo_err THEN
      dbms_output.put_line(SQLERRM);
  END;

  BEGIN
    errors.raise_err(errors.illegal_bar_num, 'Insufficient Bar-age!');
  EXCEPTION
    WHEN errors.illegal_bar_err THEN
      dbms_output.put_line(SQLERRM);
  END;

  BEGIN
    errors.raise_err(-10000, 'This Doesn''t Exist!!');
  EXCEPTION
    WHEN OTHERS THEN
      dbms_output.put_line(SQLERRM);
  END;
END;
/

--------


declare
   z exception;

begin
   if to_char(sysdate,'day')='sunday' then
     raise z;
   end if;

   exception 
     when z then
        dbms_output.put_line('to day is sunday');
end;


-------------------



SET SERVEROUTPUT ON
DECLARE
  V_DESCRIPT     VARCHAR2(35);
  v_number_test  NUMBER(8,2);
  v_location     CONSTANT VARCHAR2(4) := '603D';
  v_boolean_test BOOLEAN;
  v_start_date   DATE := TRUNC(SYSDATE) + 7;
BEGIN
  DBMS_OUTPUT.PUT_LINE ('The location is: '||v_location||'.');
  DBMS_OUTPUT.PUT_LINE ('The starting date is: '||v_start_date||'.');
END;

-----------------------------------------------------------------------

SET SERVEROUTPUT ON
DECLARE
  v_descript     VARCHAR2(35);
  v_number_test  NUMBER(8,2);
  v_location     CONSTANT VARCHAR2(4) := '603D';
  v_boolean_test BOOLEAN;
  v_start_date   DATE := TRUNC(SYSDATE) + 7;
BEGIN
  IF v_descript = 'Introduction to Underwater Basketweaving' THEN
    DBMS_OUTPUT.PUT_LINE ('This course is '||v_descript||'.');
  ELSIF v_location = '603D' THEN
    IF v_descript IS NOT NULL THEN
      DBMS_OUTPUT.PUT_LINE ('The course is '||v_descript ||'.'||' The location is '||v_location||'.');
    ELSE
      DBMS_OUTPUT.PUT_LINE ('The course is unknown.'|| ' The location is '||v_location||'.');
    END IF;
  ELSE
    DBMS_OUTPUT.PUT_LINE ('The course and location '|| 'could not be determined.');
  END IF;
EXCEPTION
WHEN OTHERS THEN
  DBMS_OUTPUT.PUT_LINE ('An error occurred.');
END;





