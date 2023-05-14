-- SELECT * from "Student"
-- SELECT * FROM "Professor"
-- SELECT * FROM "LabTeacher"
-- SELECT * FROM "Person"

-- SELECT * from search_am_3_1('2015000001')

-- SELECT amka, name, surname from "Person"``

-- SELECT * FROM show_person_characterization_3_3() 
					
-- SELECT * FROM "Person" NATURAL JOIN "Student" as stp

-- SELECT * FROM "Lab"

-- SELECT * FROM "Lab" WHERE "Lab".sector_code = 1

-- 	SELECT "Lab".sector_code, count(*) FROM "Lab"
-- 		JOIN(
-- 			SELECT "Professor".labjoins as labj from "Professor"
-- 			JOIN(
-- 			SELECT "Committee"."ProfessorAMKA" as amka FROM "Committee" 
-- 			WHERE
-- 				"Committee"."ThesisID" IN(
-- 						SELECT "Thesis"."ThesisID" FROM "Thesis" 
-- 						WHERE 
-- 							"Thesis"."ProgramID" IN (SELECT "Program"."ProgramID" FROM "Program" WHERE "Program"."DiplomaType" = 'diploma'))
-- 				AND "Committee"."Supervisor" = 'true')sq
-- 			on sq.amka = "Professor".amka)sq2
-- 		on sq2.labj = "Lab".lab_code
-- 	GROUP BY "Lab".sector_code
		
-- 		SELECT "Lab".sector_code FROM "Lab"
-- 		JOIN(
-- 			SELECT "Professor".labjoins as labj from "Professor"
-- 			JOIN(
-- 			SELECT "Committee"."ProfessorAMKA" as amka FROM "Committee" 
-- 			WHERE
-- 				"Committee"."ThesisID" IN(
-- 						SELECT "Thesis"."ThesisID" FROM "Thesis" 
-- 						WHERE 
-- 							"Thesis"."ProgramID" IN (SELECT "Program"."ProgramID" FROM "Program" WHERE "Program"."DiplomaType" = 'diploma'))
-- 				AND "Committee"."Supervisor" = 'true')sq
-- 			on sq.amka = "Professor".amka)sq2
-- 		on sq2.labj = "Lab".lab_code
		
		
						
-- 						SELECT "Professor".labjoins from "Professor"
-- 						JOIN(
-- 						SELECT "Committee"."ProfessorAMKA" as amka FROM "Committee" 
-- 						WHERE
-- 							"Committee"."ThesisID" IN(
-- 									SELECT "Thesis"."ThesisID" FROM "Thesis" 
-- 									WHERE 
-- 										"Thesis"."ProgramID" IN (SELECT "Program"."ProgramID" FROM "Program" WHERE "Program"."DiplomaType" = 'diploma'))
--  							AND "Committee"."Supervisor" = 'true')sq
-- 						on sq.amka = "Professor".amka
					

-- SELECT * FROM "Program"
-- SELECT * FROM "Professor"
-- SELECT * FROM "Lab"
-- SELECT * FROM "Student"
-- SELECT * FROM "Thesis"
-- SELECT * FROM "Committee"

-- INSERT INTO "Thesis"
-- values(5,10,'pepe5','21039608188',8)

-- INSERT INTO "Committee"
-- values('01107105181',5,'true')

-- SELECT * FROM find_most_thesis_sector_3_5('diploma')
-- DROP TABLE temp_table;

-- select * from "LabTeacher"

-- SELECT "Person".amka, "Person".surname, "Person".name, sq4.sum FROM "Person"
-- JOIN(
-- 	SELECT "LabTeacher".amka, sq3.sum FROM "LabTeacher"
-- 		JOIN(
-- 			SELECT sq2.labuses ,SUM(sq2.lab_hours) FROM (
-- 				SELECT "Course".course_code, sq.labuses, "Course".lab_hours FROM "Course"
-- 				JOIN(
-- 					SELECT * FROM "CourseRun"
-- 						WHERE "CourseRun".semesterrunsin IN (
-- 							SELECT  "Semester".semester_id FROM "Semester"
-- 							WHERE "Semester".semester_status = 'present')
-- 						AND	"CourseRun".labuses IS NOT NULL)sq
-- 				on sq.course_code = "Course".course_code) sq2
-- 				GROUP BY sq2.labuses) sq3
-- 		on sq3.labuses = "LabTeacher".labworks)sq4
-- on sq4.amka="Person".amka

	
-- 	SELECT "Course".course_code, sq.labuses, "Course".lab_hours FROM "Course"
-- 		JOIN(
-- 		SELECT * FROM "CourseRun"
-- 			WHERE "CourseRun".semesterrunsin IN (
-- 				SELECT  "Semester".semester_id FROM "Semester"
-- 				WHERE "Semester".semester_status = 'present')
-- 			AND	"CourseRun".labuses IS NOT NULL)sq
-- 		on sq.course_code = "Course".course_code
	
	
-- select * from find_LabTeacher_workload_3_7()


-- select * from "Course_depends"
-- order by dependent

-- select * from "Program" 
-- WHERE "Program"."ProgramID" IN(
-- 		SELECT "Program"."ProgramID" FROM "Program"
-- 		WHERE "Program"."ProgramID" NOT IN (SELECT "SeasonalProgram"."ProgramID" FROM "SeasonalProgram")
-- 		AND
-- 			"Program"."ProgramID" NOT IN (SELECT "ForeignLanguageProgram"."ProgramID" FROM "ForeignLanguageProgram"))

-- select * from "SeasonalProgram"
-- select * from "ForeignLanguageProgram"

-- select * FROM "ProgramOffersCourse" 
-- 	WHERE "ProgramOffersCourse"."ProgramID" IN(
-- 		SELECT "SeasonalProgram"."ProgramID" FROM "SeasonalProgram")

-- select * FROM "ProgramOffersCourse" 
-- 	WHERE "ProgramOffersCourse"."ProgramID" IN(
-- 		SELECT "ForeignLanguageProgram"."ProgramID" FROM "ForeignLanguageProgram")

-- select * FROM "ProgramOffersCourse" 
-- 	WHERE "ProgramOffersCourse"."ProgramID" IN(
-- 		SELECT "Program"."ProgramID" FROM "Program"
-- 		WHERE "Program"."ProgramID" NOT IN (SELECT "SeasonalProgram"."ProgramID" FROM "SeasonalProgram")
-- 		AND
-- 			"Program"."ProgramID" NOT IN (SELECT "ForeignLanguageProgram"."ProgramID" FROM "ForeignLanguageProgram"))

-- select "Person".surname, "Person".name FROM "Person"
-- JOIN(
-- select "Teaches".amka  from "Teaches" 
-- where "Teaches".course_code IN(
-- 	select DISTINCT "ProgramOffersCourse"."CourseCode" FROM "ProgramOffersCourse" 
-- 	WHERE "ProgramOffersCourse"."ProgramID" IN(
-- 		SELECT "Program"."ProgramID" FROM "Program"
-- 		WHERE "Program"."ProgramID" NOT IN (SELECT "SeasonalProgram"."ProgramID" FROM "SeasonalProgram")
-- 		AND
-- 			"Program"."ProgramID" NOT IN (SELECT "ForeignLanguageProgram"."ProgramID" FROM "ForeignLanguageProgram"))
-- 	)
-- INTERSECT
-- select "Teaches".amka from "Teaches" 
-- WHERE "Teaches".course_code IN(
-- 	select DISTINCT "ProgramOffersCourse"."CourseCode" FROM "ProgramOffersCourse" 
-- 	WHERE "ProgramOffersCourse"."ProgramID" IN(
-- 		SELECT "ForeignLanguageProgram"."ProgramID" FROM "ForeignLanguageProgram")
-- 	)
-- INTERSECT
-- select "Teaches".amka from "Teaches" 
-- WHERE "Teaches".course_code IN(
-- 	select DISTINCT "ProgramOffersCourse"."CourseCode" FROM "ProgramOffersCourse" 
-- 	WHERE "ProgramOffersCourse"."ProgramID" IN(
-- 		SELECT "SeasonalProgram"."ProgramID" FROM "SeasonalProgram"))
-- )sq
-- on sq.amka = "Person".amka

-- select *
-- from "Teaches"
-- where amka = '01026401140'
-- ORDER BY course_code

-- INSERT INTO "ProgramOffersCourse"
-- values(204,'ΠΛΗ 511')

-- DELETE FROM "ProgramOffersCourse" Where "ProgramID"=204

select * from find_profs_teaching_all_prog_3_9()