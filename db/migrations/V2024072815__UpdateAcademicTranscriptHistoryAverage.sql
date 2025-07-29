IF EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[UpdateAverage]') AND type in (N'P', N'PC'))
DROP PROCEDURE [dbo].[UpdateAverage]
GO

CREATE PROCEDURE UpdateAverage
    @academicTranscriptsHistoryId INT,
    @average NUMERIC(5, 2)
AS
BEGIN
    BEGIN TRY
        BEGIN TRANSACTION;

        IF EXISTS(
        SELECT 1 FROM sys.columns 
            WHERE Name = N'semesterGradeAverage'
            AND Object_ID = Object_ID(N'dbo.academicTranscriptsHistory')
        )
            BEGIN
                UPDATE academicTranscriptsHistory
                SET semesterGradeAverage = @average
                WHERE academicTranscriptsHistoryId = @academicTranscriptsHistoryId

				SELECT @@ROWCOUNT AS rowsAffected;
            END
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

