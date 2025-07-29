
CREATE OR ALTER PROCEDURE onboardStudentProc (
    @email         NVARCHAR(255),
    @firstName     NVARCHAR(100),
    @lastName      NVARCHAR(100),
    @idNumber      NVARCHAR(50),  
    @gender        NVARCHAR(20),
    @race          NVARCHAR(50),
	@title		   NVARCHAR(20),

    @phoneNumber            NVARCHAR(30),
    @addressLine            NVARCHAR(500),  
    @cityTown               NVARCHAR(100),
    @PostalCode             NVARCHAR(20),
	@complexFlat			NVARCHAR(100),
	@suburbDistrict		NVARCHAR(256),

    @degree                 NVARCHAR(255),
    @gradeAverage           NVARCHAR(10),   
    @yearOfStudy            NVARCHAR(10),   
    @universityFaculty      NVARCHAR(100),

    @bursaryType            NVARCHAR(100),
    @bursaryAmount          MONEY,
    @bursarUniversity      NVARCHAR(255),
    @bursarDepartment      NVARCHAR(100),
	@bursaryTier		   INT,

    @proofOfIdFile      NVARCHAR(255),
    @contractFile       NVARCHAR(255),
	@paymentFile		NVARCHAR(255),
	@invoiceFile		NVARCHAR(255),
	@userId				NVARCHAR(255)
)
AS
BEGIN

    SET NOCOUNT ON;
	
    BEGIN TRY
        BEGIN TRANSACTION;
		DECLARE @raceId INT;
		DECLARE @genderId INT;
		DECLARE @titleId INT;
		DECLARE @studentId INT;
		DECLARE @universityDepartmentId INT;
		DECLARE @bursaryTypeId INT;
		DECLARE @applicationId INT;

		
		
        IF NOT EXISTS (SELECT 1 FROM dbo.Students WHERE idNumber = @idNumber)
        BEGIN
			SET @bursaryTypeId = (SELECT bursaryTypeId FROM bursaryTypes WHERE bursaryType = @bursaryType)
			SET @raceId = (SELECT raceId FROM races WHERE race = @race)
			SET @genderId = (SELECT genderId FROM genders WHERE gender = @gender)
			SET @titleId = (SELECT titleId FROM titles WHERE title=@title)
			SET @universityDepartmentId = (SELECT universityDepartmentId FROM universityDepartments WHERE universityDepartments.universityDepartmentName=@bursarDepartment AND universityDepartments.facultyId = (SELECT facultyId FROM faculties WHERE facultyName=@universityFaculty) AND universityDepartments.universityId = (SELECT universityId FROM universities WHERE universities.universityName = @bursarUniversity) )
            INSERT INTO dbo.Students (
                [name], surname,email,idDocumentName,raceId,genderId,contactNumber,streetAddress,suburb,city,postalCode,IdNumber, titleId,
				complexFlat,profilePictureBlobName
            )
            VALUES (@firstName,@lastName,@email,@proofOfIdFile,@raceId,@genderId,@phoneNumber,@addressLine,@suburbDistrict,@cityTown,@PostalCode,@idNumber,@titleId,@complexFlat,null
            );

			SET @studentId = SCOPE_IDENTITY();

			INSERT INTO universityApplications(studentId,universityDepartmentId,averageGrade,degreeName,dateOfApplication,amount,yearOfFunding,motivation,degreeDuration,bursaryTypeId)
			values(@studentId,@universityDepartmentId,@gradeAverage,@degree,GETDATE(),@bursaryAmount,YEAR(GETDATE()),'',0,@bursaryTypeId);

			SET @applicationId = SCOPE_IDENTITY();

			INSERT INTO studentApplications(yearOfStudy,applicationId,academicTranscriptBlobName,questionaireId,matricCertificateBlobName,financialStatementBlobName,citizenShip,termsAndConditions,privacyPolicy,applicationAcceptanceConfirmation,confirmHonors)
			VALUES(1,@applicationId,'',0,'','',1,1,1,1,'No');

			INSERT INTO applicationTiers(applicationId,tierId)
			VALUES(@applicationId,(SELECT tierId FROM tiers WHERE tier=@bursaryTier))

			INSERT INTO applicationStatusHistory(userId,applicationId,statusId,createdAt)
			VALUES(@userId,@applicationId,(SELECT statusId from applicationStatus where [status]='Onboarded'),GETDATE());

			
			INSERT INTO adminDocuments(documentBlobName,amount,applicationId,documentTypeId,expenseCategoryId,isDeleted)
			VALUES(@contractFile,@bursaryAmount,@applicationId,(SELECT documentTypeId FROM documentTypes WHERE [type]= 'Contract'),(SELECT InvoicePaymentForId FROM InvoiceOrPaymentFor WHERE [for]='contract'),0)

			IF @invoiceFile IS NOT NULL
			BEGIN
			INSERT INTO adminDocuments(documentBlobName,amount,applicationId,documentTypeId,expenseCategoryId,isDeleted)
			VALUES(@invoiceFile,@bursaryAmount,@applicationId,(SELECT documentTypeId FROM documentTypes WHERE [type]= 'Invoice'),(SELECT InvoicePaymentForId FROM InvoiceOrPaymentFor WHERE [for]='tuition'),0)
			END

			IF @paymentFile IS NOT NULL
			BEGIN
			INSERT INTO adminDocuments(documentBlobName,amount,applicationId,documentTypeId,expenseCategoryId,isDeleted)
			VALUES(@contractFile,@bursaryAmount,@applicationId,(SELECT documentTypeId FROM documentTypes WHERE [type]= 'Payment'),(SELECT InvoicePaymentForId FROM InvoiceOrPaymentFor WHERE [for]='tuition'),0)
			END

            SELECT applicationGuid,applicationId FROM universityApplications WHERE applicationId = @applicationId;
        END
        ELSE
        BEGIN
            SELECT 'application with id number already exists' AS messageText
        END
        COMMIT TRANSACTION;

    END TRY
    BEGIN CATCH
        IF @@TRANCOUNT > 0
            ROLLBACK TRANSACTION;

        PRINT 'An error occurred. Transaction rolled back.';

        THROW; 

    END CATCH;
END
GO


