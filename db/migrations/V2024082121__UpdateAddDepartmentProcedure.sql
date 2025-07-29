/****** Object:  StoredProcedure [dbo].[add_department_proc]    Script Date: 2024/08/21 20:02:00 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
ALTER PROCEDURE [dbo].[add_department_proc]
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

		INSERT INTO [dbo].[maxAllocationPerDepartment](userId, minAmount, maxAmount, universityDepartmentId) 
		VALUES ('BBD', 1000, 135000, @universityDepartmentId); -- This needs a new feature. Admin or Exec should be able to change how much each department can be allocated
			
    END

    -- Return the universityDepartmentId
    SELECT @universityDepartmentId;
END;