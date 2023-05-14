A ======================================================================
-- SQL Statement
select * from 
(select amka, count(*) as c from "Register"
	where course_code =  'ΠΛΗ 101'
	group by amka) as t1
join 	--or natural join
(select max(c)as c from
	(select count(*) as c from "Register"
	where course_code =  'ΠΛΗ 101'
	group by amka) as t2) as t3 using (c)
natural join 
"Student"

-- SQL Statement with CTE
	
WITH
regp101 as 
	(select amka, count(*) as c from "Register"
	where course_code =  'ΠΛΗ 101'
	group by amka),
maxregp as (select max(c) as c from regp101)	

select * from
regp101 natural join maxregp natural join "Student"

B  =====================================================================
create table lab6_person as table "Person";
ALTER TABLE lab6_person ADD CONSTRAINT "pk" primary key(amka);


update lab6_person as l6
SET email = replace(email,'@tuc','@lab_'|| lp.lab_code  || '.tuc') --or concat('@lab_', lp.lab_code,'.tuc')
FROM 
	(select st.amka, max(labuses) as lab_code from 
	"Register" r join 
	"CourseRun" cr on (cr.course_code = r.course_code and --primary key is on two fields
                        cr.serial_number = r.serial_number and
						cr.semesterrunsin =  25 and final_grade = 10 and 
                        labuses is not null) join
	"Student" st on (st.amka = r.amka and  DATE_PART('year',st.entry_date)=2022)
	group by st.amka) as lp
where
	lp.amka = l6.amka
	
-- OR with CTE

WITH std as
(select st.amka, max(labuses) as labuses from 
	"Register" r join 
	"CourseRun" cr on (cr.course_code = r.course_code and --primary key is on two fields
                        cr.serial_number = r.serial_number and
						cr.semesterrunsin =  25 and final_grade = 10 and 
                        labuses is not null) join
	"Student" st on (st.amka = r.amka and  DATE_PART('year',st.entry_date)=2022)
	group by st.amka)
--select * from std
update lab6_person as l6
SET email = replace(email,'@tuc','@lab_'|| s.labuses || '.tuc')
FROM std s
where
	s.amka = l6.amka
	
-- See the updated values
select * 
from 
lab6_person 
where email like '%@lab%'

-- Count Students with mail like %@lab% that passed courses with grade 10
select count(distinct amka) 
from 
lab6_person natural join "Student" natural join "Register"
where  email LIKE '%@lab%' AND final_grade=10

C ======================================================================

-- Create the view
create or replace view school_lab AS
select lab_code,lab_title,sector_title,name,surname,email
from "Lab" natural join "Sector" join "Professor" pf ON (profdirects=amka) join "Person" p on (pf.amka = p.amka)

-- See all rows in the view
select * from school_lab
