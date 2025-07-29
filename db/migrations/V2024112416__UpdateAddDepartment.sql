/****** Object:  StoredProcedure [dbo].[add_department_proc]    Script Date: 2024/09/04 08:42:57 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
ALTER PROCEDURE [dbo].[add_department_proc]
    @universityName NVARCHAR(256),
    @facultyName NVARCHAR(256),
    @departmentName NVARCHAR(256),
    @userId VARCHAR(256),
    @newFaculty VARCHAR(256)
AS
BEGIN
    SET NOCOUNT ON;

    BEGIN TRY
	  BEGIN TRANSACTION;
        DECLARE @universityId INT;
        DECLARE @facultyId INT;
        DECLARE @universityDepartmentId INT;
        DECLARE @departmentStatusId INT;

        SET @departmentStatusId = (SELECT departmentStatusId 
                                   FROM departmentStatus 
                                   WHERE departmentStatus = 'Active');

        SELECT @universityId = universityId
        FROM universities
        WHERE universityName = @universityName;

        SELECT @facultyId = facultyId
        FROM faculties
        WHERE facultyName = @facultyName;

        SELECT @universityDepartmentId = universityDepartmentId
        FROM universityDepartments
        WHERE universityId = @universityId
          AND facultyId = @facultyId
          AND universityDepartmentName = @departmentName;

        IF @newFaculty IS NOT NULL AND @facultyName = 'Add faculty'
        BEGIN
            INSERT INTO faculties(facultyName)
            VALUES(@newFaculty)

            SET @facultyId = SCOPE_IDENTITY()
        END

        IF @universityDepartmentId IS NULL
        BEGIN
            INSERT INTO universityDepartments (universityId, facultyId, universityDepartmentName)
            VALUES (@universityId, @facultyId, @departmentName);

            SET @universityDepartmentId = SCOPE_IDENTITY();

            INSERT INTO [dbo].[maxAllocationPerDepartment] (userId, minAmount, maxAmount, universityDepartmentId)
            VALUES ('BBD', 1000, 135000, @universityDepartmentId);
        END
        ELSE
        BEGIN 
            UPDATE universityDepartments
            SET departmentStatusId = @departmentStatusId
            WHERE universityDepartmentId = @universityDepartmentId;
        END

        INSERT INTO departmentStatusHistory (departmentStatusId, universityDepartmentId, userId)
        VALUES (@departmentStatusId, @universityDepartmentId, @userId);

        COMMIT TRANSACTION;

        SELECT @universityDepartmentId;
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
