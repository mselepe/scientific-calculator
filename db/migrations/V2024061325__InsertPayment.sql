IF EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[InsertPaymentAndStatusHistory]') AND type in (N'P', N'PC'))
DROP PROCEDURE [dbo].[InsertPaymentAndStatusHistory]
GO

CREATE PROCEDURE [dbo].[InsertPaymentAndStatusHistory]
    @file NVARCHAR(MAX),
    @applicationId INT,
	@userId VARCHAR(255)
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
		WHERE [status]='Approved'

		SELECT @documentTypeId = documentTypeId
		FROM [dbo].[documentTypes]
		WHERE [type] ='Payment';

   
        INSERT INTO [dbo].[adminDocuments] ([documentBlobName],[amount],[applicationId],[documentTypeId])
        VALUES ( @file,@amount, @applicationId,@documentTypeId);

   
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