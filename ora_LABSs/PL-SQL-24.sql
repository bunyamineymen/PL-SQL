--MODULE 24
------------



--Oracle Supplied Packages
---------------------------



--Making Use of Oracle Supplied PACKAGES TO PROFILE PL/SQL, Access Files, and Schedule Jobs



--DBMS_HPROF


--SYS ile ba?lan ve gerekli i?lemleri çal??t?r
GRANT EXECUTE ON dbms_hprof TO public;
CREATE OR REPLACE DIRECTORY PROFILER_DIR AS 'c:/temp';
GRANT READ, WRITE ON DIRECTORY PROFILER_DIR TO PUBLIC;


--@?/rdbms/admin/dbmshptab.sql   scriptini Student ?emas?nda çal??t?r


--Deneme amaçl? a?a??daki sp leri olu?tur

CREATE OR REPLACE
PROCEDURE count_student(
    p_zip IN NUMBER)
AS
  v_count NUMBER;
BEGIN
  SELECT COUNT(*) INTO V_count FROM STUDENT WHERE zip = p_zip;
END;



CREATE OR REPLACE
PROCEDURE count_instructor(
    p_zip IN NUMBER)
AS
  v_count NUMBER;
BEGIN
  SELECT COUNT(*)
  INTO V_count
  FROM INSTRUCTOR
  WHERE zip = p_zip;
END;



CREATE OR REPLACE
PROCEDURE loop_Zipcode
AS
BEGIN
  FOR r IN
  (SELECT * FROM zipcode
  )
  LOOP
    count_student (r.zip);
    count_instructor (r.zip);
  END LOOP;
END;



--Ard?ndan profileri ba?lat

BEGIN
  DBMS_HPROF.start_profiling ( location => 'PROFILER_DIR', filename => 'profiler.txt');
  loop_Zipcode;
  DBMS_HPROF.STOP_PROFILING;
END;




--Analyze fonksiyonunu çal??t?r

SET SERVEROUTPUT ON
DECLARE
  l_runid NUMBER;
BEGIN
  l_runid := DBMS_HPROF.analyze ( location => 'PROFILER_DIR', filename => 'profiler.txt', run_comment => 'Test run.');
  DBMS_OUTPUT.PUT_LINE('l_runid=' || L_RUNID);
END;



--test et

SELECT runid,
  run_timestamp,
  total_elapsed_time,
  run_comment
FROM DBMSHP_RUNS
ORDER BY runid;




--ba?ka bir fonksiyonda kullan?m?

SELECT symbolid,
  owner,
  module,
  type,
  FUNCTION
FROM DBMSHP_FUNCTION_INFO
WHERE RUNID = 2
ORDER BY symbolid;


--bak?labilir, süreler

SELECT RPAD(' ', level*2, ' ') || fi.owner || '.' || fi.module AS name,
fi.function,
pci.subtree_elapsed_time,
pci.function_elapsed_time,
pci.calls
FROM dbmshp_parent_child_info pci
JOIN dbmshp_function_info fi ON pci.runid = fi.runid AND
PCI.CHILDSYMID = FI.SYMBOLID
WHERE pci.runid = 2
CONNECT BY PRIOR CHILDSYMID = PARENTSYMID
START WITH pci.parentsymid = 3;



---
---UTL_FILE

--1158 ile server initialize parameter 
--utl_file_dir = * yap?lmal?



--sys ile
GRANT SELECT ON sys.v_$session TO student;

-- ch24_1a.sql
CREATE OR REPLACE
PROCEDURE LOG_USER_COUNT(
    PI_DIRECTORY IN VARCHAR2,
    PI_FILE_NAME IN VARCHAR2)
AS
  V_File_handle UTL_FILE.FILE_TYPE;
  V_user_count NUMBER;
BEGIN
  SELECT COUNT(*) INTO V_user_count FROM v$session WHERE username IS NOT NULL;
  V_File_handle := UTL_FILE.FOPEN(PI_DIRECTORY, PI_FILE_NAME, 'A');
  UTL_FILE.NEW_LINE(V_File_handle);
  UTL_FILE.PUT_LINE(V_File_handle , '---- User log -----');
  UTL_FILE.NEW_LINE(V_File_handle);
  UTL_FILE.PUT_LINE(V_File_handle , 'on '|| TO_CHAR(SYSDATE, 'MM/DD/YY HH24:MI'));
  UTL_FILE.PUT_LINE(V_File_handle , 'Number of users logged on: '|| V_user_count);
  UTL_FILE.PUT_LINE(V_File_handle , '---- End log -----');
  UTL_FILE.NEW_LINE(V_File_handle);
  UTL_FILE.FCLOSE(V_File_handle);
EXCEPTION
WHEN UTL_FILE.INVALID_FILENAME THEN
  DBMS_OUTPUT.PUT_LINE('File is invalid');
WHEN UTL_FILE.WRITE_ERROR THEN
  DBMS_OUTPUT.PUT_LINE('Oracle is not able to write to file');
END;


create or replace directory working as 'C:\working\'

--c de working klasörü aç


exec  LOG_USER_COUNT('C:\working\', 'USER.LOG');



--24.1.1 Access Files with UTL_FILE


/*
A) Create a companion procedure to the sample procedure LOG_USER_COUNT that you just made.
Name your new procedure READ_LOG.This procedure will read a text file and display each line
using DBMS_OUTPUT.PUT_LINE.

ANSWER: The following PL/SQL creates a procedure to read a file and display the contents.Note
that the exception WHEN NO_DATA_FOUND is raised when the last line of the file has been read
and there are no more lines to read.
*/


CREATE OR REPLACE
PROCEDURE READ_FILE(
    PI_DIRECTORY IN VARCHAR2,
    PI_FILE_NAME IN VARCHAR2)
AS
  V_File_handle UTL_FILE.FILE_TYPE;
  V_FILE_Line VARCHAR2(1024);
BEGIN
  V_File_handle := UTL_FILE.FOPEN(PI_DIRECTORY, PI_FILE_NAME, 'R');
  LOOP
    UTL_FILE.GET_LINE( V_File_handle , v_file_line);
    DBMS_OUTPUT.PUT_LINE(v_file_line);
  END LOOP;
EXCEPTION
WHEN NO_DATA_FOUND THEN
  UTL_FILE.FCLOSE( V_FILE_HANDLE );
END;


/*
B) Run the procedure LOG_USER_COUNT, and then run the procedure READ_LOG for the same file.
*/
SET SERVEROUTPUT ON
EXEC LOG_USER_COUNT('C:\working\', 'User.Log');
 EXEC READ_FILE('C:\working\', 'User.Log');
 
 
 
 
 
 --
 --
 --DBMS_JOB
 
 
 --24.1.2 Schedule Jobs with DBMS_JOB
 


--6 saatte bir çal??an procedure
DECLARE
  V_JOB_NO NUMBER;
BEGIN
  DBMS_JOB.SUBMIT( JOB => v_job_no, WHAT => 'LOG_USER_COUNT
(''C:\WORKING\'', ''USER.LOG'');
  ',
NEXT_DATE => SYSDATE,
INTERVAL => 'SYSDATE + 1/4 ');
Commit;
DBMS_OUTPUT.PUT_LINE(V_JOB_NO);
END;
 
 
 --sorgula ve kay?t edildi?ini gör
 SELECT JOB, NEXT_DATE, NEXT_SEC, BROKEN, WHAT
FROM DBA_JOBS;
 
 
 
--di?er kullan?labilecek fonksiyonlar

-- execute job number 1
exec dbms_job.run(23);
-- remove job number 1 from the job queue
exec dbms_job.remove(23);
-- change job #1 to run immediately and then every hour of
-- the day
exec DBMS_JOB.CHANGE(23, null, SYSDATE, 'SYSDATE + 1/24 ');


-- set job 1 to be broken
exec dbms_job.BROKEN(23, TRUE);
-- set job 1 not to be broken
exec dbms_job.BROKEN(23, FALSE);



/*
A) Create a procedure DELETE_ENROLL that deletes a student’s enrollment if there are no grades in
the GRADE table for that student and the start date of the section is already one month past.
*/


CREATE OR REPLACE
PROCEDURE DELETE_ENROLL
AS
  CURSOR C_NO_GRADES
  IS
    SELECT st.student_id,
      se.section_id
    FROM student st,
      enrollment e,
      section se
    WHERE st.student_id    = e.student_id
    AND e.section_id       = se.section_id
    AND se.start_date_time < ADD_MONTHS(SYSDATE, -1)
    AND NOT EXISTS
      (SELECT g.student_id,
        g.section_id
      FROM grade g
      WHERE g.student_id = st.student_id
      AND g.section_id   = se.section_id
      );
BEGIN
  FOR R IN C_NO_GRADES
  LOOP
    DELETE enrollment
    WHERE section_id = r.section_id
    AND student_id   = r.student_id;
  END LOOP;
  COMMIT;
EXCEPTION
WHEN OTHERS THEN
  DBMS_OUTPUT.PUT_LINE(SQLERRM);
END;



/*
B) Submit the procedure DELETE_ENROLL to the job queue to execute once a month.
*/

DECLARE
  V_JOB NUMBER;
BEGIN
   DBMS_JOB.SUBMIT(:V_JOB, 'DELETE_ENROLL;',SYSDATE, 'ADD_MONTHS(SYSDATE, 1)');
END;


-----------------------------------------------------------------------------------------------


--Making Use of Oracle-Supplied PACKAGES TO GENERATE AN EXPLAIN Plan and Create HTML Pages


--çal??t?r?lacak scripti çal??t?r
--@$ORACLE_HOME/rdbms/admin/utlxplan.sql


explain plan for
 SELECT s.course_no,
 c.description,
 i.first_name,
 i.last_name,
 s.section_no,
 TO_CHAR(s.start_date_time,'Mon-DD-YYYY HH:MIAM'),
 s.location
 FROM section s,
 COURSE C,
 instructor i
WHERE S.COURSE_NO = C.COURSE_NO
AND s.instructor_id= i.instructor_id;



select rtrim ( lpad ( ' ', 2*level ) ||
rtrim ( operation ) || ' ' ||
rtrim ( options ) || ' ' ||
object_name || ' ' ||
partition_start || ' ' ||
partition_stop || ' ' ||
to_char ( partition_id )
) the_query_plan
from plan_table
CONNECT BY PRIOR ID = PARENT_ID
start with id = 0;





SELECT * FROM TABLE(DBMS_XPLAN.DISPLAY);


----------------------------------------------------------------------------------

--Creating Web Pages with the Oracle Web Toolkit



CREATE OR REPLACE
PROCEDURE my_first_page
AS
BEGIN
  htp.htmlOpen;
  htp.headOpen;
  htp.title('My First Page');
  htp.headClose;
  htp.bodyOpen;
  htp.p('Hello world.<BR>');
  htp.bodyClose;
  htp.htmlClose;
EXCEPTION
WHEN OTHERS THEN
  htp.p('An error occurred on this page.
Please try again later.');
END;







CREATE OR REPLACE
PACKAGE find_coords
AS
  PROCEDURE display_image;
  PROCEDURE show_coords(
      p_image IN owa_image.Point);
END find_coords;
/



CREATE OR REPLACE
PACKAGE BODY find_coords
AS
PROCEDURE display_image
IS
BEGIN
  htp.headOpen;
  htp.title('Display the Image');
  htp.headClose;
  htp.p('<BODY bgcolor="khaki">');
  htp.header(1,'Find the Coordinates');
  htp.p('Click on the image and you will see the x,y
coordinates on the next page');
  htp.formOpen('find_coords.show_coords');
  htp.formImage('p_image','/images/location.gif');
  htp.formClose;
  htp.p('</BODY>');
  htp.p('</HTML>');
EXCEPTION
WHEN OTHERS THEN
  htp.p('An error occurred: '||SQLERRM||'. Please try again
later.');
END display_image;
PROCEDURE show_coords(
    p_image IN owa_image.Point)
IS
  x_in NUMBER(4) := owa_image.Get_X(P_image);
  y_in NUMBER(4) := owa_image.Get_Y(P_image);
BEGIN
  htp.headOpen;
  htp.title('Find Your coordinates');
  htp.headClose;
  htp.p('<BODY bgcolor="khaki">');
  htp.header(1,'These are the Coordinates you clicked on:');
  htp.p('<P>
You have selected '||x_in||' as your X coordinate </p>');
  htp.p('<P>
You have selected '||Y_in||' as your Y coordinate </p>');
  htp.p('</BODY>');
  htp.p('</HTML>');
EXCEPTION
WHEN OTHERS THEN
  htp.p('An error occurred: '||SQLERRM||'. Please try again
later.');
END ;
END FIND_COORDS;














