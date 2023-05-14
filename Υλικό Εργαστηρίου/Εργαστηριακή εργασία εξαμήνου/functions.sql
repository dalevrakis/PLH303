--Random Surnames
CREATE OR REPLACE FUNCTION random_surnames(n integer)
	RETURNS TABLE(surname character varying, id integer) AS
$$
BEGIN
	RETURN QUERY --RETURN QUERY appends the results of executing a query to the function's result set. RETURN NEXT and RETURN QUERY can be freely intermixed in a single set-returning function, in which case their results will be concatenated
	SELECT snam.surname, row_number() OVER ()::integer --The ROW_NUMBER() function is a window function that assigns a sequential integer to each row in a result set. The set of rows on which the ROW_NUMBER() function operates is called a window.
	FROM (SELECT "Surname".surname
		  FROM "Surname"
	      WHERE right("Surname".surname,2)='ΗΣ'
		  ORDER BY random() LIMIT n) as snam; --generates random numbers, one for each row, and then sorts by them. So it results in n rows being presented in a random order
END;
$$
LANGUAGE 'plpgsql' VOLATILE; --VOLATILE such as functions involving random() and CURRENT_TIMESTAMP that can be expected to change output even in the same query call.

--Random Names
CREATE OR REPLACE FUNCTION random_names(n integer)
RETURNS TABLE(name character varying,sex character(1), id integer) AS
$$
BEGIN
	RETURN QUERY
	SELECT nam.name, nam.sex, row_number() OVER ()::integer
	FROM (SELECT "Name".name, "Name".sex
		  FROM "Name"
		  ORDER BY random() LIMIT n) as nam;
END;
$$
LANGUAGE 'plpgsql' VOLATILE; --VOLATILE such as functions involving random() and CURRENT_TIMESTAMP that can be expected to change output even in the same query call.

--Adapt surnames
CREATE OR REPLACE FUNCTION adapt_surname(surname character varying,
sex character(1)) RETURNS character varying AS
$$
DECLARE
result character varying;
BEGIN
	result = surname;
	IF right(surname,2)<>'ΗΣ' THEN
		RAISE NOTICE 'Cannot handle this surname';
		ELSIF sex='F' THEN
			result = left(surname,-1);
			ELSIF sex<>'M' THEN
				RAISE NOTICE 'Wrong sex parameter';
	END IF;
	RETURN result;
END;
$$
LANGUAGE 'plpgsql' IMMUTABLE; --IMMUTABLE meaning that the output of the function can be expected to be the same if the inputs are the same.

--Create new am
CREATE OR REPLACE FUNCTION create_am(year integer, x integer, num integer)
RETURNS character(10) AS
$$
BEGIN
	RETURN concat(year::character(4),x::character(1),lpad(num::text,5,'0')); --cast(expression as target_type) or ::. LPAD() function returns a string left-padded to length characters.
END;
$$
LANGUAGE 'plpgsql' IMMUTABLE;--IMMUTABLE meaning that the output of the function can be expected to be the same if the inputs are the same.

--Create mail 
CREATE OR REPLACE FUNCTION create_mail(surname character varying,amka character varying)
RETURNS character varying AS
$$
BEGIN
	RETURN concat(surname, RIGHT(amka,4) ,'@tuc.gr'); --cast(expression as target_type) or ::. LPAD() function returns a string left-padded to length characters.
END;
$$
LANGUAGE 'plpgsql' IMMUTABLE;--IMMUTABLE meaning that the output of the function can be expected to be the same if the inputs are the same.

--Create amkas
CREATE OR REPLACE FUNCTION random_amkas(num integer)
RETURNS TABLE(amka character varying, id integer) AS
$$
BEGIN
    RETURN QUERY
    SELECT RIGHT(random()::text,11)::character varying, row_number() OVER ()::integer
    FROM generate_series(1, num);
END;
$$
LANGUAGE 'plpgsql' VOLATILE;

--Create mail 
CREATE OR REPLACE FUNCTION create_mail(surname character varying,amka character varying)
RETURNS character varying AS
$$
BEGIN
	RETURN concat(LOWER(surname), RIGHT(amka,4) ,'@tuc.gr'); --cast(expression as target_type) or ::. LPAD() function returns a string left-padded to length characters.
END;
$$
LANGUAGE 'plpgsql' IMMUTABLE;

--Create Persons
CREATE OR REPLACE FUNCTION create_person(num integer)
RETURNS TABLE(amka character varying, name character varying, 
              father_name character varying, surname character varying,
              email character varying) AS
$$
BEGIN
    RETURN QUERY
    
    INSERT INTO "Person"
    SELECT am.amka, na.name, fa.name, adapt_surname(su.surname,na.sex), create_mail(su.surname, am.amka)
    FROM random_amkas(num) am
    JOIN random_names(num) na
        USING (id)
    JOIN random_names(num) fa
        USING (id)
    JOIN random_surnames(num) su
        USING (id)
    RETURNING *;
END;
$$
LANGUAGE 'plpgsql' VOLATILE;

--Create Students
CREATE OR REPLACE FUNCTION create_student(num integer,entry_date date)
RETURNS TABLE(amka character varying, am character(10), entry date) AS

$$
DECLARE
curr_year double precision;
last_am integer;
BEGIN
	SELECT EXTRACT('Year' FROM entry_date) into curr_year;
	SELECT MAX(RIGHT("Student".am,5))::integer into last_am 
	FROM "Student" WHERE LEFT("Student".am,4)=curr_year::character varying;
	
	RAISE NOTICE '%',last_am;
	RETURN QUERY 
	
	INSERT INTO "Student"
	SELECT pers.amka, create_am(curr_year::integer,round(random())::integer,pers.id+COALESCE(last_am, 0)), entry_date
	FROM (
		SELECT  per.amka, row_number() OVER ()::integer as id
    	FROM create_person(num) per) as pers
	RETURNING *;

END;
$$
LANGUAGE 'plpgsql' VOLATILE;

--Create Professor
CREATE OR REPLACE FUNCTION create_professor(num integer)
RETURNS TABLE(amka character varying, labjoins integer, rank rank_type) AS

$$
BEGIN
	RETURN QUERY 
	
	INSERT INTO "Professor"
	SELECT pers.amka, floor(random() * 10)::integer + 1, p_rank.r
    FROM(
        SELECT per.amka, row_number() OVER ()::integer as id
        FROM create_person(num) per
    ) pers
    JOIN(
		select ((enum_range(NULL::rank_type))::rank_type[])[floor(random()*4+1)] as r, row_number() OVER ()::integer as id
		from generate_series(1, num)
    ) p_rank
    on pers.id = p_rank.id
	RETURNING *;
END;
$$
LANGUAGE 'plpgsql' VOLATILE;

--Create LabTeacher
CREATE OR REPLACE FUNCTION create_labteacher(num integer)
RETURNS TABLE(amka character varying, labworks integer, level level_type) AS

$$
BEGIN
	RETURN QUERY 
	
	INSERT INTO "LabTeacher"
	SELECT pers.amka, floor(random() * 10)::integer + 1, p_level.r
    FROM(
        SELECT per.amka, row_number() OVER ()::integer as id
        FROM create_person(num) per
    ) pers
    JOIN(
		select ((enum_range(NULL::level_type))::level_type[])[floor(random()*4+1)] as r, row_number() OVER ()::integer as id
		from generate_series(1, num)
    ) p_level
    on pers.id = p_level.id
	RETURNING *;
END;
$$
LANGUAGE 'plpgsql' VOLATILE;