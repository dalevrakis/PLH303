CREATE OR REPLACE FUNCTION search_am_3_1(st_am character(10))
	RETURNS TABLE(amka character varying, 
				  name character varying(30), 
				  father_name character varying(30), 
				  surname character varying(30), 
				  email character varying(30),
				  am character(10),
				  entry_date date) AS
$$
DECLARE
BEGIN
	RETURN QUERY
	SELECT * FROM "Person" NATURAL JOIN "Student" as stp 
	WHERE stp.am = st_am;
	
END;
$$
LANGUAGE 'plpgsql' VOLATILE;
--------------------------------------------------------------------------

CREATE OR REPLACE FUNCTION get_name_am_by_course_3_2(c_code character(7))
    RETURNS TABLE(name character varying, surname character varying, am character(10)) AS
$$
DECLARE
serial integer;

BEGIN

-- find serial number for courses in current semester
SELECT serial_number
INTO serial
FROM "CourseRun"
WHERE course_code = c_code
    AND semesterrunsin =
        (SELECT semester_id
        FROM "Semester"
        WHERE semester_status = 'present'
        );

RETURN QUERY

SELECT per.name, per.surname, stu.am
FROM "Student" as stu
NATURAL JOIN "Person" as per
WHERE amka IN
    (SELECT amka
    FROM "Register" AS reg
    WHERE course_code = c_code
    AND serial_number = serial
    );
END;
$$
LANGUAGE 'plpgsql' VOLATILE;
--------------------------------------------------------------------------

CREATE OR REPLACE FUNCTION show_person_characterization_3_3()
RETURNS TABLE(name character varying, surname character varying, characterization character varying) AS

$$
DECLARE
st character varying;
prof character varying;
lab character varying;
BEGIN
	st := 'Student';
	prof := 'Professor';
	lab := 'Lab Personnel';
	RETURN QUERY
	SELECT "Person".name, "Person".surname, st FROM "Person" 
		WHERE "Person".amka 
			IN (SELECT "Student".amka FROM "Student")
	UNION
	SELECT "Person".name, "Person".surname, prof FROM "Person" 
		WHERE "Person".amka 
			IN (SELECT "Professor".amka FROM "Professor")
	UNION
	SELECT "Person".name, "Person".surname, lab FROM "Person" 
		WHERE "Person".amka 
			IN (SELECT "LabTeacher".amka FROM "LabTeacher");
		
END;
$$
LANGUAGE 'plpgsql' VOLATILE;
--------------------------------------------------------------------------
-- 3.4
CREATE OR REPLACE FUNCTION get_obligatory_courses_3_4(pid integer, s_am character(10))
    RETURNS TABLE(course character(7)) AS
$$
BEGIN

RETURN QUERY
-- obligatory courses offered in pid
SELECT course_code
FROM "Course" as crs
JOIN "ProgramOffersCourse" as ofr
ON crs.course_code = ofr."CourseCode"
WHERE "ProgramID" = pid
AND obligatory = true
INTERSECT
-- non passed courses by student with am
SELECT course_code
FROM "Register"
WHERE amka = (
    SELECT amka
    FROM "Student"
    WHERE am = s_am
) AND register_status <> 'pass';
END;
$$
LANGUAGE 'plpgsql' VOLATILE;
--------------------------------------------------------------------------

CREATE OR REPLACE FUNCTION find_most_thesis_sector_3_5(dtype diploma_type)
RETURNS TABLE(sector integer) AS

$$
BEGIN

CREATE TEMP TABLE temp_table(
	sector integer,
	occurence_count bigint
);

-- RETURN QUERY

INSERT INTO "temp_table"
SELECT "Lab".sector_code, count(*) FROM "Lab"
		JOIN(
			SELECT "Professor".labjoins as labj from "Professor"
			JOIN(
			SELECT "Committee"."ProfessorAMKA" as amka FROM "Committee" 
			WHERE
				"Committee"."ThesisID" IN(
						SELECT "Thesis"."ThesisID" FROM "Thesis" 
						WHERE 
							"Thesis"."ProgramID" IN (SELECT "Program"."ProgramID" FROM "Program" WHERE "Program"."DiplomaType" = 'diploma'))
				AND "Committee"."Supervisor" = 'true')sq
			on sq.amka = "Professor".amka)sq2
		on sq2.labj = "Lab".lab_code
	GROUP BY "Lab".sector_code;

RETURN QUERY

SELECT "temp_table".sector FROM  "temp_table"
	WHERE "temp_table".occurence_count = (SELECT MAX("temp_table".occurence_count) FROM "temp_table");

DROP TABLE temp_table;
END;
$$
LANGUAGE 'plpgsql' VOLATILE;
--------------------------------------------------------------------------

CREATE OR REPLACE FUNCTION find_LabTeacher_workload_3_7()
RETURNS TABLE(amka character varying, surname character varying(30),name character varying(30), work_load bigint) AS

$$
BEGIN
RETURN QUERY
SELECT "Person".amka, "Person".surname, "Person".name, sq4.sum FROM "Person"
JOIN(
	SELECT "LabTeacher".amka, sq3.sum FROM "LabTeacher"
		JOIN(
			SELECT sq2.labuses ,SUM(sq2.lab_hours) FROM (
				SELECT "Course".course_code, sq.labuses, "Course".lab_hours FROM "Course"
				JOIN(
					SELECT * FROM "CourseRun"
						WHERE "CourseRun".semesterrunsin IN (
							SELECT  "Semester".semester_id FROM "Semester"
							WHERE "Semester".semester_status = 'present')
						AND	"CourseRun".labuses IS NOT NULL)sq
				on sq.course_code = "Course".course_code) sq2
				GROUP BY sq2.labuses) sq3
		on sq3.labuses = "LabTeacher".labworks)sq4
on sq4.amka="Person".amka;
END;
$$
LANGUAGE 'plpgsql' VOLATILE;
--------------------------------------------------------------------------

-- 3.8
CREATE OR REPLACE FUNCTION find_prerequisites_3_8(character(7))
RETURNS TABLE(crs_code character(7), crs_title character(100)) AS

$$
BEGIN

RETURN QUERY
WITH RECURSIVE Dep(m,d) AS (
    SELECT main AS m, dependent AS d
        FROM "Course_depends"
        WHERE dependent = 'ΗΡΥ 411'
    UNION
    SELECT "Course_depends".main as m, Dep.d as d
        FROM Dep, "Course_depends"
        WHERE Dep.m = "Course_depends".dependent
)
SELECT m, course_title
FROM Dep
JOIN "Course"
on Dep.m = "Course".course_code;

END;
$$
LANGUAGE 'plpgsql' VOLATILE;
-------------------------------------------------------------------------

-- 3.9
CREATE OR REPLACE FUNCTION find_profs_teaching_all_prog_3_9()
RETURNS TABLE(surname character varying(30), name character varying(30)) AS

$$
BEGIN

RETURN QUERY
select "Person".surname, "Person".name FROM "Person"
JOIN(
select "Teaches".amka  from "Teaches" 
where "Teaches".course_code IN(
	select DISTINCT "ProgramOffersCourse"."CourseCode" FROM "ProgramOffersCourse" 
	WHERE "ProgramOffersCourse"."ProgramID" IN(
		SELECT "Program"."ProgramID" FROM "Program"
		WHERE "Program"."ProgramID" NOT IN (SELECT "SeasonalProgram"."ProgramID" FROM "SeasonalProgram")
		AND
			"Program"."ProgramID" NOT IN (SELECT "ForeignLanguageProgram"."ProgramID" FROM "ForeignLanguageProgram"))
	)
INTERSECT
select "Teaches".amka from "Teaches" 
WHERE "Teaches".course_code IN(
	select DISTINCT "ProgramOffersCourse"."CourseCode" FROM "ProgramOffersCourse" 
	WHERE "ProgramOffersCourse"."ProgramID" IN(
		SELECT "ForeignLanguageProgram"."ProgramID" FROM "ForeignLanguageProgram")
	)
INTERSECT
select "Teaches".amka from "Teaches" 
WHERE "Teaches".course_code IN(
	select DISTINCT "ProgramOffersCourse"."CourseCode" FROM "ProgramOffersCourse" 
	WHERE "ProgramOffersCourse"."ProgramID" IN(
		SELECT "SeasonalProgram"."ProgramID" FROM "SeasonalProgram"))
)sq
on sq.amka = "Person".amka;

END;
$$
LANGUAGE 'plpgsql' VOLATILE;
-------------------------------------------------------------------------
