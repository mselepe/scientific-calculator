IF EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[StudentApplicationTablesUpdates]') AND type in (N'P', N'PC'))
DROP PROCEDURE [dbo].[StudentApplicationTablesUpdates]
GO

CREATE PROCEDURE StudentApplicationTablesUpdates
    @applicationId INT,
    @studentId INT,
    @title VARCHAR(276),
    @gender VARCHAR(64),
    @idNumber VARCHAR(13),
    @race VARCHAR(10),
    @contactNumber VARCHAR(12), --There will be a +27 this number should be 12
    @streetAddress VARCHAR(176),
    @suburb VARCHAR(176),
    @city VARCHAR(176),
    @postaCode VARCHAR(10),
    @degree VARCHAR(256),
    @gradeAverage INT,
    @yearOfStudy INT,
    @userId VARCHAR(256),
	@applicationAcceptanceConfirmation VARCHAR(5),
    @citizenship VARCHAR(5),
    @termsAndConditions VARCHAR(5),
    @privacyPolicy VARCHAR(5),
    @idDocumentName VARCHAR(256),
    @academicTranscriptDocumentName VARCHAR(256),
    @financialStatementDocumentName VARCHAR(256),
    @matricDocumentName VARCHAR(256)
AS
BEGIN
    SET NOCOUNT ON;
    BEGIN TRY
        BEGIN TRANSACTION;

        -- Check if faculty name exists
        DECLARE @raceId INT;
        SELECT @raceId = raceId
        FROM races
        WHERE race = @race;

        
        DECLARE @genderId INT;
        SELECT @genderId = genderId
        FROM genders
        WHERE gender = @gender;

        -- Update university applications
        UPDATE universityApplications
        SET averageGrade = @gradeAverage,
            degreeName = @degree
        FROM universityApplications
        WHERE universityApplications.applicationId = @applicationId;

        -- Update students
        UPDATE students
        SET raceId = @raceId,
            genderId = @genderId,
			title = @title,
            idNumber = @idNumber,
            contactNumber = @contactNumber,
            streetAddress = @streetAddress,
            suburb = @suburb,
            city = @city,
            postalCode = @postaCode,
            idDocumentName = @idDocumentName
        FROM students
        WHERE students.studentId = @studentId;

        INSERT INTO applicationStatusHistory (userId, applicationId, statusId)
        VAlUES (@userId,
                @applicationId,
                (SELECT statusId FROM applicationStatus WHERE status='In Review')
        )

        -- Insert into student applications
        INSERT INTO studentApplications(yearOfStudy, 
										applicationId, 
										academicTranscriptBlobName, 
										matricCertificateBlobName,
										financialStatementBlobName,
										citizenShip, 
										termsAndConditions, 
										privacyPolicy, 
										applicationAcceptanceConfirmation, 
										questionaireId)
        VALUES (@yearOfStudy, 
				@applicationId, 
				@academicTranscriptDocumentName, 
				@matricDocumentName, 
				@financialStatementDocumentName, 
				@citizenship, 
				@termsAndConditions, 
				@privacyPolicy, 
				@applicationAcceptanceConfirmation, 0);

        COMMIT TRANSACTION;
    END TRY
    BEGIN CATCH
        IF @@TRANCOUNT > 0
            ROLLBACK TRANSACTION;
            
        DECLARE @ErrorMessage NVARCHAR(4000);
        DECLARE @ErrorSeverity INT;
        DECLARE @ErrorState INT;

        SELECT 
            @ErrorMessage = ERROR_MESSAGE(),
            @ErrorSeverity = ERROR_SEVERITY(),
            @ErrorState = ERROR_STATE();

        RAISERROR (@ErrorMessage, @ErrorSeverity, @ErrorState);
    END CATCH;
END;


