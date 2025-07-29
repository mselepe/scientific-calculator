IF EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[updateInvoicesStatusHistoryAfterContractSigned]') AND type in (N'P', N'PC'))
DROP PROCEDURE [dbo].[updateInvoicesStatusHistoryAfterContractSigned]
GO

CREATE PROCEDURE updateInvoicesStatusHistoryAfterContractSigned
    @userId VARCHAR(256),
	@applicationGuid VARCHAR(255),
    @status VARCHAR(10)
AS
BEGIN
    SET NOCOUNT ON;
    BEGIN TRY
        BEGIN TRANSACTION;

		DECLARE @applicationId INT
		SET @applicationId = (SELECT applicationId from universityApplications WHERE universityApplications.applicationGuid = @applicationGuid)

		DECLARE @statusId INT
		SET @statusId = (SELECT statusId from invoiceStatus WHERE [status] = @status)

		INSERT INTO [dbo].[invoiceStatusHistory] (userId, applicationId, statusId)
        VALUES (@userId, @applicationId, @statusId);

        COMMIT TRANSACTION;
    END TRY
    BEGIN CATCH
        IF @@TRANCOUNT > 0
            ROLLBACK TRANSACTION;
            
        DECLARE @ErrorMessage NVARCHAR(4000);
        DECLARE @ErrorSeverity INT;
        DECLARE @ErrorState INT;

        SELECT 
            @ErrorMessage = ERROR_MESSAGE(),
            @ErrorSeverity = ERROR_SEVERITY(),
            @ErrorState = ERROR_STATE();

        RAISERROR (@ErrorMessage, @ErrorSeverity, @ErrorState);
    END CATCH;
END;


