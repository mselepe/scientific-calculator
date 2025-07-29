/****** Object:  StoredProcedure [dbo].[uploadTranscriptAfterNudge]    Script Date: 2024/07/25 14:32:02 ******/

SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

IF EXISTS (
    SELECT 1 
    FROM sys.objects 
    WHERE object_id = OBJECT_ID(N'dbo.uploadTranscriptAfterNudge') 
    AND type = N'P'
)
BEGIN
	EXEC('ALTER PROCEDURE [dbo].[uploadTranscriptAfterNudge]
		@applicationGuid VARCHAR(256),
		@docBlobName VARCHAR(256),
		@semesterDescription VARCHAR(30)
    
		AS
		BEGIN
			SET NOCOUNT ON;
			BEGIN TRY
				BEGIN TRANSACTION;

				DECLARE @applicationId INT
				SET @applicationId = (
					SELECT applicationId 
					FROM universityApplications 
					WHERE applicationGuid = @applicationGuid
				)

				DECLARE @studentApplicationId INT
				SET @studentApplicationId = (
					SELECT studentApplicationId 
					FROM studentApplications 
					WHERE applicationId = @applicationId)

				DECLARE @yearOfStudy VARCHAR(10)
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
					universitySemesterId
				)
				VALUES(
					@studentApplicationId,
					@docBlobName,
					@yearOfStudy,
					@semesterId
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
	END')
END;