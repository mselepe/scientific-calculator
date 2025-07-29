-- Drop constraints

IF EXISTS (SELECT * FROM sys.objects 
WHERE object_id = OBJECT_ID(N'fk_universityFromReallocationsUniversityId') AND type in (N'F'))
BEGIN
  ALTER TABLE universityReallocations DROP CONSTRAINT fk_universityFromReallocationsUniversityId;
END;

IF EXISTS (SELECT * FROM sys.objects 
WHERE object_id = OBJECT_ID(N'fk_universityToReallocationsUniversityId') AND type in (N'F'))
BEGIN
  ALTER TABLE universityReallocations DROP CONSTRAINT fk_universityToReallocationsUniversityId;
END;

IF EXISTS (SELECT * FROM sys.objects 
WHERE object_id = OBJECT_ID(N'fk_departmentFromReallocationsUniversityId') AND type in (N'F'))
BEGIN
  ALTER TABLE departmentReallocations DROP CONSTRAINT fk_departmentFromReallocationsUniversityId;
END;

IF EXISTS (SELECT * FROM sys.objects 
WHERE object_id = OBJECT_ID(N'fk_departmentToReallocationsUniversityId') AND type in (N'F'))
BEGIN
  ALTER TABLE departmentReallocations DROP CONSTRAINT fk_departmentToReallocationsUniversityId;
END;

-- Drop tables

IF EXISTS (SELECT * FROM sys.objects 
WHERE object_id = OBJECT_ID(N'[dbo].[universityReallocations]') AND type in (N'U'))
BEGIN
  DROP TABLE universityReallocations;
END;

IF EXISTS (SELECT * FROM sys.objects 
WHERE object_id = OBJECT_ID(N'[dbo].[departmentReallocations]') AND type in (N'U'))
BEGIN
  DROP TABLE departmentReallocations;
END;

-- Create tables

CREATE TABLE universityReallocations (
    [reallocationId] [INT] IDENTITY(1,1) PRIMARY KEY,
    [reallocationFrom] [INT] NOT NULL,
    [reallocationTo] [INT] NOT NULL,
    [fromNewAllocation] [MONEY] NOT NULL,
    [fromOldAllocation] [MONEY] NOT NULL,
    [toNewAllocation] [MONEY] NOT NULL,
    [toOldAllocation] [MONEY] NOT NULL,
    [moneyReallocated] [MONEY] NOT NULL,
    [createdAt] [DATETIME] NOT NULL DEFAULT GETDATE(),
    [userId] [VARCHAR](256) NOT NULL
)

CREATE TABLE departmentReallocations (
    [reallocationId] [INT] IDENTITY(1,1) PRIMARY KEY,
    [reallocationFrom] [INT] NOT NULL,
    [reallocationTo] [INT] NOT NULL,
    [fromNewAllocation] [MONEY] NOT NULL,
    [fromOldAllocation] [MONEY] NOT NULL,
    [toNewAllocation] [MONEY] NOT NULL,
    [toOldAllocation] [MONEY] NOT NULL,
    [moneyReallocated] [MONEY] NOT NULL,
    [createdAt] [DATETIME] NOT NULL DEFAULT GETDATE(),
    [userId] [VARCHAR](256) NOT NULL
)

-- Create constraints

ALTER TABLE universityReallocations
ADD CONSTRAINT fk_universityFromReallocationsUniversityId
FOREIGN KEY (reallocationFrom)
REFERENCES universities(universityId);

ALTER TABLE universityReallocations
ADD CONSTRAINT fk_universityToReallocationsUniversityId
FOREIGN KEY (reallocationTo)
REFERENCES universities(universityId);

ALTER TABLE departmentReallocations
ADD CONSTRAINT fk_departmentFromReallocationsUniversityId
FOREIGN KEY (reallocationFrom)
REFERENCES universityDepartments(universityDepartmentId);

ALTER TABLE departmentReallocations
ADD CONSTRAINT fk_departmentToReallocationsUniversityId
FOREIGN KEY (reallocationTo)
REFERENCES universityDepartments(universityDepartmentId);