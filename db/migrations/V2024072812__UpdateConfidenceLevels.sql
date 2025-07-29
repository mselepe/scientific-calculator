IF EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[UpdateConfidence]') AND type in (N'P', N'PC'))
DROP PROCEDURE [dbo].[UpdateConfidence]
GO

CREATE PROCEDURE UpdateConfidence
AS
BEGIN
    SET NOCOUNT ON;
    BEGIN TRY
        BEGIN TRANSACTION;

        IF EXISTS(
        SELECT 1 FROM sys.columns 
            WHERE Name = N'averageToolConfidence'
            AND Object_ID = Object_ID(N'dbo.universities')
        )
            BEGIN

                -- Declare a temporary table
                DECLARE @noConfidenceUnis TABLE 
                (
                    uniId INT IDENTITY(1,1),
                    universityName NVARCHAR(256)
                )
                                
                -- Populate temporary table
                INSERT INTO @noConfidenceUnis(
                    universityName
                )
                VALUES
                    ('University of the Western Cape'),
                    ('Walter Sisulu University'),
                    ('University of Venda'),
                    ('Nelson Mandela University')


                -- Update the universities table
                UPDATE universities
                SET averageToolConfidence = 0
                WHERE universityName IN (
                    SELECT universityName
                    FROM @noConfidenceUnis
                )
            END;
		
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


