-- B Σύνδεση με τον εξυπηρετητή -- Δημιουργία πινάκων 
CREATE TABLE "Course_depends"
(
    dependent character(7) NOT NULL,
    main character(7) NOT NULL,
    mode course_dependency_mode_type,
    CONSTRAINT "Course_depends_pkey" PRIMARY KEY (dependent, main),
    CONSTRAINT dependent FOREIGN KEY (dependent) REFERENCES public."Course" (course_code) ON UPDATE CASCADE ON DELETE CASCADE,
    CONSTRAINT main FOREIGN KEY (main) REFERENCES public."Course" (course_code) ON UPDATE CASCADE ON DELETE CASCADE
);

CREATE TABLE public."Semester"
(
    semester_id integer NOT NULL,
    start_date date,
    end_date date,
    semester_status semester_status_type NOT NULL,
    CONSTRAINT "Semester_pkey" PRIMARY KEY (semester_id)
);

CREATE TABLE public."CourseRun"
(
    course_code character(7) NOT NULL,
    serial_number integer NOT NULL,
    exam_min numeric,
    lab_min numeric,
    exam_percentage numeric,
    labuses integer,
    semesterrunsin integer NOT NULL,
    CONSTRAINT "CourseRun_pkey" PRIMARY KEY (course_code, serial_number),
    CONSTRAINT "CourseRun_course_code_fkey" FOREIGN KEY (course_code)
        REFERENCES public."Course" (course_code) ON UPDATE CASCADE ON DELETE RESTRICT,
    CONSTRAINT "CourseRun_labuses_fkey" FOREIGN KEY (labuses)
        REFERENCES public."Lab" (lab_code) ON UPDATE CASCADE ON DELETE RESTRICT,
    CONSTRAINT "CourseRun_semesterrunsin_fkey" FOREIGN KEY (semesterrunsin)
        REFERENCES public."Semester" (semester_id) ON UPDATE CASCADE ON DELETE RESTRICT
);

-- Γ Εξάσκηση σε SQL

-- 1. JOIN
-- Βρες ζεύγη της μορφής (sector_title, lab_title) για όλα τα εργαστήρια
-- και τους τομείς όπου ανήκει το καθένα
SELECT s.sector_title,l.lab_title
FROM "Sector" s,"Lab" l
WHERE s.sector_code = l.sector_code

SELECT s.sector_title,l.lab_title
FROM "Sector" s JOIN "Lab" l USING (sector_code)

SELECT s.sector_title,l.lab_title
FROM "Sector" s JOIN "Lab" l ON (s.sector_code=l.sector_code)

-- 2. Computations and aliases in SELECT clause
-- Βρες τις συνολικές ώρες (lecture+tutorial+lab) κάθε μαθήματος και 
-- εμφάνισε το άθροισμα αυτό μαζί με τον αντίστοιχο κωδικό μαθήματος
SELECT c.course_code,c.lecture_hours+c.tutorial_hours+c.lab_hours as total_hours
FROM "Course" c

-- 3. UNION operator - Union of sets
-- Βρες τους τίτλους όλων των τομέων και των εργαστηρίων του τμήματος
(SELECT sector_title as title FROM "Sector")
UNION
(SELECT lab_title as title FROM "Lab")

-- 4. INTERSECT operator - Intersection of sets
-- Βρες τις γνωστικές περιοχές που καλύπτονται από μαθήματα τόσο 
-- στο πρώτο όσο και στο δεύτερο έτος σπουδών
(SELECT left(course_code,3) FROM "Course" WHERE typical_year=1)
INTERSECT
(SELECT left(course_code,3) FROM "Course" WHERE typical_year=2)

-- 5. IN / NOT IN operator
-- Βρες τους κωδικούς των μαθημάτων του δεύτερου έτους με γνωστικές
-- περιοχές που καλύπτονται από το εργαστήριο με κωδικό 8 
-- (χρησιμοποιήστε τον τελεστή IN)
SELECT course_code
FROM "Course"
WHERE typical_year=2 AND 
	left(course_code,3) IN 
		(SELECT field_code FROM "Covers" WHERE lab_code=8)

-- 6. EXISTS / NOT EXISTS operator
-- Βρες τους κωδικούς των μαθημάτων του δεύτερου έτους με γνωστικές 
-- περιοχές που καλύπτονται από το εργαστήριο με κωδικό 8 
-- (χρησιμοποιήστε τον τελεστή EXISTS)
SELECT course_code
FROM "Course"
WHERE typical_year=2 AND 
	EXISTS (SELECT field_code FROM "Covers" WHERE lab_code=8 
    AND left(course_code,3)=field_code)
		
-- 7. ALL
-- Βρες τους κωδικούς των μαθημάτων του πρώτου έτους σπουδών με τις 
-- λιγότερες διδακτικές μονάδες
SELECT course_code
FROM "Course"
WHERE typical_year= 1 AND 
	units <= ALL (	SELECT units
			FROM "Course" 
			WHERE typical_year=1)

-- 8. ANY
-- Βρες τους κωδικούς των μαθημάτων του πρώτου έτους σπουδών που δεν 
-- έχουν τις περισσότερες διδακτικές μονάδες
SELECT course_code
FROM "Course"
WHERE typical_year=1 AND 
	units < ANY (SELECT units
			FROM "Course" 
			WHERE typical_year=1)

-- 9. Subqueries in SELECT
-- Εμφάνισε τον τίτλο και το πλήθος των γνωστικών περιοχών κάθε εργαστηρίου.
SELECT lab_title, count(field_code)
FROM "Covers" c natural join "Lab" l
group by lab_title
-- or use subquery in select
SELECT l.lab_title, (SELECT count(*) 
FROM "Covers" f 
WHERE l.lab_code=f.lab_code) as number_of_fields
FROM "Lab" l

-- 1. Βρες το πλήθος των υποχρεωτικών μαθημάτων σε κάθε εξαμήνο σπουδών
SELECT typical_year, typical_season, COUNT(*) as num
FROM "Course"
WHERE obligatory
GROUP BY typical_year, typical_season

-- 2. Εμφάνισε το πλήθος των διδακτικών μονάδων των υποχρεωτικών 
--    μαθημάτων σε κάθε έτος σπουδών και ταξινόμησε με βάση το πλήθος 
--    σε φθίνουσα σειρά
SELECT typical_year, SUM(units) as units
FROM "Course"
WHERE obligatory
GROUP BY typical_year
ORDER BY units DESC

-- 3. Βρες τα εξάμηνα σπουδών που έχουν πάνω από 5 κατ' επιλογήν υποχρεωτικά 
--    μαθήματα
SELECT typical_year, typical_season
FROM "Course"
WHERE NOT obligatory
GROUP BY typical_year, typical_season
HAVING COUNT(*)>5

-- 4. Δείξε ταξινομημένους σε αντίστροφη αλφαβητική σειρά τους τίτλους 
--    των εργαστηρίων και το πλήθος των γνωστικών περιοχών καθενός
SELECT l.lab_title, COUNT(*)
FROM "Lab" l INNER JOIN "Covers" f ON l.lab_code = f.lab_code
GROUP BY l.lab_title
ORDER BY l.lab_title DESC
-- Εναλλακτική έκφραση με χρήση USING:
SELECT l.lab_title, COUNT(*)
FROM "Lab" l INNER JOIN "Covers" f USING (lab_code)
GROUP BY l.lab_title
ORDER BY l.lab_title DESC
-- Εναλλακτική έκφραση με NATURAL JOIN:
SELECT l.lab_title, COUNT(*)
FROM "Lab" l NATURAL JOIN "Covers" f
GROUP BY l.lab_title
ORDER BY l.lab_title DESC

-- 5. Βρες το μέγιστο συνολικό πλήθος διδακτικών μονάδων υποχρεωτικών 
--    μαθημάτων στα εξάμηνα σπουδών
SELECT MAX(total_units) 
FROM (	SELECT SUM(units) as total_units
	FROM "Course"
	WHERE obligatory
	GROUP BY typical_year, typical_season) s

-- 6. Βρες το εξάμηνο σπουδών με το μέγιστο συνολικό πλήθος 
--    διδακτικών μονάδων υποχρεωτικών μαθημάτων
SELECT typical_year, typical_season --, SUM(units)
FROM "Course"
WHERE obligatory
GROUP BY typical_year, typical_season
HAVING SUM(units) = (
	SELECT MAX(total_units) 
	FROM (	SELECT SUM(units) as total_units
		FROM "Course"
		WHERE obligatory
		GROUP BY typical_year, typical_season) s)
-- Εναλλακτική που δεν θα λειτουργήσει αν υπάρχουν παραπάνω 
-- από ένα εξάμηνα που ικανοποιούν τη συνθήκη
SELECT typical_year, typical_season,SUM(units) as total_units
FROM "Course"
WHERE obligatory
GROUP BY typical_year, typical_season
ORDER BY total_units DESC
LIMIT 1



 
