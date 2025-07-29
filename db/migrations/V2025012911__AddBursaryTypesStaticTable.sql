-- UPDATE UNIVERSITY APPLICATIONS TABLE
IF EXISTS (
    SELECT 1 
    FROM INFORMATION_SCHEMA.COLUMNS 
    WHERE TABLE_NAME = 'universityApplications' 
      AND COLUMN_NAME = 'bursaryType'
)
BEGIN
	ALTER TABLE universityApplications
	DROP COLUMN bursaryType
END;

IF NOT EXISTS (
    SELECT 1 
    FROM INFORMATION_SCHEMA.COLUMNS 
    WHERE TABLE_NAME = 'universityApplications' 
    AND COLUMN_NAME = 'bursaryTypeId'
)
BEGIN
	ALTER TABLE universityApplications
	ADD bursaryTypeId INT NOT NULL DEFAULT 1; 
END;

-- DROP CONSTRAINT

IF EXISTS (SELECT * FROM sys.objects 
WHERE object_id = OBJECT_ID(N'fk_universityApplicationsBursaryTypeId') AND type in (N'F'))
BEGIN
  ALTER TABLE universityApplications DROP CONSTRAINT fk_universityApplicationsBursaryTypeId;
END;

-- DROP TABLE

IF EXISTS (SELECT * FROM sys.objects 
WHERE object_id = OBJECT_ID(N'[dbo].[bursaryTypes]') AND type in (N'U'))
BEGIN
  DROP TABLE bursaryTypes;
END;

-- CREATE TABLE

CREATE TABLE bursaryTypes (
  [bursaryTypeId] [INT] IDENTITY(1,1) PRIMARY KEY,
  [bursaryType] [VARCHAR](10) NOT NULL
);

-- INSERT DATA 

IF EXISTS (SELECT * FROM sys.objects 
WHERE object_id = OBJECT_ID(N'[dbo].[bursaryTypes]') AND type in (N'U'))
BEGIN
    INSERT INTO [dbo].[bursaryTypes] (bursaryType)
    VALUES
      ('Ukukhula'),
	    ('BBD')
END;

-- ADD CONSTRAINT

ALTER TABLE universityApplications
ADD CONSTRAINT fk_universityApplicationsBursaryTypeId
FOREIGN KEY (bursaryTypeId)
REFERENCES bursaryTypes(bursaryTypeId);