/****** Object:  StoredProcedure [dbo].[updateDepartmentStatusProc]    Script Date: 2024/09/10 17:08:15 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
ALTER PROCEDURE [dbo].[updateDepartmentStatusProc]
    @university VARCHAR(256),
    @department VARCHAR(256),
	@faculty VARCHAR(256),
    @status VARCHAR(20),
	@userId VARCHAR(256)
AS
BEGIN
    SET NOCOUNT ON;
    
    BEGIN TRY
        BEGIN TRANSACTION;

        DECLARE @universityId INT;
        DECLARE @universityDepartmentId INT;
		DECLARE @departmentStatusId INT;
		DECLARE @facultyId INT;


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

		SET @facultyId = (
			SELECT facultyId
			FROM faculties
			WHERE facultyName=@faculty
		);

		IF @facultyId IS NULL
        BEGIN
            RAISERROR ('Faculty not found.', 16, 1);
            ROLLBACK TRANSACTION;
            RETURN;
        END


        SET @universityDepartmentId = (
            SELECT universityDepartmentId 
            FROM universityDepartments 
            WHERE universityId = @universityId 
              AND universityDepartmentName = @department
			  AND facultyId= @facultyId
        );

        IF @universityDepartmentId IS NULL
        BEGIN
            RAISERROR ('Department not found.', 16, 1);
            ROLLBACK TRANSACTION;
            RETURN;
        END

		SET @departmentStatusId= (SELECT departmentStatus.departmentStatusId FROM departmentStatus WHERE departmentStatus.departmentStatus=@status);

        UPDATE universityDepartments
        SET departmentStatusId = @departmentStatusId
        WHERE universityDepartmentId = @universityDepartmentId;

        INSERT INTO departmentStatusHistory (departmentStatusId, universityDepartmentId, userId)
        VALUES (@departmentStatusId, @universityDepartmentId,@userId);

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