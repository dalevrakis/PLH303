select reg.amka, reg.serial_number, reg.course_code, grades.exam ,calc_grade(reg.serial_number,reg.course_code,grades.exam, grades.lab), grades.lab ,passfail(calc_grade(reg.serial_number,reg.course_code,grades.exam, grades.lab))
from (
	select amka, serial_number, course_code , row_number() OVER ()::integer as id 
	from "Register" 
	where "Register".course_code in (
		select course_code from "CourseRun" 
		where "CourseRun".semesterrunsin = 2 and register_status='approved')
	) reg
	JOIN ( 
		select floor(random() * 10)::integer + 1 as exam, floor(random() * 10)::integer + 1 as lab, row_number() OVER ()::integer as id 
		from generate_series(1, 10)
		) grades
		on reg.id = grades.id
		
		

