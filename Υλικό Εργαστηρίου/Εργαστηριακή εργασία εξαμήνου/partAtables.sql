CREATE TYPE public.diploma_type AS ENUM (
    'degree',
    'diploma',
    'certificate'
);

CREATE TABLE public."Committee" (
    "ProfessorAMKA" character varying NOT NULL,
    "ThesisID" integer NOT NULL,
    "Supervisor" boolean
);

CREATE TABLE public."CustomUnits" (
    "CustomUnitID" integer NOT NULL,
    "SeasonalProgramID" integer NOT NULL,
    "Credits" integer
);

CREATE TABLE public."Diploma" (
    "DiplomaNum" integer NOT NULL,
    "DiplomaGrade" numeric,
    "DiplomaTitle" character varying,
    "StudentAMKA" character varying NOT NULL,
    "ProgramID" integer NOT NULL
);

CREATE TABLE public."ForeignLanguageProgram" (
    "ProgramID" integer NOT NULL,
    "Language" character varying
);

CREATE TABLE public."Joins" (
    "StudentAMKA" character varying NOT NULL,
    "ProgramID" integer NOT NULL
);

CREATE TABLE public."Program" (
    "ProgramID" integer NOT NULL,
    "Duration" integer,
    "MinCourses" integer,
    "MinCredits" integer,
    "Obligatory" boolean,
    "CommitteeNum" integer,
    "DiplomaType" public.diploma_type,
    "NumOfParticipants" integer,
    "Year" character(4)
);

CREATE TABLE public."ProgramOffersCourse" (
    "ProgramID" integer NOT NULL,
    "CourseCode" character(7) NOT NULL
);

CREATE TABLE public."RefersTo" (
    "CustomUnitID" integer NOT NULL,
    "SeasonalProgramID" integer NOT NULL,
    "CourseRunCode" character(7) NOT NULL,
    "CourseRunSerial" integer NOT NULL
);

CREATE TABLE public."SeasonalProgram" (
    "ProgramID" integer NOT NULL,
    "Season" character varying
);

CREATE TABLE public."Thesis" (
    "ThesisID" integer NOT NULL,
    "Grade" numeric,
    "Title" character varying,
    "StudentAMKA" character varying,
    "ProgramID" integer
);

ALTER TABLE ONLY public."Committee"
    ADD CONSTRAINT "Committee_pkey" PRIMARY KEY ("ProfessorAMKA", "ThesisID");

ALTER TABLE ONLY public."CustomUnits"
    ADD CONSTRAINT "CustomUnits_pkey" PRIMARY KEY ("CustomUnitID", "SeasonalProgramID");

ALTER TABLE ONLY public."Diploma"
    ADD CONSTRAINT "Diploma_pkey" PRIMARY KEY ("DiplomaNum", "StudentAMKA", "ProgramID");

ALTER TABLE ONLY public."ForeignLanguageProgram"
    ADD CONSTRAINT "ForeignLanguageProgram_pkey" PRIMARY KEY ("ProgramID");

ALTER TABLE ONLY public."Joins"
    ADD CONSTRAINT "Joins_pkey" PRIMARY KEY ("StudentAMKA", "ProgramID");

ALTER TABLE ONLY public."ProgramOffersCourse"
    ADD CONSTRAINT "ProgramOffersCourse_pkey" PRIMARY KEY ("ProgramID", "CourseCode");

ALTER TABLE ONLY public."Program"
    ADD CONSTRAINT "Program_pkey" PRIMARY KEY ("ProgramID");

ALTER TABLE ONLY public."RefersTo"
    ADD CONSTRAINT "RefersTo_pkey" PRIMARY KEY ("CustomUnitID", "CourseRunCode", "SeasonalProgramID", "CourseRunSerial");

ALTER TABLE ONLY public."SeasonalProgram"
    ADD CONSTRAINT "SeasonalProgram_pkey" PRIMARY KEY ("ProgramID");

ALTER TABLE ONLY public."Thesis"
    ADD CONSTRAINT "Thesis_pkey" PRIMARY KEY ("ThesisID");

ALTER TABLE ONLY public."CustomUnits"
    ADD CONSTRAINT "CustomUnits_fk_1" FOREIGN KEY ("SeasonalProgramID") REFERENCES public."SeasonalProgram"("ProgramID") ON UPDATE CASCADE ON DELETE CASCADE;

ALTER TABLE ONLY public."ForeignLanguageProgram"
    ADD CONSTRAINT "ForeignLanguageProgram_fk_1" FOREIGN KEY ("ProgramID") REFERENCES public."Program"("ProgramID");

ALTER TABLE ONLY public."SeasonalProgram"
    ADD CONSTRAINT "SeasonalProgram_fk_1" FOREIGN KEY ("ProgramID") REFERENCES public."Program"("ProgramID");

ALTER TABLE ONLY public."Committee"
    ADD CONSTRAINT committee_fk_1 FOREIGN KEY ("ProfessorAMKA") REFERENCES public."Professor"(amka);

ALTER TABLE ONLY public."Committee"
    ADD CONSTRAINT committee_fk_2 FOREIGN KEY ("ThesisID") REFERENCES public."Thesis"("ThesisID");

ALTER TABLE ONLY public."Diploma"
    ADD CONSTRAINT diploma_fk_1 FOREIGN KEY ("StudentAMKA") REFERENCES public."Student"(amka) ON UPDATE CASCADE ON DELETE CASCADE;

ALTER TABLE ONLY public."Diploma"
    ADD CONSTRAINT diploma_fk_2 FOREIGN KEY ("ProgramID") REFERENCES public."Program"("ProgramID") ON UPDATE CASCADE ON DELETE CASCADE;

ALTER TABLE ONLY public."Joins"
    ADD CONSTRAINT joins_fk_1 FOREIGN KEY ("StudentAMKA") REFERENCES public."Student"(amka);

ALTER TABLE ONLY public."Joins"
    ADD CONSTRAINT joins_fk_2 FOREIGN KEY ("ProgramID") REFERENCES public."Program"("ProgramID");

ALTER TABLE ONLY public."ProgramOffersCourse"
    ADD CONSTRAINT offers_fk_1 FOREIGN KEY ("ProgramID") REFERENCES public."Program"("ProgramID");

ALTER TABLE ONLY public."ProgramOffersCourse"
    ADD CONSTRAINT offers_fk_2 FOREIGN KEY ("CourseCode") REFERENCES public."Course"(course_code);

ALTER TABLE ONLY public."RefersTo"
    ADD CONSTRAINT refersto_fk_1 FOREIGN KEY ("CustomUnitID", "SeasonalProgramID") REFERENCES public."CustomUnits"("CustomUnitID", "SeasonalProgramID") ;

ALTER TABLE ONLY public."RefersTo"
    ADD CONSTRAINT refersto_fk_2 FOREIGN KEY ("CourseRunCode", "CourseRunSerial") REFERENCES public."CourseRun"(course_code, serial_number);

ALTER TABLE ONLY public."Thesis"
    ADD CONSTRAINT thesis_fk_1 FOREIGN KEY ("StudentAMKA") REFERENCES public."Student"(amka);

ALTER TABLE ONLY public."Thesis"
    ADD CONSTRAINT thesis_fk_2 FOREIGN KEY ("ProgramID") REFERENCES public."Program"("ProgramID");
