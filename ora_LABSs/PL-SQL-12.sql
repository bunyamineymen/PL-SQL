
--------------------------------------------------------
declare
CURSOR c_zip (p_state IN zipcode.state%TYPE)
IS
  SELECT zip, city, state FROM ZIPCODE WHERE state = p_state;


DECLARE
  CURSOR c_zip (p_state IN zipcode.state%TYPE)
  IS
    SELECT zip, city, state FROM ZIPCODE WHERE state = p_state;
BEGIN
  FOR r_zip IN c_zip('NJ')
  LOOP
     DBMS_OUTPUT.PUT_LINE(R_ZIP.CITY || ' ' ||R_ZIP.ZIP || ' ' ||r_zip.state);
  END LOOP;
END;


--------------------------------------------------------


SET SERVEROUTPUT ON
DECLARE
  CURSOR c_student
  IS
    SELECT first_name,
      last_name,
      student_id
    FROM student
    WHERE last_name LIKE 'J%';
  CURSOR c_course (i_student_id IN student.student_id%TYPE)
  IS
    SELECT c.description,
      s.section_id sec_id
    FROM course c,
      section s,
      enrollment e
    WHERE e.student_id = i_student_id
    AND c.course_no    = s.course_no
    AND s.section_id   = e.section_id;
  CURSOR c_grade(i_section_id IN section.section_id%TYPE, i_student_id IN student.student_id%TYPE)
  IS
    SELECT gt.description grd_desc,
      TO_CHAR (AVG(g.numeric_grade), '999.99') num_grd
    FROM enrollment e,
      grade g,
      grade_type gt
    WHERE e.section_id    = i_section_id
    AND e.student_id      = g.student_id
    AND e.student_id      = i_student_id
    AND e.section_id      = g.section_id
    AND g.grade_type_code = gt.grade_type_code
    GROUP BY gt.description ;
BEGIN
  FOR r_student IN c_student
  LOOP
    DBMS_OUTPUT.PUT_LINE(CHR(10));
    DBMS_OUTPUT.PUT_LINE(r_student.first_name|| ' '||r_student.last_name);
    FOR r_course IN c_course(r_student.student_id)
    LOOP
      DBMS_OUTPUT.PUT_LINE ('Grades for course :'|| r_course.description);
      FOR r_grade IN c_grade(r_course.sec_id, r_student.student_id)
      LOOP
        DBMS_OUTPUT.PUT_LINE(r_grade.num_grd|| ' '||r_grade.grd_desc);
      END LOOP;
    END LOOP;
  END LOOP;
END;

-----------------------------------------------------------------------------------

DECLARE
  CURSOR c_course
  IS
    SELECT course_no, cost FROM course FOR UPDATE;
BEGIN
  FOR r_course IN c_course
  LOOP
    IF r_course.cost < 2500 THEN
      UPDATE course
      SET cost        = r_course.cost + 10
      WHERE course_no = r_course.course_no;
    END IF;
  END LOOP;
END;


--------------------------------------------------------


DECLARE
  CURSOR c_grade( i_student_id IN enrollment.student_id%TYPE, i_section_id IN enrollment.section_id%TYPE)
  IS
    SELECT final_grade
    FROM enrollment
    WHERE student_id = i_student_id
    AND section_id   = i_section_id FOR UPDATE;
  CURSOR c_enrollment
  IS
    SELECT e.student_id,
      e.section_id
    FROM enrollment e,
      section s
    WHERE s.course_no = 135
    AND e.section_id  = s.section_id;
BEGIN
  FOR r_enroll IN c_enrollment
  LOOP
    FOR r_grade IN c_grade(r_enroll.student_id, r_enroll.section_id)
    LOOP
      UPDATE enrollment
      SET final_grade  = 90
      WHERE student_id = r_enroll.student_id
      AND section_id   = r_enroll.section_id;
    END LOOP;
  END LOOP;
END;

--------------------------------------------------------

DECLARE
  CURSOR c_stud_zip
  IS
    SELECT s.student_id,
      z.city
    FROM student s,
      zipcode z
    WHERE z.city = 'Brooklyn'
    AND s.zip    = z.zip FOR UPDATE OF phone;
BEGIN
  FOR r_stud_zip IN c_stud_zip
  LOOP
    UPDATE student
    SET phone = '718'
      ||SUBSTR(phone,4)
    WHERE student_id = r_stud_zip.student_id;
  END LOOP;
END;

--------------------------------------------------------

DECLARE
  CURSOR c_stud_zip
  IS
    SELECT s.student_id,
      z.city
    FROM student s,
      zipcode z
    WHERE z.city = 'Brooklyn'
    AND s.zip    = z.zip FOR UPDATE OF phone;
BEGIN
  FOR r_stud_zip IN c_stud_zip
  LOOP
    DBMS_OUTPUT.PUT_LINE(r_stud_zip.student_id);
    UPDATE student SET phone = '718'||SUBSTR(phone,4) WHERE CURRENT OF c_stud_zip;
  END LOOP;
END;


--------------------------------------------------------






