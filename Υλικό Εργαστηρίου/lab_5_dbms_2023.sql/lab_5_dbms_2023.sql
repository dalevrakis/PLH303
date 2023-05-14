
========================================================================================
ΕΡΩΤΗΜΑ Α1
========================================================================================
CREATE TABLE ab(
  id INTEGER PRIMARY KEY,
  item_type_id INTEGER,
  item_type character varying(5) NOT NULL
 );
 
 CREATE TABLE typea(
   typea_id INTEGER PRIMARY KEY 
 );
 
 CREATE TABLE typeb(
   typeb_id INTEGER PRIMARY KEY
 );
 
 CREATE FUNCTION check_type(id integer, tp varchar(5)) RETURNS boolean
  AS $$
     
     BEGIN
       IF tp = 'A' THEN
          PERFORM * FROM typea WHERE typea_id = id; --use perform query instead of select query just to evaluate an expression and discard the result
       ELSIF tp = 'B' THEN
          PERFORM * FROM typeb WHERE typeb_id = id;
       END IF;
       RETURN FOUND; --special variable of plpgsql FOUND is set to true if the query produced at least one row, or false if it produced no rows
     END;
  $$
  LANGUAGE 'plpgsql';
  
  
  ALTER TABLE ab ADD CONSTRAINT "check reference type"  CHECK (check_type(item_type_id, item_type))
  
  insert into typea values (1),(2)
  insert into typeb values (3),(4)
  insert into ab values (1,3,'A') -- check violation  
  

========================================================================================
ΕΡΩΤΗΜΑ Α2
========================================================================================
CREATE TABLE public."Student"
(
    am character(10) NOT NULL,
    name character varying NOT NULL,
    surname character varying NOT NULL,
    CONSTRAINT "Student_pkey" PRIMARY KEY (am)
);

CREATE TABLE public."Name"
(
    name character varying COLLATE pg_catalog."default" NOT NULL,
    sex character(1) COLLATE pg_catalog."default" NOT NULL,
    CONSTRAINT "Names_pkey" PRIMARY KEY (name)
);

CREATE TABLE public."Surname"
(
    surname character varying COLLATE pg_catalog."default" NOT NULL,
    CONSTRAINT "Surnames_pkey" PRIMARY KEY (surname)
);

-- use COPY for import or use Import/export from pgAdmin

COPY "Name"
FROM 'path_to\names.csv'
CSV HEADER;




========================================================================================
ΕΡΩΤΗΜΑ Α3
========================================================================================
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

CREATE OR REPLACE FUNCTION create_am(year integer, num integer)
RETURNS character(10) AS
$$
BEGIN
	RETURN concat(year::character(4),lpad(num::text,6,'0')); --cast(expression as target_type) or ::. LPAD() function returns a string left-padded to length characters.
END;
$$
LANGUAGE 'plpgsql' IMMUTABLE;--IMMUTABLE meaning that the output of the function can be expected to be the same if the inputs are the same.

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

-- check  functions' operation

select * from random_surnames(1000)
select * from random_names(1000)
select * from create_am(2021, 100)
select * from adapt_surname('ΑΓΕΛΑΔΑΡΗΣ', 'F')

========================================================================================
ΕΡΩΤΗΜΑ Α4
========================================================================================
CREATE OR REPLACE FUNCTION create_students(year integer, num integer)
RETURNS TABLE(am character(10),  name character varying, surname character varying) AS
$$
BEGIN
	RETURN QUERY
	SELECT create_am(year,n.id), n.name, adapt_surname(s.surname,sex)
	FROM random_names(num) n JOIN random_surnames(num) s USING (id);
END;
$$
LANGUAGE 'plpgsql' VOLATILE;

-- check  function's operation

select * from create_students(2021, 1000);
insert into "Student" select * from create_students(2021, 1000);
