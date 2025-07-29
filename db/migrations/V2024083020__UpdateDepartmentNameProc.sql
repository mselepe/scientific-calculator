
IF EXISTS (SELECT * FROM sys.objects 
           WHERE object_id = OBJECT_ID(N'[dbo].[updateDepartmentProc]') 
           AND type IN (N'P', N'PC'))
BEGIN
    DROP PROCEDURE [dbo].[updateDepartmentProc];
END
GO

CREATE PROCEDURE [dbo].[updateDepartmentProc]
    @university VARCHAR(256),
    @oldDepartment VARCHAR(256),
    @newDepartment VARCHAR(256),
	@userId VARCHAR(256)
AS
BEGIN
    SET NOCOUNT ON;
    
    BEGIN TRY
        BEGIN TRANSACTION;

        DECLARE @universityId INT;
        DECLARE @universityDepartmentId INT;

        SET @universityId = (
            SELECT universityId 
            FROM universities 
            WHERE universityName = @university
        );

        IF @universityId IS NULL
        BEGIN
            RAISERROR ('University not found.', 16, 1);
            ROLLBACK TRANSACTION;
            RETURN;
        END

        SET @universityDepartmentId = (
            SELECT universityDepartmentId 
            FROM universityDepartments 
            WHERE universityId = @universityId 
              AND universityDepartmentName = @oldDepartment
        );

        IF @universityDepartmentId IS NULL
        BEGIN
            RAISERROR ('Department not found.', 16, 1);
            ROLLBACK TRANSACTION;
            RETURN;
        END

        UPDATE universityDepartments
        SET universityDepartmentName = @newDepartment
        WHERE universityDepartmentId = @universityDepartmentId;

        INSERT INTO departmentNameHistory (universityDepartmentId, oldName, newName,userId)
        VALUES (@universityDepartmentId, @oldDepartment, @newDepartment,@userId);

        DECLARE @recordId INT;
        SET @recordId = SCOPE_IDENTITY();

        SELECT @recordId AS RecordId;

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
