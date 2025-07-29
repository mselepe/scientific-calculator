IF EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[InsertInvoiceAndStatusHistory]') AND type in (N'P', N'PC'))
DROP PROCEDURE [dbo].[InsertInvoiceAndStatusHistory]
GO

CREATE PROCEDURE InsertInvoiceAndStatusHistory
    @file NVARCHAR(MAX),
    @applicationId INT
AS
BEGIN
    BEGIN TRY
     
        BEGIN TRANSACTION

        DECLARE @amount DECIMAL(18, 2);
        DECLARE @statusId INT;
        DECLARE @userId VARCHAR(255);

        SELECT @amount = amount
        FROM [dbo].[universityApplications]
        WHERE [applicationId] = @applicationId;

        SELECT TOP 1 @userId = userId
        FROM [dbo].[applicationStatusHistory]
        WHERE [applicationId] = @applicationId
        ORDER BY [createdAt] DESC;

		SELECT @statusId = statusId
		FROM [dbo].[invoiceStatus]
		WHERE [status]='In Review'

   
        INSERT INTO [dbo].[invoices] ([amount], [pdfName], [statusId])
        VALUES (@amount, @file, @statusId);

   
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



