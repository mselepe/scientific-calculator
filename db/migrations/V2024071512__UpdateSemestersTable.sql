-- DROP SEMESTERID CONSTRAINT

IF EXISTS (SELECT * FROM sys.objects 
WHERE object_id = OBJECT_ID(N'fk_academicTranscriptsHistorySemesterId') AND type in (N'F'))
BEGIN
  ALTER TABLE academicTranscriptsHistory DROP CONSTRAINT fk_academicTranscriptsHistorySemesterId;
END;

-- DROP UNIVERSITY SEMESTERS TABLE

IF EXISTS (SELECT * FROM sys.objects 
WHERE object_id = OBJECT_ID(N'[dbo].[universitySemesters]') AND type in (N'U'))
BEGIN
  DROP TABLE universitySemesters;
END;

-- RECREATE UNIVERSITY SEMESTERS TABLE

CREATE TABLE universitySemesters (
  [semesterId] [INT] IDENTITY(1,1) PRIMARY KEY,
  [semesterDescription] [VARCHAR](30) NOT NULL
);

-- POPULATE SEMESTERS TABLE

IF EXISTS (SELECT * FROM sys.objects 
WHERE object_id = OBJECT_ID(N'[dbo].[universitySemesters]') AND type in (N'U'))
BEGIN
    INSERT INTO [dbo].[universitySemesters] ([semesterDescription])
    VALUES
            ('First semester'),
            ('Second semester'),
            ('Matric'),
            ('Initial Transcript')
END;

-- ADD CONSTRAINT BACK

ALTER TABLE academicTranscriptsHistory
ADD CONSTRAINT fk_academicTranscriptsHistorySemesterId
FOREIGN KEY (universitySemesterId)
REFERENCES universitySemesters(semesterId);