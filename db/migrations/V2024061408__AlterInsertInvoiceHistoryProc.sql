/****** Object:  StoredProcedure [dbo].[InsertInvoiceAndStatusHistory]    Script Date: 2024/06/14 13:46:01 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
ALTER PROCEDURE [dbo].[InsertInvoiceAndStatusHistory]
    @file NVARCHAR(MAX),
    @applicationId INT,
	@userId VARCHAR(255),
	@InvoicePaymentFor VARCHAR(255)
AS
BEGIN
    BEGIN TRY

        BEGIN TRANSACTION

        DECLARE @amount DECIMAL(18, 2);
        DECLARE @statusId INT;
		DECLARE @documentTypeId INT;
		DECLARE @InvoicePaymentForId INT;

        SELECT @amount = amount
        FROM [dbo].[universityApplications]
        WHERE [applicationId] = @applicationId;


		SELECT @statusId = statusId
		FROM [dbo].[invoiceStatus]
		WHERE [status]='In Review';

		SELECT @documentTypeId = [documentTypeId]
		FROM [dbo].[documentTypes]
		WHERE [type] ='Invoice';

		SELECT @InvoicePaymentForId = InvoicePaymentForId
		FROM [dbo].[InvoiceOrPaymentFor]
		WHERE [for]=@InvoicePaymentFor;



        INSERT INTO [dbo].[adminDocuments] ([documentBlobName],[amount],[applicationId],[documentTypeId],[expenseCategoryId])
        VALUES ( @file,@amount, @applicationId,@documentTypeId,@InvoicePaymentForId);


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
