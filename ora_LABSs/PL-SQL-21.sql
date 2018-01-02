--MODULE 21
-----------



--Packages
-----------
--The Benefits of Using Packages

CREATE OR REPLACE
PACKAGE manage_students
AS
  PROCEDURE find_sname(
      i_student_id IN student.student_id%TYPE,
      o_first_name OUT student.first_name%TYPE,
      o_last_name OUT student.last_name%TYPE );
  FUNCTION id_is_good(
      i_student_id IN student.student_id%TYPE)
    RETURN BOOLEAN;
END MANAGE_STUDENTS;

SET SERVEROUTPUT ON
DECLARE
  v_first_name student.first_name%TYPE;
  v_last_name student.last_name%TYPE;
BEGIN
  manage_students.find_sname (125, v_first_name, v_last_name);
  DBMS_OUTPUT.PUT_LINE(V_FIRST_NAME||' '||V_LAST_NAME);
END;

--------------------------------------------------------------------------


CREATE OR REPLACE
PACKAGE school_api
AS
  PROCEDURE discount;
  FUNCTION new_instructor_id
    RETURN INSTRUCTOR.INSTRUCTOR_ID%TYPE;
END school_api;

--------------------------------------------------------------------------
--21.1.2 Create Package Bodies

CREATE OR REPLACE
PACKAGE BODY manage_students
AS
PROCEDURE find_sname(
    i_student_id IN student.student_id%TYPE,
    o_first_name OUT student.first_name%TYPE,
    o_last_name OUT student.last_name%TYPE )
IS
  v_student_id student.student_id%TYPE;
BEGIN
  SELECT first_name,
    last_name
  INTO o_first_name,
    o_last_name
  FROM student
  WHERE student_id = i_student_id;
EXCEPTION
WHEN OTHERS THEN
  DBMS_OUTPUT.PUT_LINE ('Error in finding student_id: '||v_student_id);
END find_sname;
FUNCTION id_is_good(
    i_student_id IN student.student_id%TYPE)
  RETURN BOOLEAN
IS
  v_id_cnt NUMBER;
BEGIN
  SELECT COUNT(*) INTO v_id_cnt FROM student WHERE student_id = i_student_id;
  RETURN 1 = v_id_cnt;
EXCEPTION
WHEN OTHERS THEN
  RETURN FALSE;
END ID_IS_GOOD;
END manage_students;


--------------------------------------------------------------------------


CREATE OR REPLACE
PACKAGE BODY school_api
AS
PROCEDURE discount
IS
  CURSOR c_group_discount
  IS
    SELECT DISTINCT s.course_no,
      c.description
    FROM section s,
      enrollment e,
      course c
    WHERE s.section_id = e.section_id
    GROUP BY s.course_no,
      c.description,
      e.section_id,
      s.section_id
    HAVING COUNT(*) >=8;
BEGIN
  FOR r_group_discount IN c_group_discount
  LOOP
    UPDATE course
    SET cost        = cost * .95
    WHERE course_no = r_group_discount.course_no;
    DBMS_OUTPUT.PUT_LINE ('A 5% discount has been given to' ||r_group_discount.course_no||' '||r_group_discount.description);
  END LOOP;
END discount;
FUNCTION new_instructor_id
  RETURN instructor.instructor_id%TYPE
IS
  v_new_instid instructor.instructor_id%TYPE;
BEGIN
  SELECT INSTRUCTOR_ID_SEQ.NEXTVAL INTO v_new_instid FROM dual;
  RETURN v_new_instid;
EXCEPTION
WHEN OTHERS THEN
  DECLARE
    v_sqlerrm VARCHAR2(250) := SUBSTR(SQLERRM,1,250);
  BEGIN
    RAISE_APPLICATION_ERROR(-20003, 'Error in instructor_id: '||v_sqlerrm);
  END;
END NEW_INSTRUCTOR_ID;
END school_api;
--------------------------------------------------------------------------
SET SERVEROUTPUT ON
DECLARE
  v_first_name student.first_name%TYPE;
  v_last_name student.last_name%TYPE;
BEGIN
  IF manage_students.id_is_good(&&v_id) THEN
    manage_students.find_sname(&&v_id, v_first_name, v_last_name);
    DBMS_OUTPUT.PUT_LINE('Student No. '||&&v_id||' is ' ||v_last_name||', '||v_first_name);
  ELSE
    DBMS_OUTPUT.PUT_LINE ('Student ID: '||&&v_id||' is not in the database.');
  END IF;
END;
--------------------------------------------------------------------------
SET SERVEROUTPUT ON
DECLARE
  V_instructor_id instructor.instructor_id%TYPE;
BEGIN
  School_api.Discount;
  v_instructor_id := school_api.new_instructor_id;
  DBMS_OUTPUT.PUT_LINE ('The new id is: '||V_INSTRUCTOR_ID);
END;

--------------------------------------------------------------------------
PROCEDURE DISPLAY_STUDENT_COUNT;
 END manage_students;
--------------------------------------------------------------------------
FUNCTION student_count_priv
  RETURN NUMBER
IS
  v_count NUMBER;
BEGIN
  SELECT COUNT(*) INTO v_count FROM student;
  RETURN v_count;
EXCEPTION
WHEN OTHERS THEN
  RETURN(0);
END student_count_priv;
PROCEDURE display_student_count
IS
  v_count NUMBER;
BEGIN
  v_count := student_count_priv;
  DBMS_OUTPUT.PUT_LINE ('There are '||v_count||' students.');
END DISPLAY_STUDENT_COUNT;
END manage_students;
--------------------------------------------------------------------------
DECLARE
  V_count NUMBER;
BEGIN
  V_count := Manage_students.student_count_priv;
  DBMS_OUTPUT.PUT_LINE(V_COUNT);
END;

--------------------------------------------------------------------------

SET SERVEROUTPUT ON
Execute manage_students.display_student_count;

--------------------------------------------------------------------------
FUNCTION get_course_descript_private(
    i_course_no course.course_no%TYPE)
  RETURN course.description%TYPE
IS
  v_course_descript course.description%TYPE;
BEGIN
  SELECT description
  INTO v_course_descript
  FROM course
  WHERE course_no = i_course_no;
  RETURN v_course_descript;
EXCEPTION
WHEN OTHERS THEN
  RETURN NULL;
END GET_COURSE_DESCRIPT_PRIVATE;
END manage_students;
--------------------------------------------------------------------------
CREATE OR REPLACE
PACKAGE school_api
AS
  v_current_date DATE;
  PROCEDURE Discount_Cost;
  FUNCTION new_instructor_id
    RETURN INSTRUCTOR.INSTRUCTOR_ID%TYPE;
END school_api;

--------------------------------------------------------------------------
CREATE OR REPLACE
PACKAGE BODY school_api
AS
PROCEDURE discount_cost
IS
  CURSOR c_group_discount
  IS
    SELECT DISTINCT s.course_no,
      c.description
    FROM section s,
      enrollment e,
      course c
    WHERE s.section_id = e.section_id
    GROUP BY s.course_no,
      c.description,
      e.section_id,
      s.section_id
    HAVING COUNT(*) >=8;
BEGIN
  FOR r_group_discount IN c_group_discount
  LOOP
    UPDATE course
    SET cost        = cost * .95
    WHERE course_no = r_group_discount.course_no;
    DBMS_OUTPUT.PUT_LINE ('A 5% discount has been given to' ||r_group_discount.course_no||' 
'||r_group_discount.description);
  END LOOP;
END discount_cost;
FUNCTION new_instructor_id
  RETURN instructor.instructor_id%TYPE
IS
  v_new_instid instructor.instructor_id%TYPE;
BEGIN
  SELECT INSTRUCTOR_ID_SEQ.NEXTVAL INTO v_new_instid FROM dual;
  RETURN v_new_instid;
EXCEPTION
WHEN OTHERS THEN
  DECLARE
    v_sqlerrm VARCHAR2(250) := SUBSTR(SQLERRM,1,250);
  BEGIN
    RAISE_APPLICATION_ERROR(-20003, 'Error in instructor_id: '||v_sqlerrm);
  END;
END new_instructor_id;
BEGIN
  SELECT TRUNC(sysdate, 'DD') INTO v_current_date FROM DUAL;
END school_api;


---------------------------------------------------------------------------------------

--Cursor Variables

--------------------------------------------------------------------------
--package içinde cursor variable (REF CURSOR) kullan?m?
-- ch21_9a.sql
CREATE OR REPLACE
PACKAGE course_pkg
AS
TYPE course_rec_typ
IS
  RECORD
  (
    first_name student.first_name%TYPE,
    last_name student.last_name%TYPE,
    course_no course.course_no%TYPE,
    description course.description%TYPE,
    section_no section.section_no%TYPE );
TYPE course_cur
IS
  REF
  CURSOR
    RETURN course_rec_typ;
    PROCEDURE get_course_list(
        p_student_id    NUMBER ,
        p_instructor_id NUMBER ,
        course_list_cv IN OUT course_cur);
  END course_pkg;
  /
  
  
  
CREATE OR REPLACE
PACKAGE BODY course_pkg
AS
PROCEDURE get_course_list(
    p_student_id    NUMBER ,
    p_instructor_id NUMBER ,
    course_list_cv IN OUT course_cur)
IS
BEGIN
  IF p_student_id IS NULL AND p_instructor_id IS NULL THEN
    OPEN COURSE_LIST_CV FOR SELECT 'Please choose a student-' FIRST_NAME, 'instructor combination' LAST_NAME, NULL COURSE_NO, NULL DESCRIPTION, NULL SECTION_NO 
                            FROM dual;
  ELSIF p_student_id  IS NULL THEN
    OPEN course_list_cv FOR SELECT s.first_name first_name, s.last_name last_name, c.course_no course_no, c.description description, se.section_no section_no
                            FROM INSTRUCTOR I, STUDENT S, SECTION SE, COURSE C, ENROLLMENT E 
                            WHERE i.instructor_id = p_instructor_id AND i.instructor_id = se.instructor_id AND se.course_no = c.course_no AND e.student_id = s.student_id AND e.section_id = se.section_id
                            ORDER BY c.course_no, se.section_no;
  ELSIF p_instructor_id  IS NULL THEN
    OPEN COURSE_LIST_CV FOR SELECT I.FIRST_NAME FIRST_NAME, I.LAST_NAME LAST_NAME, C.COURSE_NO COURSE_NO, C.DESCRIPTION DESCRIPTION, SE.SECTION_NO SECTION_NO 
                            FROM INSTRUCTOR I, STUDENT S, SECTION SE, COURSE C, ENROLLMENT E 
                            WHERE s.student_id    = p_student_id AND i.instructor_id = se.instructor_id AND se.course_no = c.course_no AND e.student_id = s.student_id AND e.section_id = se.section_id
                            ORDER BY c.course_no, se.section_no;
  END IF;
END GET_COURSE_LIST;
END course_pkg;



--21.2.1 Make Use of Cursor Variables

--------------------------------------------------------------------------

VARIABLE course_cv REFCURSOR


EXEC COURSE_PKG.GET_COURSE_LIST(102, NULL, :COURSE_CV);


PRINT COURSE_CV


exec course_pkg.get_course_list(NULL, 102, :course_cv);

PRINT COURSE_CV


exec course_pkg.get_course_list(NULL, NULL, :course_cv);



PRINT COURSE_CV


CREATE OR REPLACE
PACKAGE student_info_pkg
AS
TYPE student_details
IS
  REF
  CURSOR;
    PROCEDURE get_student_info(
        p_student_id NUMBER ,
        p_choice     NUMBER ,
        details_cv IN OUT student_details);
  END student_info_pkg;
  /
  
  
  --------------------------------------------------------------------------
  
  
CREATE OR REPLACE
PACKAGE BODY student_info_pkg
AS
PROCEDURE get_student_info(
    p_student_id NUMBER ,
    p_choice     NUMBER ,
    details_cv IN OUT student_details)
IS
BEGIN
  IF p_choice = 1 THEN
    OPEN DETAILS_CV FOR SELECT S.FIRST_NAME FIRST_NAME, S.LAST_NAME LAST_NAME, S.STREET_ADDRESS ADDRESS, Z.CITY CITY, Z.STATE STATE, Z.ZIP ZIP 
                        FROM STUDENT S, ZIPCODE Z 
                        WHERE s.student_id = p_student_id AND z.zip = s.zip;
  ELSIF p_choice = 2 THEN
    OPEN details_cv FOR SELECT c.course_no course_no, c.description description, se.section_no section_no, s.first_name first_name, s.last_name last_name
                        FROM STUDENT S, SECTION SE, COURSE C, ENROLLMENT E 
                        WHERE se.course_no = c.course_no AND e.student_id = s.student_id AND e.section_id = se.section_id AND se.section_id IN
    (SELECT e.section_id
    FROM student s,
      enrollment e
    WHERE s.student_id = p_student_id
    AND s.student_id   = e.student_id
    ) ORDER BY c.course_no;
  ELSIF p_choice = 3 THEN
    OPEN details_cv FOR SELECT i.first_name first_name, i.last_name last_name, c.course_no course_no, c.description description, se.section_no section_no
                        FROM INSTRUCTOR I, STUDENT S, SECTION SE, COURSE C, ENROLLMENT E 
                        WHERE S.STUDENT_ID = P_STUDENT_ID AND I.INSTRUCTOR_ID = SE.INSTRUCTOR_ID AND SE.COURSE_NO = C.COURSE_NO AND E.STUDENT_ID = S.STUDENT_ID AND E.SECTION_ID = SE.SECTION_ID 
                        ORDER BY c.course_no, se.section_no;
  END IF;
END GET_STUDENT_INFO;
END student_info_pkg;

--------------------------------------------------------------------------


VARIABLE student_cv REFCURSOR
execute student_info_pkg.GET_STUDENT_INFO(102, 1, :student_cv);

PRINT STUDENT_CV

--------------------------------------------------------------------------


execute student_info_pkg.GET_STUDENT_INFO(102, 2, :student_cv);

PRINT STUDENT_CV

--------------------------------------------------------------------------
execute student_info_pkg.GET_STUDENT_INFO(214, 3, :student_cv);

PRINT STUDENT_CV

--------------------------------------------------------------------------
CREATE OR REPLACE
PACKAGE MANAGE_GRADES
AS
  -- Cursor to loop through all grade types for a given section.
  CURSOR c_grade_type (pc_section_id section.section_id%TYPE, PC_student_ID student.student_id%TYPE)
  IS
    SELECT GRADE_TYPE_CODE,
      NUMBER_PER_SECTION,
      PERCENT_OF_FINAL_GRADE,
      DROP_LOWEST
    FROM grade_Type_weight
    WHERE section_id = pc_section_id
    AND section_id  IN
      (SELECT section_id FROM grade WHERE STUDENT_ID = PC_STUDENT_ID
      );
END MANAGE_GRADES;



--------------------------------------------------------------------------


-- ch21_11b.sql
CREATE OR REPLACE
PACKAGE MANAGE_GRADES
AS
  -- Cursor to loop through all grade types for a given section.
  CURSOR c_grade_type (pc_section_id section.section_id%TYPE, PC_student_ID student.student_id%TYPE)
  IS
    SELECT GRADE_TYPE_CODE,
      NUMBER_PER_SECTION,
      PERCENT_OF_FINAL_GRADE,
      DROP_LOWEST
    FROM grade_Type_weight
    WHERE section_id = pc_section_id
    AND section_id  IN
      (SELECT section_id FROM grade WHERE student_id = pc_student_id
      );
  -- Cursor to loop through all grades for a given student
  -- in a given section.
  CURSOR c_grades (p_grade_type_code grade_Type_weight.grade_type_code%TYPE, pc_student_id student.student_id%TYPE, pc_section_id section.section_id%TYPE)
  IS
    SELECT grade_type_code,
      grade_code_occurrence,
      numeric_grade
    FROM grade
    WHERE student_id    = pc_student_id
    AND section_id      = pc_section_id
    AND GRADE_TYPE_CODE = P_GRADE_TYPE_CODE;
END MANAGE_GRADES;

--------------------------------------------------------------------------
CREATE OR REPLACE
PACKAGE MANAGE_GRADES
AS
  -- Cursor to loop through all grade types for a given section.
  CURSOR c_grade_type (pc_section_id section.section_id%TYPE, PC_student_ID student.student_id%TYPE)
  IS
    SELECT GRADE_TYPE_CODE,
      NUMBER_PER_SECTION,
      PERCENT_OF_FINAL_GRADE,
      DROP_LOWEST
    FROM grade_Type_weight
    WHERE section_id = pc_section_id
    AND section_id  IN
      (SELECT section_id FROM grade WHERE student_id = pc_student_id
      );
  -- Cursor to loop through all grades for a given student
  -- in a given section.
  CURSOR c_grades (p_grade_type_code grade_Type_weight.grade_type_code%TYPE, pc_student_id student.student_id%TYPE, pc_section_id section.section_id%TYPE)
  IS
    SELECT grade_type_code,
      grade_code_occurrence,
      numeric_grade
    FROM grade
    WHERE student_id    = pc_student_id
    AND section_id      = pc_section_id
    AND grade_type_code = p_grade_type_code;
  -- Function to calcuate a student's final grade
  -- in one section
  PROCEDURE final_grade(
      P_student_id IN student.student_id%type,
      P_section_id IN section.section_id%TYPE,
      P_Final_grade OUT enrollment.final_grade%TYPE,
      P_EXIT_CODE OUT CHAR);
END MANAGE_GRADES;

--------------------------------------------------------------------------


CREATE OR REPLACE
PACKAGE BODY MANAGE_GRADES
AS
PROCEDURE final_grade(
    P_student_id IN student.student_id%type,
    P_section_id IN section.section_id%TYPE,
    P_Final_grade OUT enrollment.final_grade%TYPE,
    P_Exit_Code OUT CHAR)
IS
  v_student_id student.student_id%TYPE;
  v_section_id section.section_id%TYPE;
  v_grade_type_code grade_type_weight.grade_type_code%TYPE;
  v_grade_percent NUMBER;
  v_final_grade   NUMBER;
  v_grade_count   NUMBER;
  v_lowest_grade  NUMBER;
  v_exit_code     CHAR(1) := 'S';
  v_no_rows1      CHAR(1) := 'N';
  v_no_rows2      CHAR(1) := 'N';
  e_no_grade      EXCEPTION;
BEGIN
  NULL;
END;
END MANAGE_GRADES;

--------------------------------------------------------------------------


CREATE OR REPLACE
PACKAGE BODY MANAGE_GRADES
AS
PROCEDURE final_grade(
    P_student_id IN student.student_id%type,
    P_section_id IN section.section_id%TYPE,
    P_Final_grade OUT enrollment.final_grade%TYPE,
    P_Exit_Code OUT CHAR)
IS
  v_student_id student.student_id%TYPE;
  v_section_id section.section_id%TYPE;
  v_grade_type_code grade_type_weight.grade_type_code%TYPE;
  v_grade_percent NUMBER;
  v_final_grade   NUMBER;
  v_grade_count   NUMBER;
  v_lowest_grade  NUMBER;
  v_exit_code     CHAR(1) := 'S';
  v_no_rows1      CHAR(1) := 'N';
  v_no_rows2      CHAR(1) := 'N';
  e_no_grade      EXCEPTION;
BEGIN
  v_section_id := p_section_id;
  v_student_id := p_student_id;
  -- Start loop of grade types for the section.
  FOR r_grade IN c_grade_type(v_section_id, v_student_id)
  LOOP
    -- Since cursor is open it has a result
    -- set; change indicator.
    v_no_rows1 := 'Y';
    -- To hold the number of grades per section,
    -- reset to 0 before detailed cursor loops
    v_grade_count     := 0;
    v_grade_type_code := r_grade.GRADE_TYPE_CODE;
    -- Variable to hold the lowest grade.
    -- 500 will not be the lowest grade.
    v_lowest_grade := 500;
    -- Determine what to multiply a grade by to
    -- compute final grade. Must take into consideration
    -- if the drop lowest grade indicator is Y.
    SELECT (r_grade.percent_of_final_grade / DECODE(r_grade.drop_lowest, 'Y', (r_grade.number_per_section - 1), r_grade.number_per_section ))* 0.01
    INTO v_grade_percent
    FROM dual;
    -- Open cursor of detailed grade for a student in a
    -- given section.
    FOR r_detail IN c_grades(v_grade_type_code, v_student_id, v_section_id)
    LOOP
      -- Since cursor is open it has a result
      -- set; change indicator.
      v_no_rows2    := 'Y';
      v_grade_count := v_grade_count + 1;
      -- Handle the situation where there are more
      -- entries for grades of a given grade type
      -- than there should be for that section.
      IF v_grade_count > r_grade.number_per_section THEN
        v_exit_code   := 'T';
        raise e_no_grade;
      END IF;
      -- If drop lowest flag is Y, determine which is lowest
      -- grade to drop
      IF r_grade.drop_lowest       = 'Y' THEN
        IF NVL(v_lowest_grade, 0) >= r_detail.numeric_grade THEN
          v_lowest_grade          := r_detail.numeric_grade;
        END IF;
      END IF;
      -- Increment the final grade with percentage of current
      -- grade in the detail loop.
      v_final_grade := NVL(v_final_grade, 0) + (r_detail.numeric_grade * v_grade_percent);
    END LOOP;
    -- Once detailed loop is finished, if the number of grades
    -- for a given student for a given grade type and section
    -- is less than the required amount, raise an exception.
    IF v_grade_count < r_grade.NUMBER_PER_SECTION THEN
      v_exit_code   := 'I';
      raise e_no_grade;
    END IF;
    -- If the drop lowest flag was Y, you need to take
    -- the lowest grade out of the final grade. It was not
    -- known when it was added which was the lowest grade
    -- to drop until all grades were examined.
    IF r_grade.drop_lowest = 'Y' THEN
      v_final_grade       := NVL(v_final_grade, 0) -
      (v_lowest_grade                              * v_grade_percent);
    END IF;
  END LOOP;
  -- If either cursor had no rows, there is an error.
  IF v_no_rows1  = 'N' OR v_no_rows2 = 'N' THEN
    v_exit_code := 'N';
    raise e_no_grade;
  END IF;
  P_final_grade := v_final_grade;
  P_exit_code   := v_exit_code;
EXCEPTION
WHEN e_no_grade THEN
  P_final_grade := NULL;
  P_exit_code   := v_exit_code;
WHEN OTHERS THEN
  P_final_grade := NULL;
  P_exit_code   := 'E';
END FINAL_GRADE;
END MANAGE_GRADES;


--------------------------------------------------------------------------


DESC MANAGE_GRADES

--------------------------------------------------------------------------

-- ch21_11f.sql
SET SERVEROUTPUT ON
DECLARE
  v_student_id student.student_id%TYPE := &sv_student_id;
  v_section_id section.section_id%TYPE := &sv_section_id;
  v_final_grade enrollment.final_grade%TYPE;
  v_exit_code CHAR;
BEGIN
  manage_grades.final_grade(v_student_id, v_section_id, v_final_grade, v_exit_code);
  DBMS_OUTPUT.PUT_LINE('The Final Grade is '||v_final_grade);
  DBMS_OUTPUT.PUT_LINE('The Exit Code is '||V_EXIT_CODE);
END;
--------------------------------------------------------------------------
CREATE OR REPLACE
PACKAGE MANAGE_GRADES
AS
  -- Cursor to loop through all grade types for a given section.
  CURSOR c_grade_type (pc_section_id section.section_id%TYPE, PC_student_ID student.student_id%TYPE)
  IS
    SELECT GRADE_TYPE_CODE,
      NUMBER_PER_SECTION,
      PERCENT_OF_FINAL_GRADE,
      DROP_LOWEST
    FROM grade_Type_weight
    WHERE section_id = pc_section_id
    AND section_id  IN
      (SELECT section_id FROM grade WHERE student_id = pc_student_id
      );
  -- Cursor to loop through all grades for a given student
  -- in a given section.
  CURSOR c_grades (p_grade_type_code grade_Type_weight.grade_type_code%TYPE, pc_student_id student.student_id%TYPE, pc_section_id section.section_id%TYPE)
  IS
    SELECT grade_type_code,
      grade_code_occurrence,
      numeric_grade
    FROM grade
    WHERE student_id    = pc_student_id
    AND section_id      = pc_section_id
    AND grade_type_code = p_grade_type_code;
  -- Function to calcuate a student's final grade
  -- in one section
  PROCEDURE final_grade(
      P_student_id IN student.student_id%type,
      P_section_id IN section.section_id%TYPE,
      P_Final_grade OUT enrollment.final_grade%TYPE,
      P_Exit_Code OUT CHAR);
  -- ---------------------------------------------------------
  -- Function to calculate the median grade
  FUNCTION median_grade(
      p_course_number section.course_no%TYPE,
      p_section_number section.section_no%TYPE,
      p_grade_type grade.grade_type_code%TYPE)
    RETURN grade.numeric_grade%TYPE;
  CURSOR c_work_grade (p_course_no section.course_no%TYPE, p_section_no section.section_no%TYPE, p_grade_type_code grade.grade_type_code%TYPE )
  IS
    SELECT DISTINCT numeric_grade
    FROM grade
    WHERE section_id =
      (SELECT section_id
      FROM section
      WHERE course_no= p_course_no
      AND section_no = p_section_no
      )
  AND grade_type_code = p_grade_type_code
  ORDER BY numeric_grade;
TYPE t_grade_type
IS
  TABLE OF c_work_grade%ROWTYPE INDEX BY BINARY_INTEGER;
  T_GRADE T_GRADE_TYPE;
END MANAGE_GRADES;



--------------------------------------------------------------------------
CREATE OR REPLACE
PACKAGE BODY MANAGE_GRADES
AS
PROCEDURE final_grade(
    P_student_id IN student.student_id%type,
    P_section_id IN section.section_id%TYPE,
    P_Final_grade OUT enrollment.final_grade%TYPE,
    P_Exit_Code OUT CHAR)
IS
  v_student_id student.student_id%TYPE;
  v_section_id section.section_id%TYPE;
  v_grade_type_code grade_type_weight.grade_type_code%TYPE;
  v_grade_percent NUMBER;
  v_final_grade   NUMBER;
  v_grade_count   NUMBER;
  v_lowest_grade  NUMBER;
  v_exit_code     CHAR(1) := 'S';
  -- Next two variables are used to calculate whether a cursor
  -- has no result set.
  v_no_rows1 CHAR(1) := 'N';
  v_no_rows2 CHAR(1) := 'N';
  e_no_grade EXCEPTION;
BEGIN
  v_section_id := p_section_id;
  v_student_id := p_student_id;
  -- Start loop of grade types for the section.
  FOR r_grade IN c_grade_type(v_section_id, v_student_id)
  LOOP
    -- Since cursor is open it has a result
    -- set; change indicator.
    v_no_rows1 := 'Y';
    -- To hold the number of grades per section,
    -- reset to 0 before detailed cursor loops
    v_grade_count     := 0;
    v_grade_type_code := r_grade.GRADE_TYPE_CODE;
    -- Variable to hold the lowest grade.
    -- 500 will not be the lowest grade.
    v_lowest_grade := 500;
    -- Determine what to multiply a grade by to
    -- compute final grade. Must take into consideration
    -- if the drop lowest grade indicator is Y.
    SELECT (r_grade.percent_of_final_grade / DECODE(r_grade.drop_lowest, 'Y', (r_grade.number_per_section - 1), r_grade.number_per_section ))* 0.01
    INTO v_grade_percent
    FROM dual;
    -- Open cursor of detailed grade for a student in a
    -- given section.
    FOR r_detail IN c_grades(v_grade_type_code, v_student_id, v_section_id)
    LOOP
      -- Since cursor is open it has a result
      -- set; change indicator.
      v_no_rows2    := 'Y';
      v_grade_count := v_grade_count + 1;
      -- Handle the situation where there are more
      -- entries for grades of a given grade type
      -- than there should be for that section.
      IF v_grade_count > r_grade.number_per_section THEN
        v_exit_code   := 'T';
        raise e_no_grade;
      END IF;
      -- If drop lowest flag is Y determine which is lowest
      -- grade to drop
      IF r_grade.drop_lowest       = 'Y' THEN
        IF NVL(v_lowest_grade, 0) >= r_detail.numeric_grade THEN
          v_lowest_grade          := r_detail.numeric_grade;
        END IF;
      END IF;
      -- Increment the final grade with percentage of current
      -- grade in the detail loop.
      v_final_grade := NVL(v_final_grade, 0) + (r_detail.numeric_grade * v_grade_percent);
    END LOOP;
    -- Once detailed loop is finished, if the number of grades
    -- for a given student for a given grade type and section
    -- is less than the required amount, raise an exception.
    IF v_grade_count < r_grade.NUMBER_PER_SECTION THEN
      v_exit_code   := 'I';
      raise e_no_grade;
    END IF;
    -- If the drop lowest flag was Y, you need to take
    -- the lowest grade out of the final grade. It was not
    -- known when it was added which was the lowest grade
    -- to drop until all grades were examined.
    IF r_grade.drop_lowest = 'Y' THEN
      v_final_grade       := NVL(v_final_grade, 0) -
      (v_lowest_grade                              * v_grade_percent);
    END IF;
  END LOOP;
  -- If either cursor had no rows then there is an error.
  IF v_no_rows1  = 'N' OR v_no_rows2 = 'N' THEN
    v_exit_code := 'N';
    raise e_no_grade;
  END IF;
  P_final_grade := v_final_grade;
  P_exit_code   := v_exit_code;
EXCEPTION
WHEN e_no_grade THEN
  P_final_grade := NULL;
  P_exit_code   := v_exit_code;
WHEN OTHERS THEN
  P_final_grade := NULL;
  P_exit_code   := 'E';
END final_grade;
FUNCTION median_grade(
    p_course_number section.course_no%TYPE,
    p_section_number section.section_no%TYPE,
    p_grade_type grade.grade_type_code%TYPE)
  RETURN grade.numeric_grade%TYPE
IS
BEGIN
  FOR r_work_grade IN c_work_grade(p_course_number, p_section_number, p_grade_type)
  LOOP
    t_grade(NVL(t_grade.COUNT,0) + 1).numeric_grade := r_work_grade.numeric_grade;
  END LOOP;
  IF t_grade.COUNT = 0 THEN
    RETURN NULL;
  ELSE
    IF MOD(t_grade.COUNT, 2) = 0 THEN
      -- There is an even number of work grades. Find the middle
      -- two and average them.
      RETURN (t_grade(t_grade.COUNT / 2).numeric_grade + t_grade((t_grade.COUNT / 2) + 1).numeric_grade ) / 2;
    ELSE
      -- There is an odd number of grades. Return the one in
      -- the middle.
      RETURN t_grade(TRUNC(t_grade.COUNT / 2, 0) + 1).numeric_grade;
    END IF;
  END IF;
EXCEPTION
WHEN OTHERS THEN
  RETURN NULL;
END MEDIAN_GRADE;
END MANAGE_GRADES;


--------------------------------------------------------------------------
  COURSE_NAME,
  SECTION_NO,
  GRADE_TYPE,
  manage_grades.median_grade (COURSE_NO, SECTION_NO, GRADE_TYPE) median_grade
FROM
  (SELECT DISTINCT C.COURSE_NO COURSE_NO,
    C.DESCRIPTION COURSE_NAME,
    S.SECTION_NO SECTION_NO,
    G.GRADE_TYPE_CODE GRADE_TYPE
  FROM SECTION S,
    COURSE C,
    ENROLLMENT E,
    GRADE G
  WHERE C.course_no = s.course_no
  AND s.section_id  = e.section_id
  AND e.student_id  = g.student_id
  AND c.course_no   = 25
  AND S.SECTION_NO BETWEEN 1 AND 2
  ORDER BY 1,
    4,
    3
  ) grade_source

--------------------------------------------------------------------------

CREATE OR REPLACE
PACKAGE student_api
AS
  v_current_date DATE;
  PROCEDURE discount;
  FUNCTION new_instructor_id
    RETURN instructor.instructor_id%TYPE;
  FUNCTION total_cost_for_student(
      p_student_id IN student.student_id%TYPE)
    RETURN course.cost%TYPE;
  PRAGMA RESTRICT_REFERENCES (total_cost_for_student, WNDS, WNPS, RNPS);
  PROCEDURE get_student_info(
      p_student_id IN student.student_id%TYPE,
      p_last_name OUT student.last_name%TYPE,
      p_first_name OUT student.first_name%TYPE,
      p_zip OUT student.zip%TYPE,
      p_return_code OUT NUMBER);
  PROCEDURE get_student_info(
      p_last_name  IN student.last_name%TYPE,
      p_first_name IN student.first_name%TYPE,
      p_student_id OUT student.student_id%TYPE,
      p_zip OUT student.zip%TYPE,
      p_return_code OUT NUMBER);
  PROCEDURE remove_student(
      p_studid IN student.student_id%TYPE);
END student_api;
/

--------------------------------------------------------------------------

CREATE OR REPLACE
PACKAGE BODY student_api
AS
PROCEDURE discount
IS
  CURSOR c_group_discount
  IS
    SELECT DISTINCT s.course_no,
      c.description
    FROM section s,
      enrollment e,
      course c
    WHERE s.section_id = e.section_id
    GROUP BY s.course_no,
      c.description,
      e.section_id,
      s.section_id
    HAVING COUNT(*) >=8;
BEGIN
  FOR r_group_discount IN c_group_discount
  LOOP
    UPDATE course
    SET cost        = cost * .95
    WHERE course_no = r_group_discount.course_no;
    DBMS_OUTPUT.PUT_LINE ('A 5% discount has been given to'|| r_group_discount.course_no||' '|| r_group_discount.description);
  END LOOP;
END discount;
FUNCTION new_instructor_id
  RETURN instructor.instructor_id%TYPE
IS
  v_new_instid instructor.instructor_id%TYPE;
BEGIN
  SELECT INSTRUCTOR_ID_SEQ.NEXTVAL INTO v_new_instid FROM dual;
  RETURN v_new_instid;
EXCEPTION
WHEN OTHERS THEN
  DECLARE
    v_sqlerrm VARCHAR2(250) := SUBSTR(SQLERRM,1,250);
  BEGIN
    RAISE_APPLICATION_ERROR (-20003, 'Error in instructor_id: '||v_sqlerrm);
  END;
END new_instructor_id;
FUNCTION get_course_descript_private(
    p_course_no course.course_no%TYPE)
  RETURN course.description%TYPE
IS
  v_course_descript course.description%TYPE;
BEGIN
  SELECT description
  INTO v_course_descript
  FROM course
  WHERE course_no = p_course_no;
  RETURN v_course_descript;
EXCEPTION
WHEN OTHERS THEN
  RETURN NULL;
END get_course_descript_private;
FUNCTION total_cost_for_student(
    p_student_id IN student.student_id%TYPE)
  RETURN course.cost%TYPE
IS
  v_cost course.cost%TYPE;
BEGIN
  SELECT SUM(cost)
  INTO v_cost
  FROM course c,
    section s,
    enrollment e
  WHERE c.course_no = c.course_no
  AND e.section_id  = s.section_id
  AND e.student_id  = p_student_id;
  RETURN v_cost;
EXCEPTION
WHEN OTHERS THEN
  RETURN NULL;
END total_cost_for_student;
PROCEDURE get_student_info(
    p_student_id IN student.student_id%TYPE,
    p_last_name OUT student.last_name%TYPE,
    p_first_name OUT student.first_name%TYPE,
    p_zip OUT student.zip%TYPE,
    p_return_code OUT NUMBER)
IS
BEGIN
  SELECT last_name,
    first_name,
    zip
  INTO p_last_name,
    p_first_name,
    p_zip
  FROM student
  WHERE student.student_id = p_student_id;
  p_return_code           := 0;
EXCEPTION
WHEN NO_DATA_FOUND THEN
  DBMS_OUTPUT.PUT_LINE ('Student ID is not valid.');
  p_return_code := -100;
  p_last_name   := NULL;
  p_first_name  := NULL;
  p_zip         := NULL;
WHEN OTHERS THEN
  DBMS_OUTPUT.PUT_LINE ('Error in procedure get_student_info');
END get_student_info;
PROCEDURE get_student_info(
    p_last_name  IN student.last_name%TYPE,
    p_first_name IN student.first_name%TYPE,
    p_student_id OUT student.student_id%TYPE,
    p_zip OUT student.zip%TYPE,
    p_return_code OUT NUMBER)
IS
BEGIN
  SELECT student_id,
    zip
  INTO p_student_id,
    p_zip
  FROM student
  WHERE UPPER(last_name) = UPPER(p_last_name)
  AND UPPER(first_name)  = UPPER(p_first_name);
  p_return_code         := 0;
EXCEPTION
WHEN NO_DATA_FOUND THEN
  DBMS_OUTPUT.PUT_LINE ('Student name is not valid.');
  p_return_code := -100;
  p_student_id  := NULL;
  p_zip         := NULL;
WHEN OTHERS THEN
  DBMS_OUTPUT.PUT_LINE ('Error in procedure get_student_info');
END get_student_info;
PROCEDURE remove_student(
    p_studid IN student.student_id%TYPE)
IS
BEGIN
  DELETE FROM STUDENT WHERE student_id = p_studid;
END;
BEGIN
  SELECT TRUNC(sysdate, 'DD') INTO v_current_date FROM dual;
END student_api;
/


--------------------------------------------------------------------------


CREATE OR REPLACE
PACKAGE student_api
AS
  v_current_date DATE;
  PROCEDURE discount;
  FUNCTION new_instructor_id
    RETURN instructor.instructor_id%TYPE;
  FUNCTION total_cost_for_student(
      p_student_id IN student.student_id%TYPE)
    RETURN course.cost%TYPE;
  PRAGMA RESTRICT_REFERENCES (total_cost_for_student, WNDS, WNPS, RNPS);
  PROCEDURE get_student_info(
      p_student_id IN student.student_id%TYPE,
      p_last_name OUT student.last_name%TYPE,
      p_first_name OUT student.first_name%TYPE,
      p_zip OUT student.zip%TYPE,
      p_return_code OUT NUMBER);
  PROCEDURE get_student_info(
      p_last_name  IN student.last_name%TYPE,
      p_first_name IN student.first_name%TYPE,
      p_student_id OUT student.student_id%TYPE,
      p_zip OUT student.zip%TYPE,
      p_return_code OUT NUMBER);
  PROCEDURE remove_student(
      p_studid IN student.student_id%TYPE,
      p_ri     IN VARCHAR2 DEFAULT 'R');
END student_api;
/


--------------------------------------------------------------------------

CREATE OR REPLACE
PACKAGE BODY student_api
AS
PROCEDURE discount
IS
  CURSOR c_group_discount
  IS
    SELECT DISTINCT s.course_no,
      c.description
    FROM section s,
      enrollment e,
      course c
    WHERE s.section_id = e.section_id
    GROUP BY s.course_no,
      c.description,
      e.section_id,
      s.section_id
    HAVING COUNT(*) >=8;
BEGIN
  FOR r_group_discount IN c_group_discount
  LOOP
    UPDATE course
    SET cost        = cost * .95
    WHERE course_no = r_group_discount.course_no;
    DBMS_OUTPUT.PUT_LINE ('A 5% discount has been given to'|| r_group_discount.course_no||' '|| r_group_discount.description);
  END LOOP;
END discount;
FUNCTION new_instructor_id
  RETURN instructor.instructor_id%TYPE
IS
  v_new_instid instructor.instructor_id%TYPE;
BEGIN
  SELECT INSTRUCTOR_ID_SEQ.NEXTVAL INTO v_new_instid FROM dual;
  RETURN v_new_instid;
EXCEPTION
WHEN OTHERS THEN
  DECLARE
    v_sqlerrm VARCHAR2(250) := SUBSTR(SQLERRM,1,250);
  BEGIN
    RAISE_APPLICATION_ERROR (-20003, 'Error in instructor_id: '||v_sqlerrm);
  END;
END new_instructor_id;
FUNCTION get_course_descript_private(
    p_course_no course.course_no%TYPE)
  RETURN course.description%TYPE
IS
  v_course_descript course.description%TYPE;
BEGIN
  SELECT description
  INTO v_course_descript
  FROM course
  WHERE course_no = p_course_no;
  RETURN v_course_descript;
EXCEPTION
WHEN OTHERS THEN
  RETURN NULL;
END get_course_descript_private;
FUNCTION total_cost_for_student(
    p_student_id IN student.student_id%TYPE)
  RETURN course.cost%TYPE
IS
  v_cost course.cost%TYPE;
BEGIN
  SELECT SUM(cost)
  INTO v_cost
  FROM course c,
    section s,
    enrollment e
  WHERE c.course_no = c.course_no
  AND e.section_id  = s.section_id
  AND e.student_id  = p_student_id;
  RETURN v_cost;
EXCEPTION
WHEN OTHERS THEN
  RETURN NULL;
END total_cost_for_student;
PROCEDURE get_student_info(
    p_student_id IN student.student_id%TYPE,
    p_last_name OUT student.last_name%TYPE,
    p_first_name OUT student.first_name%TYPE,
    p_zip OUT student.zip%TYPE,
    p_return_code OUT NUMBER)
IS
BEGIN
  SELECT last_name,
    first_name,
    zip
  INTO p_last_name,
    p_first_name,
    p_zip
  FROM student
  WHERE student.student_id = p_student_id;
  p_return_code           := 0;
EXCEPTION
WHEN NO_DATA_FOUND THEN
  DBMS_OUTPUT.PUT_LINE ('Student ID is not valid.');
  p_return_code := -100;
  p_last_name   := NULL;
  p_first_name  := NULL;
  p_zip         := NULL;
WHEN OTHERS THEN
  DBMS_OUTPUT.PUT_LINE ('Error in procedure get_student_info');
END get_student_info;
PROCEDURE get_student_info(
    p_last_name  IN student.last_name%TYPE,
    p_first_name IN student.first_name%TYPE,
    p_student_id OUT student.student_id%TYPE,
    p_zip OUT student.zip%TYPE,
    p_return_code OUT NUMBER)
IS
BEGIN
  SELECT student_id,
    zip
  INTO p_student_id,
    p_zip
  FROM student
  WHERE UPPER(last_name) = UPPER(p_last_name)
  AND UPPER(first_name)  = UPPER(p_first_name);
  p_return_code         := 0;
EXCEPTION
WHEN NO_DATA_FOUND THEN
  DBMS_OUTPUT.PUT_LINE ('Student name is not valid.');
  p_return_code := -100;
  p_student_id  := NULL;
  p_zip         := NULL;
WHEN OTHERS THEN
  DBMS_OUTPUT.PUT_LINE ('Error in procedure get_student_info');
END get_student_info;
PROCEDURE remove_student
  -- The parameters student_id and p_ri give the user an
  -- option of cascade delete or restrict delete for
  -- the given student's records
  (
    p_studid IN student.student_id%TYPE,
    p_ri     IN VARCHAR2 DEFAULT 'R')
IS
  -- Declare exceptions for use in procedure
  enrollment_present EXCEPTION;
  bad_pri            EXCEPTION;
BEGIN
  -- R value is for restrict delete option
  IF p_ri = 'R' THEN
    DECLARE
      -- A variable is needed to test if the student
      -- is in the enrollment table
      v_dummy CHAR(1);
    BEGIN
      -- This is a standard existence check.
      -- If v_dummy is assigned a value via the
      -- SELECT INTO, the exception
      -- enrollment_present will be raised.
      -- If the v_dummy is not assigned a value, the
      -- exception no_data_found will be raised.
      SELECT NULL
      INTO v_dummy
      FROM enrollment e
      WHERE e.student_id = p_studid
      AND ROWNUM         = 1;
      -- The rownum set to 1 prevents the SELECT
      -- INTO statement raise to_many_rows
      -- exception.
      -- If there is at least one row in the enrollment
      -- table with a corresponding student_id, the
      -- restrict delete parameter will disallow the
      -- deletion of the student by raising
      -- the enrollment_present exception.
      RAISE enrollment_present;
    EXCEPTION
    WHEN NO_DATA_FOUND THEN
      -- The no_data_found exception is raised
      -- when there are no students found in the
      -- enrollment table. Since the p_ri indicates
      -- a restrict delete user choice the delete
      -- operation is permitted.
      DELETE
      FROM student
      WHERE student_id = p_studid;
    END;
    -- When the user enters "C" for the p_ri
    -- he/she indicates a cascade delete choice
  ELSIF p_ri = 'C' THEN
    -- Delete the student from the enrollment and
    -- grade tables
    DELETE
    FROM enrollment
    WHERE student_id = p_studid;
    DELETE FROM grade WHERE student_id = p_studid;
    -- Delete from student table only after corresponding
    -- records have been removed from the other tables
    -- because the student table is the parent table
    DELETE
    FROM student
    WHERE student_id = p_studid;
  ELSE
    RAISE bad_pri;
  END IF;
EXCEPTION
WHEN bad_pri THEN
  RAISE_APPLICATION_ERROR (-20231, 'An incorrect p_ri value was '|| 'entered. The remove_student procedure can '|| 'only accept a C or R for the p_ri parameter.');
WHEN enrollment_present THEN
  RAISE_APPLICATION_ERROR (-20239, 'The student with ID'||p_studid|| ' exists in the enrollment table thus records'|| ' will not be removed.');
END remove_student;
BEGIN
  SELECT TRUNC(sysdate, 'DD') INTO v_current_date FROM DUAL;
END student_api;




--------------------------------------------------------------------------

