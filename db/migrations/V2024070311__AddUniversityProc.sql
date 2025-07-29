IF EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[AddUniversity]') AND type in (N'P', N'PC'))
DROP PROCEDURE [dbo].[AddUniversity]
GO

CREATE PROCEDURE [dbo].[AddUniversity]
    @universityName NVARCHAR(252),
    @faculty NVARCHAR(252),
    @department NVARCHAR(252)
AS
BEGIN
    SET NOCOUNT ON;
	DECLARE @universityId INT;
	DECLARE @facultyId INT;
	DECLARE @departmentId INT;

	INSERT INTO universities(universityName,universityStatusId)
	VALUES(@universityName,(SELECT universityStatus.status FROM universityStatus WHERE universityStatus.status='Inactive'));

	SET @universityId= SCOPE_IDENTITY();

	INSERT INTO faculties(facultyName)
	VALUES(@faculty);

	SET @faculty = SCOPE_IDENTITY();

	INSERT INTO universityDepartments(universityDepartmentId,facultyId,universityDepartmentName)
	VALUES (@universityId,@faculty,@department);

END;
GO


