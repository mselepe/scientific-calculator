IF EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[dataTransfer]') AND type in (N'P', N'PC'))
DROP PROCEDURE [dbo].[dataTransfer]
GO

CREATE PROCEDURE [dbo].[dataTransfer]
(   
    -- students
    @name VARCHAR(747),
    @surname VARCHAR(747),
    @email VARCHAR(345),
    @race VARCHAR(10),
    @gender VARCHAR(64),
    @contactNumber VARCHAR(12),
    @city VARCHAR(176),
    @idNumber VARCHAR(13),

    -- university applications
    @universityDepartmentName VARCHAR(256),
    @averageGrade DECIMAL(18, 0),
    @degreeName VARCHAR(256),
    @dateOfApplication DATETIME,
    @bursaryAmount MONEY,
    @universityName VARCHAR(256),

    -- student applications
    @yearOfStudy VARCHAR(10),

    -- expenses
    @accommodation MONEY,
    @tuition MONEY,
    @meals MONEY,
    @Other MONEY,
    @otherDescription VARCHAR(255)
)
AS
BEGIN
    BEGIN TRY
        BEGIN TRANSACTION;

        -- insert into students
        DECLARE @raceId INT
        SET @raceId = (
          SELECT raceId FROM races WHERE race = @race
        )

        DECLARE @genderId INT
        SET @genderId = (
          SELECT genderId FROM genders WHERE gender = @gender
        )
        INSERT INTO students(
          [name], surname,
          title, email,
          idDocumentName,
          raceId,
          genderId,
          contactNumber,
          streetAddress,
          suburb,
          city,
          postalCode,
          idNumber
        )
        VALUES (
          @name, @surname,
          'Unavailable', @email,
          'Unavailable', @raceId,
          @genderId, @contactNumber,
          'Unavailable', 'Unavailable',
          @city, 'None',
          @idNumber
        )

        DECLARE @studentId INT
        SET @studentId = SCOPE_IDENTITY()

        -- insert into university applications
        INSERT INTO universityApplications(
          studentId, universityDepartmentId,
          averageGrade, degreeName,
          dateOfApplication, amount,
          yearOfFunding, motivation
        )

        VALUES (
          @studentId, (
            SELECT universityDepartmentId FROM universityDepartments
            INNER JOIN universities
            ON universityDepartments.universityId = universities.universityId
            WHERE universityDepartments.universityDepartmentName = @universityDepartmentName
            AND universities.universityName = @universityName
          ), @averageGrade, @degreeName,
          @dateOfApplication, @bursaryAmount,
          2024, 'Unavailable'
        )

        DECLARE @applicationId INT
        SET @applicationId = SCOPE_IDENTITY()

        -- insert into application status hist
        INSERT INTO applicationStatusHistory(
          userId, applicationId,
          statusId, createdAt
        )

        VALUES (
          'BBD', @applicationId,
          (
          SELECT statusId FROM applicationStatus
          WHERE [status] = 'Approved'
          ), @dateOfApplication
        )

        -- insert into student applications
        INSERT INTO studentApplications(
          yearOfStudy, applicationId,
          academicTranscriptBlobName, questionaireId,
          matricCertificateBlobName, financialStatementBlobName,
          citizenShip, termsAndConditions, privacyPolicy,
          applicationAcceptanceConfirmation
        )

        VALUES (
          @yearOfStudy, @applicationId,
          'Unavailable', 0,
          'Unavailable', 'Unavailable',
          1, 1, 1, 1
        )

        -- insert into expenses
        INSERT INTO expenses(
          accommodation, tuition,
          meals, other,
          applicationId, otherDescription
        )

        VALUES (
          @accommodation, @tuition,
          @meals, @other,
          @applicationId, @otherDescription
        )
        
        DECLARE @docTypeInvoice VARCHAR(30)
        SET @docTypeInvoice = 'Invoice'

        DECLARE @docTypePayment VARCHAR(30)
        SET @docTypePayment = 'Payment'

        DECLARE @expenseCategory VARCHAR(30)

        DECLARE @adminDocAmount MONEY


        DECLARE expenseCategoryCursor CURSOR FOR
        SELECT [for] FROM InvoiceOrPaymentFor;

        OPEN expenseCategoryCursor;

        FETCH NEXT FROM expenseCategoryCursor INTO @expenseCategory;

        WHILE @@FETCH_STATUS = 0
        BEGIN

          SET @adminDocAmount = CASE 
                    WHEN @expenseCategory = 'tuition' THEN @tuition  
                    WHEN @expenseCategory = 'accommodation' THEN @accommodation
                    WHEN @expenseCategory = 'meals' THEN @meals
                    WHEN @expenseCategory = 'other' THEN @other
                    ELSE @bursaryAmount
                  END;
          
          EXEC dataTransferAdminDocs @applicationId, 
            @docTypeInvoice, @expenseCategory, @dateOfApplication, @adminDocAmount
          
          IF @expenseCategory <> 'contract'          
          BEGIN
            EXEC dataTransferAdminDocs @applicationId, 
              @docTypePayment, @expenseCategory, @dateOfApplication,@adminDocAmount
          END

          FETCH NEXT FROM expenseCategoryCursor INTO @expenseCategory;
        END

        CLOSE expenseCategoryCursor;
        DEALLOCATE expenseCategoryCursor;
        

        COMMIT TRANSACTION;
    END TRY
    BEGIN CATCH
        IF @@TRANCOUNT > 0
            ROLLBACK TRANSACTION;

        THROW;
    END CATCH;
END
