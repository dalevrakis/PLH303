CREATE OR REPLACE FUNCTION input_program(program_type character varying,
                                        lang character varying,
                                        season semester_season_type,
                                        start_year integer,
                                        duration integer,
                                        min_courses integer,
                                        min_credits integer,
                                        isObligatory boolean,
                                        committee_num integer,
                                        diplomaType diploma_type
                                        )
	RETURNS void AS
$$
DECLARE
most_recent_year integer;
pid integer;
cuid integer;
num_grads integer;
num_participants integer;
BEGIN
-- get pid
SELECT coalesce(max("ProgramID"),0)+1::integer INTO pid FROM "Program";

IF program_type = 'Typical'  THEN
	SELECT max("Year") INTO most_recent_year
	FROM "Program"
	WHERE "Program"."ProgramID" NOT IN
		(SELECT "ProgramID"
			FROM "ForeignLanguageProgram")
	AND "Program"."ProgramID" NOT IN
		(SELECT "ProgramID"
			FROM "SeasonalProgram");

	IF start_year < most_recent_year THEN
		raise notice 'Start year for Typical Program cannot be before %', most_recent_year;
		RETURN;
	END IF;
	
-- 	-- get pid
-- 	SELECT coalesce(max("ProgramID"),0)+1::integer INTO pid FROM "Program";

	INSERT INTO "Program"
	VALUES (pid,
			duration,
			min_courses,
			min_credits,
			isObligatory,
			committee_num,
			diplomaType,
			0,
			start_year);
	
	-- insert
	INSERT INTO "ProgramOffersCourse"
	SELECT pid, course_code
	FROM "Course";
	
	-- insert students who are only in foreign language program
	INSERT INTO "Joins"
	SELECT "StudentAMKA", pid
	FROM "Joins"
	WHERE "StudentAMKA" NOT IN
	(
	SELECT "StudentAMKA"
	FROM "Joins"
	WHERE "Joins"."ProgramID" NOT IN
		(SELECT "ProgramID"
			FROM "ForeignLanguageProgram")
	AND "Joins"."ProgramID" NOT IN
		(SELECT "ProgramID"
			FROM "SeasonalProgram")
	)
	AND "Joins"."ProgramID" NOT IN
	(SELECT "ProgramID"
		FROM "SeasonalProgram")
	AND "Joins"."StudentAMKA" IN
		(SELECT amka
			FROM "Student"
			WHERE EXTRACT('Year' from entry_date) >= start_year);
	
	-- insert students who are not in any program
	INSERT INTO "Joins"
	SELECT amka, pid
	FROM "Student"
	WHERE amka NOT IN
	(
		SELECT "StudentAMKA"
		FROM "Joins"
	) AND EXTRACT('Year' from entry_date) >= start_year;
	
	-- update students in typical program
	UPDATE "Joins"
	SET "ProgramID" = pid
	FROM
	(
		SELECT "StudentAMKA", "ProgramID"
		FROM "Joins"
		WHERE "Joins"."ProgramID" NOT IN
			(SELECT "ProgramID"
				FROM "ForeignLanguageProgram")
		AND "Joins"."ProgramID" NOT IN
			(SELECT "ProgramID"
				FROM "SeasonalProgram")
		AND "Joins"."StudentAMKA" IN
			(SELECT amka
				FROM "Student"
				WHERE EXTRACT('Year' from entry_date) >= start_year)
	) AS sq
	WHERE "Joins"."StudentAMKA" = sq."StudentAMKA" AND "Joins"."ProgramID" = sq."ProgramID";
	
	--update participants count
    SELECT count(*)
    INTO num_participants
    FROM "Joins"
    WHERE "ProgramID" = pid;

    UPDATE "Program"
    SET "NumOfParticipants" = num_participants
    FROM (
    	SELECT * FROM "Program" 
    	WHERE "ProgramID" = pid) as sq
	WHERE "Program"."ProgramID" = sq."ProgramID"; 
	
ELSIF program_type = 'ForeignLanguage' THEN
	SELECT MAX("Year") INTO MOST_RECENT_YEAR
	FROM "Program"
	NATURAL JOIN "ForeignLanguageProgram";
	
	IF start_year < most_recent_year THEN
		raise notice 'Start year for Foreign Language Program cannot be before %', most_recent_year;
		RETURN;
	END IF;
	
-- 	-- get pid
-- 	SELECT coalesce(max("ProgramID"),0)+1::integer INTO pid FROM "Program";

	INSERT INTO "Program"
	VALUES (pid,
			duration,
			min_courses,
			min_credits,
			isObligatory,
			committee_num,
			diplomaType,
			0,
			start_year);
	
	INSERT INTO "ForeignLanguageProgram"
	values(pid,lang);
	
	--Insert Foreign Students
	INSERT INTO "Joins"
	SELECT "Student".amka , pid FROM "Student"
	WHERE
		LEFT("Student".am,4)=start_year::character varying
	AND
		SUBSTRING("Student".am,5,1)='1';
	
	
	--Insert random diploma students 
	
	SELECT COUNT(*)
	INTO num_grads
	FROM "Diploma"
	WHERE "ProgramID" NOT IN
			(SELECT "ProgramID"
				FROM "ForeignLanguageProgram")
		AND "ProgramID" NOT IN
			(SELECT "ProgramID"
				FROM "SeasonalProgram");
			
			
	INSERT INTO "Joins"
	SELECT "Diploma"."StudentAMKA" ,pid
	FROM "Diploma"
	WHERE "ProgramID" NOT IN
			(SELECT "ProgramID"
				FROM "ForeignLanguageProgram")
		AND "ProgramID" NOT IN
			(SELECT "ProgramID"
				FROM "SeasonalProgram")
	ORDER BY random() limit floor(random()*num_grads)+1::integer;
	
	--update participants count
    SELECT count(*)
    INTO num_participants
    FROM "Joins"
    WHERE "ProgramID" = pid;

    UPDATE "Program"
    SET "NumOfParticipants" = num_participants
    FROM (
    	SELECT * FROM "Program" 
    	WHERE "ProgramID" = pid) as sq
	WHERE "Program"."ProgramID" = sq."ProgramID"; 
	
	raise notice 'ForeignLanguage';
	
	
ELSIF program_type = 'Seasonal' THEN
	SELECT MAX("Year") INTO MOST_RECENT_YEAR
	FROM "Program"
	NATURAL JOIN "SeasonalProgram";

	IF start_year < most_recent_year THEN
		raise notice 'Start year for Seasonal Program cannot be before %', most_recent_year;
		RETURN;
	END IF;
	
	INSERT INTO "Program"
	VALUES (pid,
			duration,
			min_courses,
			min_credits,
			isObligatory,
			committee_num,
			diplomaType,
			0,
			start_year);
	
	INSERT INTO "SeasonalProgram"
	values(pid,season);
	
	--insert random student
	SELECT COUNT(*)
	INTO num_participants
	FROM "Student";

	INSERT INTO "Joins"
    SELECT amka, pid
    FROM "Student"
    ORDER BY random() limit floor(random()*num_participants)+1::integer;
	
	--update number of participants in Program
	SELECT count(*)
    INTO num_participants
    FROM "Joins"
    WHERE "ProgramID" = pid;
    
    UPDATE "Program"
    SET "NumOfParticipants" = num_participants
    FROM (
        SELECT * FROM "Program" 
        WHERE "ProgramID" = pid) as sq
    WHERE "Program"."ProgramID" = sq."ProgramID";

	SELECT coalesce(max("CustomUnitID"),0)+1::integer INTO cuid FROM "CustomUnits";
	
	Perform gen_units(pid, cuid, array(select course_code from "CourseRun"));
	
	raise notice 'Seasonal';
ELSE
	raise notice 'program_type "%" not supported', program_type;	
END IF;

END;
$$
LANGUAGE 'plpgsql' VOLATILE;


CREATE OR REPLACE FUNCTION gen_units(pid integer, cuid integer, course_c character(7)[] )
	RETURNS void AS
$$
DECLARE
curr_semester integer;
BEGIN
	INSERT INTO "CustomUnits"
	values(cuid,pid,0);
	
	SELECT MAX("Semester"."semester_id") into curr_semester from "Semester";
	
-- 	RETURN QUERY
-- 	SELECT "CourseRun"."course_code" FROM "CourseRun" 
-- 	WHERE(
-- 		"CourseRun"."course_code" = ANY(course_c)
-- 	AND 
-- 		"CourseRun"."semesterrunsin" = curr_semester);
	
 	INSERT INTO "RefersTo"
	SELECT cuid, pid , "CourseRun"."course_code", "CourseRun"."serial_number" FROM "CourseRun" 
	WHERE(
		"CourseRun"."course_code" = ANY(course_c)
	AND 
		"CourseRun"."semesterrunsin" = curr_semester);
	
	UPDATE "CustomUnits"
	SET "Credits" = sq.credits
	FROM(
		SELECT sum(units) as credits
		FROM "CourseRun"
		NATURAL JOIN "Course"
		WHERE course_code = ANY(course_c)
		AND semesterrunsin = curr_semester
		)as sq
	WHERE "CustomUnits"."CustomUnitID" = cuid AND "CustomUnits"."SeasonalProgramID"=pid;
END;
$$
LANGUAGE 'plpgsql' VOLATILE;
--------------------------------------------------------------------------