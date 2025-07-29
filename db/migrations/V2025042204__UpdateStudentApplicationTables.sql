SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
ALTER PROCEDURE [dbo].[StudentApplicationTablesUpdates]
		@applicationId INT,
		@studentId INT,
		@title VARCHAR(276),
		@other VARCHAR(276),
		@name VARCHAR(747),
		@surname VARCHAR(747),
		@gender VARCHAR(64),
		@idNumber VARCHAR(13),
		@race VARCHAR(10),
		@contactNumber VARCHAR(12), --There will be a +27 this number should be 12
		@streetAddress VARCHAR(176),
		@suburb VARCHAR(176),
		@city VARCHAR(176),
		@postaCode VARCHAR(10),
		@degree VARCHAR(256),
		@gradeAverage DECIMAL,
		@yearOfStudy NCHAR(10),
		@userId VARCHAR(256),
		@applicationAcceptanceConfirmation VARCHAR(5),
		@citizenship VARCHAR(5),
		@termsAndConditions VARCHAR(5),
		@privacyPolicy VARCHAR(5),
		@idDocumentName VARCHAR(256),
		@academicTranscriptDocumentName VARCHAR(256),
		@financialStatementDocumentName VARCHAR(256),
		@matricDocumentName VARCHAR(256),
		@dateOfBirth VARCHAR(10),
		@questionnaireResponseJson VARCHAR(MAX),
		@questionnaireStatus VARCHAR(10),
        @complexFlat VARCHAR(170),
        @degreeDuration INT,
        @confirmHonors VARCHAR(15)
	AS
	BEGIN
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

			DECLARE @titleId INT;
			SELECT @titleId = titleId
			FROM titles
			WHERE titles.title = @title

			DECLARE @bursaryTypeId INT;
			SELECT @bursaryTypeId = bursaryTypeId
			FROM universityApplications
			WHERE universityApplications.applicationId = @applicationId

			-- Update university applications
			UPDATE universityApplications
			SET averageGrade = @gradeAverage,
				degreeName = @degree,
                degreeDuration = @degreeDuration
			FROM universityApplications
			WHERE universityApplications.applicationId = @applicationId;

			-- Update students
			UPDATE students
			SET name=@name,
				surname=@surname,
				raceId = @raceId,
				genderId = @genderId,
				titleId = @titleId,
				idNumber = @idNumber,
				contactNumber = @contactNumber,
				streetAddress = @streetAddress,
				suburb = @suburb,
				city = @city,
				postalCode = @postaCode,
				idDocumentName = @idDocumentName,
				dateOfBirth = @dateOfBirth,
                complexFlat = @complexFlat

			FROM students
			WHERE students.studentId = @studentId;

			IF @bursaryTypeId = (SELECT bursaryTypeId FROM bursaryTypes WHERE bursaryType = 'Ukukhula') 
			BEGIN
				INSERT INTO applicationStatusHistory (userId, applicationId, statusId)
				VALUES (@userId, @applicationId, 
						(SELECT statusId FROM applicationStatus WHERE status = 'In Review'))
			END
			ELSE
			BEGIN
				INSERT INTO applicationStatusHistory (userId, applicationId, statusId)
				VALUES (@userId, @applicationId, 
						(SELECT statusId FROM applicationStatus WHERE status = 'Onboarded'))
			END

			-- Insert questionnaire
			DECLARE @questionnaireId INT
			INSERT INTO questionnaires ([questionnaireStatusId])
			VALUES ((SELECT questionnaireStatusId FROM questionnaireStatuses WHERE [status] = @questionnaireStatus));
			SET @questionnaireId = SCOPE_IDENTITY();

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

			-- Get the recent student application Id
			DECLARE @studentApplicationId INT
			SET @studentApplicationId = SCOPE_IDENTITY();

			-- Insert matric and initial transcript
			IF @studentApplicationId IS NOT NULL
			BEGIN
				DECLARE @applicationGuid VARCHAR(256)
				SET @applicationGuid = (
					SELECT applicationGuid
					FROM universityApplications
					WHERE applicationId = @applicationId)

				UPDATE studentApplications
				SET questionaireId = @questionnaireId,
                    confirmHonors = @confirmHonors
				FROM studentApplications
				WHERE studentApplications.applicationId = @applicationId;

				EXEC uploadTranscriptAfterNudge @applicationGuid, @matricDocumentName, 'Matric'
				EXEC uploadTranscriptAfterNudge @applicationGuid, @academicTranscriptDocumentName, 'Initial Transcript'
			END;

			-- Insert responses
			IF @questionnaireId IS NOT NULL
			BEGIN
				DECLARE @date DATETIME
				SET @date = GETDATE()
				INSERT INTO [responses]
				SELECT [response], 
					[questionId],
					@questionnaireId AS [questionnaireId],
					@date AS [responseDate]
				FROM OPENJSON (@questionnaireResponseJson)
				WITH (
					[response] VARCHAR(MAX),
					[questionId] INT
					)
			END;

			-- Insert custom title
			IF @other IS NOT NULL AND @studentId IS NOT NULL
			BEGIN
				INSERT INTO customTitles(customTitle, studentId)
				VALUES (@other, @studentId)
			END;

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