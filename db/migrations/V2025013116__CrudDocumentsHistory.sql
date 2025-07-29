IF COL_LENGTH('dbo.adminDocuments', 'createdAt') IS NULL
BEGIN
ALTER TABLE adminDocuments
ADD createdAt DATETIME DEFAULT GETDATE();
END

--DROP CONSTRAINTS
IF EXISTS (SELECT * FROM sys.objects 
WHERE object_id = OBJECT_ID(N'fk_previousAdminDocumentId') AND type in (N'F'))
BEGIN
  ALTER TABLE adminDocumentsHistory DROP CONSTRAINT fk_previousAdminDocumentId;
END;

IF EXISTS (SELECT * FROM sys.objects 
WHERE object_id = OBJECT_ID(N'fk_newAdminDocumentId') AND type in (N'F'))
BEGIN
  ALTER TABLE adminDocumentsHistory DROP CONSTRAINT fk_newAdminDocumentId;
END;

--DROP TABLE
IF EXISTS (SELECT * FROM sys.objects 
WHERE object_id = OBJECT_ID(N'[dbo].[adminDocumentsHistory]') AND type in (N'U'))
BEGIN
  DROP TABLE adminDocumentsHistory;
END;

--CREATE TABLE
CREATE TABLE adminDocumentsHistory
(
    adminDocumentsHistoryId INT IDENTITY(1,1) PRIMARY KEY,
    previousAdminDocumentId INT NOT NULL,
    newAdminDocumentId INT NOT NULL,
    modifierUserId VARCHAR(256),
    reasonForUpdate VARCHAR(MAX)
)

-- ADD CONSTRAINTS
ALTER TABLE adminDocumentsHistory
ADD CONSTRAINT fk_previousAdminDocumentId
FOREIGN KEY (previousAdminDocumentId)
REFERENCES adminDocuments(adminDocumentId);

ALTER TABLE adminDocumentsHistory
ADD CONSTRAINT fk_newAdminDocumentId
FOREIGN KEY (newAdminDocumentId)
REFERENCES adminDocuments(adminDocumentId);

--PROC

IF EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[updateStudentDocumentProc]') AND type in (N'P', N'PC'))
DROP PROCEDURE [dbo].[updateStudentDocumentProc]
GO

CREATE PROCEDURE [dbo].[updateStudentDocumentProc]
(
   @previousFile VARCHAR(256),
   @newFile VARCHAR(256),
   @reasonForUpdate VARCHAR(MAX),
   @markAsDeleted BIT,
   @userId VARCHAR(256)
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
		WHERE adminDocumentId = @previousAdminDocumentId

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

		INSERT INTO adminDocumentsHistory(previousAdminDocumentId,newAdminDocumentId,modifierUserId,reasonForUpdate)
		VALUES(@previousAdminDocumentId,@newAdminDocumentId,@userId,@reasonForUpdate)
		
		SELECT @newAdminDocumentId as 'id'

        COMMIT TRANSACTION;
    END TRY
    BEGIN CATCH
        IF @@TRANCOUNT > 0
            ROLLBACK TRANSACTION;

        THROW;
    END CATCH;
END