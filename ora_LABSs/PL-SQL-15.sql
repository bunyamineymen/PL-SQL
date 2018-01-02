
----------------------------------------------------------------------------------------
--Collections
--------------
--PL/SQL Tables
--ASSOCIATIVE ARRAYS   Esgüdümlü diziler
DECLARE
TYPE last_name_type
IS
  TABLE OF STUDENT.LAST_NAME%TYPE INDEX BY BINARY_INTEGER;
  
  LAST_NAME_TAB LAST_NAME_TYPE;
  
  
--student tablosundaki 10 ögrencinin soyadi cursor ile index by table'a aktariliyor ve ekranda gösteriliyor
DECLARE
  CURSOR name_cur
  IS
    SELECT last_name FROM student WHERE rownum <= 10;
TYPE last_name_type
IS
  TABLE OF student.last_name%TYPE INDEX BY BINARY_INTEGER;
  last_name_tab last_name_type;
  v_counter INTEGER := 0;
BEGIN
  FOR name_rec IN name_cur
  LOOP
    v_counter                := v_counter + 1;
    last_name_tab(v_counter) := name_rec.last_name;
    DBMS_OUTPUT.PUT_LINE ('last_name('||v_counter||'): '|| last_name_tab(v_counter));
  END LOOP;
END; 

--NESTED TABLES
----------------------------------------------------------------------------------------

DECLARE
  CURSOR name_cur
  IS
    SELECT last_name FROM student WHERE rownum <= 10;
TYPE last_name_type
IS
  TABLE OF student.last_name%TYPE;
  last_name_tab last_name_type;
  v_counter INTEGER := 0;
BEGIN
  FOR name_rec IN name_cur
  LOOP
    v_counter                := v_counter + 1;
    last_name_tab(v_counter) := name_rec.last_name;
    DBMS_OUTPUT.PUT_LINE ('last_name('||v_counter||'): '|| last_name_tab(v_counter));
  END LOOP;
END;


----------------------------------------------------------------------------------------

DECLARE
  CURSOR name_cur
  IS
    SELECT last_name FROM student WHERE rownum <= 10;
TYPE last_name_type
IS
  TABLE OF student.last_name%TYPE;
  last_name_tab last_name_type := last_name_type();
  v_counter INTEGER            := 0;
BEGIN
  FOR name_rec IN name_cur
  LOOP
    v_counter := v_counter + 1;
    last_name_tab.EXTEND;
    last_name_tab(v_counter) := name_rec.last_name;
    DBMS_OUTPUT.PUT_LINE ('last_name('||v_counter||'): '|| last_name_tab(v_counter));
  END LOOP;
END;

----------------------------------------------------------------------------------------

--Collection method kullan?m örnekleri

DECLARE
TYPE index_by_type
IS
  TABLE OF NUMBER INDEX BY BINARY_INTEGER;
  index_by_table index_by_type;
TYPE nested_type
IS
  TABLE OF NUMBER;
  nested_table nested_type := nested_type(1, 2, 3, 4, 5, 6, 7, 8, 9, 10);
BEGIN
  -- Populate index by table
  FOR i IN 1..10
  LOOP
    index_by_table(i) := i;
  END LOOP;
  IF index_by_table.EXISTS(3) THEN
    DBMS_OUTPUT.PUT_LINE ('index_by_table(3) ='||index_by_table(3));
  END IF;
  -- delete 10th element from a collection
  nested_table.DELETE(10);
  -- delete elements 1 through 3 from a collection
  nested_table.DELETE(1,3);
  index_by_table.DELETE(10);
  DBMS_OUTPUT.PUT_LINE ('nested_table.COUNT ='||nested_table.COUNT);
  DBMS_OUTPUT.PUT_LINE ('index_by_table.COUNT = '|| index_by_table.COUNT);
  DBMS_OUTPUT.PUT_LINE ('nested_table.FIRST ='||nested_table.FIRST);
  DBMS_OUTPUT.PUT_LINE ('nested_table.LAST = '||nested_table.LAST);
  DBMS_OUTPUT.PUT_LINE ('index_by_table.FIRST = '|| index_by_table.FIRST);
  DBMS_OUTPUT.PUT_LINE ('index_by_table.LAST ='||index_by_table.LAST);
  DBMS_OUTPUT.PUT_LINE ('nested_table.PRIOR(2) = '|| nested_table. PRIOR(2));
  DBMS_OUTPUT.PUT_LINE ('nested_table.NEXT(2) = '|| nested_table.NEXT(2));
  DBMS_OUTPUT.PUT_LINE ('index_by_table.PRIOR(2) = '|| index_by_table.PRIOR(2));
  DBMS_OUTPUT.PUT_LINE ('index_by_table.NEXT(2) = '|| index_by_table.NEXT(2));
  -- Trim last two elements
  nested_table.TRIM(2);
  -- Trim last element
  nested_table.TRIM;
  DBMS_OUTPUT.PUT_LINE('nested_table.LAST = '||NESTED_TABLE.LAST);
END;
----------------------------------------------------------------------------------------
SET SERVEROUTPUT ON
DECLARE
  CURSOR course_cur
  IS
    SELECT description FROM course;
TYPE course_type
IS
  TABLE OF course.description%TYPE INDEX BY BINARY_INTEGER;
  course_tab course_type;
  v_counter INTEGER := 0;
BEGIN
  FOR course_rec IN course_cur
  LOOP
    v_counter             := v_counter + 1;
    course_tab(v_counter) := course_rec.description;
  END LOOP;
END;


----------------------------------------------------------------------------------------
SET SERVEROUTPUT ON
DECLARE
  CURSOR course_cur
  IS
    SELECT description FROM course;
TYPE course_type
IS
  TABLE OF course.description%TYPE INDEX BY BINARY_INTEGER;
  course_tab course_type;
  v_counter INTEGER := 0;
BEGIN
  FOR course_rec IN course_cur
  LOOP
    v_counter             := v_counter + 1;
    course_tab(v_counter) := course_rec.description;
  END LOOP;
  -- Display the total number of elements in the associative array
  DBMS_OUTPUT.PUT_LINE ('1. Total number of elements: '|| course_tab.COUNT);
  -- Delete the last element of the associative array
  -- Display the total number of elements in the associative array
  course_tab.DELETE(course_tab.LAST);
  DBMS_OUTPUT.PUT_LINE ('2. Total number of elements: '|| course_tab.COUNT);
  -- Delete the fifth element of the associative array
  -- Display the total number of elements in the associative array
  -- Display the subscript of the last element of the associative
  -- array
  course_tab.DELETE(5);
  DBMS_OUTPUT.PUT_LINE ('3. Total number of elements: '|| course_tab.COUNT);
  DBMS_OUTPUT.PUT_LINE ('3. The subscript of the last element: '|| COURSE_TAB.LAST);
END;
----------------------------------------------------------------------------------------
SET SERVEROUTPUT ON
DECLARE
  CURSOR course_cur
  IS
    SELECT description FROM course;
  TYPE course_type
IS
  TABLE OF course.description%TYPE;
  course_tab course_type := course_type();
  v_counter INTEGER      := 0;
BEGIN
  FOR course_rec IN course_cur
  LOOP
    v_counter := v_counter + 1;
    course_tab.EXTEND;
    course_tab(v_counter) := course_rec.description;
  END LOOP;
END;

----------------------------------------------------------------------------------------
--Varrays

--önceki örnek nested table yerine varray ile yaz?l?yor.
DECLARE
  CURSOR name_cur
  IS
    SELECT last_name FROM student WHERE rownum <= 10;
TYPE last_name_type IS VARRAY(10) OF student.last_name%TYPE;
last_name_varray last_name_type := last_name_type();
v_counter INTEGER               := 0;
BEGIN
  FOR name_rec IN name_cur
  LOOP
    v_counter := v_counter + 1;
    last_name_varray.EXTEND;
    last_name_varray(v_counter) := name_rec.last_name;
    DBMS_OUTPUT.PUT_LINE ('last_name('||v_counter||'): '|| last_name_varray(v_counter));
  END LOOP;
END;


----------------------------------------------------------------------------------------
--Collection method lar ile varray kullan?m?
DECLARE
TYPE varray_type IS VARRAY(10) OF NUMBER;
                   
varray VARRAY_TYPE := VARRAY_TYPE(1, 2, 3, 4, 5, 6);

BEGIN
  DBMS_OUTPUT.PUT_LINE ('varray.COUNT = '||varray.COUNT);
  DBMS_OUTPUT.PUT_LINE ('varray.LIMIT = '||varray.LIMIT);
  DBMS_OUTPUT.PUT_LINE ('varray.FIRST = '||varray.FIRST);
  DBMS_OUTPUT.PUT_LINE ('varray.LAST = '||varray.LAST);
  varray.EXTEND(2, 4);
  DBMS_OUTPUT.PUT_LINE ('varray.LAST = '||varray.LAST);
  DBMS_OUTPUT.PUT_LINE ('varray('||varray.LAST||') = '|| varray(varray.LAST));
  -- Trim last two elements
  varray.TRIM(2);
  DBMS_OUTPUT.PUT_LINE('varray.LAST = '||VARRAY.LAST);
END;
--varray ile DELETE metodu kullan?lamaz. hata verir
DECLARE
TYPE varray_type IS VARRAY(3) OF CHAR(1);
                    varray varray_type := varray_type('A', 'B', 'C');
BEGIN
  VARRAY.DELETE(3);
END;


--15.2.1 Use Varrays
----------------------------------------------------------------------------------------
SET SERVEROUTPUT ON
DECLARE
  CURSOR city_cur
  IS
    SELECT city FROM zipcode WHERE rownum <= 10;
TYPE city_type IS VARRAY(10) OF zipcode.city%TYPE;
city_varray city_type;
v_counter INTEGER := 0;
BEGIN
  FOR city_rec IN city_cur
  LOOP
    v_counter              := v_counter + 1;
    city_varray(v_counter) := city_rec.city;
    DBMS_OUTPUT.PUT_LINE('city_varray('||v_counter||'): '|| city_varray(v_counter));
  END LOOP;
END;


----------------------------------------------------------------------------------------

SET SERVEROUTPUT ON
DECLARE
  CURSOR city_cur
  IS
    SELECT city FROM zipcode WHERE rownum <= 10;
TYPE city_type IS VARRAY(10) OF zipcode.city%TYPE;
city_varray city_type := city_type();
v_counter INTEGER     := 0;
BEGIN
  FOR city_rec IN city_cur
  LOOP
    v_counter := v_counter + 1;
    city_varray.EXTEND;
    city_varray(v_counter) := city_rec.city;
    DBMS_OUTPUT.PUT_LINE('city_varray('||v_counter||'): '|| city_varray(v_counter));
  END LOOP;
END;
----------------------------------------------------------------------------------------
SET SERVEROUTPUT ON
DECLARE
  CURSOR city_cur
  IS
    SELECT city FROM zipcode WHERE rownum <= 10;
TYPE city_type IS VARRAY(20) OF zipcode.city%TYPE;
city_varray city_type := city_type();
v_counter INTEGER     := 0;
BEGIN
  FOR city_rec IN city_cur
  LOOP
    v_counter := v_counter + 1;
    city_varray.EXTEND;
    city_varray(v_counter) := city_rec.city;
  END LOOP;
  FOR i IN 1..v_counter
  LOOP
    -- extend the size of varray by 1 and copy the
    -- current element to the last element
    city_varray.EXTEND(1, i);
  END LOOP;
  FOR i IN 1..20
  LOOP
    DBMS_OUTPUT.PUT_LINE('city_varray('||i||'): '|| city_varray(i));
  END LOOP;
END;

----------------------------------------------------------------------------------------
--Multilevel Collections
DECLARE
TYPE varray_type1 IS VARRAY(4) OF INTEGER;
TYPE varray_type2 IS VARRAY(3) OF varray_type1;
varray1 varray_type1 := varray_type1(2, 4, 6, 8);
varray2 varray_type2 := varray_type2(varray1);
BEGIN
  DBMS_OUTPUT.PUT_LINE ('Varray of integers');
  FOR i IN 1..4
  LOOP
    DBMS_OUTPUT.PUT_LINE ('varray1('||i||'): '||varray1(i));
  END LOOP;
  varray2.EXTEND;
  varray2(2) := varray_type1(1, 3, 5, 7);
  DBMS_OUTPUT.PUT_LINE (chr(10)||'Varray of varrays of integers');
  FOR i IN 1..2
  LOOP
    FOR j IN 1..4
    LOOP
      DBMS_OUTPUT.PUT_LINE ('varray2('||i||')('||j||'): '||varray2(i)(j));
    END LOOP;
  END LOOP;
END;
------------------------------------------------------------
SET SERVEROUTPUT ON
DECLARE
TYPE table_type1
IS
  TABLE OF INTEGER INDEX BY BINARY_INTEGER;
TYPE table_type2
IS
  TABLE OF TABLE_TYPE1 INDEX BY BINARY_INTEGER;
  table_tab1 table_type1;
  table_tab2 table_type2;
BEGIN
  FOR i IN 1..2
  LOOP
    FOR j IN 1..3
    LOOP
      IF i             = 1 THEN
        table_tab1(j) := j;
      ELSE
        table_tab1(j) := 4 - j;
      END IF;
      table_tab2(i)(j) := table_tab1(j);
      DBMS_OUTPUT.PUT_LINE ('table_tab2('||i||')('||j||'): '|| table_tab2(i)(j));
    END LOOP;
  END LOOP;
END;
------------------------------------------------------------
SET SERVEROUTPUT ON
DECLARE
TYPE table_type1
IS
  TABLE OF INTEGER INDEX BY BINARY_INTEGER;
TYPE table_type2
IS
  TABLE OF TABLE_TYPE1;
  table_tab1 table_type1;
  table_tab2 table_type2 := table_type2();
BEGIN
  FOR i IN 1..2
  LOOP
    table_tab2.EXTEND;
    FOR j IN 1..3
    LOOP
      IF i             = 1 THEN
        table_tab1(j) := j;
      ELSE
        table_tab1(j) := 4 - j;
      END IF;
      table_tab2(i)(j) := table_tab1(j);
      DBMS_OUTPUT.PUT_LINE ('table_tab2('||i||')('||j||'): '|| table_tab2(i)(j));
    END LOOP;
  END LOOP;
END;

------------------------------------------------------------


SET SERVEROUTPUT ON
DECLARE
TYPE table_type1 IS VARRAY(3) OF INTEGER;
TYPE table_type2
IS
  TABLE OF TABLE_TYPE1;
  table_tab1 table_type1 := table_type1();
  table_tab2 table_type2 := table_type2(table_tab1);
BEGIN
  FOR i IN 1..2
  LOOP
    table_tab2.EXTEND;
    table_tab2(i) := table_type1();
    FOR j IN 1..3
    LOOP
      IF i = 1 THEN
        table_tab1.EXTEND;
        table_tab1(j) := j;
      ELSE
        table_tab1(j) := 4 - j;
      END IF;
      table_tab2(i).EXTEND;
      table_tab2(i)(j):= table_tab1(j);
      DBMS_OUTPUT.PUT_LINE ('table_tab2('||i||')('||j||'): '|| table_tab2(i)(j));
    END LOOP;
  END LOOP;
END;


----------------------------


SET SERVEROUTPUT ON
DECLARE
  CURSOR name_cur
  IS
    SELECT first_name||' '||last_name name FROM instructor;
TYPE name_type
IS
  TABLE OF VARCHAR2(50) INDEX BY BINARY_INTEGER;
  name_tab name_type;
  v_counter INTEGER := 0;
BEGIN
  FOR name_rec IN name_cur
  LOOP
    v_counter           := v_counter + 1;
    name_tab(v_counter) := name_rec.name;
    DBMS_OUTPUT.PUT_LINE ('name('||v_counter||'): '|| name_tab(v_counter));
  END LOOP;
END;



-------------


SET SERVEROUTPUT ON
DECLARE
  CURSOR name_cur
  IS
    SELECT first_name||' '||last_name name FROM instructor;
TYPE name_type IS VARRAY(15) OF VARCHAR2(50);
name_varray name_type := name_type();
v_counter INTEGER     := 0;
BEGIN
  FOR name_rec IN name_cur
  LOOP
    v_counter := v_counter + 1;
    name_varray.EXTEND;
    name_varray(v_counter) := name_rec.name;
    DBMS_OUTPUT.PUT_LINE ('name('||v_counter||'): '|| name_varray(v_counter));
  END LOOP;
END;

-------------

SET SERVEROUTPUT ON
DECLARE
  CURSOR instructor_cur
  IS
    SELECT instructor_id, first_name||' '||last_name name FROM instructor;
  CURSOR course_cur (p_instructor_id NUMBER)
  IS
    SELECT UNIQUE course_no course
    FROM section
    WHERE instructor_id = p_instructor_id;
TYPE name_type IS VARRAY(15) OF VARCHAR2(50);
name_varray name_type := name_type();
TYPE course_type IS VARRAY(10) OF NUMBER;
course_varray course_type;
v_counter1 INTEGER := 0;
v_counter2 INTEGER;
BEGIN
  FOR instructor_rec IN instructor_cur
  LOOP
    v_counter1 := v_counter1 + 1;
    name_varray.EXTEND;
    name_varray(v_counter1) := instructor_rec.name;
    DBMS_OUTPUT.PUT_LINE ('name('||v_counter1||'): '|| name_varray(v_counter1));
    -- Initialize and populate course_varray
    v_counter2    := 0;
    course_varray := course_type();
    FOR course_rec IN course_cur (instructor_rec.instructor_id)
    LOOP
      v_counter2 := v_counter2 + 1;
      course_varray.EXTEND;
      course_varray(v_counter2) := course_rec.course;
      DBMS_OUTPUT.PUT_LINE ('course('||v_counter2||'): '|| course_varray(v_counter2));
    END LOOP;
    DBMS_OUTPUT.PUT_LINE ('===========================');
  END LOOP;
END;

-------------

DECLARE
TYPE varray_type1 IS VARRAY(7) OF INTEGER;
TYPE table_type2
IS
  TABLE OF varray_type1 INDEX BY BINARY_INTEGER;
  varray1 varray_type1 := varray_type1(1, 2, 3);
  table2 table_type2   := table_type2(varray1, varray_type1(8, 9, 0));
BEGIN
  DBMS_OUTPUT.PUT_LINE ('table2(1)(2): '||table2(1)(2));
  FOR i IN 1..10
  LOOP
    varray1.EXTEND;
    varray1(i) := i;
    DBMS_OUTPUT.PUT_LINE ('varray1('||i||'): '||varray1(i));
  END LOOP;
END;

-------------


DECLARE
TYPE varray_type1 IS VARRAY(7) OF INTEGER;
TYPE table_type2
IS
  TABLE OF varray_type1 INDEX BY BINARY_INTEGER;
  varray1 varray_type1 := varray_type1(1, 2, 3);
  table2 table_type2;
BEGIN
  -- These statements populate associative array
  table2(1) := varray1;
  table2(2) := varray_type1(8, 9, 0);
  DBMS_OUTPUT.PUT_LINE ('table2(1)(2): '||table2(1)(2));
  FOR i IN 1..10
  LOOP
    varray1.EXTEND;
    varray1(i) := i;
    DBMS_OUTPUT.PUT_LINE ('varray1('||i||'): '||varray1(i));
  END LOOP;
END;














  