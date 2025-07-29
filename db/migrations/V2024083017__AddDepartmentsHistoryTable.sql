
IF EXISTS (SELECT * FROM sys.objects 
WHERE object_id = OBJECT_ID(N'fk_departmentNameHistoryId') AND type in (N'F'))
BEGIN
  ALTER TABLE departmentNameHistory DROP CONSTRAINT fk_departmentNameHistoryId
END;

IF EXISTS (SELECT * FROM sys.objects 
WHERE object_id = OBJECT_ID(N'[dbo].[departmentNameHistory]') AND type in (N'U'))
BEGIN
  DROP TABLE departmentNameHistory;
END;

CREATE TABLE departmentNameHistory (
    departmentNameHistoryId INT IDENTITY(1,1) PRIMARY KEY,
    universityDepartmentId INT NOT NULL,
    oldName VARCHAR(255) NOT NULL,
    newName VARCHAR(255) NOT NULL,
    changeDate DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP,
	  userId VARCHAR(256)
);

ALTER TABLE departmentNameHistory
ADD CONSTRAINT fk_departmentNameHistoryId
FOREIGN KEY (universityDepartmentId)
REFERENCES universityDepartments(universityDepartmentId);