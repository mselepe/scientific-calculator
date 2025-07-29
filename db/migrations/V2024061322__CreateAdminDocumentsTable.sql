-- Drop Constraints


IF EXISTS (SELECT * FROM sys.objects
WHERE object_id = OBJECT_ID(N'fk_InvoicePaymentForId') AND type in (N'F'))
BEGIN
  ALTER TABLE adminDocuments DROP CONSTRAINT fk_InvoicePaymentForId;
END;

IF EXISTS (SELECT * FROM sys.objects 
WHERE object_id = OBJECT_ID(N'fk_adminDocumentsApplicationId') AND type in (N'F'))
BEGIN
  ALTER TABLE adminDocuments DROP CONSTRAINT fk_adminDocumentsApplicationId;
END;

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


-- Drop Tables

IF EXISTS (SELECT * FROM sys.objects 
WHERE object_id = OBJECT_ID(N'[dbo].[adminDocuments]') AND type in (N'U'))
BEGIN
  DROP TABLE adminDocuments;
END;

IF EXISTS (SELECT * FROM sys.objects 
WHERE object_id = OBJECT_ID(N'[dbo].[documentTypes]') AND type in (N'U'))
BEGIN
  DROP TABLE documentTypes;
END;

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

IF EXISTS (SELECT * FROM sys.objects
WHERE object_id = OBJECT_ID(N'[dbo].[InvoiceOrPaymentFor]') AND type in (N'U'))
BEGIN
  DROP TABLE InvoiceOrPaymentFor;
END;

-- Create Tables

CREATE TABLE adminDocuments (
    [adminDocumentId] [INT] IDENTITY(1,1) PRIMARY KEY,
    [documentBlobName] [VARCHAR](256) NOT NULL,
    [amount] [MONEY] NOT NULL,
    [applicationId] [INT] NOT NULL,
    [documentTypeId] [INT] NOT NULL,
    [expenseCategoryId] [INT] NOT NULL
)


CREATE TABLE documentTypes (
    [documentTypeId] [INT] IDENTITY(1,1) PRIMARY KEY,
    [type] [VARCHAR](30) NOT NULL
)


CREATE TABLE universityReallocations (
    [reallocationId] [INT] IDENTITY(1,1) PRIMARY KEY,
    [reallocationFrom] [INT] NOT NULL,
    [reallocationTo] [INT] NOT NULL,
    [newAllocation] [MONEY] NOT NULL,
    [oldAllocation] [MONEY] NOT NULL,
    [moneyReallocated] [MONEY] NOT NULL,
    [createdAt] [DATETIME] NOT NULL DEFAULT GETDATE(),
    [userId] [VARCHAR](256) NOT NULL
)

CREATE TABLE departmentReallocations (
    [reallocationId] [INT] IDENTITY(1,1) PRIMARY KEY,
    [reallocationFrom] [INT] NOT NULL,
    [reallocationTo] [INT] NOT NULL,
    [newAllocation] [MONEY] NOT NULL,
    [oldAllocation] [MONEY] NOT NULL,
    [moneyReallocated] [MONEY] NOT NULL,
    [createdAt] [DATETIME] NOT NULL DEFAULT GETDATE(),
    [userId] [VARCHAR](256) NOT NULL
)

CREATE TABLE InvoiceOrPaymentFor (
  [InvoicePaymentForId] [INT] IDENTITY(1,1) PRIMARY KEY,
  [for] [VARCHAR](256) NOT NULL
);

-- Create constraints

ALTER TABLE adminDocuments
ADD CONSTRAINT fk_adminDocumentsApplicationId
FOREIGN KEY (applicationId)
REFERENCES universityApplications(applicationId);

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

ALTER TABLE adminDocuments
ADD CONSTRAINT fk_InvoicePaymentForId
FOREIGN KEY (expenseCategoryId)
REFERENCES InvoiceOrPaymentFor(InvoicePaymentForId);
