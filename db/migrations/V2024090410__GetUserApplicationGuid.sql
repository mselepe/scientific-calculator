IF EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[GetStudentApplicationGuid]') AND type in (N'P', N'PC'))
DROP PROCEDURE [dbo].[GetStudentApplicationGuid]
GO

CREATE PROCEDURE GetStudentApplicationGuid
    @department VARCHAR(256),
	@faculty VARCHAR(256),
	@emailAddress VARCHAR(256),
	@name VARCHAR(716),
	@surname VARCHAR(716),
	@university VARCHAR(716)
AS
BEGIN
    SET NOCOUNT ON;
    BEGIN TRY
		SELECT applicationGuid, MAX(dateOfApplication) AS applicationDate
		FROM universityApplications
		INNER JOIN students
		ON students.studentId = universityApplications.studentId
		WHERE (
			universityApplications.universityDepartmentId = (SELECT universityDepartmentId 
			FROM universityDepartments WHERE universityDepartmentName = @department
			AND universityDepartments.universityId = (
				SELECT universityId FROM universities
				WHERE universities.universityName = @university)
			AND universityDepartments.facultyId = (
				SELECT facultyId FROM faculties
				WHERE faculties.facultyName = @faculty)
			)
			AND
			students.[name] = @name
			AND
			students.surname = @surname
			AND
			students.email = @emailAddress
		)
		GROUP BY applicationGuid
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

exec GetStudentApplicationGuid 'Computer Science','Science','xovij21147@biscoine.com','Elliot','Ahmed','University of the Witwatersrand'
