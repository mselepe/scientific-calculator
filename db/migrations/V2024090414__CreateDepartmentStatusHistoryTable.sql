IF EXISTS (SELECT * FROM sys.objects 
WHERE object_id = OBJECT_ID(N'fk_departmentStatusId') AND type in (N'F'))
BEGIN
  ALTER TABLE departmentStatusHistory DROP CONSTRAINT fk_departmentStatusId
END;


IF EXISTS (SELECT * FROM sys.objects 
WHERE object_id = OBJECT_ID(N'fk_universityDepartmentStatusId') AND type in (N'F'))
BEGIN
  ALTER TABLE departmentStatusHistory DROP CONSTRAINT fk_universityDepartmentStatusId
END;

IF EXISTS (SELECT * FROM sys.objects 
WHERE object_id = OBJECT_ID(N'[dbo].[departmentStatusHistory]') AND type in (N'U'))
BEGIN
  DROP TABLE departmentStatusHistory;
END;
  
CREATE TABLE departmentStatusHistory (
    departmentStatusHistoryId INT IDENTITY(1,1) PRIMARY KEY, 
    departmentStatusId INT NOT NULL,
    universityDepartmentId INT NOT NULL, 
	  userId VARCHAR(256) NOT NULL,
    statusChangeDate DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP
	
);

ALTER TABLE departmentStatusHistory
ADD CONSTRAINT fk_universityDepartmentStatusId
FOREIGN KEY (universityDepartmentId)
REFERENCES universityDepartments(universityDepartmentId);

ALTER TABLE departmentStatusHistory
ADD CONSTRAINT fk_departmentStatusId
FOREIGN KEY (departmentStatusId)
REFERENCES departmentStatus(departmentStatusId);
