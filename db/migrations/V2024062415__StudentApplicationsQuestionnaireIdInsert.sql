IF EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[InsertQuestionnaireIdIntoStudentApplications]') AND type in (N'P', N'PC'))
DROP PROCEDURE [dbo].[InsertQuestionnaireIdIntoStudentApplications]
GO

CREATE PROCEDURE InsertQuestionnaireIdIntoStudentApplications
    @applicationId INT,
    @questionnaireId INT
AS
BEGIN
    BEGIN TRY
        BEGIN TRANSACTION;

        UPDATE studentApplications
        SET questionaireId = @questionnaireId
        FROM studentApplications
        WHERE studentApplications.applicationId = @applicationId;

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