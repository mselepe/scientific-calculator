IF EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[setCronConfig]') AND type in (N'P', N'PC'))
DROP PROCEDURE [dbo].[setCronConfig]
GO

CREATE PROCEDURE [dbo].[setCronConfig]
    @config BIT
AS
BEGIN
    SET NOCOUNT ON;
    BEGIN TRY
        BEGIN TRANSACTION;

        UPDATE cronConfig
        SET config = @config

        SELECT config FROM cronConfig;
        COMMIT TRANSACTION;
    END TRY
    BEGIN CATCH
        IF @@TRANCOUNT > 0
            ROLLBACK TRANSACTION;

        THROW;
    END CATCH;
END
