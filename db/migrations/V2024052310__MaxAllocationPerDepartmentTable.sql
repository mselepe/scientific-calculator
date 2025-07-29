
IF EXISTS (SELECT * FROM sys.objects 
WHERE object_id = OBJECT_ID(N'fk_universityDepartmentId') AND type in (N'F'))
BEGIN
  ALTER TABLE maxAllocationPerDepartment DROP CONSTRAINT fk_universityDepartmentId
END;

IF EXISTS (SELECT * FROM sys.objects 
WHERE object_id = OBJECT_ID(N'[dbo].[maxAllocationPerDepartment]') AND type in (N'U'))
BEGIN
  DROP TABLE maxAllocationPerDepartment;
END;

CREATE TABLE maxAllocationPerDepartment(
 [maxAllocationPerDepartmentId] [INT] IDENTITY(1,1) PRIMARY KEY,
 [userId] [VARCHAR](256) NOT NULL,
 [minAmount] [MONEY] NOT NULL,
 [maxAmount] [MONEY] NOT NULL,
 [universityDepartmentId] [INT] NOT NULL,
 [createdAt] [DATETIME] NOT NULL DEFAULT GETDATE())


 ALTER TABLE maxAllocationPerDepartment
 ADD CONSTRAINT fk_universityDepartmentId
 FOREIGN KEY (universityDepartmentId)
 REFERENCES universityDepartments(universityDepartmentId)