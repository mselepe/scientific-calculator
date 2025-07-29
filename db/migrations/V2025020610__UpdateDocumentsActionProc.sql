IF EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[updateDocumentAction]') AND type in (N'P', N'PC'))
DROP PROCEDURE [dbo].[updateDocumentAction]
GO

CREATE PROCEDURE [dbo].[updateDocumentAction]
  (@documentType VARCHAR(50),
   @previousFile VARCHAR(256),
   @newFile VARCHAR(256),
   @userId VARCHAR(256),
   @applicationGuid VARCHAR(256),
   @reasonForUpdate VARCHAR(MAX),
   @markAsDeleted BIT,
   @actionType VARCHAR(30)
   )
   AS
BEGIN
    SET NOCOUNT ON;

	DECLARE @documentTypeId INT;
	DECLARE @actionTypeId INT
   BEGIN TRY
	     
	SET @actionTypeId = (SELECT actionTypeId FROM actionTypes WHERE actionType =@actionType)

    IF NOT EXISTS (SELECT 1 FROM documentTypes WHERE [type] = @documentType) OR @documentType = 'contract'
    BEGIN
     EXEC updateStudentDocumentProc @previousFile,@newFile,@reasonForUpdate,@markAsDeleted,@userId, @actionTypeId 
    END
    ELSE
     EXEC updateDocument @documentType, @previousFile,@newFile,@userId,@applicationGuid,@reasonForUpdate, @actionTypeId

  END TRY
  BEGIN CATCH
        THROW;
  END CATCH;
END
