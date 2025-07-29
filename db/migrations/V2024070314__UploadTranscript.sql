IF EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[uploadTranscriptAfterNudge]') AND type in (N'P', N'PC'))
DROP PROCEDURE [dbo].[uploadTranscriptAfterNudge]
GO

CREATE PROCEDURE uploadTranscriptAfterNudge
    @applicationId INT,
    @docBlobName VARCHAR(256),
    @semesterDescription VARCHAR(30),
	@semesterGradeAverage INT
    
	AS
	BEGIN
		SET NOCOUNT ON;
		BEGIN TRY
			BEGIN TRANSACTION;

			DECLARE @studentApplicationId INT
			SET @studentApplicationId = (
				SELECT studentApplicationId 
				FROM studentApplications 
				WHERE applicationId = @applicationId)

			DECLARE @yearOfStudy INT
			SET @yearOfStudy = (
				SELECT yearOfStudy 
				FROM studentApplications 
				WHERE applicationId = @applicationId)

			DECLARE @semesterId INT 
			SET @semesterId = (
				SELECT semesterId 
				FROM universitySemesters 
				WHERE semesterDescription = @semesterDescription)

			INSERT INTO academicTranscriptsHistory(
				studentApplicationId,
				docBlobName,
				yearOfStudy,
				universitySemesterId,
				semesterGradeAverage
			)
			VALUES(
				@studentApplicationId,
				@docBlobName,
				@yearOfStudy,
				@semesterId,
				@semesterGradeAverage
			)

			DECLARE @newTranscript INT
			SET @newTranscript = SCOPE_IDENTITY()

			SELECT @newTranscript AS newTranscriptId

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


