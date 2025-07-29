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