--SELECT COALESCE(MAX("Program"."ProgramID"),0) FROM "Program";
--SELECT MAX("Program"."ProgramID") FROM "Program";

-- INSERT INTO "Program" 
-- 	values(3,10,10,10,'true',10,'degree'::diploma_type,0,2023);
-- select * from "Program"

-- INSERT INTO "ProgramOffersCourse"
-- 	select 1 as "ProgramID", "course_code"
-- 	from "Course";

-- INSERT INTO "SeasonalProgram"
-- 	values(2,'winter')
-- select * from "SeasonalProgram"

-- INSERT INTO "ForeignLanguageProgram"
-- 	values(3,'Chinese');
--  select * from "ForeignLanguageProgram"

--  select * from "Student"
-- INSERT INTO "Joins"
-- 	values ('05099603860',1)
-- INSERT INTO "Joins"
-- 	values ('13039608668',2)
-- INSERT INTO "Joins"
-- 	values ('27079602581',3)

-- INSERT INTO "Joins"
-- 	values ('18029602085',1)
-- INSERT INTO "Joins"
-- 	values ('18029602085',3)
-- select * from "Joins"



-- SELECT "StudentAMKA" from "Joins" 
-- 	WHERE "ProgramID" IN (SELECT DISTINCT "ProgramID" from "SeasonalProgram")

-- SELECT amka, 1
-- 	FROM "Student"
-- 	WHERE EXTRACT('Year' from entry_date) >= 2015 
-- 	AND amka NOT IN(
-- 		SELECT "StudentAMKA" from "Joins" 
-- 		WHERE "ProgramID" IN (SELECT DISTINCT "ProgramID" from "SeasonalProgram")
-- 		 );

-- SELECT "StudentAMKA" from "Joins" 
-- 		WHERE "ProgramID" NOT IN (SELECT DISTINCT "ProgramID" from "SeasonalProgram")


-- select * from "Program" 
-- where "ProgramID" NOT IN
-- (
-- 	select "ProgramID" from "ForeignLanguageProgram"
-- 	UNION
-- 	select "ProgramID" from "SeasonalProgram"
-- 	)

-- Select "StudentAMKA" from "Joins"
-- Where "StudentAMKA" NOT IN(
-- 	Select * 
-- 	)

-- SELECT *
-- FROM "Joins"
-- WHERE "Joins"."ProgramID" NOT IN
--     (SELECT "ProgramID"
--         FROM "ForeignLanguageProgram")
-- AND "Joins"."ProgramID" NOT IN
--     (SELECT "ProgramID"
--         FROM "SeasonalProgram")
-- AND "Joins"."StudentAMKA" IN
-- (
--     SELECT amka
--     FROM "Student"
--     WHERE EXTRACT('Year' from entry_date) >= 2015
-- )



-- select amka
-- from "Student"
-- WHERE amka not in 
-- 	(select "StudentAMKA" from "Joins")
-- AND EXTRACT('Year' from entry_date) >= 2015
-- UNION
-- select "StudentAMKA" from "Joins"



-- select * from "Joins"
-- Where "ProgramID" IN(
-- 	select "ProgramID" from "ForeignLanguageProgram"
-- 	)

        
-- SELECT *
-- FROM "Joins"
-- WHERE "StudentAMKA" NOT IN
-- (        
-- 	SELECT "StudentAMKA"
-- 	FROM "Joins"
-- 	WHERE "Joins"."ProgramID" NOT IN
-- 		(SELECT "ProgramID"
-- 			FROM "ForeignLanguageProgram")
-- 	AND "Joins"."ProgramID" NOT IN
-- 		(SELECT "ProgramID"
-- 			FROM "SeasonalProgram")
-- )
-- AND "Joins"."ProgramID" NOT IN
-- 	(SELECT "ProgramID"
--     	FROM "SeasonalProgram")
-- AND "Joins"."StudentAMKA" IN
--     (SELECT amka
--         FROM "Student"
--         WHERE EXTRACT('Year' from entry_date) >= 2015)

-- select * from "Student"
-- select * from "Diploma"

-- INSERT INTO "Diploma"
-- values(9,	8,	'foreign3',	'01019608535',	202);

-- SELECT * FROM "Student"
-- WHERE
-- 	LEFT("Student".am,4)='2023'
-- AND
-- 	SUBSTRING("Student".am,5,1)='1'
       
	   
-- SELECT COUNT(*)
-- INTO num_grads
-- FROM "Diploma"
-- WHERE "ProgramID" NOT IN
--         (SELECT "ProgramID"
--             FROM "ForeignLanguageProgram")
--     AND "ProgramID" NOT IN
--         (SELECT "ProgramID"
--             FROM "SeasonalProgram")
            
-- SELECT amka  FROM "Student"
-- WHERE
-- 	LEFT("Student".am,4)='2023'
-- AND
-- 	SUBSTRING("Student".am,5,1)='1'

-- SELECT "StudentAMKA" as amka
-- FROM "Diploma"
-- WHERE "ProgramID" NOT IN
--         (SELECT "ProgramID"
--             FROM "ForeignLanguageProgram")
--     AND "ProgramID" NOT IN
--         (SELECT "ProgramID"
--             FROM "SeasonalProgram")
-- ORDER BY random() limit floor(random()*3)+1::integer;

-- SELECT COUNT(*)
-- INTO num_grads
-- FROM "Student"

-- SELECT "StudentAMKA" as amka
-- FROM "Student"
-- ORDER BY random() limit floor(random()*num_grads)+1::integer;


-- select * from "SeasonalProgram"
-- select * from gen_units(201, 3, array(select course_code from "CourseRun" where LEFT("CourseRun".course_code,3) = 'ΠΛΗ')  )
-- select * from "CustomUnits"
-- BEGIN;
-- SAVEPOINT my_savepoint;

-- select * from input_program('Seasonal','pepe','spring',2023,10,10,10,'true',10,'diploma');
-- select * from "Program";
-- select * from "SeasonalProgram"
-- select * from "CustomUnits"
-- select * from "RefersTo"

-- ROLLBACK TO SAVEPOINT my_savepoint;
-- COMMIT;
