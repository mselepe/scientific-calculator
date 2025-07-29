IF EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[InsertIntoQuestionnaire]') AND type in (N'P', N'PC'))
DROP PROCEDURE [dbo].[InsertIntoQuestionnaire]
GO

CREATE PROCEDURE InsertIntoQuestionnaire
    @questionnaireStatus VARCHAR(15),
    @newQuestionnaireId INT = NULL OUTPUT
AS
BEGIN
    SET NOCOUNT ON;
    BEGIN TRY
        BEGIN TRANSACTION;

        INSERT INTO questionnaires ([questionnaireStatusId])
        VALUES ((SELECT questionnaireStatusId FROM questionnaireStatuses WHERE [status] = @questionnaireStatus));
        SET @newQuestionnaireId = SCOPE_IDENTITY();

        SELECT @newQuestionnaireId AS questionnaireId;

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