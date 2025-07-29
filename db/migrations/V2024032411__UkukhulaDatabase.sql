-- DROP CONSTRAINTS

IF EXISTS (SELECT * FROM sys.objects 
WHERE object_id = OBJECT_ID(N'fk_studentRaceId') AND type in (N'F'))
BEGIN
  ALTER TABLE students DROP CONSTRAINT fk_studentRaceId;
END;

IF EXISTS (SELECT * FROM sys.objects 
WHERE object_id = OBJECT_ID(N'fk_studentId') AND type in (N'F'))
BEGIN
  ALTER TABLE universityApplications DROP CONSTRAINT fk_studentId;
END;

IF EXISTS (SELECT * FROM sys.objects 
WHERE object_id = OBJECT_ID(N'fk_universityId') AND type in (N'F'))
BEGIN
  ALTER TABLE universityDepartments DROP CONSTRAINT fk_universityId;
END;

IF EXISTS (SELECT * FROM sys.objects 
WHERE object_id = OBJECT_ID(N'fk_universityAllocationsDepartmentId') AND type in (N'F'))
BEGIN
  ALTER TABLE allocations DROP CONSTRAINT fk_universityAllocationsDepartmentId;
END;

IF EXISTS (SELECT * FROM sys.objects 
WHERE object_id = OBJECT_ID(N'fk_invoiceStatusId') AND type in (N'F'))
BEGIN
  ALTER TABLE invoices DROP CONSTRAINT fk_invoiceStatusId;
END;

IF EXISTS (SELECT * FROM sys.objects 
WHERE object_id = OBJECT_ID(N'fk_invoiceStatusHistoryApplicationId') AND type in (N'F'))
BEGIN
  ALTER TABLE invoiceStatusHistory DROP CONSTRAINT fk_invoiceStatusHistoryApplicationId;
END;

IF EXISTS (SELECT * FROM sys.objects 
WHERE object_id = OBJECT_ID(N'fk_applicationStatusHistoryId') AND type in (N'F'))
BEGIN
  ALTER TABLE universityApplications DROP CONSTRAINT fk_applicationStatusHistoryId;
END;

IF EXISTS (SELECT * FROM sys.objects 
WHERE object_id = OBJECT_ID(N'fk_universityApplicationsInvoiceStatusHistoryId') AND type in (N'F'))
BEGIN
  ALTER TABLE universityApplications DROP CONSTRAINT fk_universityApplicationsInvoiceStatusHistoryId;
END;

IF EXISTS (SELECT * FROM sys.objects 
WHERE object_id = OBJECT_ID(N'fk_degreeId') AND type in (N'F'))
BEGIN
  ALTER TABLE universityApplications DROP CONSTRAINT fk_degreeId;
END;

IF EXISTS (SELECT * FROM sys.objects 
WHERE object_id = OBJECT_ID(N'fk_universityApplicationsDepartmentId') AND type in (N'F'))
BEGIN
  ALTER TABLE universityApplications DROP CONSTRAINT fk_universityApplicationsDepartmentId;
END;

IF EXISTS (SELECT * FROM sys.objects 
WHERE object_id = OBJECT_ID(N'fk_invoiceStatusHistoryId') AND type in (N'F'))
BEGIN
  ALTER TABLE invoiceStatusHistory DROP CONSTRAINT fk_invoiceStatusHistoryId;
END;

IF EXISTS (SELECT * FROM sys.objects 
WHERE object_id = OBJECT_ID(N'fk_genderId') AND type in (N'F'))
BEGIN
  ALTER TABLE students DROP CONSTRAINT fk_genderId;
END;

IF EXISTS (SELECT * FROM sys.objects 
WHERE object_id = OBJECT_ID(N'fk_studentApplicationsApplicationId') AND type in (N'F'))
BEGIN
  ALTER TABLE studentApplications DROP CONSTRAINT fk_studentApplicationsApplicationId;
END;

IF EXISTS (SELECT * FROM sys.objects 
WHERE object_id = OBJECT_ID(N'fk_applicationstatusId') AND type in (N'F'))
BEGIN
  ALTER TABLE applicationStatusHistory DROP CONSTRAINT fk_applicationstatusId;
END;

IF EXISTS (SELECT * FROM sys.objects 
WHERE object_id = OBJECT_ID(N'fk_applicationStatusHistoryApplicationStatusStatusId') AND type in (N'F'))
BEGIN
  ALTER TABLE applicationStatusHistory DROP CONSTRAINT fk_applicationStatusHistoryApplicationStatusStatusId;
END;

IF EXISTS (SELECT * FROM sys.objects 
WHERE object_id = OBJECT_ID(N'fk_applicationStatusHistoryApplicationId') AND type in (N'F'))
BEGIN
  ALTER TABLE applicationStatusHistory DROP CONSTRAINT fk_applicationStatusHistoryApplicationId
END;

IF EXISTS (SELECT * FROM sys.objects 
WHERE object_id = OBJECT_ID(N'fk_universitiesUniversityStatus') AND type in (N'F'))
BEGIN
  ALTER TABLE universities DROP CONSTRAINT fk_universitiesUniversityStatus
END;

IF EXISTS (SELECT * FROM sys.objects 
WHERE object_id = OBJECT_ID(N'fk_declinedReasonsHistoryApplicationId') AND type in (N'F'))
BEGIN
  ALTER TABLE declinedReasonsHistory DROP CONSTRAINT fk_declinedReasonsHistoryApplicationStatusHistoryId
END;

IF EXISTS (SELECT * FROM sys.objects 
WHERE object_id = OBJECT_ID(N'fk_declinedReasonsHistoryReasonId') AND type in (N'F'))
BEGIN
  ALTER TABLE declinedReasonsHistory DROP CONSTRAINT fk_declinedReasonsHistoryReasonId
END;

IF EXISTS (SELECT * FROM sys.objects 
WHERE object_id = OBJECT_ID(N'fk_declinedMotivationsDeclinedReasonsHistoryId') AND type in (N'F'))
BEGIN
  ALTER TABLE declinedMotivations DROP CONSTRAINT fk_declinedMotivationsDeclinedReasonsHistoryId
END;

IF EXISTS (SELECT * FROM sys.objects 
WHERE object_id = OBJECT_ID(N'chk_universityApplicationsYearOfFunding') AND type in (N'F'))
BEGIN
  ALTER TABLE universityApplications DROP CONSTRAINT chk_universityApplicationsYearOfFunding;
END;

IF EXISTS (SELECT * FROM sys.objects 
WHERE object_id = OBJECT_ID(N'chk_allocationsYearOfFunding') AND type in (N'F'))
BEGIN
  ALTER TABLE allocations DROP CONSTRAINT chk_allocationsYearOfFunding;
END;

IF EXISTS (SELECT * FROM sys.objects 
WHERE object_id = OBJECT_ID(N'fk_facultyId') AND type in (N'F'))
BEGIN
  ALTER TABLE universityDepartments DROP CONSTRAINT fk_facultyId;
END;

IF EXISTS (SELECT * FROM sys.objects 
WHERE object_id = OBJECT_ID(N'fk_declinedMotivationsReasonsHistoryId') AND type in (N'F'))
BEGIN
  ALTER TABLE declinedMotivations DROP CONSTRAINT fk_declinedMotivationsReasonsHistoryId;
END;


-- DROP TABLES

IF EXISTS (SELECT * FROM sys.objects 
WHERE object_id = OBJECT_ID(N'[dbo].[invoiceStatus]') AND type in (N'U'))
BEGIN
  DROP TABLE invoiceStatus;
END;

IF EXISTS (SELECT * FROM sys.objects 
WHERE object_id = OBJECT_ID(N'[dbo].[invoiceStatusHistory]') AND type in (N'U'))
BEGIN
  DROP TABLE invoiceStatusHistory;
END;

IF EXISTS (SELECT * FROM sys.objects 
WHERE object_id = OBJECT_ID(N'[dbo].[applicationStatus]') AND type in (N'U'))
BEGIN
  DROP TABLE applicationStatus;
END;

IF EXISTS (SELECT * FROM sys.objects 
WHERE object_id = OBJECT_ID(N'[dbo].[applicationStatusHistory]') AND type in (N'U'))
BEGIN
  DROP TABLE applicationStatusHistory;
END;

IF EXISTS (SELECT * FROM sys.objects 
WHERE object_id = OBJECT_ID(N'[dbo].[races]') AND type in (N'U'))
BEGIN
  DROP TABLE races;
END;

IF EXISTS (SELECT * FROM sys.objects 
WHERE object_id = OBJECT_ID(N'[dbo].[genders]') AND type in (N'U'))
BEGIN
  DROP TABLE genders;
END;

IF EXISTS (SELECT * FROM sys.objects 
WHERE object_id = OBJECT_ID(N'[dbo].[universityStatus]') AND type in (N'U'))
BEGIN
  DROP TABLE universityStatus;
END;

IF EXISTS (SELECT * FROM sys.objects 
WHERE object_id = OBJECT_ID(N'[dbo].[students]') AND type in (N'U'))
BEGIN
  DROP TABLE students;
END;

IF EXISTS (SELECT * FROM sys.objects 
WHERE object_id = OBJECT_ID(N'[dbo].[universities]') AND type in (N'U'))
BEGIN
  DROP TABLE universities;
END;

IF EXISTS (SELECT * FROM sys.objects 
WHERE object_id = OBJECT_ID(N'[dbo].[universityDepartments]') AND type in (N'U'))
BEGIN
  DROP TABLE universityDepartments;
END;

IF EXISTS (SELECT * FROM sys.objects 
WHERE object_id = OBJECT_ID(N'[dbo].[allocations]') AND type in (N'U'))
BEGIN
  DROP TABLE allocations;
END;

IF EXISTS (SELECT * FROM sys.objects 
WHERE object_id = OBJECT_ID(N'[dbo].[universityApplications]') AND type in (N'U'))
BEGIN
  DROP TABLE universityApplications;
END;

IF EXISTS (SELECT * FROM sys.objects 
WHERE object_id = OBJECT_ID(N'[dbo].[degrees]') AND type in (N'U'))
BEGIN
  DROP TABLE degrees;
END;

IF EXISTS (SELECT * FROM sys.objects 
WHERE object_id = OBJECT_ID(N'[dbo].[invoices]') AND type in (N'U'))
BEGIN
  DROP TABLE invoices;
END;

IF EXISTS (SELECT * FROM sys.objects 
WHERE object_id = OBJECT_ID(N'[dbo].[studentApplications]') AND type in (N'U'))
BEGIN
  DROP TABLE studentApplications;
END;

IF EXISTS (SELECT * FROM sys.objects 
WHERE object_id = OBJECT_ID(N'[dbo].[faculties]') AND type in (N'U'))
BEGIN
  DROP TABLE faculties;
END;

IF EXISTS (SELECT * FROM sys.objects 
WHERE object_id = OBJECT_ID(N'[dbo].[declinedReasons]') AND type in (N'U'))
BEGIN
  DROP TABLE declinedReasons;
END;

IF EXISTS (SELECT * FROM sys.objects 
WHERE object_id = OBJECT_ID(N'[dbo].[declinedReasonsHistory]') AND type in (N'U'))
BEGIN
  DROP TABLE declinedReasonsHistory;
END;

IF EXISTS (SELECT * FROM sys.objects 
WHERE object_id = OBJECT_ID(N'[dbo].[declinedMotivations]') AND type in (N'U'))
BEGIN
  DROP TABLE declinedMotivations;
END;


-- CREATE TABLES

CREATE TABLE invoiceStatus (
  [statusId] [INT] IDENTITY(1,1) PRIMARY KEY,
  [status] [VARCHAR](10) NOT NULL
);

CREATE TABLE invoiceStatusHistory (
  [invoiceStatusHistoryId] [INT] IDENTITY(1,1) PRIMARY KEY,
  [userId] [VARCHAR](256) NOT NULL,
  [applicationId] [INT] NOT NULL,
  [statusId] [INT] NOT NULL,
  [createdAt] [DATETIME] NOT NULL DEFAULT GETDATE()
);

CREATE TABLE applicationStatus (
  [statusId] [INT] IDENTITY(1,1) PRIMARY KEY,
  [status] [VARCHAR](50) NOT NULL,
  [bbdDescription] [VARCHAR](1024) NOT NULL,
  [universityDescription] [VARCHAR](1024) NOT NULL
);

CREATE TABLE applicationStatusHistory (
  [applicationStatusHistoryId] [INT] IDENTITY(1,1) PRIMARY KEY,
  [userId] [VARCHAR](256) NOT NULL,
  [applicationId] [INT] NOT NULL,
  [statusId] [INT] NOT NULL,
  [createdAt] [DATETIME] NOT NULL DEFAULT GETDATE()
);

CREATE TABLE races (
  [raceId] [INT] IDENTITY(1,1) PRIMARY KEY,
  [race] [VARCHAR](10) NOT NULL
)

CREATE TABLE genders (
  [genderId] [INT] IDENTITY(1,1) PRIMARY KEY,
  [gender] [VARCHAR](64) NOT NULL
);

CREATE TABLE students (
  [studentId] [INT] IDENTITY(1,1) PRIMARY KEY,
  [name] [VARCHAR](747) NOT NULL,
  [surname] [VARCHAR](747) NOT NULL,
  [title] [VARCHAR](276) NOT NULL,
  [email] [VARCHAR](345) NOT NULL,
  [idDocumentName] [VARCHAR](256),
  [raceId] [INT] NOT NULL,
  [genderId] [INT] NOT NULL,
  [contactNumber] [VARCHAR](12) NOT NULL,
  [streetAddress] [VARCHAR](176) NOT NULL,
  [suburb] [VARCHAR](176) NOT NULL,
  [city] [VARCHAR](176) NOT NULL,
  [postalCode] [VARCHAR](10) NOT NULL,
  [idNumber] [VARCHAR](13) NOT NULL 
);

CREATE TABLE universityStatus (
  [universityStatusId] [INT] IDENTITY(1,1) PRIMARY KEY,
  [status] [VARCHAR](10) NOT NULL
);

CREATE TABLE universities (
  [universityId] [INT] IDENTITY(1,1) PRIMARY KEY,
  [universityName] [VARCHAR](256) NOT NULL,
  [universityStatusId] [INT] NOT NULL
);

CREATE TABLE universityDepartments (
  [universityDepartmentId] [INT] IDENTITY(1,1) PRIMARY KEY,
  [universityId] [INT] NOT NULL,
  [facultyId] [INT] NOT NULL,
  [universityDepartmentName] [VARCHAR](256) NOT NULL
);

CREATE TABLE allocations (
  [allocationId] [INT] IDENTITY(1,1) PRIMARY KEY,
  [universityDepartmentId] [INT] NOT NULL,
  [yearOfFunding] [INT] NOT NULL,
  [createdAt] [DATETIME] NOT NULL DEFAULT GETDATE(),
  [userId] [VARCHAR](256) NOT NULL,
  [amount] [MONEY] NOT NULL
);

CREATE TABLE universityApplications (
  [applicationId] [INT] IDENTITY(1,1) PRIMARY KEY,
  [studentId] [INT] NOT NULL,
  [universityDepartmentId] [INT] NOT NULL,
  [averageGrade] [DECIMAL] NOT NULL,
  [degreeName] [VARCHAR](256) NOT NULL,
  [dateOfApplication] [DATETIME] NOT NULL,
  [amount] [MONEY] NOT NULL,
  [yearOfFunding] [INT] NOT NULL
);

CREATE TABLE invoices (
  [invoiceId] [INT] IDENTITY(1,1) PRIMARY KEY,
  [amount] [MONEY] NOT NULL,
  [pdfName] [VARCHAR](256) NOT NULL,
  [statusId] [INT] NOT NULL
);

CREATE TABLE studentApplications (
  [studentApplicationId] [INT] IDENTITY(1,1) PRIMARY KEY,
  [yearOfStudy] [INT] NOT NULL,
  [applicationId] [INT] NOT NULL,
  [academicTranscriptBlobName] [VARCHAR](256) NOT NULL,
  [questionaireId] [INT] NOT NULL,
  [matricCertificateBlobName] [VARCHAR](256) NOT NULL,
  [financialStatementBlobName] [VARCHAR](256) NOT NULL,
  [citizenShip] [BIT] NOT NULL,
  [termsAndConditions] [BIT] NOT NULL,
  [privacyPolicy] [BIT] NOT NULL,
  [applicationAcceptanceConfirmation] [BIT] NOT NULL
);

CREATE TABLE faculties (
  [facultyId] [INT] IDENTITY(1,1) PRIMARY KEY,
  [facultyName] [VARCHAR](256) NOT NULL
);

CREATE TABLE declinedReasons (
  [reasonId] [INT] IDENTITY(1,1) PRIMARY KEY,
  [reason] [VARCHAR](256) NOT NULL
);

CREATE TABLE declinedReasonsHistory (
  [declinedReasonsHistoryId] [INT] IDENTITY(1,1) PRIMARY KEY,
  [applicationStatusHistoryId] [INT] NOT NULL,
  [reasonId] [INT] NOT NULL,
);

CREATE TABLE declinedMotivations (
  [motivationId] [INT] IDENTITY(1,1) PRIMARY KEY,
  [motivation] [VARCHAR](256) NOT NULL,
  [declinedReasonsHistoryId] [INT] NOT NULL
);


-- ADD CONSTRAINTS

ALTER TABLE students
ADD CONSTRAINT fk_studentRaceId
FOREIGN KEY (raceId)
REFERENCES races(raceId);

ALTER TABLE universityApplications
ADD CONSTRAINT fk_studentId
FOREIGN KEY (studentId)
REFERENCES students(studentId);

ALTER TABLE universityDepartments
ADD CONSTRAINT fk_universityId
FOREIGN KEY (universityId)
REFERENCES universities(universityId);

ALTER TABLE universityDepartments
ADD CONSTRAINT fk_facultyId
FOREIGN KEY (facultyId)
REFERENCES faculties(facultyId);

ALTER TABLE allocations
ADD CONSTRAINT fk_universityallocationsDepartmentId
FOREIGN KEY (universityDepartmentId)
REFERENCES universityDepartments(universityDepartmentId);

ALTER TABLE invoices
ADD CONSTRAINT fk_invoiceStatusId
FOREIGN KEY (invoiceId)
REFERENCES invoices(invoiceId);

ALTER TABLE invoiceStatusHistory
ADD CONSTRAINT fk_universityApplicationId
FOREIGN KEY (applicationId)
REFERENCES universityApplications(applicationId);

ALTER TABLE universityApplications
ADD CONSTRAINT fk_universityApplicationsDepartmentId
FOREIGN KEY (universityDepartmentId)
REFERENCES universityDepartments(universityDepartmentId);

ALTER TABLE invoiceStatusHistory
ADD CONSTRAINT fk_invoiceStatusHistoryId
FOREIGN KEY (statusId)
REFERENCES invoiceStatus(statusId);

ALTER TABLE students
ADD CONSTRAINT fk_genderId
FOREIGN KEY (genderId)
REFERENCES genders(genderId);

ALTER TABLE universities
ADD CONSTRAINT fk_universitiesUniversityStatus
FOREIGN KEY (universityStatusId)
REFERENCES universityStatus(universityStatusId);

ALTER TABLE studentApplications
ADD CONSTRAINT fk_studentApplicationsApplicationId
FOREIGN KEY (applicationId)
REFERENCES universityApplications(applicationId);

ALTER TABLE applicationStatusHistory
ADD CONSTRAINT fk_applicationStatusHistoryApplicationStatusStatusId
FOREIGN KEY (statusId)
REFERENCES applicationStatus(statusId);

ALTER TABLE applicationStatusHistory
ADD CONSTRAINT fk_applicationStatusHistoryApplicationId
FOREIGN KEY (applicationId)
REFERENCES universityApplications(applicationId);


ALTER TABLE declinedReasonsHistory
ADD CONSTRAINT fk_declinedReasonsHistoryApplicationStatusHistoryId
FOREIGN KEY (applicationStatusHistoryId)
REFERENCES applicationStatusHistory(applicationStatusHistoryId);

ALTER TABLE declinedReasonsHistory
ADD CONSTRAINT fk_declinedReasonsHistoryReasonId
FOREIGN KEY (reasonId)
REFERENCES declinedReasons(reasonId);


ALTER TABLE declinedMotivations
ADD CONSTRAINT fk_declinedMotivationsDeclinedReasonsHistoryId
FOREIGN KEY (declinedReasonsHistoryId)
REFERENCES declinedReasonsHistory(declinedReasonsHistoryId);

ALTER TABLE universityApplications
ADD CONSTRAINT chk_universityApplicationsYearOfFunding
CHECK (
    yearOfFunding >= YEAR(GETDATE()) - 1
    AND yearOfFunding <= YEAR(GETDATE()) + 1
);

ALTER TABLE allocations
ADD CONSTRAINT chk_allocationsYearOfFunding
CHECK (
    yearOfFunding >= YEAR(GETDATE()) - 1
    AND yearOfFunding <= YEAR(GETDATE()) + 1
);
