CREATE OR REPLACE FUNCTION input_grade(semester integer)
	RETURNS void AS
$$
DECLARE
num_rows integer;

BEGIN

SELECT count(*)
INTO num_rows
FROM "CourseRun"
JOIN "Register"
ON "CourseRun".course_code = "Register".course_code AND "CourseRun".serial_number = "Register".serial_number
WHERE semesterrunsin = semester AND "Register".register_status = 'approved';

UPDATE "Register"
SET exam_grade = sq.exam_g, final_grade = sq.final_g, lab_grade = sq.lab_g, register_status = sq.pf
FROM(
	SELECT reg.amka as amka, reg.serial_number as serial_num, reg.course_code as c_code, grades.exam as exam_g,
		calc_grade(reg.course_code, reg.serial_number, grades.exam, grades.lab) as final_g, grades.lab as lab_g,
		passfail(calc_grade(reg.course_code, reg.serial_number, grades.exam, grades.lab)) as pf
	FROM (
		SELECT "Register".amka, "Register".serial_number, "Register".course_code, row_number() OVER ()::integer AS id
		FROM "CourseRun"
		JOIN "Register"
		ON "CourseRun".course_code = "Register".course_code AND "CourseRun".serial_number = "Register".serial_number
		WHERE semesterrunsin = semester AND "Register".register_status = 'approved'
		) AS reg
	JOIN ( 
		SELECT floor(random() * 10)::numeric + 1 as exam, floor(random() * 10)::numeric + 1 as lab, 
		row_number() OVER ()::integer as id 
		FROM generate_series(1, num_rows)
	) AS grades
	ON reg.id = grades.id
) AS sq
WHERE "Register".amka = sq.amka
	and "Register".course_code = sq.c_code
	and "Register".serial_number = sq.serial_num;
END;
$$
LANGUAGE 'plpgsql' VOLATILE;

--------------------------------------------------------------------------

CREATE OR REPLACE FUNCTION calc_grade(crs_code character varying, serial_num integer, exam_g numeric, lab_g numeric)
	RETURNS numeric AS
$$
DECLARE
has_lab smallint;
l_min smallint;
e_min smallint;
e_percentage double precision;
BEGIN

SELECT lab_hours
INTO has_lab
FROM "Course"
WHERE course_code = crs_code;

IF has_lab = 0 THEN
	RETURN exam_g;
ELSE

	SELECT lab_min, exam_min, exam_percentage
	INTO l_min, e_min, e_percentage
	FROM "CourseRun"
	WHERE course_code = crs_code AND serial_number = serial_num;
		
	IF lab_g < l_min THEN
		RETURN 0;
	ELSIF exam_g < e_min THEN
		RETURN exam_g;
	ELSE
		RETURN round(e_percentage/100 * exam_g + (1 - e_percentage/100) * lab_g);
	END IF;
END IF;

END;
$$
LANGUAGE 'plpgsql' VOLATILE;

--------------------------------------------------------------------------\

CREATE OR REPLACE FUNCTION passfail(grade numeric)
RETURNS register_status_type AS

$$
BEGIN
IF grade < 5 THEN
    RETURN 'fail';
ELSE
    RETURN 'pass';
END IF;

END;
$$
LANGUAGE 'plpgsql' VOLATILE;