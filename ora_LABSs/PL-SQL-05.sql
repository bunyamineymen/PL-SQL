
SET SERVEROUTPUT ON
DECLARE
  v_num      NUMBER := &sv_user_num;
  v_num_flag NUMBER;
BEGIN
  v_num_flag := MOD(v_num,2);
  -- test if the number provided by the user is even
  CASE v_num_flag
  WHEN 0 THEN
    DBMS_OUTPUT.PUT_LINE (V_NUM||'  IS even number');
  ELSE
    DBMS_OUTPUT.PUT_LINE (v_num||'  IS odd number');
  END CASE;
  DBMS_OUTPUT.PUT_LINE ('Done');
END;

---------------------------------------------------------------------------------------------

DECLARE
  v_num NUMBER := &sv_user_num;
BEGIN
  -- test if the number provided by the user is even
  CASE
  WHEN MOD(v_num,2) = 0 THEN
    DBMS_OUTPUT.PUT_LINE (v_num||' is even number');
  ELSE
    DBMS_OUTPUT.PUT_LINE (v_num||' is odd number');
  END CASE;
  DBMS_OUTPUT.PUT_LINE ('Done');
END;

---------------------------------------------------------------------------------------------

DECLARE
  V_NUM      NUMBER := &SV_NUM;
  v_num_flag NUMBER ;              --BOOLEAN   --TRUE
BEGIN
  CASE v_num_flag
  WHEN MOD(v_num,2) = 0 THEN
    DBMS_OUTPUT.PUT_LINE (v_num||' is even number');
  ELSE
    DBMS_OUTPUT.PUT_LINE (v_num||' is odd number');
  END CASE;
  DBMS_OUTPUT.PUT_LINE ('Done');
END;

---------------------------------------------------------------------------------------------

SET SERVEROUTPUT ON
DECLARE
  v_date DATE := TO_DATE('&sv_user_date', 'DD-MON-YYYY');
  v_day  VARCHAR2(1);
BEGIN
  v_day := TO_CHAR(v_date, 'D');
  CASE v_day
  WHEN '1' THEN
    DBMS_OUTPUT.PUT_LINE ('Today is Sunday');
  WHEN '2' THEN
    DBMS_OUTPUT.PUT_LINE ('Today is Monday');
  WHEN '3' THEN
    DBMS_OUTPUT.PUT_LINE ('Today is Tuesday');
  WHEN '4' THEN
    DBMS_OUTPUT.PUT_LINE ('Today is Wednesday');
  WHEN '5' THEN
    DBMS_OUTPUT.PUT_LINE ('Today is Thursday');
  WHEN '6' THEN
    DBMS_OUTPUT.PUT_LINE ('Today is Friday');
  WHEN '7' THEN
    DBMS_OUTPUT.PUT_LINE ('Today is Saturday');
  END CASE;
END;


---------------------------------------------------------------------------------------------


SET SERVEROUTPUT ON
DECLARE
  v_date DATE := TO_DATE('&sv_user_date', 'DD-MON-YYYY');
BEGIN
  CASE
  WHEN TO_CHAR(v_date, 'D') = '1' THEN
    DBMS_OUTPUT.PUT_LINE ('Today is Sunday');
  WHEN TO_CHAR(v_date, 'D') = '2' THEN
    DBMS_OUTPUT.PUT_LINE ('Today is Monday');
  WHEN TO_CHAR(v_date, 'D') = '3' THEN
    DBMS_OUTPUT.PUT_LINE ('Today is Tuesday');
  WHEN TO_CHAR(v_date, 'D') = '4' THEN
    DBMS_OUTPUT.PUT_LINE ('Today is Wednesday');
  WHEN TO_CHAR(v_date, 'D') = '5' THEN
    DBMS_OUTPUT.PUT_LINE ('Today is Thursday');
  WHEN TO_CHAR(v_date, 'D') = '6' THEN
    DBMS_OUTPUT.PUT_LINE ('Today is Friday');
  WHEN TO_CHAR(v_date, 'D') = '7' THEN
    DBMS_OUTPUT.PUT_LINE ('Today is Saturday');
  END CASE;
END;

---------------------------------------------------------------------------------------------

SET SERVEROUTPUT ON
DECLARE
  v_student_id   NUMBER := 102;
  v_section_id   NUMBER := 89;
  v_final_grade  NUMBER;
  v_letter_grade CHAR(1);
BEGIN
  SELECT final_grade
  INTO v_final_grade
  FROM enrollment
  WHERE student_id = v_student_id
  AND section_id   = v_section_id;
  CASE
  WHEN v_final_grade >= 90 THEN
    v_letter_grade   := 'A';
  WHEN v_final_grade >= 80 THEN
    v_letter_grade   := 'B';
  WHEN v_final_grade >= 70 THEN
    v_letter_grade   := 'C';
  WHEN v_final_grade >= 60 THEN
    v_letter_grade   := 'D';
  ELSE
    v_letter_grade := 'F';
  END CASE;
  -- control resumes here
  DBMS_OUTPUT.PUT_LINE ('Letter grade is: '||V_LETTER_GRADE);
END;


---------------------------------------------------------------------------------------------

SET SERVEROUTPUT ON
DECLARE
  v_student_id   NUMBER := &sv_student_id;
  v_section_id   NUMBER := 89;
  v_final_grade  NUMBER;
  v_letter_grade CHAR(1);
BEGIN
  SELECT final_grade
  INTO v_final_grade
  FROM enrollment
  WHERE student_id = v_student_id
  AND section_id   = v_section_id;
  CASE -- outer CASE
  WHEN v_final_grade IS NULL THEN
    DBMS_OUTPUT.PUT_LINE ('There is no final grade.');
  ELSE
    CASE -- inner CASE
    WHEN v_final_grade >= 90 THEN
      v_letter_grade   := 'A';
    WHEN v_final_grade >= 80 THEN
      v_letter_grade   := 'B';
    WHEN v_final_grade >= 70 THEN
      v_letter_grade   := 'C';
    WHEN v_final_grade >= 60 THEN
      v_letter_grade   := 'D';
    ELSE
      v_letter_grade := 'F';
    END CASE;
    -- control resumes here after inner CASE terminates
    DBMS_OUTPUT.PUT_LINE ('Letter grade is: '||v_letter_grade);
  END CASE;
  -- control resumes here after outer CASE terminates
END;


---------------------------------------------------------------------------------------------


DECLARE
  v_num      NUMBER := &sv_user_num;
  v_num_flag NUMBER;
  v_result   VARCHAR2(30);
BEGIN
  v_num_flag := MOD(v_num,2);
  v_result   :=
  CASE v_num_flag
  WHEN 0 THEN
    v_num||' is even number'
  ELSE
    v_num||' is odd number'
  END;
  DBMS_OUTPUT.PUT_LINE (v_result);
  DBMS_OUTPUT.PUT_LINE ('Done');
END;


---------------------------------------------------------------------------------------------


DECLARE
  v_course_no   NUMBER;
  v_description VARCHAR2(50);
  v_prereq      VARCHAR2(35);
BEGIN
  SELECT course_no,
    description,
    CASE
      WHEN prerequisite IS NULL
      THEN 'No prerequisite course required'
      ELSE TO_CHAR(prerequisite)
    END prerequisite
  INTO v_course_no,
    v_description,
    v_prereq
  FROM course
  WHERE course_no = 20;
  DBMS_OUTPUT.PUT_LINE ('Course: '||v_course_no);
  DBMS_OUTPUT.PUT_LINE ('Description: '||v_description);
  DBMS_OUTPUT.PUT_LINE ('Prerequisite: '||V_PREREQ);
END;


---------------------------------------------------------------------------------------------


SET SERVEROUTPUT ON
DECLARE
  v_student_id   NUMBER := 102;
  v_section_id   NUMBER := 89;
  v_final_grade  NUMBER;
  v_letter_grade CHAR(1);
BEGIN
  SELECT final_grade
  INTO v_final_grade
  FROM enrollment
  WHERE student_id = v_student_id
  AND SECTION_ID   = V_SECTION_ID;
  
  v_letter_grade  :=
  CASE
  WHEN V_FINAL_GRADE >= 90 THEN 'A'
  WHEN v_final_grade >= 80 THEN 'B'
  WHEN v_final_grade >= 70 THEN 'C'
  WHEN v_final_grade >= 60 THEN 'D'
  ELSE 'F'
  END;
  -- control resumes here
  DBMS_OUTPUT.PUT_LINE ('Letter grade is: '||V_LETTER_GRADE);
END;


---------------------------------------------------------------------------------------------

SET SERVEROUTPUT ON
DECLARE
  v_student_id   NUMBER := 102;
  v_section_id   NUMBER := 89;
  v_letter_grade CHAR(1);
BEGIN
  SELECT
    CASE
      WHEN final_grade >= 90
      THEN 'A'
      WHEN final_grade >= 80
      THEN 'B'
      WHEN final_grade >= 70
      THEN 'C'
      WHEN final_grade >= 60
      THEN 'D'
      ELSE 'F'
    END
  INTO v_letter_grade
  FROM enrollment
  WHERE student_id = v_student_id
  AND section_id   = v_section_id;
  -- control resumes here
  DBMS_OUTPUT.PUT_LINE ('Letter grade is: '||V_LETTER_GRADE);
END;


----------------------------------------------------------------------------------


DECLARE
  v_num       NUMBER := &sv_user_num;
  v_remainder NUMBER;
BEGIN
  -- calculate the remainder and if it is zero return NULL
  v_remainder := NULLIF(MOD(v_num,2),0);
  DBMS_OUTPUT.PUT_LINE ('v_remainder: '||V_REMAINDER);
END;


--COLAESCE
SELECT e.student_id,
  e.section_id,
  e.final_grade,
  g.numeric_grade,
  COALESCE(e.final_grade, g.numeric_grade, 0) grade
FROM enrollment e,
  grade g
WHERE e.student_id    = g.student_id
AND e.section_id      = g.section_id
AND E.STUDENT_ID      = 102
AND g.grade_type_code = 'FI';


---------------------------------------------------------------------------------------------


SET SERVEROUTPUT ON
DECLARE
  v_final_grade NUMBER;
BEGIN
  SELECT
    CASE
      WHEN e.final_grade = g.numeric_grade
      THEN NULL
      ELSE g.numeric_grade
    END
  INTO v_final_grade
  FROM enrollment e
  JOIN grade g
  ON (e.student_id      = g.student_id
  AND e.section_id      = g.section_id)
  WHERE e.student_id    = 102
  AND e.section_id      = 86
  AND g.grade_type_code = 'FI';
  DBMS_OUTPUT.PUT_LINE ('Final grade: '||V_FINAL_GRADE);
END;


---------------------------------------------------------------------------------------------


SET SERVEROUTPUT ON
DECLARE
  v_final_grade NUMBER;
BEGIN
  SELECT NULLIF(g.numeric_grade, e.final_grade)
  INTO v_final_grade
  FROM enrollment e
  JOIN grade g
  ON (e.student_id      = g.student_id
  AND e.section_id      = g.section_id)
  WHERE e.student_id    = 102
  AND e.section_id      = 86
  AND g.grade_type_code = 'FI';
  DBMS_OUTPUT.PUT_LINE ('Final grade: '||v_final_grade);
END;


---------------------------------------------------------------------------------------------


SET SERVEROUTPUT ON
DECLARE
  v_num1   NUMBER := &sv_num1;
  v_num2   NUMBER := &sv_num2;
  v_num3   NUMBER := &sv_num3;
  v_result NUMBER;
BEGIN
  v_result :=
  CASE
  WHEN v_num1 IS NOT NULL THEN
    v_num1
  ELSE
    CASE
    WHEN v_num2 IS NOT NULL THEN
      v_num2
    ELSE
      v_num3
    END
  END;
  DBMS_OUTPUT.PUT_LINE ('Result: '||V_RESULT);
END;


---------------------------------------------------------------------------------------------


SET SERVEROUTPUT ON
DECLARE
  v_num1   NUMBER := &sv_num1;
  v_num2   NUMBER := &sv_num2;
  v_num3   NUMBER := &sv_num3;
  v_result NUMBER;
BEGIN
  v_result := COALESCE(v_num1, v_num2, v_num3);
  DBMS_OUTPUT.PUT_LINE ('Result: '||v_result);
END;


SET SERVEROUTPUT ON
DECLARE
  v_day  VARCHAR2(15);
  v_time VARCHAR(8);
BEGIN
  v_day  := TO_CHAR(SYSDATE, 'fmDAY');
  v_time := TO_CHAR(SYSDATE, 'HH24:MI');
  IF v_day IN ('SATURDAY', 'SUNDAY') THEN
    DBMS_OUTPUT.PUT_LINE (v_day||', '||v_time);
    IF v_time BETWEEN '12:01' AND '24:00' THEN
      DBMS_OUTPUT.PUT_LINE ('It''s afternoon');
    ELSE
      DBMS_OUTPUT.PUT_LINE ('It''s morning');
    END IF;
  END IF;
  -- control resumes here
  DBMS_OUTPUT.PUT_LINE ('Done...');
END;


---------------------------------------------------------------------------------------------


SET SERVEROUTPUT ON
DECLARE
  v_day  VARCHAR2(15);
  v_time VARCHAR(8);
BEGIN
  v_day  := TO_CHAR(SYSDATE, 'fmDay');
  v_time := TO_CHAR(SYSDATE, 'HH24:MI');
  -- CASE statement
  CASE SUBSTR(v_day, 1, 1)
  WHEN 'S' THEN
    DBMS_OUTPUT.PUT_LINE (v_day||', '||v_time);
    -- searched CASE statement
    CASE
    WHEN v_time BETWEEN '12:01' AND '24:00' THEN
      DBMS_OUTPUT.PUT_LINE ('It''s afternoon');
    ELSE
      DBMS_OUTPUT.PUT_LINE ('It''s morning');
    END CASE;
  ELSE 
    DBMS_OUTPUT.PUT_LINE ('Hafta içi...');
  END CASE;
  -- control resumes here
  DBMS_OUTPUT.PUT_LINE('Done...');
END;


---------------------------------------------------------------------------------------------


SET SERVEROUTPUT ON
DECLARE
  v_instructor_id NUMBER := &sv_instructor_id;
  v_total         NUMBER;
BEGIN
  SELECT COUNT(*)
  INTO v_total
  FROM section
  WHERE instructor_id = v_instructor_id;
  -- check if instructor teaches 3 or more sections
  IF v_total >= 3 THEN
    DBMS_OUTPUT.PUT_LINE ('This instructor needs '|| 'a vacation');
  ELSE
    DBMS_OUTPUT.PUT_LINE ('This instructor teaches '|| v_total||' sections');
  END IF;
  -- control resumes here
  DBMS_OUTPUT.PUT_LINE ('Done...');
END;


---------------------------------------------------------------------------------------------


SET SERVEROUTPUT ON
DECLARE
  v_instructor_id NUMBER := &sv_instructor_id;
  v_total         NUMBER;
BEGIN
  SELECT COUNT(*)
  INTO v_total
  FROM section
  WHERE instructor_id = v_instructor_id;
  -- check if instructor teaches 3 or more sections
  CASE
  WHEN v_total >= 3 THEN
    DBMS_OUTPUT.PUT_LINE ('This instructor needs '|| 'a vacation');
  ELSE
    DBMS_OUTPUT.PUT_LINE ('This instructor teaches '|| v_total||' sections');
  END CASE;
  -- control resumes here
  DBMS_OUTPUT.PUT_LINE ('Done...');
END;

---------------------------------------------------------------------------------------------

SELECT e.student_id,
  e.section_id,
  e.final_grade,
  g.numeric_grade,
  COALESCE(g.numeric_grade, e.final_grade) grade
FROM enrollment e,
  grade g
WHERE e.student_id    = g.student_id
AND e.section_id      = g.section_id
AND e.student_id      = 102
AND G.GRADE_TYPE_CODE = 'FI';


SELECT e.student_id,
  e.section_id,
  e.final_grade,
  g.numeric_grade,
  NULLIF(g.numeric_grade, e.final_grade) grade
FROM enrollment e,
  grade g
WHERE e.student_id    = g.student_id
AND e.section_id      = g.section_id
AND e.student_id      = 102
AND G.GRADE_TYPE_CODE = 'FI';












