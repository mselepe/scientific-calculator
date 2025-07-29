-- DROP CONSTRAINTS

IF EXISTS (SELECT * FROM sys.objects 
WHERE object_id = OBJECT_ID(N'fk_academicTranscriptsHistorySemesterId') AND type in (N'F'))
BEGIN
  ALTER TABLE academicTranscriptsHistory DROP CONSTRAINT fk_academicTranscriptsHistorySemesterId;
END;

IF EXISTS (SELECT * FROM sys.objects 
WHERE object_id = OBJECT_ID(N'fk_academicTranscriptsHistoryStudentApplicationsId') AND type in (N'F'))
BEGIN
  ALTER TABLE academicTranscriptsHistory DROP CONSTRAINT fk_academicTranscriptsHistoryStudentApplicationId;
END;


-- DROP TABLES

IF EXISTS (SELECT * FROM sys.objects 
WHERE object_id = OBJECT_ID(N'[dbo].[academicTranscriptsHistory]') AND type in (N'U'))
BEGIN
  DROP TABLE academicTranscriptsHistory;
END;

IF EXISTS (SELECT * FROM sys.objects 
WHERE object_id = OBJECT_ID(N'[dbo].[universitySemesters]') AND type in (N'U'))
BEGIN
  DROP TABLE universitySemesters;
END;


-- CREATE TABLES

CREATE TABLE universitySemesters (
  [semesterId] [INT] IDENTITY(1,1) PRIMARY KEY,
  [semesterDescription] [VARCHAR](30) NOT NULL
);

CREATE TABLE academicTranscriptsHistory (
  [academicTranscriptsHistoryId] [INT] IDENTITY(1,1) PRIMARY KEY,
  [docBlobName] [VARCHAR](256) NOT NULL,
  [createdAt] [DATETIME] NOT NULL DEFAULT GETDATE(),
  [yearOfStudy] [INT] NOT NULL,
  [semesterGradeAverage] [INT] NOT NULL,
  [universitySemesterId] [INT] NOT NULL,
  [studentApplicationId] [INT] NOT NULL
);

-- ADD CONSTRAINTS

ALTER TABLE academicTranscriptsHistory
ADD CONSTRAINT fk_academicTranscriptsHistorySemesterId
FOREIGN KEY (universitySemesterId)
REFERENCES universitySemesters(semesterId);

-- ADD CONSTRAINTS

ALTER TABLE academicTranscriptsHistory
ADD CONSTRAINT fk_academicTranscriptsHistoryStudentApplicationId
FOREIGN KEY (studentApplicationId)
REFERENCES studentApplications(studentApplicationId);