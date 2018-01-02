
SET SERVEROUTPUT ON
DECLARE
  v_first_name VARCHAR2(35);
  v_last_name  VARCHAR2(35);
BEGIN
  SELECT first_name,
    last_name
  INTO v_first_name,
    v_last_name
  FROM student
  WHERE student_id = 1235;
  DBMS_OUTPUT.PUT_LINE ('Student name: '||v_first_name||' '|| v_last_name);
EXCEPTION
WHEN NO_DATA_FOUND THEN
  DBMS_OUTPUT.PUT_LINE ('There is no student with '|| 'student id 123');
END;
--------------------------------------------------------------------------------
DECLARE
  v_name  VARCHAR2(50);
  v_total NUMBER;
BEGIN
  SELECT i.first_name
    ||' '
    ||i.last_name,
    COUNT(*)
  INTO v_name,
    v_total
  FROM instructor i,
    section s
  WHERE i.instructor_id = s.instructor_id
  AND i.instructor_id   = 102
  GROUP BY i.first_name
    ||' '
    ||i.last_name;
  DBMS_OUTPUT.PUT_LINE ('Instructor '||v_name||' teaches '||v_total||' courses');
EXCEPTION
WHEN NO_DATA_FOUND THEN
  DBMS_OUTPUT.PUT_LINE ('There is no such instructor');
END;
--------------------------------------------------------------------------------
DECLARE
  v_student_id NUMBER := &sv_student_id;
  v_first_name VARCHAR2(35);
  v_last_name  VARCHAR2(35);
BEGIN
  SELECT first_name,
    last_name
  INTO v_first_name,
    v_last_name
  FROM student
  WHERE student_id = v_student_id;
  DBMS_OUTPUT.PUT_LINE ('Student name: '||v_first_name||' '|| v_last_name);
EXCEPTION
WHEN NO_DATA_FOUND THEN
  DBMS_OUTPUT.PUT_LINE ('There is no such student');
END;
--------------------------------------------------------------------------------
BEGIN
  DBMS_OUTPUT.PUT_LINE ('Today is '||'&sv_day');
  DBMS_OUTPUT.PUT_LINE ('Tomorrow will be '||'&sv_day');
END;
--------------------------------------------------------------------------------
----1 kere yaz defalarca çalistir....
BEGIN
  DBMS_OUTPUT.PUT_LINE ('Today is '||'&&sv_day');
  DBMS_OUTPUT.PUT_LINE ('Tomorrow will be '||'&sv_day');
END;
-------------------------------------------------------------------------------
SET SERVEROUTPUT ON
DECLARE
  v_num    NUMBER := &sv_num;
  v_result NUMBER;
BEGIN
  v_result := POWER(v_num, 2);
  DBMS_OUTPUT.PUT_LINE ('The value of v_result is: '|| V_RESULT);
END;
--------------------------------------------------------------------------------
SET SERVEROUTPUT ON
DECLARE
  v_day VARCHAR2(20);
BEGIN
  v_day := TO_CHAR(SYSDATE, 'Day');
  DBMS_OUTPUT.PUT_LINE ('Today is '||v_day);
END;
--------------------------------------------------------------------------------
SET SERVEROUTPUT ON
DECLARE
  v_day VARCHAR2(20);
BEGIN
  v_day := TO_CHAR(SYSDATE, 'Day, HH24:MI');
  DBMS_OUTPUT.PUT_LINE ('Today is '|| v_day);
END;
--------------------------------------------------------------------------------
SET SERVEROUTPUT ON
DECLARE
  v_radius NUMBER := &sv_radius;
  v_area   NUMBER;
BEGIN
  v_area := POWER(v_radius, 2) * 3.14;
  DBMS_OUTPUT.PUT_LINE ('The area of the circle is: '||v_area);
END;
-----------------------------------------------------------------------------------
SET SERVEROUTPUT ON
DECLARE
  v_day VARCHAR2(20);
BEGIN
  v_day := TO_CHAR(SYSDATE, 'fmDay, HH24:MI');
  DBMS_OUTPUT.PUT_LINE ('Today is '|| v_day);
END;
-----------------------------------------------------------------------------------
