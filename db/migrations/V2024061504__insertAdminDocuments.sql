IF EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[insertAdminDocuments]') AND type in (N'P', N'PC'))
DROP PROCEDURE [dbo].[insertAdminDocuments]
GO

CREATE PROCEDURE [dbo].[insertAdminDocuments]
    @file NVARCHAR(MAX), -- students/4fc864f5-1544-4368-833b-8ed6603ba0be.pdf
    @applicationId INT, -- 219
	@userId VARCHAR(255), -- ffca0f81-e075-4f7c-80c2-b25c61651865
	@status VARCHAR(30), -- Pending
	@documentType VARCHAR(30), -- Invoice
	@expenseCategory INT -- 1
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

    
            INSERT INTO [dbo].[invoiceStatusHistory] ([userId], [applicationId], [statusId], [createdAt])
            VALUES (@userId, @applicationId, @statusId, GETDATE());

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
GO