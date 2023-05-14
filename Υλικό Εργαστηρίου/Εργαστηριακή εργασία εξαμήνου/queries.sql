--select RIGHT(max(am),5) from "Student" where left(am,4)='2023'
--select max(am) from "Student"

--SELECT EXTRACT('Year' FROM CURRENT_DATE);
select * from create_student(10,CURRENT_DATE)
--select * from "Student"