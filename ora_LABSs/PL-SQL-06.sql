
BEGIN
  DBMS_OUTPUT.PUT_LINE ('Line 1');
  RETURN;
  DBMS_OUTPUT.PUT_LINE ('Line 2');
END;


--------------------------------------------------------------------------


DECLARE
  v_counter NUMBER := 0;
BEGIN
  LOOP
    DBMS_OUTPUT.PUT_LINE ('v_counter = '||v_counter);
    EXIT;
  END LOOP;
END;



--------------------------------------------------------------------------





SET SERVEROUTPUT ON
DECLARE
  v_counter BINARY_INTEGER := 0;
BEGIN
  LOOP
    -- increment loop counter by one
    v_counter := v_counter + 1;
    DBMS_OUTPUT.PUT_LINE ('v_counter = '||v_counter);
    -- if EXIT condition yields TRUE exit the loop
    IF v_counter = 5 THEN
      EXIT;
    END IF;
  END LOOP;
  -- control resumes here
  DBMS_OUTPUT.PUT_LINE ('Done...');
END;


--------------------------------------------------------------------------


SET SERVEROUTPUT ON
DECLARE
  v_counter BINARY_INTEGER := 0;
BEGIN
  LOOP
    -- increment loop counter by one
    v_counter := v_counter + 1;
    DBMS_OUTPUT.PUT_LINE ('v_counter = '||v_counter);
    -- if EXIT WHEN condition yields TRUE exit the loop
    EXIT WHEN v_counter = 5;
  END LOOP;
  -- control resumes here
  DBMS_OUTPUT.PUT_LINE ('Done...');
END;



--------------------------------------------------------------------------



SET SERVEROUTPUT ON
DECLARE
  v_course course.course_no%type                := 430;
  v_instructor_id instructor.instructor_id%type := 102;
  v_sec_num section.section_no%type             := 0;
BEGIN
  LOOP
    -- increment section number by one
    v_sec_num := v_sec_num + 1;
    INSERT
    INTO section
      (
        section_id,
        course_no,
        section_no,
        instructor_id,
        created_date,
        created_by,
        modified_date,
        modified_by
      )
      VALUES
      (
        section_id_seq.nextval,
        v_course,
        v_sec_num,
        v_instructor_id,
        SYSDATE,
        USER,
        SYSDATE,
        USER
      );
    -- if number of sections added is four exit the loop
    EXIT WHEN v_sec_num = 4;
  END LOOP;
  -- control resumes here
 -- COMMIT;
END;


----------------------------------------------------------------------------------------------

DECLARE
  v_counter NUMBER := 5;
BEGIN
  WHILE v_counter < 5
  LOOP
    DBMS_OUTPUT.PUT_LINE ('v_counter = '||v_counter);
    -- decrement the value of v_counter by one
    v_counter := v_counter - 1;
  END LOOP;
END;




--------------------------------------------------------------------------



DECLARE
  v_counter NUMBER := 1;
BEGIN
  WHILE v_counter < 5
  LOOP
    DBMS_OUTPUT.PUT_LINE('v_counter = '||v_counter);
    v_counter := v_counter + 1;
  END LOOP;
END;



--------------------------------------------------------------------------


DECLARE
  v_counter NUMBER := 1;
BEGIN
  WHILE v_counter <= 5
  LOOP
    DBMS_OUTPUT.PUT_LINE ('v_counter = '||v_counter);
    IF v_counter = 2 THEN
      EXIT;
    END IF;
    v_counter := v_counter + 1;
  END LOOP;
END;



--------------------------------------------------------------------------


DECLARE
  v_counter NUMBER := 1;
BEGIN
  WHILE v_counter <= 2
  LOOP
    DBMS_OUTPUT.PUT_LINE ('v_counter = '||v_counter);
    v_counter   := v_counter + 1;
    IF v_counter = 5 THEN
      EXIT;
    END IF;
  END LOOP;
END;


--------------------------------------------------------------------------


SET SERVEROUTPUT ON
DECLARE
  v_counter BINARY_INTEGER := 1;
  v_sum NUMBER             := 0;
BEGIN
  WHILE v_counter <= 10
  LOOP
    v_sum := v_sum + v_counter;
    DBMS_OUTPUT.PUT_LINE ('Current sum is: '||v_sum);
    -- increment loop counter by one
    v_counter := v_counter + 1;
  END LOOP;
  -- control resumes here
  DBMS_OUTPUT.PUT_LINE ('The sum of integers between 1 '|| 'and 10 is: '||V_SUM);
END;


--------------------------------------------------------------------------


SET SERVEROUTPUT ON
DECLARE
  v_counter BINARY_INTEGER := 2;
  v_sum NUMBER             := 0;
BEGIN
  WHILE v_counter <= 100
  LOOP
    v_sum := v_sum + v_counter;
    DBMS_OUTPUT.PUT_LINE ('Current sum is: '||v_sum);
    -- increment loop counter by two
    v_counter := v_counter + 2;
  END LOOP;
  -- control resumes here
  DBMS_OUTPUT.PUT_LINE ('The sum of even integers between '|| '1 and 100 is: '||V_SUM);
END;

---------------------------------------------------------------------------------------------


BEGIN
  FOR v_counter IN 1..5
  LOOP
    DBMS_OUTPUT.PUT_LINE ('v_counter = '||v_counter);
  END LOOP;
END;



--------------------------------------------------------------------------



BEGIN
  FOR v_counter IN REVERSE 1..5
  LOOP
    DBMS_OUTPUT.PUT_LINE ('v_counter = '||v_counter);
  END LOOP;
END;


--------------------------------------------------------------------------


BEGIN
  FOR v_counter IN 1..5
  LOOP
    DBMS_OUTPUT.PUT_LINE ('v_counter = '||v_counter);
    EXIT WHEN v_counter = 3;
  END LOOP;
END;


--------------------------------------------------------------------------


SET SERVEROUTPUT ON
DECLARE
  v_factorial NUMBER := 1;
BEGIN
  FOR v_counter IN 1..10
  LOOP
    v_factorial := v_factorial * v_counter;
  END LOOP;
  -- control resumes here
  DBMS_OUTPUT.PUT_LINE ('Factorial of ten is: '||V_FACTORIAL);
END;


--------------------------------------------------------------------------


SET SERVEROUTPUT ON
BEGIN
  FOR v_counter IN REVERSE 0..10
  LOOP
    -- if v_counter is even, display its value on the
    -- screen
    IF MOD(v_counter, 2) = 0 THEN
      DBMS_OUTPUT.PUT_LINE ('v_counter = '||v_counter);
    END IF;
  END LOOP;
  -- control resumes here
  DBMS_OUTPUT.PUT_LINE ('Done...');
END;


--------------------------------------------------------------------------

SET SERVEROUTPUT ON
DECLARE
  v_counter BINARY_INTEGER := 0;
BEGIN
  LOOP
    -- increment loop counter by one
    v_counter := v_counter + 1;
    DBMS_OUTPUT.PUT_LINE ('v_counter = '||v_counter);
    -- if EXIT condition yields TRUE exit the loop
    IF v_counter = 5 THEN
      EXIT;
    END IF;
  END LOOP;
  -- control resumes here
  DBMS_OUTPUT.PUT_LINE ('Done...');
END;


--------------------------------------------------------------------------


SET SERVEROUTPUT ON
DECLARE
  v_counter BINARY_INTEGER := 0;
BEGIN
  WHILE v_counter < 5
  LOOP
    -- increment loop counter by one
    v_counter := v_counter + 1;
    DBMS_OUTPUT.PUT_LINE ('v_counter = '||v_counter);
  END LOOP;
  -- control resumes here
  DBMS_OUTPUT.PUT_LINE('Done...');
END;


--------------------------------------------------------------------------


SET SERVEROUTPUT ON
DECLARE
  v_counter BINARY_INTEGER := 1;
  v_sum NUMBER             := 0;
BEGIN
  WHILE v_counter <= 10
  LOOP
    v_sum := v_sum + v_counter;
    DBMS_OUTPUT.PUT_LINE ('Current sum is: '||v_sum);
    -- increment loop counter by one
    v_counter := v_counter + 1;
  END LOOP;
  -- control resumes here
  DBMS_OUTPUT.PUT_LINE ('The sum of integers between 1 '|| 'and 10 is: '||v_sum);
END;


--------------------------------------------------------------------------


SET SERVEROUTPUT ON
DECLARE
  v_sum NUMBER := 0;
BEGIN
  FOR v_counter IN 1..10
  LOOP
    v_sum := v_sum + v_counter;
    DBMS_OUTPUT.PUT_LINE ('Current sum is: '||v_sum);
  END LOOP;
  -- control resumes here
  DBMS_OUTPUT.PUT_LINE ('The sum of integers between 1 '|| 'and 10 is: '||v_sum);
END;



--------------------------------------------------------------------------


SET SERVEROUTPUT ON
DECLARE
  v_factorial NUMBER := 1;
BEGIN
  FOR v_counter IN 1..10
  LOOP
    v_factorial := v_factorial * v_counter;
  END LOOP;
  DBMS_OUTPUT.PUT_LINE ('Factorial of ten is: '||v_factorial);
END;


--------------------------------------------------------------------------


SET SERVEROUTPUT ON
DECLARE
  v_counter   NUMBER := 1;
  v_factorial NUMBER := 1;
BEGIN
  LOOP
    v_factorial := v_factorial * v_counter;
    v_counter   := v_counter   + 1;
    EXIT
  WHEN v_counter = 10;
  END LOOP;
  -- control resumes here
  DBMS_OUTPUT.PUT_LINE ('Factorial of ten is: '||v_factorial);
END;



















