------------------------------------------------------------------------
SET SERVEROUTPUT ON
BEGIN
  UPDATE student SET first_name = 'B' WHERE first_name LIKE 'B%';
  DBMS_OUTPUT.PUT_LINE(SQL%ROWCOUNT);
END;

------------------------------------------------------------------------
SET SERVEROUTPUT ON;
DECLARE
  v_first_name VARCHAR2(35);
  v_last_name  VARCHAR2(35);
BEGIN
  SELECT first_name,
    last_name
  INTO v_first_name,
    v_last_name
  FROM student
  WHERE student_id = 123;
  DBMS_OUTPUT.PUT_LINE ('Student name: '|| v_first_name||' '||v_last_name);
EXCEPTION
WHEN NO_DATA_FOUND THEN
  DBMS_OUTPUT.PUT_LINE ('There is no student with student ID 123');
END;
------------------------------------------------------------------------
SET SERVEROUTPUT ON;
DECLARE
  vr_zip ZIPCODE%ROWTYPE;
BEGIN
  SELECT * INTO vr_zip FROM zipcode WHERE rownum < 2;
  DBMS_OUTPUT.PUT_LINE('City: '||vr_zip.city);
  DBMS_OUTPUT.PUT_LINE('State: '||vr_zip.state);
  DBMS_OUTPUT.PUT_LINE('Zip: '||VR_ZIP.ZIP);
END;


------------------------------------------------------------------------

DECLARE
  CURSOR c_student_name
  IS
    SELECT FIRST_NAME, LAST_NAME FROM STUDENT;
    
  vr_student_name c_student_name%ROWTYPE;

------------------------------------------------------------------------

DECLARE
  CURSOR c_student
  IS
    SELECT first_name||' '||Last_name name FROM STUDENT;
  vr_student c_student%ROWTYPE;
------------------------------------------------------------------------

BEGIN
  OPEN c_student;


------------------------------------------------------------------------

LOOP
  FETCH C_STUDENT INTO VR_STUDENT;
  DBMS_OUTPUT.PUT_LINE(VR_STUDENT.NAME);

------------------------------------------------------------------------

CLOSE C_STUDENT;

------------------------------------------------------------------------

SET SERVEROUTPUT ON;
DECLARE
  CURSOR c_student_name
  IS
    SELECT first_name, last_name FROM student WHERE rownum <= 5;
  vr_student_name c_student_name%ROWTYPE;
BEGIN
  OPEN c_student_name;
  LOOP
    FETCH C_STUDENT_NAME INTO VR_STUDENT_NAME;
    EXIT WHEN c_student_name%NOTFOUND;
    DBMS_OUTPUT.PUT_LINE('Student name: '|| vr_student_name.first_name ||' '||vr_student_name.last_name);
  END LOOP;
  CLOSE C_STUDENT_NAME;
END;

------------------------------------------------------------------------

SET SERVEROUTPUT ON;
DECLARE
  CURSOR c_student_name
  IS
    SELECT first_name, last_name FROM student WHERE rownum <= 5;
  vr_student_name c_student_name%ROWTYPE;
BEGIN
  OPEN c_student_name;
  LOOP
    FETCH c_student_name INTO vr_student_name;
    EXIT
  WHEN c_student_name%NOTFOUND;
  END LOOP;
  CLOSE c_student_name;
  DBMS_OUTPUT.PUT_LINE('Student name: '|| vr_student_name.first_name||' ' ||vr_student_name.last_name);
END;

------------------------------------------------------------------------

SET SERVEROUTPUT ON;
DECLARE
TYPE instructor_info IS RECORD
  (
    first_name instructor.first_name%TYPE,
    last_name instructor.last_name%TYPE,
    SECTIONS NUMBER
  );
    
  rv_instructor instructor_info;
BEGIN
  SELECT RTRIM(i.first_name),
    RTRIM(i.last_name),
    COUNT(*)
  INTO rv_instructor
  FROM instructor i,
    section s
  WHERE i.instructor_id = s.instructor_id
  AND i.instructor_id   = 102
  GROUP BY i.first_name,
    i.last_name;
  DBMS_OUTPUT.PUT_LINE('Instructor, '|| rv_instructor.first_name|| ' '||rv_instructor.last_name|| ', teaches '||rv_instructor.sections|| ' section(s)');
EXCEPTION
WHEN NO_DATA_FOUND THEN
  DBMS_OUTPUT.PUT_LINE ('There is no such instructor');
END;

------------------------------------------------------------------------

EXIT
WHEN c_student%NOTFOUND;
END LOOP;
CLOSE c_student;
EXCEPTION
WHEN OTHERS THEN
  IF c_student%ISOPEN THEN
    CLOSE c_student;
  END IF;
END;
------------------------------------------------------------------------
SET SERVEROUTPUT ON
DECLARE
  v_city zipcode.city%type;
BEGIN
  SELECT city INTO v_city FROM zipcode WHERE zip = 07002;
  IF SQL%ROWCOUNT = 1 THEN
    DBMS_OUTPUT.PUT_LINE(v_city ||' has a '|| 'zipcode of 07002');
  ELSIF SQL%ROWCOUNT = 0 THEN
    DBMS_OUTPUT.PUT_LINE('The zipcode 07002 is '|| ' not in the database');
  ELSE
    DBMS_OUTPUT.PUT_LINE('Stop harassing me');
  END IF;
END;
------------------------------------------------------------------------
DECLARE
  v_sid student.student_id%TYPE;
  CURSOR c_student
  IS
    SELECT student_id FROM student WHERE student_id < 110;
BEGIN
  OPEN c_student;
  LOOP
    FETCH C_STUDENT INTO V_SID;
    EXIT WHEN c_student%NOTFOUND;
    DBMS_OUTPUT.PUT_LINE('STUDENT ID : '||v_sid);
  END LOOP;
  CLOSE c_student;
EXCEPTION
WHEN OTHERS THEN
  IF c_student%ISOPEN THEN
    CLOSE c_student;
  END IF;
END;
------------------------------------------------------------------------
SET SERVEROUTPUT ON
DECLARE
  v_sid student.student_id%TYPE;
  CURSOR c_student
  IS
    SELECT student_id FROM student WHERE student_id < 110;
BEGIN
  OPEN c_student;
  LOOP
    FETCH c_student INTO v_sid;
    IF c_student%FOUND THEN
      DBMS_OUTPUT.PUT_LINE ('Just FETCHED row ' ||TO_CHAR(c_student%ROWCOUNT)|| ' Student ID: '||v_sid);
    ELSE
      EXIT;
    END IF;
  END LOOP;
  CLOSE c_student;
EXCEPTION
WHEN OTHERS THEN
  IF c_student%ISOPEN THEN
    CLOSE c_student;
  END IF;
END;

------------------------------------------------------------------------

SET SERVEROUTPUT ON
DECLARE
  CURSOR c_student_enroll
  IS
    SELECT s.student_id,
      first_name,
      last_name,
      COUNT(*) enroll,
      (
      CASE
        WHEN COUNT(*) = 1
        THEN ' class.'
        WHEN COUNT(*) IS NULL
        THEN ' no classes.'
        ELSE ' classes.'
      END) class
    FROM student s,
      enrollment e
    WHERE s.student_id = e.student_id
    AND s.student_id   <110
    GROUP BY s.student_id,
      first_name,
      last_name;
  r_student_enroll c_student_enroll%ROWTYPE;
BEGIN
  OPEN c_student_enroll;
  LOOP
    FETCH c_student_enroll INTO r_student_enroll;
    EXIT WHEN c_student_enroll%NOTFOUND;
    DBMS_OUTPUT.PUT_LINE('Student INFO: ID '|| r_student_enroll.student_id||' is '|| r_student_enroll.first_name|| ' ' || r_student_enroll.last_name|| ' is enrolled in '||r_student_enroll.enroll|| r_student_enroll.class);
  END LOOP;
  CLOSE c_student_enroll;
EXCEPTION
WHEN OTHERS THEN
  IF c_student_enroll %ISOPEN THEN
    CLOSE c_student_enroll;
  END IF;
END;

-------------------------------------------------------------------------------------------

------------------------------------------------------------------------

CREATE TABLE TABLE_LOG
(description VARCHAR2(250));
------------------------------------------------------------------------
DECLARE
  CURSOR c_student
  IS
    SELECT student_id, last_name, first_name FROM student WHERE student_id < 110;
BEGIN
  FOR r_student IN c_student
  LOOP
    INSERT INTO table_log VALUES
      (r_student.last_name
      );
  END LOOP;
END;
------------------------------------------------------------------------
DECLARE
  CURSOR c_group_discount
  IS
    SELECT DISTINCT s.course_no
    FROM section s,
      enrollment e
    WHERE s.section_id = e.section_id
    GROUP BY s.course_no,
      e.section_id,
      s.section_id
    HAVING COUNT(*)>=8;
BEGIN
  FOR r_group_discount IN c_group_discount
  LOOP
    UPDATE course
    SET cost        = cost * .95
    WHERE course_no = r_group_discount.course_no;
  END LOOP;
  COMMIT;
END;

------------------------------------------------------------------------
DECLARE
  v_zip zipcode.zip%TYPE;
  v_student_flag CHAR;
  CURSOR c_zip
  IS
    SELECT zip, city, state FROM zipcode WHERE state = 'CT';
  CURSOR c_student
  IS
    SELECT first_name, last_name FROM student WHERE zip = v_zip;
BEGIN
  FOR r_zip IN c_zip
  LOOP
    v_student_flag := 'N';
    v_zip          := r_zip.zip;
    DBMS_OUTPUT.PUT_LINE(CHR(10));
    DBMS_OUTPUT.PUT_LINE('Students living in '|| r_zip.city);
    FOR r_student IN c_student
    LOOP
      DBMS_OUTPUT.PUT_LINE( r_student.first_name|| ' '||r_student.last_name);
      v_student_flag := 'Y';
    END LOOP;
    IF v_student_flag = 'N' THEN
      DBMS_OUTPUT.PUT_LINE ('No Students for this zipcode');
    END IF;
  END LOOP;
END;

------------------------------------------------------------------------
SET SERVEROUTPUT ON
DECLARE
  v_sid student.student_id%TYPE;
  CURSOR c_student
  IS
    SELECT student_id, first_name, last_name FROM student WHERE student_id < 110;
  CURSOR c_course
  IS
    SELECT c.course_no,
      c.description
    FROM course c,
      section s,
      enrollment e
    WHERE c.course_no = s.course_no
    AND s.section_id  = e.section_id
    AND e.student_id  = v_sid;
BEGIN
  FOR r_student IN c_student
  LOOP
    v_sid := r_student.student_id;
    DBMS_OUTPUT.PUT_LINE(chr(10));
    DBMS_OUTPUT.PUT_LINE(' The Student '|| r_student.student_id||' '|| r_student.first_name||' '|| r_student.last_name);
    DBMS_OUTPUT.PUT_LINE(' is enrolled in the '|| 'following courses: ');
    FOR r_course IN c_course
    LOOP
      DBMS_OUTPUT.PUT_LINE(r_course.course_no|| ' '||r_course.description);
    END LOOP;
  END LOOP;
END;


------------------------------------------------------------------------


SET SERVEROUTPUT ON
DECLARE
  CURSOR c_course
  IS
    SELECT course_no, description FROM course WHERE course_no < 120;
  CURSOR c_enrollment(p_course_no IN course.course_no%TYPE)
  IS
    SELECT s.section_no section_no,
      COUNT(*) COUNT
    FROM section s,
      enrollment e
    WHERE s.course_no = p_course_no
    AND s.section_id  = e.section_id
    GROUP BY s.section_no;
BEGIN
  FOR r_course IN c_course
  LOOP
    DBMS_OUTPUT.PUT_LINE (r_course.course_no||' '|| r_course.description);
    FOR r_enroll IN c_enrollment(r_course.course_no)
    LOOP
      DBMS_OUTPUT.PUT_LINE (Chr(9)||'Section: '||r_enroll.section_no|| ' has an enrollment of: '||r_enroll.count);
    END LOOP;
  END LOOP;
END;

------------------------------------------------------------------------


SET SERVEROUTPUT ON
DECLARE
  v_instid_min instructor.instructor_id%TYPE;
  v_section_id_new section.section_id%TYPE;
  v_snumber_recent section.section_no%TYPE := 0;
  -- This cursor determines the courses that have at least
  -- one section filled to capacity.
  CURSOR c_filled
  IS
    SELECT DISTINCT s.course_no
    FROM section s
    WHERE s.capacity =
      (SELECT COUNT(section_id) FROM enrollment e WHERE e.section_id = s.section_id
      );
BEGIN
  FOR r_filled IN c_filled
  LOOP
    -- For each course in this list, add another section.
    -- First, determine the instructor who is teaching
    -- the fewest courses. If more than one instructor
    -- is teaching the same number of minimum courses
    -- (e.g. if there are three instructors teaching one
    -- course) use any of those instructors.
    SELECT instructor_id
    INTO v_instid_min
    FROM instructor
    WHERE EXISTS
      (SELECT NULL
      FROM section
      WHERE section.instructor_id = instructor.instructor_id
      GROUP BY instructor_id
      HAVING COUNT(       *) =
        (SELECT MIN(COUNT(*))
        FROM section
        WHERE instructor_id IS NOT NULL
        GROUP BY instructor_id
        )
      )
    AND ROWNUM = 1;
    -- Determine the section_id for the new section.
    -- Note that this method would not work in a multiuser
    -- environment. A sequence should be used instead.
    SELECT MAX(section_id) + 1
    INTO v_section_id_new
    FROM section;
    -- Determine the section number for the new section.
    -- This only needs to be done in the real world if
    -- the system specification calls for a sequence in
    -- a parent. The sequence in parent here refers to
    -- the section_no incrementing within the course_no,
    -- and not the section_no incrementing within the
    -- section_id.
    DECLARE
      CURSOR c_snumber_in_parent
      IS
        SELECT section_no
        FROM section
        WHERE course_no = r_filled.course_no
        ORDER BY section_no;
    BEGIN
      -- Go from the lowest to the highest section_no
      -- and find any gaps. If there are no gaps make
      -- the new section_no equal to the highest
      -- current section_no + 1.
      FOR r_snumber_in_parent IN c_snumber_in_parent
      LOOP
        EXIT
      WHEN r_snumber_in_parent.section_no > v_snumber_recent               + 1;
        v_snumber_recent                 := r_snumber_in_parent.section_no + 1;
      END LOOP;
      -- At this point, v_snumber_recent will be equal
      -- either to the value preceeding the gap or to
      -- the highest section_no for that course.
    END;
    -- Do the insert.
    INSERT
    INTO section
      (
        section_id,
        course_no,
        section_no,
        instructor_id
      )
      VALUES
      (
        v_section_id_new,
        r_filled.course_no,
        v_snumber_recent,
        v_instid_min
      );
    COMMIT;
  END LOOP;
EXCEPTION
WHEN OTHERS THEN
  DBMS_OUTPUT.PUT_LINE ('An error has occurred');
END;







