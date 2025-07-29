IF EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[dataTransferAdminDocs]') AND type in (N'P', N'PC'))
DROP PROCEDURE [dbo].[dataTransferAdminDocs]
GO

CREATE PROCEDURE [dbo].[dataTransferAdminDocs]
(   
    -- admin docs
    @applicationId INT,
    @documentType VARCHAR(30),
    @expenseCategory VARCHAR(256),
    @dateOfApplication DATETIME,

    -- invoices
    @adminDocAmount MONEY
)
AS
BEGIN
    BEGIN TRY
        BEGIN TRANSACTION;

        -- insert into admin docs
        INSERT INTO adminDocuments(
          documentBlobName, amount,
          applicationId, documentTypeId,
          expenseCategoryId, isDeleted
        )

        VALUES (
          'Unavailable', @adminDocAmount,
          @applicationId, (
            SELECT documentTypeId FROM documentTypes
            WHERE [type] = @documentType
          ), (
            SELECT InvoicePaymentForId FROM InvoiceOrPaymentFor
            WHERE [for] = @expenseCategory
          ), 0
        )

        -- invoice status history
        INSERT INTO invoiceStatusHistory (
          userId, applicationId,
          statusId, createdAt
        )


        VALUES (
          'BBD', @applicationId,
          (
            SELECT statusId FROM invoiceStatus
            WHERE [status] = 'Approved'
          ), @dateOfApplication
        )
        COMMIT TRANSACTION;
    END TRY
    BEGIN CATCH
        IF @@TRANCOUNT > 0
            ROLLBACK TRANSACTION;

        THROW;
    END CATCH;
END
