

----------------------------------------------------------------------



SET SERVEROUTPUT ON
DECLARE
  v_counter BINARY_INTEGER := 0;
BEGIN
  LOOP
    -- increment loop counter by one
    v_counter := v_counter + 1;
    DBMS_OUTPUT.PUT_LINE ('before continue condition, v_counter = '|| v_counter);
    -- if CONTINUE condition yields TRUE pass control to the
    -- first executable statement of the loop
    IF v_counter < 3 THEN
      CONTINUE;
    END IF;
    DBMS_OUTPUT.PUT_LINE ('after continue condition, v_counter = '|| v_counter);
    -- if EXIT condition yields TRUE exit the loop
    IF v_counter = 5 THEN
      EXIT;
    END IF;
  END LOOP;
  -- control resumes here
  DBMS_OUTPUT.PUT_LINE ('Done...');
END;




----------------------------------------------------------------------




SET SERVEROUTPUT ON
DECLARE
  v_counter BINARY_INTEGER := 0;
BEGIN
  LOOP
    -- increment loop counter by one
    v_counter := v_counter + 1;
    DBMS_OUTPUT.PUT_LINE ('before continue condition, v_counter = '|| v_counter);
    -- if EXIT condition yields TRUE exit the loop
    IF v_counter = 5 THEN
      EXIT;
    END IF;
    -- if CONTINUE condition yields TRUE pass control to the
    -- first executable statement of the loop
    IF v_counter > 3 THEN
      CONTINUE;
    END IF;
    DBMS_OUTPUT.PUT_LINE ('after continue condition, v_counter = '|| v_counter);
  END LOOP;
  -- control resumes here
  DBMS_OUTPUT.PUT_LINE ('Done...');
END;



----------------------------------------------------------------------


SET SERVEROUTPUT ON
DECLARE
  v_sum NUMBER := 0;
BEGIN
  FOR v_counter IN 1..10
  LOOP
    -- if v_counter is odd, pass control to the top of the loop
    CONTINUE WHEN mod(v_counter, 2) != 0;
    v_sum                := v_sum + v_counter;
    DBMS_OUTPUT.PUT_LINE ('Current sum is: '||v_sum);
  END LOOP;
  -- control resumes here
  DBMS_OUTPUT.PUT_LINE ('Final sum is: '||V_SUM);
END;


----------------------------------------------------------------------


DECLARE
  v_counter1 INTEGER := 0;
  v_counter2 INTEGER;
BEGIN
  WHILE v_counter1 < 3
  LOOP
    DBMS_OUTPUT.PUT_LINE ('v_counter1: '||v_counter1);
    v_counter2 := 0;
    LOOP
      DBMS_OUTPUT.PUT_LINE ('v_counter2: '||v_counter2);
      V_COUNTER2 := V_COUNTER2 + 1;
      EXIT WHEN v_counter2 >= 2;
    END LOOP;
    DBMS_OUTPUT.PUT_LINE ('--------------------');
    v_counter1 := v_counter1 + 1;
  END LOOP;
END;


----------------------------------------------------------------------

BEGIN
  <<outer_loop>>
  FOR i IN 1..3
  LOOP
    DBMS_OUTPUT.PUT_LINE ('i = '||i);
    <<inner_loop>>
    FOR j IN 1..2
    LOOP
      DBMS_OUTPUT.PUT_LINE ('j = '||j);
    END LOOP inner_loop;
  END LOOP OUTER_LOOP;
END;

----------------------------------------------------------------------

BEGIN
  <<OUTER>>
  FOR v_counter IN 1..3
  LOOP
    <<INNER>>
    FOR v_counter IN 1..2
    LOOP
      DBMS_OUTPUT.PUT_LINE ('outer.v_counter '||outer.v_counter);
      DBMS_OUTPUT.PUT_LINE ('inner.v_counter '||inner.v_counter);
    END LOOP INNER;
  END LOOP OUTER;
END;



----------------------------------------------------------------------




SET SERVEROUTPUT ON
DECLARE
  v_test NUMBER := 0;
BEGIN
  <<outer_loop>>
  FOR i IN 1..3
  LOOP
    DBMS_OUTPUT.PUT_LINE('Outer Loop');
    DBMS_OUTPUT.PUT_LINE('i = '||i);
    DBMS_OUTPUT.PUT_LINE('v_test = '||v_test);
    v_test := v_test + 1;
    <<inner_loop>>
    FOR j IN 1..2
    LOOP
      DBMS_OUTPUT.PUT_LINE('Inner Loop');
      DBMS_OUTPUT.PUT_LINE('j = '||j);
      DBMS_OUTPUT.PUT_LINE('i = '||i);
      DBMS_OUTPUT.PUT_LINE('v_test = '||v_test);
    END LOOP inner_loop;
  END LOOP OUTER_LOOP;
END;

----------------------------------------------------------------------

SET SERVEROUTPUT ON
DECLARE
  v_factorial NUMBER := 1;
BEGIN
  FOR v_counter IN 1..10
  LOOP
    v_factorial := v_factorial * v_counter;
  END LOOP;
  -- control resumes here
  DBMS_OUTPUT.PUT_LINE ('Factorial of ten is: '||v_factorial);
END;




----------------------------------------------------------------------



SET SERVEROUTPUT ON
DECLARE
  v_factorial NUMBER := 1;
BEGIN
  FOR v_counter IN 1..10
  LOOP
    CONTINUE WHEN MOD(v_counter, 2) != 0;
    v_factorial          := v_factorial * v_counter;
  END LOOP;
  -- control resumes here
  DBMS_OUTPUT.PUT_LINE ('Factorial of even numbers between 1 and 10 is: '|| v_factorial);
END;


----------------------------------------------------------------------


SET SERVEROUTPUT ON
DECLARE
  v_test NUMBER := 0;
BEGIN
  <<outer_loop>>
  FOR i IN 1..3
  LOOP
    DBMS_OUTPUT.PUT_LINE('Outer Loop');
    DBMS_OUTPUT.PUT_LINE('i = '||i);
    DBMS_OUTPUT.PUT_LINE('v_test = '||v_test);
    v_test := v_test + 1;
    <<inner_loop>>
    FOR j IN 1..2
    LOOP
      DBMS_OUTPUT.PUT_LINE('Inner Loop');
      DBMS_OUTPUT.PUT_LINE('j = '||j);
      DBMS_OUTPUT.PUT_LINE('i = '||i);
      DBMS_OUTPUT.PUT_LINE('v_test = '||v_test);
    END LOOP inner_loop;
  END LOOP outer_loop;
END;



----------------------------------------------------------------------


SET SERVEROUTPUT ON
DECLARE
  i      INTEGER := 1;
  j      INTEGER := 1;
  v_test NUMBER  := 0;
BEGIN
  <<outer_loop>>
  LOOP
    DBMS_OUTPUT.PUT_LINE ('Outer Loop');
    DBMS_OUTPUT.PUT_LINE ('i = '||i);
    DBMS_OUTPUT.PUT_LINE ('v_test = '||v_test);
    v_test := v_test + 1;
    -- reset inner loop counter
    j := 1;
    <<inner_loop>>
    WHILE j <= 2
    LOOP
      DBMS_OUTPUT.PUT_LINE ('Inner Loop');
      DBMS_OUTPUT.PUT_LINE ('j = '||j);
      DBMS_OUTPUT.PUT_LINE ('i = '||i);
      DBMS_OUTPUT.PUT_LINE ('v_test = '||v_test);
      j := j + 1;
    END LOOP inner_loop;
    i := i + 1;
    -- EXIT condition of the outer loop
    EXIT WHEN i > 3;
  END LOOP outer_loop;
END;












