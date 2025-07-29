IF EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[add_department_proc]') AND type in (N'P', N'PC'))
DROP PROCEDURE [dbo].[add_department_proc]
GO
CREATE PROCEDURE [dbo].[add_department_proc]
    @universityName NVARCHAR(256),
    @facultyName NVARCHAR(256),
    @departmentName NVARCHAR(256)
AS
BEGIN
    SET NOCOUNT ON;

    DECLARE @universityId INT;
    DECLARE @facultyId INT;
    DECLARE @universityDepartmentId INT;

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

    IF @universityDepartmentId IS NULL
    BEGIN
        INSERT INTO universityDepartments (universityId, facultyId, universityDepartmentName)
        VALUES (@universityId, @facultyId, @departmentName);

        SET @universityDepartmentId = SCOPE_IDENTITY();
    END

    -- Return the universityDepartmentId
    SELECT @universityDepartmentId;
END;
