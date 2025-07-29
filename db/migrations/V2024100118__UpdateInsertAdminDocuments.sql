SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
ALTER PROCEDURE [dbo].[insertAdminDocuments]
    @file NVARCHAR(MAX),
    @applicationId INT, 
	@userId VARCHAR(255),
	@status VARCHAR(30), 
	@documentType VARCHAR(30),
	@expenseCategory INT, 
	@reason VARCHAR(255) = ''
    AS
    BEGIN
        BEGIN TRY
        
            BEGIN TRANSACTION

            DECLARE @amount DECIMAL(18, 2);
            DECLARE @statusId INT;
            DECLARE @documentTypeId INT;

            SELECT @amount = amount
            FROM [dbo].[universityApplications]
            WHERE [applicationId] = @applicationId;


            SELECT @statusId = statusId
            FROM [dbo].[invoiceStatus]
            WHERE [status]= @status;

            SELECT @documentTypeId = [documentTypeId]
            FROM [dbo].[documentTypes]
            WHERE [type] = @documentType;
    
            INSERT INTO [dbo].[adminDocuments] ([documentBlobName],[amount],[applicationId],[documentTypeId], [expenseCategoryId])
            VALUES ( @file,@amount, @applicationId,@documentTypeId, @expenseCategory);

    
            INSERT INTO [dbo].[invoiceStatusHistory] ([userId], [applicationId], [statusId], [createdAt], [requestedChange])
            VALUES (@userId, @applicationId, @statusId, GETDATE(),@reason);

            DECLARE @invoiceStatusHistoryId INT;
            SET @invoiceStatusHistoryId = SCOPE_IDENTITY();

            COMMIT TRANSACTION;

            SELECT @invoiceStatusHistoryId AS 'NewInvoiceId';
        END TRY
        BEGIN CATCH
    
            IF @@TRANCOUNT > 0
                ROLLBACK TRANSACTION;

            THROW;
        END CATCH;
END;

