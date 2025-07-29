IF EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[updateStudentDocumentProc]') AND type in (N'P', N'PC'))
DROP PROCEDURE [dbo].[updateStudentDocumentProc]
GO

CREATE PROCEDURE [dbo].[updateStudentDocumentProc]
(
   @previousFile VARCHAR(256),
   @newFile VARCHAR(256),
   @reasonForUpdate VARCHAR(MAX),
   @markAsDeleted BIT,
   @userId VARCHAR(256),
   @actionTypeId INT
)
AS
BEGIN
    SET NOCOUNT ON;

    DECLARE @previousAdminDocumentId INT;
  	DECLARE @newAdminDocumentId INT;
  	DECLARE @amount MONEY;
  	DECLARE @applicationId INT;
  	DECLARE @documentTypeId INT;
  	DECLARE @expenseCategoryId INT;

    BEGIN TRY
        BEGIN TRANSACTION;
		-- DIRTY DATA
		SET @amount = (SELECT TOP 1 amount FROM adminDocuments ad WHERE ad.documentBlobName = @previousFile)

		SET @applicationId = (SELECT TOP 1applicationId FROM adminDocuments ad WHERE ad.documentBlobName = @previousFile)

		SET @documentTypeId = (SELECT TOP 1 documentTypeId FROM adminDocuments ad WHERE ad.documentBlobName = @previousFile)

		SET @expenseCategoryId = (SELECT TOP 1 expenseCategoryId FROM adminDocuments ad WHERE ad.documentBlobName = @previousFile)

		SET @previousAdminDocumentId =(SELECT TOP 1 adminDocumentId FROM adminDocuments ad WHERE ad.documentBlobName = @previousFile AND isDeleted = 0)

		UPDATE adminDocuments 
		SET isDeleted = @markAsDeleted
		WHERE documentBlobName = @previousFile AND isDeleted = 0

		 IF @newFile = ' '
        BEGIN
         SET @markAsDeleted = 1
        END
        ELSE
        BEGIN
         SET @markAsDeleted = 0
     END  
 
		INSERT INTO adminDocuments(documentBlobName,amount,applicationId,documentTypeId,expenseCategoryId,isDeleted)
		VALUES (@newFile,@amount,@applicationId,@documentTypeId,@expenseCategoryId, @markAsDeleted)

		SET @newAdminDocumentId = SCOPE_IDENTITY();

		INSERT INTO documentHistory(documentTypeId,applicationId,previousFile,newFile,userId,changeReason,actionTypeId)
		VALUES(@documentTypeId,@applicationId,@previousFile,@newFile,@userId,@reasonForUpdate,@actionTypeId)

		SELECT @newAdminDocumentId as 'id'

        COMMIT TRANSACTION;
    END TRY
    BEGIN CATCH
        IF @@TRANCOUNT > 0
            ROLLBACK TRANSACTION;

        THROW;
    END CATCH;
END
