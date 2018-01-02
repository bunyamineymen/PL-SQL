--MODULE 17
------------


--Native Dynamic SQL
-----------------------


--EXECUTE IMMEDIATE Statements

--11106 nolu zipe sahip bütün ö?rencileri tutan yeni bir tablo olu?turuluyor
--kaç ö?renci eklendi?i bilgisi de?i?kene aktar?l?p ekranda gösteriliyor
--günün tarihini gösteren PL/SQL blok olu?turulup ekrana yazd?r?l?yor
-- son olarak 151 nolu ö?rencinin zip de?eri 11105 olarak de?i?tiriliyor
DECLARE
  sql_stmt         VARCHAR2(100);
  plsql_block      VARCHAR2(300);
  v_zip            VARCHAR2(5) := '11106';
  v_total_students NUMBER;
  v_new_zip        VARCHAR2(5);
  v_student_id     NUMBER := 151;
BEGIN
  -- Create table MY_STUDENT
  sql_stmt := 'CREATE TABLE my_student '|| 'AS SELECT * FROM student WHERE zip = '||v_zip;
  EXECUTE IMMEDIATE sql_stmt;
  -- Select total number of records from MY_STUDENT table
  -- and display results on the screen
  EXECUTE IMMEDIATE 'SELECT COUNT(*) FROM my_student' INTO v_total_students;
  DBMS_OUTPUT.PUT_LINE ('Students added: '||v_total_students);
  -- Select current date and display it on the screen
  PLSQL_BLOCK := 'DECLARE ' || ' v_date DATE; ' || 'BEGIN ' || ' SELECT SYSDATE INTO v_date FROM DUAL; '|| ' DBMS_OUTPUT.PUT_LINE (TO_CHAR(v_date,
''DD-MON-YYYY''))
;'|| 'END;';
  EXECUTE IMMEDIATE plsql_block;
  -- Update record in MY_STUDENT table
  sql_stmt := 'UPDATE my_student SET zip = 11105 WHERE student_id =
:1 '|| 'RETURNING zip INTO :2';
  EXECUTE IMMEDIATE sql_stmt USING v_student_id RETURNING INTO v_new_zip;
  DBMS_OUTPUT.PUT_LINE ('New zip code: '||V_NEW_ZIP);
END;


--hatal? hali
--DDL cümleleri içinde bind variable kullan?lamaz!!!
DECLARE
  sql_stmt         VARCHAR2(100);
  v_zip            VARCHAR2(5) := '11106';
  v_total_students NUMBER;
BEGIN
  -- Drop table MY_STUDENT
  EXECUTE IMMEDIATE 'DROP TABLE my_student';
  -- Create table MY_STUDENT
  sql_stmt := 'CREATE TABLE my_student '|| 'AS SELECT * FROM student '|| 'WHERE zip = :zip';
  EXECUTE IMMEDIATE sql_stmt USING v_zip;
  -- Select total number of records from MY_STUDENT table
  -- and display results on the screen
  EXECUTE IMMEDIATE 'SELECT COUNT(*) FROM my_student' INTO v_total_students;
  DBMS_OUTPUT.PUT_LINE ('Students added: '|| V_TOTAL_STUDENTS);
END;



--Tablo veya kolon isimleri bind variable olarak verilemez. Syntax hatas? olu?ur

DECLARE
  sql_stmt         VARCHAR2(100);
  v_zip            VARCHAR2(5) := '11106';
  v_total_students NUMBER;
BEGIN
  -- Create table MY_STUDENT
  sql_stmt := 'CREATE TABLE my_student '|| 'AS SELECT * FROM student '|| 'WHERE zip ='|| v_zip;
  EXECUTE IMMEDIATE sql_stmt;
  -- Select total number of records from MY_STUDENT table
  -- and display results on the screen
  EXECUTE IMMEDIATE 'SELECT COUNT(*) FROM :my_table' INTO v_total_students USING 'my_student';
  DBMS_OUTPUT.PUT_LINE ('Students added: '|| V_TOTAL_STUDENTS);
END;


--SQL cümleleri ; ile PL/SQL bloklar? / ile bitemez!!!

DECLARE
  sql_stmt         VARCHAR2(100);
  v_zip            VARCHAR2(5) := '11106';
  v_total_students NUMBER;
BEGIN
  -- Create table MY_STUDENT
  sql_stmt := 'CREATE TABLE my_student '|| 'AS SELECT * FROM student '|| 'WHERE zip = '||v_zip;
  EXECUTE IMMEDIATE sql_stmt;
  -- Select total number of records from MY_STUDENT table
  -- and display results on the screen
  EXECUTE IMMEDIATE 'SELECT COUNT(*) FROM my_student;' INTO v_total_students;
  DBMS_OUTPUT.PUT_LINE ('Students added: '|| V_TOTAL_STUDENTS);
END;


--NULL de?er bind variable a direkt de?er olarak girilemez
DECLARE
  sql_stmt VARCHAR2(100);
BEGIN
  sql_stmt := 'UPDATE course'|| ' SET prerequisite = :some_value';
  EXECUTE IMMEDIATE sql_stmt USING NULL;
END;


--Düzeltilmi? hali. Null bir de?i?ken atan?yor
DECLARE
  sql_stmt VARCHAR2(100);
  v_null   VARCHAR2(1);
BEGIN
  sql_stmt := 'UPDATE course'|| ' SET prerequisite = :some_value';
  EXECUTE IMMEDIATE sql_stmt USING V_NULL;
END;



--17.1.1 Use the EXECUTE IMMEDIATE Statement


--girilen ö?rencinin ad? ve soyad? bilgisi ekranda gösterilsin
-- ch17_1a.sql, version 1.0
SET SERVEROUTPUT ON
DECLARE
  sql_stmt     VARCHAR2(200);
  v_student_id NUMBER := &sv_student_id;
  v_first_name VARCHAR2(25);
  v_last_name  VARCHAR2(25);
BEGIN
  sql_stmt := 'SELECT first_name, last_name'|| ' FROM student' || ' WHERE student_id = :1';
  EXECUTE IMMEDIATE sql_stmt INTO v_first_name, v_last_name USING v_student_id;
  DBMS_OUTPUT.PUT_LINE ('First Name: '||v_first_name);
  DBMS_OUTPUT.PUT_LINE ('Last Name: '||V_LAST_NAME);
END;


/*
B) Modify the script so that the student’s address (street, city, state, and zip code) is displayed on the
screen as well.
*/


-- ch17_1b.sql, version 2.0
SET SERVEROUTPUT ON
DECLARE
  sql_stmt     VARCHAR2(200);
  v_student_id NUMBER := &sv_student_id;
  v_first_name VARCHAR2(25);
  v_last_name  VARCHAR2(25);
  v_street     VARCHAR2(50);
  v_city       VARCHAR2(25);
  v_state      VARCHAR2(2);
  v_zip        VARCHAR2(5);
BEGIN
  sql_stmt := 'SELECT a.first_name, a.last_name, a.street_address'|| ' ,b.city, b.state, b.zip' || ' FROM student a, zipcode b' || ' WHERE a.zip = b.zip' || ' AND student_id = :1';
  EXECUTE IMMEDIATE sql_stmt INTO v_first_name, v_last_name, v_street, v_city, v_state, v_zip USING v_student_id;
  DBMS_OUTPUT.PUT_LINE ('First Name: '||v_first_name);
  DBMS_OUTPUT.PUT_LINE ('Last Name: '||v_last_name);
  DBMS_OUTPUT.PUT_LINE ('Street: '||v_street);
  DBMS_OUTPUT.PUT_LINE ('City: '||v_city);
  DBMS_OUTPUT.PUT_LINE ('State: '||v_state);
  DBMS_OUTPUT.PUT_LINE ('Zip Code: '||V_ZIP);
END;

--de?i?kenlerin s?ras? önemli üstteki için denenebilir


/*
C) Modify the script created in the previous exercise (ch17_1b.sql) so that the SELECT statement can
be run against either the STUDENT or INSTRUCTOR table. In other words, a user can specify the
table name used in the SELECT statement at runtime.
*/


-- ch17_1c.sql, version 3.0
SET SERVEROUTPUT ON
DECLARE
  sql_stmt     VARCHAR2(200);
  v_table_name VARCHAR2(20) := '&sv_table_name';
  v_id         NUMBER       := &sv_id;
  v_first_name VARCHAR2(25);
  v_last_name  VARCHAR2(25);
  v_street     VARCHAR2(50);
  v_city       VARCHAR2(25);
  v_state      VARCHAR2(2);
  v_zip        VARCHAR2(5);
BEGIN
  sql_stmt := 'SELECT a.first_name, a.last_name, a.street_address'|| ' ,b.city, b.state, b.zip' || ' FROM '||v_table_name||' a, zipcode b' || ' WHERE a.zip = b.zip' || ' AND '||v_table_name||'_id = :1';
  EXECUTE IMMEDIATE sql_stmt INTO v_first_name, v_last_name, v_street, v_city, v_state, v_zip USING v_id;
  DBMS_OUTPUT.PUT_LINE ('First Name: '||v_first_name);
  DBMS_OUTPUT.PUT_LINE ('Last Name: '||v_last_name);
  DBMS_OUTPUT.PUT_LINE ('Street: '||v_street);
  DBMS_OUTPUT.PUT_LINE ('City: '||v_city);
  DBMS_OUTPUT.PUT_LINE ('State: '||v_state);
  DBMS_OUTPUT.PUT_LINE ('Zip Code: '||V_ZIP);
END;

----------------------------------------------------------------------------------------


--OPEN-FOR, FETCH, and CLOSE Statements


DECLARE
TYPE student_cur_type
IS
  REF
  CURSOR;
    student_cur student_cur_type;
    v_zip        VARCHAR2(5) := '&sv_zip';
    v_first_name VARCHAR2(25);
    v_last_name  VARCHAR2(25);
  BEGIN
    OPEN student_cur FOR 'SELECT first_name, last_name FROM student '|| 'WHERE zip = :1' USING v_zip;
    LOOP
      FETCH student_cur INTO v_first_name, v_last_name;
    EXIT
  WHEN student_cur%NOTFOUND;
    DBMS_OUTPUT.PUT_LINE ('First Name: '||v_first_name);
    DBMS_OUTPUT.PUT_LINE ('Last Name: '||v_last_name);
  END LOOP;
  CLOSE student_cur;
EXCEPTION
WHEN OTHERS THEN
  IF student_cur%ISOPEN THEN
    CLOSE student_cur;
  END IF;
  DBMS_OUTPUT.PUT_LINE ('ERROR: '|| SUBSTR(SQLERRM, 1, 200));
END;




--17.2.1 Use OPEN-FOR, FETCH, and CLOSE Statements


-- ch17_2a.sql, version 1.0
SET SERVEROUTPUT ON
DECLARE
TYPE zip_cur_type
IS
  REF
  CURSOR;
    zip_cur zip_cur_type;
    sql_stmt VARCHAR2(500);
    v_zip    VARCHAR2(5);
    v_total  NUMBER;
    v_count  NUMBER;
  BEGIN
    sql_stmt := 'SELECT zip, COUNT(*) total'|| ' FROM student ' || 'GROUP BY zip';
    v_count  := 0;
    OPEN zip_cur FOR sql_stmt;
    LOOP
      FETCH ZIP_CUR INTO V_ZIP, V_TOTAL;
    EXIT WHEN zip_cur%NOTFOUND;
    -- Limit the number of lines printed on the
    -- screen to 10
    v_count    := v_count + 1;
    IF v_count <= 10 THEN
      DBMS_OUTPUT.PUT_LINE ('Zip code: '||v_zip|| ' Total: '||v_total);
    END IF;
  END LOOP;
  CLOSE zip_cur;
EXCEPTION
WHEN OTHERS THEN
  IF zip_cur%ISOPEN THEN
    CLOSE zip_cur;
  END IF;
  DBMS_OUTPUT.PUT_LINE ('ERROR: '|| SUBSTR(SQLERRM, 1, 200));
END;


/*
B) Modify the script you just created (ch17_2a.sql) so that the SELECT statement can be run against
either the STUDENT or INSTRUCTOR table. In other words, a user can specify the table name used
in the SELECT statement at runtime.
*/


-- ch17_2b.sql, version 2.0
SET SERVEROUTPUT ON
DECLARE
TYPE zip_cur_type IS REF CURSOR;
zip_cur zip_cur_type;
v_table_name VARCHAR2(20) := '&sv_table_name';
sql_stmt VARCHAR2(500);
v_zip VARCHAR2(5);
v_total NUMBER;
v_count NUMBER;
BEGIN
  DBMS_OUTPUT.PUT_LINE ('Totals from '||v_table_name|| ' table');
  sql_stmt := 'SELECT zip, COUNT(*) total'|| ' FROM '||v_table_name||' '|| 'GROUP BY zip';
  v_count  := 0;
  OPEN zip_cur FOR sql_stmt;
  LOOP
    FETCH zip_cur INTO v_zip, v_total;
    EXIT
  WHEN zip_cur%NOTFOUND;
    -- Limit the number of lines printed on the
    -- screen to 10
    v_count    := v_count + 1;
    IF v_count <= 10 THEN
      DBMS_OUTPUT.PUT_LINE ('Zip code: '||v_zip|| ' Total: '||v_total);
    END IF;
  END LOOP;
  CLOSE zip_cur;
EXCEPTION
WHEN OTHERS THEN
  IF zip_cur%ISOPEN THEN
    CLOSE zip_cur;
  END IF;
  DBMS_OUTPUT.PUT_LINE ('ERROR: '|| SUBSTR(SQLERRM, 1, 200));
END;



--Ayn? örnek tek tek variable tan?mlanarak de?il, record tan?mlanarak yaz?l?yor

SET SERVEROUTPUT ON
DECLARE
TYPE zip_cur_type
IS
  REF
  CURSOR;
    zip_cur zip_cur_type;
  TYPE zip_rec_type
IS
  RECORD
  (
    zip   VARCHAR2(5),
    total NUMBER);
  zip_rec zip_rec_type;
  v_table_name VARCHAR2(20) := '&sv_table_name';
  sql_stmt     VARCHAR2(500);
  v_count      NUMBER;
BEGIN
  DBMS_OUTPUT.PUT_LINE ('Totals from '||v_table_name|| ' table');
  sql_stmt := 'SELECT zip, COUNT(*) total'|| ' FROM '||v_table_name||' '|| 'GROUP BY zip';
  v_count  := 0;
  OPEN zip_cur FOR sql_stmt;
  LOOP
    FETCH zip_cur INTO zip_rec;
  EXIT
WHEN zip_cur%NOTFOUND;
  -- Limit the number of lines printed on the
  -- screen to 10
  v_count    := v_count + 1;
  IF v_count <= 10 THEN
    DBMS_OUTPUT.PUT_LINE ('Zip code: '||zip_rec.zip|| ' Total: '||zip_rec.total);
  END IF;
END LOOP;
CLOSE zip_cur;
EXCEPTION
WHEN OTHERS THEN
  IF zip_cur%ISOPEN THEN
    CLOSE zip_cur;
  END IF;
  DBMS_OUTPUT.PUT_LINE ('ERROR: '|| SUBSTR(SQLERRM, 1, 200));
END;














