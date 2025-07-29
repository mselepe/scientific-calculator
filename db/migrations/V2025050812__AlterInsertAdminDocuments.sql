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
        BEGIN TRANSACTION;
            DECLARE @amount DECIMAL(18, 2);
            DECLARE @statusId INT;
            DECLARE @documentTypeId INT;
            DECLARE @invoiceStatusHistoryId INT;
            DECLARE @applicationStatusId INT;
            DECLARE @mappedApplicationStatus VARCHAR(50);

            SELECT @amount = amount
            FROM [dbo].[universityApplications]
            WHERE [applicationId] = @applicationId;

            SELECT @documentTypeId = [documentTypeId]
            FROM [dbo].[documentTypes]
            WHERE [type] = @documentType;

            INSERT INTO [dbo].[adminDocuments] ([documentBlobName], [amount], [applicationId], [documentTypeId], [expenseCategoryId])
            VALUES (@file, @amount, @applicationId, @documentTypeId, @expenseCategory);

            SET @mappedApplicationStatus =
                CASE LOWER(@status)
                    WHEN 'invoice'   THEN 'Invoice'
                    WHEN 'in review' THEN 'Payment'
                    WHEN 'approved'  THEN 'Active'
                    ELSE NULL
                END;

            IF @mappedApplicationStatus IS NOT NULL
            BEGIN
                SELECT @applicationStatusId = statusId
                FROM [dbo].[applicationStatus]
                WHERE [status] = @mappedApplicationStatus;

                INSERT INTO [dbo].[applicationStatusHistory] ([userId], [applicationId], [statusId], [createdAt])
                VALUES ( @userId, @applicationId, @applicationStatusId, GETDATE());
            END;

            IF LOWER(@status) <> 'invoice'
            BEGIN
                SELECT @statusId = statusId
                FROM [dbo].[invoiceStatus]
                WHERE [status] = @status;

                INSERT INTO [dbo].[invoiceStatusHistory] ([userId], [applicationId], [statusId], [createdAt], [requestedChange])
                VALUES (@userId, @applicationId, @statusId, GETDATE(), @reason);

                SET @invoiceStatusHistoryId = SCOPE_IDENTITY();
            END;

        COMMIT TRANSACTION;

        SELECT @invoiceStatusHistoryId AS 'NewInvoiceId';
    END TRY
    BEGIN CATCH
    IF @@TRANCOUNT > 0
                ROLLBACK TRANSACTION;

            THROW;
    END CATCH;
END;