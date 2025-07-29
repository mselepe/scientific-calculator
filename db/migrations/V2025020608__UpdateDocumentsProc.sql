IF EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[updateDocument]') AND type in (N'P', N'PC'))
DROP PROCEDURE [dbo].[updateDocument]
GO

CREATE PROCEDURE [dbo].[updateDocument]
(
   @documentType VARCHAR(50),
   @previousFile VARCHAR(256),
   @newFile VARCHAR(256),
   @userId VARCHAR(256),
   @applicationGuid VARCHAR(256),
   @reasonForUpdate VARCHAR(MAX),
   @actionTypeId INT
)
AS
BEGIN
    SET NOCOUNT ON;

	DECLARE @applicationId INT;
	DECLARE @documentHistoryId INT;
	DECLARE @documentTypeId INT;
	DECLARE @matricDocumentTypeId INT;
	DECLARE @identityDocumentTypeId INT;
	DECLARE @financialStatementDocumentTypeId INT;
	DECLARE @academicRecordDocumentTypeId INT;

    BEGIN TRY
        BEGIN TRANSACTION;

		SET @documentTypeId = (SELECT documentTypeId from documentTypes WHERE documentTypes.type = @documentType) 
		
		SET @matricDocumentTypeId = (SELECT documentTypeId FROM documentTypes WHERE documentTypes.type='Matric Certificate')

		SET @identityDocumentTypeId = (SELECT documentTypeId FROM documentTypes WHERE documentTypes.type='Proof of Identification')

		SET @financialStatementDocumentTypeId =  (SELECT documentTypeId FROM documentTypes WHERE documentTypes.type='Financial Statement')

		SET @academicRecordDocumentTypeId =  (SELECT documentTypeId FROM documentTypes WHERE documentTypes.type='Academic Record')

		SET @applicationId = (SELECT ua.applicationId FROM universityApplications ua WHERE ua.applicationGuid = @applicationGuid)

		--store
		INSERT INTO documentHistory(documentTypeId,applicationId,previousFile,newFile,userId,changeReason,actionTypeId)
		VALUES(@documentTypeId,@applicationId,@previousFile,@newFile,@userId,@reasonForUpdate,@actionTypeId)

		SET @documentHistoryId = SCOPE_IDENTITY();

		IF @documentTypeId = @matricDocumentTypeId 
		BEGIN
			UPDATE studentApplications
			SET matricCertificateBlobName = @newFile
			WHERE applicationId = @applicationId
		END
		ELSE IF @documentTypeId = @identityDocumentTypeId 
		BEGIN
			UPDATE students
			SET idDocumentName = @newFile
			WHERE studentId =(SELECT studentId FROM universityApplications WHERE applicationId =  @applicationId)
		END
		ELSE IF @documentTypeId = @financialStatementDocumentTypeId 
		BEGIN
			UPDATE studentApplications
			SET financialStatementBlobName = @newFile
			WHERE applicationId = @applicationId
		END
		ELSE IF @documentTypeId = @academicRecordDocumentTypeId 
		BEGIN
			UPDATE studentApplications
			SET academicTranscriptBlobName = @newFile
			WHERE applicationId = @applicationId
		END
				
		SELECT @documentHistoryId as 'id'

        COMMIT TRANSACTION;
    END TRY
    BEGIN CATCH
        IF @@TRANCOUNT > 0
            ROLLBACK TRANSACTION;

        THROW;
    END CATCH;
END