IF EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[TotalFundInsert]') AND type in (N'P', N'PC'))
DROP PROCEDURE [dbo].[TotalFundInsert]
GO

CREATE PROCEDURE TotalFundInsert
    @userId VARCHAR(256),
    @amount MONEY,
    @year INT
AS
BEGIN
    BEGIN TRY
        BEGIN TRANSACTION;

            INSERT INTO totalFundHistory(amount, yearOfFunding, userId)
            VALUES(@amount, @year, @userId)

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


