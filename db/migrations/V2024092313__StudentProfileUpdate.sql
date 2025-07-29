IF EXISTS (SELECT * FROM sys.objects 
           WHERE object_id = OBJECT_ID(N'[dbo].[updateStudentDetails]') 
           AND type IN (N'P', N'PC'))
BEGIN
    DROP PROCEDURE [dbo].[updateStudentDetails];
END
GO

CREATE PROCEDURE [dbo].[updateStudentDetails]
    @newName VARCHAR(747),
    @newSurname VARCHAR(747),
    @newEmail VARCHAR(345),
    @newContactNumber VARCHAR(12),
    @name VARCHAR(747),
    @surname VARCHAR(747),
    @email VARCHAR(345),
	@contactNumber VARCHAR(12),
    @department VARCHAR(256),
    @faculty VARCHAR(256),
    @university VARCHAR(256)
AS
BEGIN
    SET NOCOUNT ON;
    
    BEGIN TRY
        BEGIN TRANSACTION;
        IF @name IS NOT NULL AND @surname IS NOT NULL AND @email IS NOT NULL AND @contactNumber IS NOT NULL
        BEGIN

            IF OBJECT_ID('tempdb..#temStudentDetails') IS NOT NULL
            BEGIN
                DROP TABLE #tempStudentDetails;
            END;

            CREATE TABLE #tempStudentDetails(
                applicationGuid VARCHAR(256), 
                applicationDate DATETIME)
            INSERT INTO #tempStudentDetails(applicationGuid, applicationDate)
            EXEC GetStudentApplicationGuid @department, @faculty, 
                @email, @name, @surname, @university

            DECLARE @studentId INT, @applicationGuid VARCHAR(256)
                        SET @applicationGuid = (SELECT applicationGuid FROM #tempStudentDetails)
                        SET @studentId = (
                            SELECT studentId FROM universityApplications WHERE universityApplications.applicationGuid = @applicationGuid 
                        )   
            UPDATE students
            SET [name] = @newName,
                surname = @newSurname,
                email = @newEmail,
                contactNumber = @newContactNumber
            WHERE studentId = @studentId
            DROP TABLE #tempStudentDetails
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
GO