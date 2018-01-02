--MODULE 18
-----------


--Bulk SQL
-----------


--The FORALL Statement


CREATE TABLE test (row_num NUMBER, row_text VARCHAR2(10));


DECLARE
  -- Define collection types and variables
TYPE row_num_type
IS
  TABLE OF NUMBER INDEX BY PLS_INTEGER;
TYPE row_text_type
IS
  TABLE OF VARCHAR2(10) INDEX BY PLS_INTEGER;
  row_num_tab row_num_type;
  row_text_tab row_text_type;
  v_total NUMBER;
BEGIN
  -- Populate collections
  FOR i IN 1..10
  LOOP
    row_num_tab(i)  := i;
    row_text_tab(i) := 'row '||i;
  END LOOP;
  -- Populate TEST table
  FORALL i IN 1..10
  INSERT INTO test
    (row_num, row_text
    ) VALUES
    (row_num_tab(i), row_text_tab(i)
    );
  COMMIT;
  -- Check how many rows were inserted in the TEST table
  -- and display it on the screen
  SELECT COUNT(*)
  INTO v_total
  FROM TEST;
  DBMS_OUTPUT.PUT_LINE ('There are '||V_TOTAL||' rows in the TEST table');
END;



--Test tablosuna ilk 100 kay?t FOR ile di?er 100 kay?t FORALL ile kay?t ediliyor
TRUNCATE TABLE test;


DECLARE
  -- Define collection types and variables
TYPE row_num_type
IS
  TABLE OF NUMBER INDEX BY PLS_INTEGER;
TYPE row_text_type
IS
  TABLE OF VARCHAR2(10) INDEX BY PLS_INTEGER;
  row_num_tab row_num_type;
  row_text_tab row_text_type;
  v_total      NUMBER;
  v_start_time INTEGER;
  v_end_time   INTEGER;
BEGIN
  -- Populate collections
  FOR i IN 1..10000
  LOOP
    row_num_tab(i)  := i;
    row_text_tab(i) := 'row '||i;
  END LOOP;
  -- Record start time
  v_start_time := DBMS_UTILITY.GET_TIME;
  -- Insert first 100 rows
  FOR i IN 1..10000
  LOOP
    INSERT INTO test
      (row_num, row_text
      ) VALUES
      (row_num_tab(i), row_text_tab(i)
      );
  END LOOP;
  -- Record end time
  v_end_time := DBMS_UTILITY.GET_TIME;
  -- Calculate and display elapsed time
  DBMS_OUTPUT.PUT_LINE ('Duration of the FOR LOOP: '|| (v_end_time - v_start_time));
  -- Record start time
  v_start_time := DBMS_UTILITY.GET_TIME;
  -- Insert second 100 rows
  FORALL i IN 1..10000
  INSERT INTO test
    (row_num, row_text
    ) VALUES
    (row_num_tab(i), row_text_tab(i)
    );
  -- Record end time
  v_end_time := DBMS_UTILITY.GET_TIME;
  -- Calculate and display elapsed time
  DBMS_OUTPUT.PUT_LINE ('Duration of the FORALL statement: '|| (v_end_time - v_start_time));
  COMMIT;
END;



--SAVE EXCEPTION ile ç?kan hatalarda devam edilmesi

TRUNCATE TABLE TEST;



--1, 5, 7 nolu kay?rlar hata verecek ?ekilde bozuluyor ve hatalar ekranda gösteriliyor
DECLARE
  -- Define collection types and variables
TYPE row_num_type
IS
  TABLE OF NUMBER INDEX BY PLS_INTEGER;
TYPE row_text_type
IS
  TABLE OF VARCHAR2(11) INDEX BY PLS_INTEGER;
  row_num_tab row_num_type;
  row_text_tab row_text_type;
  -- Define user-defined exception and associated Oracle
  -- error number with it
  errors EXCEPTION;
  PRAGMA EXCEPTION_INIT(errors, -24381);
BEGIN
  -- Populate collections
  FOR i IN 1..10
  LOOP
    row_num_tab(i)  := i;
    row_text_tab(i) := 'row '||i;
  END LOOP;
  -- Modify 1, 5, and 7 elements of the V_ROW_TEXT collection
  -- These rows will cause exception in the FORALL statement
  row_text_tab(1) := RPAD(row_text_tab(1), 11, ' ');
  row_text_tab(5) := RPAD(row_text_tab(5), 11, ' ');
  row_text_tab(7) := RPAD(row_text_tab(7), 11, ' ');
  -- Populate TEST table
  FORALL i IN 1..10 SAVE EXCEPTIONS
  INSERT INTO test
    (row_num, row_text
    ) VALUES
    (row_num_tab(i), row_text_tab(i)
    );
  COMMIT;
EXCEPTION
WHEN errors THEN
  -- Display total number of exceptions encountered
  DBMS_OUTPUT.PUT_LINE ('There were '||SQL%BULK_EXCEPTIONS.COUNT||' exceptions');
  -- Display detailed exception information
  FOR i IN 1.. SQL%BULK_EXCEPTIONS.COUNT
  LOOP
    DBMS_OUTPUT.PUT_LINE
    (
      'Record '|| SQL%BULK_EXCEPTIONS(i).error_index||' caused error '||i|| ': '||SQL%BULK_EXCEPTIONS(i).ERROR_CODE||' '|| SQLERRM(-SQL%BULK_EXCEPTIONS(i).ERROR_CODE)
    )
    ;
  END LOOP;
END;



--INDICES OF kullan?m?
--1,5,7  nolu elementler siliniyor
--silinmi? elementleri görmezden gelir, di?erlerini aktar?r
TRUNCATE TABLE TEST;


DECLARE
  -- Define collection types and variables
TYPE row_num_type
IS
  TABLE OF NUMBER INDEX BY PLS_INTEGER;
TYPE row_text_type
IS
  TABLE OF VARCHAR2(10) INDEX BY PLS_INTEGER;
  row_num_tab row_num_type;
  row_text_tab row_text_type;
  v_total NUMBER;
BEGIN
  -- Populate collections
  FOR i IN 1..10
  LOOP
    row_num_tab(i)  := i;
    row_text_tab(i) := 'row '||i;
  END LOOP;
  -- Delete 1, 5, and 7 elements of collections
  row_num_tab.DELETE(1);
  row_text_tab.DELETE(1);
  row_num_tab.DELETE(5);
  row_text_tab.DELETE(5);
  row_num_tab.DELETE(7);
  row_text_tab.DELETE(7);
  -- Populate TEST table
  FORALL i IN INDICES OF row_num_tab
  INSERT INTO test
    (row_num, row_text
    ) VALUES
    (row_num_tab(i), row_text_tab(i)
    );
  COMMIT;
  SELECT COUNT(*) INTO v_total FROM test;
  DBMS_OUTPUT.PUT_LINE ('There are '||V_TOTAL||' rows in the TEST table');
END;



--VALUES OF kullan?m?


--hatalar?n kay?t edilece?i yeni bir tablo olu?turuluyor
--1,5,7 kay?tlar bozuluyor ve hatalar VALUES OF kullan?larak yeni tabloya kaydediliyor
CREATE TABLE TEST_EXC (row_num NUMBER, row_text VARCHAR2(50));


TRUNCATE TABLE TEST;


DECLARE
  -- Define collection types and variables
TYPE row_num_type
IS
  TABLE OF NUMBER INDEX BY PLS_INTEGER;
TYPE row_text_type
IS
  TABLE OF VARCHAR2(11) INDEX BY PLS_INTEGER;
TYPE exc_ind_type
IS
  TABLE OF PLS_INTEGER INDEX BY PLS_INTEGER;
  row_num_tab row_num_type;
  row_text_tab row_text_type;
  exc_ind_tab exc_ind_type;
  -- Define user-defined exception and associated Oracle
  -- error number with it
  errors EXCEPTION;
  PRAGMA EXCEPTION_INIT(errors, -24381);
BEGIN
  -- Populate collections
  FOR i IN 1..10
  LOOP
    row_num_tab(i)  := i;
    row_text_tab(i) := 'row '||i;
  END LOOP;
  -- Modify 1, 5, and 7 elements of the V_ROW_TEXT collection
  -- These rows will cause exception in the FORALL statement
  row_text_tab(1) := RPAD(row_text_tab(1), 11, ' ');
  row_text_tab(5) := RPAD(row_text_tab(5), 11, ' ');
  row_text_tab(7) := RPAD(row_text_tab(7), 11, ' ');
  -- Populate TEST table
  FORALL i IN 1..10 SAVE EXCEPTIONS
  INSERT INTO test
    (row_num, row_text
    ) VALUES
    (row_num_tab(i), row_text_tab(i)
    );
  COMMIT;
EXCEPTION
WHEN errors THEN
  -- Populate V_EXC_IND_TAB collection to be used in the VALUES
  -- OF clause
  FOR i IN 1.. SQL%BULK_EXCEPTIONS.COUNT
  LOOP
    exc_ind_tab ( i ) := SQL%BULK_EXCEPTIONS ( i ) .error_index;
  END LOOP;
  -- Insert records that caused exceptions in the TEST_EXC
  -- table
  FORALL i IN VALUES OF exc_ind_tab
  INSERT
  INTO test_exc
    (
      row_num,
      row_text
    )
    VALUES
    (
      row_num_tab(i),
      row_text_tab(i)
    );
  COMMIT;
END;



--18.1.1 Use the FORALL Statement


--örneklerde kullan?lmak üzere zipcode tablosu ile ayn? yap?da bir tablo olu?turuluyor

CREATE TABLE my_zipcode AS
SELECT *
FROM ZIPCODE
WHERE 1 = 2;



--zipcode tablosunda state CT olan kay?tlar getiriliyor ve olu?turulan index by table larda saklan?yor.
--ard?ndan buradan kay?tlar yeni olu?turulan my_zipcode tablosuna aktar?l?yor
-- ch18_1a.sql, version 1.0
SET SERVEROUTPUT ON
DECLARE
  -- Declare collection types
TYPE string_type
IS
  TABLE OF VARCHAR2(100) INDEX BY PLS_INTEGER;
TYPE date_type
IS
  TABLE OF DATE INDEX BY PLS_INTEGER;
  -- Declare collection variables to be used by the FORALL
  -- statement
  zip_tab string_type;
  city_tab string_type;
  state_tab string_type;
  cr_by_tab string_type;
  cr_date_tab date_type;
  mod_by_tab string_type;
  mod_date_tab date_type;
  v_counter PLS_INTEGER := 0;
  v_total INTEGER       := 0;
BEGIN
  -- Populate individual collections
  FOR rec IN
  (SELECT * FROM zipcode WHERE state = 'CT'
  )
  LOOP
    v_counter               := v_counter + 1;
    zip_tab(v_counter)      := rec.zip;
    city_tab(v_counter)     := rec.city;
    state_tab(v_counter)    := rec.state;
    cr_by_tab(v_counter)    := rec.created_by;
    cr_date_tab(v_counter)  := rec.created_date;
    mod_by_tab(v_counter)   := rec.modified_by;
    mod_date_tab(v_counter) := rec.modified_date;
  END LOOP;
  -- Populate MY_ZIPCODE table
  FORALL i IN 1..zip_tab.COUNT
  INSERT
  INTO my_zipcode
    (
      zip,
      city,
      state,
      created_by,
      created_date,
      modified_by,
      modified_date
    )
    VALUES
    (
      zip_tab(i),
      city_tab(i),
      state_tab(i),
      cr_by_tab(i),
      cr_date_tab(i),
      mod_by_tab(i),
      mod_date_tab(i)
    );
  COMMIT;
  -- Check how many records were added to MY_ZIPCODE table
  SELECT COUNT(*)
  INTO v_total
  FROM my_zipcode
  WHERE state = 'CT';
  DBMS_OUTPUT.PUT_LINE (V_TOTAL||' records were added to MY_ZIPCODE table');
END;


/*
B) Modify the previous version of the script as follows: Select data from the ZIPCODE table for a
different state, such as MA. Modify the selected records so that they will cause various exceptions
in the FORALL statement.Modify the FORALL statement so that it does not fail when an exception
occurs. Finally, display exception details on the screen.
*/


-- ch18_1b.sql, version 2.0
SET SERVEROUTPUT ON
DECLARE
  -- Declare collection types
TYPE string_type
IS
  TABLE OF VARCHAR2(100) INDEX BY PLS_INTEGER;
TYPE date_type
IS
  TABLE OF DATE INDEX BY PLS_INTEGER;
  -- Declare collection variables to be used by the FORALL
  -- statement
  zip_tab string_type;
  city_tab string_type;
  state_tab string_type;
  cr_by_tab string_type;
  cr_date_tab date_type;
  mod_by_tab string_type;
  mod_date_tab date_type;
  v_counter PLS_INTEGER := 0;
  v_total INTEGER       := 0;
  -- Define user-defined exception and associated Oracle
  -- error number with it
  errors EXCEPTION;
  PRAGMA EXCEPTION_INIT(errors, -24381);
BEGIN
  -- Populate individual collections
  FOR rec IN
  (SELECT * FROM zipcode WHERE state = 'MA'
  )
  LOOP
    v_counter               := v_counter + 1;
    zip_tab(v_counter)      := rec.zip;
    city_tab(v_counter)     := rec.city;
    state_tab(v_counter)    := rec.state;
    cr_by_tab(v_counter)    := rec.created_by;
    cr_date_tab(v_counter)  := rec.created_date;
    mod_by_tab(v_counter)   := rec.modified_by;
    mod_date_tab(v_counter) := rec.modified_date;
  END LOOP;
  -- Modify individual collection records to produce various
  -- exceptions
  zip_tab(1)     := NULL;
  city_tab(2)    := RPAD(city_tab(2), 26, ' ');
  state_tab(3)   := SYSDATE;
  cr_by_tab(4)   := RPAD(cr_by_tab(4), 31, ' ');
  cr_date_tab(5) := NULL;
  -- Populate MY_ZIPCODE table
  FORALL i IN 1..zip_tab.COUNT SAVE EXCEPTIONS
  INSERT
  INTO my_zipcode
    (
      zip,
      city,
      state,
      created_by,
      created_date,
      modified_by,
      modified_date
    )
    VALUES
    (
      zip_tab(i),
      city_tab(i),
      state_tab(i),
      cr_by_tab(i),
      cr_date_tab(i),
      mod_by_tab(i),
      mod_date_tab(i)
    );
  COMMIT;
  -- Check how many records were added to MY_ZIPCODE table
  SELECT COUNT(*)
  INTO v_total
  FROM my_zipcode
  WHERE state = 'MA';
  DBMS_OUTPUT.PUT_LINE (v_total||' records were added to MY_ZIPCODE table');
EXCEPTION
WHEN errors THEN
  -- Display total number of exceptions encountered
  DBMS_OUTPUT.PUT_LINE ('There were '||SQL%BULK_EXCEPTIONS.COUNT||' exceptions');
  -- Display detailed exception information
  FOR i IN 1.. SQL%BULK_EXCEPTIONS.COUNT
  LOOP
    DBMS_OUTPUT.PUT_LINE ('Record '|| SQL%BULK_EXCEPTIONS(i).error_index||' caused error '||i|| ': '||SQL%BULK_EXCEPTIONS(i).ERROR_CODE||' '|| SQLERRM(-SQL%BULK_EXCEPTIONS(i).ERROR_CODE));
  END LOOP;
  -- Commit records if any that were inserted successfully
  COMMIT;
END;

---------------------------------------------------------------------------------------------------

/*
C) Modify the previous version of the script as follows:Do not modify records selected from the
ZIPCODE table so that no exceptions are raised. Instead, delete the first three records from each
collection so that they become sparse.Then modify the FORALL statement accordingly.
*/


-- ch18_1c.sql, version 3.0
SET SERVEROUTPUT ON
DECLARE
  -- Declare collection types
TYPE string_type
IS
  TABLE OF VARCHAR2(100) INDEX BY PLS_INTEGER;
TYPE date_type
IS
  TABLE OF DATE INDEX BY PLS_INTEGER;
  -- Declare collection variables to be used by the FORALL
  -- statement
  zip_tab string_type;
  city_tab string_type;
  state_tab string_type;
  cr_by_tab string_type;
  cr_date_tab date_type;
  mod_by_tab string_type;
  mod_date_tab date_type;
  v_counter PLS_INTEGER := 0;
  v_total INTEGER       := 0;
  -- Define user-defined exception and associated Oracle
  -- error number with it
  errors EXCEPTION;
  PRAGMA EXCEPTION_INIT(errors, -24381);
BEGIN
  -- Populate individual collections
  FOR rec IN
  (SELECT * FROM zipcode WHERE state = 'MA'
  )
  LOOP
    v_counter               := v_counter + 1;
    zip_tab(v_counter)      := rec.zip;
    city_tab(v_counter)     := rec.city;
    state_tab(v_counter)    := rec.state;
    cr_by_tab(v_counter)    := rec.created_by;
    cr_date_tab(v_counter)  := rec.created_date;
    mod_by_tab(v_counter)   := rec.modified_by;
    mod_date_tab(v_counter) := rec.modified_date;
  END LOOP;
  -- Delete first 3 records from each collection
  zip_tab.DELETE(1,3);
  city_tab.DELETE(1,3);
  state_tab.DELETE(1,3);
  cr_by_tab.DELETE(1,3);
  cr_date_tab.DELETE(1,3);
  mod_by_tab.DELETE(1,3);
  mod_date_tab.DELETE(1,3);
  -- Populate MY_ZIPCODE table
  FORALL i IN INDICES OF zip_tab SAVE EXCEPTIONS
  INSERT
  INTO my_zipcode
    (
      zip,
      city,
      state,
      created_by,
      created_date,
      modified_by,
      modified_date
    )
    VALUES
    (
      zip_tab(i),
      city_tab(i),
      state_tab(i),
      cr_by_tab(i),
      cr_date_tab(i),
      mod_by_tab(i),
      mod_date_tab(i)
    );
  COMMIT;
  -- Check how many records were added to MY_ZIPCODE table
  SELECT COUNT(*)
  INTO v_total
  FROM my_zipcode
  WHERE state = 'MA';
  DBMS_OUTPUT.PUT_LINE (v_total||' records were added to MY_ZIPCODE table');
EXCEPTION
WHEN errors THEN
  -- Display total number of exceptions encountered
  DBMS_OUTPUT.PUT_LINE ('There were '||SQL%BULK_EXCEPTIONS.COUNT||' exceptions');
  -- Display detailed exception information
  FOR i IN 1.. SQL%BULK_EXCEPTIONS.COUNT
  LOOP
    DBMS_OUTPUT.PUT_LINE ('Record '|| SQL%BULK_EXCEPTIONS(i).error_index||' caused error '||i|| ': '||SQL%BULK_EXCEPTIONS(i).ERROR_CODE||' '|| SQLERRM(-SQL%BULK_EXCEPTIONS(i).ERROR_CODE));
  END LOOP;
  -- Commit records if any that were inserted successfully
  COMMIT;
END;

---------------------------------------------------------------------------------------------------
/*
D) Modify the second version of the script, ch18_1b.sql, as follows: Insert records that cause exceptions
in a different table called MY_ZIPCODE_EXC.
*/


CREATE TABLE MY_ZIPCODE_EXC
  (
    ZIP           VARCHAR2(100),
    CITY          VARCHAR2(100),
    STATE         VARCHAR2(100),
    CREATED_BY    VARCHAR2(100),
    CREATED_DATE  DATE,
    MODIFIED_BY   VARCHAR2(100),
    MODIFIED_DATE DATE
  );


-- ch18_1d.sql, version 4.0
SET SERVEROUTPUT ON
DECLARE
  -- Declare collection types
TYPE string_type
IS
  TABLE OF VARCHAR2(100) INDEX BY PLS_INTEGER;
TYPE date_type
IS
  TABLE OF DATE INDEX BY PLS_INTEGER;
TYPE exc_ind_type
IS
  TABLE OF PLS_INTEGER INDEX BY PLS_INTEGER;
  -- Declare collection variables to be used by the FORALL
  -- statement
  zip_tab string_type;
  city_tab string_type;
  state_tab string_type;
  cr_by_tab string_type;
  cr_date_tab date_type;
  mod_by_tab string_type;
  mod_date_tab date_type;
  exc_ind_tab exc_ind_type;
  v_counter PLS_INTEGER := 0;
  v_total INTEGER       := 0;
  -- Define user-defined exception and associated Oracle
  -- error number with it
  errors EXCEPTION;
  PRAGMA EXCEPTION_INIT(errors, -24381);
BEGIN
  -- Populate individual collections
  FOR rec IN
  (SELECT * FROM zipcode WHERE state = 'MA'
  )
  LOOP
    v_counter               := v_counter + 1;
    zip_tab(v_counter)      := rec.zip;
    city_tab(v_counter)     := rec.city;
    state_tab(v_counter)    := rec.state;
    cr_by_tab(v_counter)    := rec.created_by;
    cr_date_tab(v_counter)  := rec.created_date;
    mod_by_tab(v_counter)   := rec.modified_by;
    mod_date_tab(v_counter) := rec.modified_date;
  END LOOP;
  -- Modify individual collection records to produce various
  -- exceptions
  zip_tab(1)     := NULL;
  city_tab(2)    := RPAD(city_tab(2), 26, ' ');
  state_tab(3)   := SYSDATE;
  cr_by_tab(4)   := RPAD(cr_by_tab(4), 31, ' ');
  cr_date_tab(5) := NULL;
  -- Populate MY_ZIPCODE table
  FORALL i IN 1..zip_tab.COUNT SAVE EXCEPTIONS
  INSERT
  INTO my_zipcode
    (
      zip,
      city,
      state,
      created_by,
      created_date,
      modified_by,
      modified_date
    )
    VALUES
    (
      zip_tab(i),
      city_tab(i),
      state_tab(i),
      cr_by_tab(i),
      cr_date_tab(i),
      mod_by_tab(i),
      mod_date_tab(i)
    );
  COMMIT;
  -- Check how many records were added to MY_ZIPCODE table
  SELECT COUNT(*)
  INTO v_total
  FROM my_zipcode
  WHERE state = 'MA';
  DBMS_OUTPUT.PUT_LINE (v_total||' records were added to MY_ZIPCODE table');
EXCEPTION
WHEN errors THEN
  -- Populate V_EXC_IND_TAB collection to be used in the VALUES
  -- OF clause
  FOR i IN 1.. SQL%BULK_EXCEPTIONS.COUNT
  LOOP
    exc_ind_tab(i) := SQL%BULK_EXCEPTIONS(i).error_index;
  END LOOP;
  -- Insert records that caused exceptions in the MY_ZIPCODE_EXC
  -- table
  FORALL i IN VALUES OF exc_ind_tab
  INSERT
  INTO my_zipcode_exc
    (
      zip,
      city,
      state,
      created_by,
      created_date,
      modified_by,
      modified_date
    )
    VALUES
    (
      zip_tab(i),
      city_tab(i),
      state_tab(i),
      cr_by_tab(i),
      cr_date_tab(i),
      mod_by_tab(i),
      mod_date_tab(i)
    );
  COMMIT;
END;

-----------------------------------------------------------------------------------------------



--The BULK COLLECT Clause


--normal cursor kullan?ld???nda tek tek sat?rlar getiriliyor
DECLARE
  CURSOR student_cur
  IS
    SELECT student_id, first_name, last_name FROM student;
BEGIN
  FOR rec IN student_cur
  LOOP
    DBMS_OUTPUT.PUT_LINE ('student_id: '||rec.student_id);
    DBMS_OUTPUT.PUT_LINE ('first_name: '||rec.first_name);
    DBMS_OUTPUT.PUT_LINE ('last_name: '||rec.last_name);
  END LOOP;
END;

---------------------------------------------------------------------------------------------------

--BULK COLLECT ile kullan?m?
--collection olu?turuluyor. Kay?tlar BULK COLLECT ile aktar?l?yor
--tek seferde getiriliyor
DECLARE
  -- Define collection type and variables to be used by the
  -- BULK COLLECT clause
TYPE student_id_type
IS
  TABLE OF student.student_id%TYPE;
TYPE first_name_type
IS
  TABLE OF student.first_name%TYPE;
TYPE last_name_type
IS
  TABLE OF student.last_name%TYPE;
  student_id_tab student_id_type;
  first_name_tab first_name_type;
  last_name_tab last_name_type;
BEGIN
  -- Fetch all student data at once via BULK COLLECT clause
  SELECT student_id,
    first_name,
    LAST_NAME 
    BULK COLLECT
    INTO student_id_tab,
    first_name_tab,
    last_name_tab
  FROM student;
  FOR i IN student_id_tab.FIRST..student_id_tab.LAST
  LOOP
    DBMS_OUTPUT.PUT_LINE ('student_id: '||student_id_tab(i));
    DBMS_OUTPUT.PUT_LINE ('first_name: '||first_name_tab(i));
    DBMS_OUTPUT.PUT_LINE ('last_name: '||last_name_tab(i));
  END LOOP;
END;


---------------------------------------------------------------------------------------------------
--LIMIT kullan?m?

DECLARE
  CURSOR student_cur
  IS
    SELECT student_id, first_name, last_name FROM student;
  -- Define collection type and variables to be used by the
  -- BULK COLLECT clause
TYPE student_id_type
IS
  TABLE OF student.student_id%TYPE;
TYPE first_name_type
IS
  TABLE OF student.first_name%TYPE;
TYPE last_name_type
IS
  TABLE OF student.last_name%TYPE;
  student_id_tab student_id_type;
  first_name_tab first_name_type;
  last_name_tab last_name_type;
  -- Define variable to be used by the LIMIT clause
  v_limit PLS_INTEGER := 50;
BEGIN
  OPEN student_cur;
  LOOP
    -- Fetch 50 rows at once
    FETCH student_cur BULK COLLECT
    INTO student_id_tab,
      first_name_tab,
      last_name_tab LIMIT v_limit;
    EXIT
  WHEN student_id_tab.COUNT = 0;
    FOR i IN student_id_tab.FIRST..student_id_tab.LAST
    LOOP
      DBMS_OUTPUT.PUT_LINE ('student_id: '||student_id_tab(i));
      DBMS_OUTPUT.PUT_LINE ('first_name: '||first_name_tab(i));
      DBMS_OUTPUT.PUT_LINE ('last_name: '||last_name_tab(i));
    END LOOP;
  END LOOP;
  CLOSE STUDENT_CUR;
END;


--INSERT, UPDATE, DELETE ile beraber BULK COLLECT ve RETURNING kullan?m?

---------------------------------------------------------------------------------------------------
--silinen kay?tlarRETURNING ve BULK COLLECT INTO ile collection içine aktar?l?yor ve ekranda gösteriliyor
DECLARE
  -- Define collection types and variables
TYPE row_num_type
IS
  TABLE OF NUMBER INDEX BY PLS_INTEGER;
TYPE row_text_type
IS
  TABLE OF VARCHAR2(10) INDEX BY PLS_INTEGER;
  row_num_tab row_num_type;
  row_text_tab row_text_type;
BEGIN
  DELETE
  FROM TEST RETURNING row_num,
    row_text BULK COLLECT
  INTO row_num_tab,
    row_text_tab;
  DBMS_OUTPUT.PUT_LINE ('Deleted '||SQL%ROWCOUNT ||' rows:');
  FOR i IN row_num_tab.FIRST..row_num_tab.LAST
  LOOP
    DBMS_OUTPUT.PUT_LINE ('row_num = '||row_num_tab(i)|| ' row_text = ' ||row_text_tab(i));
  END LOOP;
  COMMIT;
END;
---------------------------------------------------------------------------------------------------
DECLARE
  -- Declare collection types
TYPE string_type
IS
  TABLE OF VARCHAR2(100) INDEX BY PLS_INTEGER;
TYPE date_type
IS
  TABLE OF DATE INDEX BY PLS_INTEGER;
  -- Declare collection variables to be used by the FORALL statement
  zip_tab string_type;
  city_tab string_type;
  state_tab string_type;
  cr_by_tab string_type;
  cr_date_tab date_type;
  mod_by_tab string_type;
  mod_date_tab date_type;
  v_counter PLS_INTEGER := 0;
  v_total INTEGER       := 0;
BEGIN
  -- Populate individual collections
  SELECT * BULK COLLECT
  INTO zip_tab,
    city_tab,
    state_tab,
    cr_by_tab,
    cr_date_tab,
    mod_by_tab,
    mod_date_tab
  FROM zipcode
  WHERE state = 'CT';
  -- Populate MY_ZIPCODE table
  FORALL i IN 1..zip_tab.COUNT
  INSERT
  INTO my_zipcode
    (
      zip,
      city,
      state,
      created_by,
      created_date,
      modified_by,
      modified_date
    )
    VALUES
    (
      zip_tab(i),
      city_tab(i),
      state_tab(i),
      cr_by_tab(i),
      cr_date_tab(i),
      mod_by_tab(i),
      mod_date_tab(i)
    );
  COMMIT;
  -- Check how many records were added to MY_ZIPCODE table
  SELECT COUNT(*)
  INTO v_total
  FROM my_zipcode
  WHERE state = 'CT';
  DBMS_OUTPUT.PUT_LINE (V_TOTAL||' records were added to MY_ZIPCODE table');
END;


---------------------------------------------------------------------------------------------------

CREATE TABLE my_instructor AS
SELECT * FROM instructor;
---------------------------------------------------------------------------------------------------
SET SERVEROUTPUT ON;
DECLARE
  -- Define collection types and variables to be used by the
  -- BULK COLLECT clause
TYPE instructor_id_type
IS
  TABLE OF my_instructor.instructor_id%TYPE;
TYPE first_name_type
IS
  TABLE OF my_instructor.first_name%TYPE;
TYPE last_name_type
IS
  TABLE OF my_instructor.last_name%TYPE;
  instructor_id_tab instructor_id_type;
  first_name_tab first_name_type;
  last_name_tab last_name_type;
BEGIN
  -- Fetch all instructor data at once via BULK COLLECT clause
  SELECT instructor_id,
    first_name,
    last_name BULK COLLECT
  INTO instructor_id_tab,
    first_name_tab,
    last_name_tab
  FROM my_instructor;
  FOR i IN instructor_id_tab.FIRST..instructor_id_tab.LAST
  LOOP
    DBMS_OUTPUT.PUT_LINE ('instructor_id: '||instructor_id_tab(i));
    DBMS_OUTPUT.PUT_LINE ('first_name: '||first_name_tab(i));
    DBMS_OUTPUT.PUT_LINE ('last_name: '||last_name_tab(i));
  END LOOP;
END;

---------------------------------------------------------------------------------------------------
SET SERVEROUTPUT ON;
DECLARE
  CURSOR instructor_cur
  IS
    SELECT instructor_id, first_name, last_name FROM my_instructor;
  -- Define collection types and variables to be used by the
  -- BULK COLLECT clause
TYPE instructor_id_type
IS
  TABLE OF my_instructor.instructor_id%TYPE;
TYPE first_name_type
IS
  TABLE OF my_instructor.first_name%TYPE;
TYPE last_name_type
IS
  TABLE OF my_instructor.last_name%TYPE;
  instructor_id_tab instructor_id_type;
  first_name_tab first_name_type;
  last_name_tab last_name_type;
  v_limit PLS_INTEGER := 5;
BEGIN
  OPEN instructor_cur;
  LOOP
    -- Fetch partial instructor data at once via BULK COLLECT
    -- clause
    FETCH instructor_cur BULK COLLECT
    INTO instructor_id_tab,
      first_name_tab,
      last_name_tab LIMIT v_limit;
    EXIT
  WHEN instructor_id_tab.COUNT = 0;
    FOR i IN instructor_id_tab.FIRST..instructor_id_tab.LAST
    LOOP
      DBMS_OUTPUT.PUT_LINE ('instructor_id: '||instructor_id_tab(i));
      DBMS_OUTPUT.PUT_LINE ('first_name: '||first_name_tab(i));
      DBMS_OUTPUT.PUT_LINE ('last_name: '||last_name_tab(i));
    END LOOP;
  END LOOP;
  CLOSE instructor_cur;
END;

---------------------------------------------------------------------------------------------------
SET SERVEROUTPUT ON;
DECLARE
  CURSOR instructor_cur
  IS
    SELECT instructor_id, first_name, last_name FROM my_instructor;
  -- Define record type
TYPE instructor_rec
IS
  RECORD
  (
    instructor_id my_instructor.instructor_id%TYPE,
    first_name my_instructor.first_name%TYPE,
    last_name my_instructor.last_name%TYPE);
  -- Define collection type and variable to be used by the
  -- BULK COLLECT clause
TYPE instructor_type
IS
  TABLE OF instructor_rec;
  instructor_tab instructor_type;
  v_limit PLS_INTEGER := 5;
BEGIN
  OPEN instructor_cur;
  LOOP
    -- Fetch partial instructor data at once via BULK COLLECT
    -- clause
    FETCH instructor_cur BULK COLLECT
    INTO instructor_tab LIMIT v_limit;
    EXIT
  WHEN instructor_tab.COUNT = 0;
    FOR i IN instructor_tab.FIRST..instructor_tab.LAST
    LOOP
      DBMS_OUTPUT.PUT_LINE ('instructor_id: '||instructor_tab(i).instructor_id);
      DBMS_OUTPUT.PUT_LINE ('first_name: '||instructor_tab(i).first_name);
      DBMS_OUTPUT.PUT_LINE ('last_name: '||instructor_tab(i).last_name);
    END LOOP;
  END LOOP;
  CLOSE instructor_cur;
END;

---------------------------------------------------------------------------------------------------
SET SERVEROUTPUT ON;
DECLARE
  -- Define collection types and variables to be used by the
  -- BULK COLLECT clause
TYPE instructor_id_type
IS
  TABLE OF my_instructor.instructor_id%TYPE;
TYPE first_name_type
IS
  TABLE OF my_instructor.first_name%TYPE;
TYPE last_name_type
IS
  TABLE OF my_instructor.last_name%TYPE;
  instructor_id_tab instructor_id_type;
  first_name_tab first_name_type;
  last_name_tab last_name_type;
BEGIN
  DELETE
  FROM MY_INSTRUCTOR RETURNING instructor_id,
    first_name,
    last_name BULK COLLECT
  INTO instructor_id_tab,
    first_name_tab,
    last_name_tab;
  DBMS_OUTPUT.PUT_LINE ('Deleted '||SQL%ROWCOUNT||' rows ');
  IF instructor_id_tab.COUNT > 0 THEN
    FOR i IN instructor_id_tab.FIRST..instructor_id_tab.LAST
    LOOP
      DBMS_OUTPUT.PUT_LINE ('instructor_id: '||instructor_id_tab(i));
      DBMS_OUTPUT.PUT_LINE ('first_name: '||first_name_tab(i));
      DBMS_OUTPUT.PUT_LINE ('last_name: '||last_name_tab(i));
    END LOOP;
  END IF;
  COMMIT;
END;

---------------------------------------------------------------------------------------------------

CREATE TABLE my_section AS
SELECT *
FROM section
WHERE 1 = 2;
---------------------------------------------------------------------------------------------------

SET SERVEROUTPUT ON
DECLARE
  -- Declare collection types
TYPE number_type
IS
  TABLE OF NUMBER INDEX BY PLS_INTEGER;
TYPE string_type
IS
  TABLE OF VARCHAR2(100) INDEX BY PLS_INTEGER;
TYPE date_type
IS
  TABLE OF DATE INDEX BY PLS_INTEGER;
  -- Declare collection variables to be used by the FORALL statement
  section_id_tab number_type;
  course_no_tab number_type;
  section_no_tab number_type;
  start_date_time_tab date_type;
  location_tab string_type;
  instructor_id_tab number_type;
  capacity_tab number_type;
  cr_by_tab string_type;
  cr_date_tab date_type;
  mod_by_tab string_type;
  mod_date_tab date_type;
  v_counter PLS_INTEGER := 0;
  v_total INTEGER       := 0;
  -- Define user-defined exception and associated Oracle
  -- error number with it
  errors EXCEPTION;
  PRAGMA EXCEPTION_INIT(errors, -24381);
BEGIN
  -- Populate individual collections
  FOR rec IN
  (SELECT * FROM section
  )
  LOOP
    v_counter                      := v_counter + 1;
    section_id_tab(v_counter)      := rec.section_id;
    course_no_tab(v_counter)       := rec.course_no;
    section_no_tab(v_counter)      := rec.section_no;
    start_date_time_tab(v_counter) := rec.start_date_time;
    location_tab(v_counter)        := rec.location;
    instructor_id_tab(v_counter)   := rec.instructor_id;
    capacity_tab(v_counter)        := rec.capacity;
    cr_by_tab(v_counter)           := rec.created_by;
    cr_date_tab(v_counter)         := rec.created_date;
    mod_by_tab(v_counter)          := rec.modified_by;
    mod_date_tab(v_counter)        := rec.modified_date;
  END LOOP;
  -- Populate MY_SECTION table
  FORALL i IN 1..section_id_tab.COUNT SAVE EXCEPTIONS
  INSERT
  INTO my_section
    (
      section_id,
      course_no,
      section_no,
      start_date_time,
      location,
      instructor_id,
      capacity,
      created_by,
      created_date,
      modified_by,
      modified_date
    )
    VALUES
    (
      section_id_tab(i),
      course_no_tab(i),
      section_no_tab(i),
      start_date_time_tab(i),
      location_tab(i),
      instructor_id_tab(i),
      capacity_tab(i),
      cr_by_tab(i),
      cr_date_tab(i),
      mod_by_tab(i),
      mod_date_tab(i)
    );
  COMMIT;
  -- Check how many records were added to MY_SECTION table
  SELECT COUNT(*)
  INTO v_total
  FROM my_section;
  DBMS_OUTPUT.PUT_LINE (v_total||' records were added to MY_SECTION table');
EXCEPTION
WHEN errors THEN
  -- Display total number of exceptions encountered
  DBMS_OUTPUT.PUT_LINE ('There were '||SQL%BULK_EXCEPTIONS.COUNT||' exceptions');
  -- Display detailed exception information
  FOR i IN 1.. SQL%BULK_EXCEPTIONS.COUNT
  LOOP
    DBMS_OUTPUT.PUT_LINE ('Record '|| SQL%BULK_EXCEPTIONS(i).error_index||' caused error '||i|| ': '||SQL%BULK_EXCEPTIONS(i).ERROR_CODE||' '|| SQLERRM(-SQL%BULK_EXCEPTIONS(i).ERROR_CODE));
  END LOOP;
  -- Commit records if any that were inserted successfully
  COMMIT;
END;


---------------------------------------------------------------------------------------------------


SET SERVEROUTPUT ON
DECLARE
  -- Declare collection types
TYPE number_type
IS
  TABLE OF NUMBER INDEX BY PLS_INTEGER;
TYPE string_type
IS
  TABLE OF VARCHAR2(100) INDEX BY PLS_INTEGER;
TYPE date_type
IS
  TABLE OF DATE INDEX BY PLS_INTEGER;
  -- Declare collection variables to be used by the FORALL statement
  section_id_tab number_type;
  course_no_tab number_type;
  section_no_tab number_type;
  start_date_time_tab date_type;
  location_tab string_type;
  instructor_id_tab number_type;
  capacity_tab number_type;
  cr_by_tab string_type;
  cr_date_tab date_type;
  mod_by_tab string_type;
  mod_date_tab date_type;
  total_recs_tab number_type;
  v_counter PLS_INTEGER := 0;
  v_total INTEGER       := 0;
  -- Define user-defined exception and associated Oracle
  -- error number with it
  errors EXCEPTION;
  PRAGMA EXCEPTION_INIT(errors, -24381);
BEGIN
  -- Populate individual collections
  FOR rec IN
  (SELECT * FROM section
  )
  LOOP
    v_counter                      := v_counter + 1;
    section_id_tab(v_counter)      := rec.section_id;
    course_no_tab(v_counter)       := rec.course_no;
    section_no_tab(v_counter)      := rec.section_no;
    start_date_time_tab(v_counter) := rec.start_date_time;
    location_tab(v_counter)        := rec.location;
    instructor_id_tab(v_counter)   := rec.instructor_id;
    capacity_tab(v_counter)        := rec.capacity;
    cr_by_tab(v_counter)           := rec.created_by;
    cr_date_tab(v_counter)         := rec.created_date;
    mod_by_tab(v_counter)          := rec.modified_by;
    mod_date_tab(v_counter)        := rec.modified_date;
  END LOOP;
  -- Populate MY_SECTION table
  FORALL i IN 1..section_id_tab.COUNT SAVE EXCEPTIONS
  INSERT
  INTO my_section
    (
      section_id,
      course_no,
      section_no,
      start_date_time,
      location,
      instructor_id,
      capacity,
      created_by,
      created_date,
      modified_by,
      modified_date
    )
    VALUES
    (
      section_id_tab(i),
      course_no_tab(i),
      section_no_tab(i),
      start_date_time_tab(i),
      location_tab(i),
      instructor_id_tab(i),
      capacity_tab(i),
      cr_by_tab(i),
      cr_date_tab(i),
      mod_by_tab(i),
      mod_date_tab(i)
    );
  COMMIT;
  -- Check how many records were added to MY_SECTION table
  SELECT COUNT(*)
  INTO v_total
  FROM my_section;
  DBMS_OUTPUT.PUT_LINE (v_total||' records were added to MY_SECTION table');
  -- Check how many records were inserted for each course
  -- and display this information
  -- Fetch data from MY_SECTION table via BULK COLLECT clause
  SELECT course_no,
    COUNT(*) BULK COLLECT
  INTO course_no_tab,
    total_recs_tab
  FROM my_section
  GROUP BY course_no;
  IF course_no_tab.COUNT > 0 THEN
    FOR i IN course_no_tab.FIRST..course_no_tab.LAST
    LOOP
      DBMS_OUTPUT.PUT_LINE ('course_no: '||course_no_tab(i)|| ', total sections: '||total_recs_tab(i));
    END LOOP;
  END IF;
EXCEPTION
WHEN errors THEN
  -- Display total number of exceptions encountered
  DBMS_OUTPUT.PUT_LINE ('There were '||SQL%BULK_EXCEPTIONS.COUNT||' exceptions');
  -- Display detailed exception information
  FOR i IN 1.. SQL%BULK_EXCEPTIONS.COUNT
  LOOP
    DBMS_OUTPUT.PUT_LINE ('Record '|| SQL%BULK_EXCEPTIONS(i).error_index||' caused error '||i|| ': '||SQL%BULK_EXCEPTIONS(i).ERROR_CODE||' '|| SQLERRM(-SQL%BULK_EXCEPTIONS(i).ERROR_CODE));
  END LOOP;
  -- Commit records if any that were inserted successfully
  COMMIT;
END;


---------------------------------------------------------------------------------------------------


SET SERVEROUTPUT ON;
DECLARE
  -- Define collection types and variables to be used by the
  -- BULK COLLECT clause
TYPE section_id_type
IS
  TABLE OF my_section.section_id%TYPE;
  section_id_tab section_id_type;
BEGIN
  FOR rec IN
  (SELECT UNIQUE course_no FROM my_section
  )
  LOOP
    DELETE
    FROM MY_SECTION
    WHERE course_no = rec.course_no RETURNING section_id BULK COLLECT
    INTO section_id_tab;
    DBMS_OUTPUT.PUT_LINE ('Deleted '||SQL%ROWCOUNT|| ' rows for course '||rec.course_no);
    IF section_id_tab.COUNT > 0 THEN
      FOR i IN section_id_tab.FIRST..section_id_tab.LAST
      LOOP
        DBMS_OUTPUT.PUT_LINE ('section_id: '||section_id_tab(i));
      END LOOP;
      DBMS_OUTPUT.PUT_LINE ('===============================');
    END IF;
    COMMIT;
  END LOOP;
END;






