IF EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[ApplicationAction]') AND type in (N'P', N'PC'))
DROP PROCEDURE [dbo].[ApplicationAction]
GO

CREATE PROCEDURE [dbo].[ApplicationAction]
(
    @applicationId INT,
    @name VARCHAR(747) = NULL,
    @surname VARCHAR(747) = NULL,
    @title VARCHAR(276) = NULL,
    @email VARCHAR(345) = NULL,
    @idDocumentName VARCHAR(256) = NULL,
    @race VARCHAR(10) = NULL,
    @gender VARCHAR(64) = NULL,
    @degreeName VARCHAR(256) = NULL,
	@university VARCHAR(256) =NULL,
	@faculty VARCHAR(256) =NULL,
	@department VARCHAR(256) = NULL,
    @yearOfFunding INT = NULL,
    @amount MONEY = NULL,
    @averageGrade DECIMAL(5, 2) = NULL,
	@motivation NTEXT,
    @status VARCHAR(10) = NULL,
    @userId VARCHAR(256),
    @userRole VARCHAR(10)
)
AS
BEGIN
    SET NOCOUNT ON;
    DECLARE @applicationExists BIT;
    DECLARE @UniversityActive BIT;
	DECLARE @universityDepartmentId INT;
	DECLARE @raceId INT;
	DECLARE @genderId INT;
	DECLARE @statusId INT;
    DECLARE @bursaryTypeId INT;

	-- Get correct busary type id
	SELECT @bursaryTypeId = CASE @userRole 
	WHEN 'HOD' 
	THEN (SELECT bursaryTypeId FROM bursaryTypes WHERE bursaryType = 'Ukukhula') 
	ELSE 
	(SELECT bursaryTypeId FROM bursaryTypes WHERE bursaryType = 'BBD') END;

    -- Check if university is active
    SELECT @UniversityActive = CASE WHEN EXISTS (SELECT 1 FROM universities WHERE universityName = @university AND universityStatusId = (SELECT universityStatusId FROM universityStatus WHERE status = 'Inactive')) THEN 1 ELSE 0 END;

    -- Check if application exists
    SELECT @applicationExists = CASE WHEN EXISTS (SELECT 1 FROM universityApplications WHERE applicationId = @applicationId) THEN 1 ELSE 0 END;
	SET @universityDepartmentId = (SELECT universityDepartments.universityDepartmentId FROM universityDepartments
		INNER JOIN faculties ON faculties.facultyId = universityDepartments.facultyId
		INNER JOIN universities ON universities.universityId = universityDepartments.universityId
		WHERE universities.universityName = @university AND faculties.facultyName= @faculty 
		AND universityDepartments.universityDepartmentName = @department );
	SET @raceId = (SELECT raceId FROM races WHERE race=@race);
	SET @genderId = (SELECT genderId FROM genders WHERE gender=@gender);
	SET @statusId = (SELECT statusId FROM applicationStatus WHERE status=@status);

    BEGIN TRY
        IF @UniversityActive = 1
        BEGIN
           UPDATE universities SET universityStatusId = (SELECT universityStatusId FROM universityStatus WHERE status = 'Active') WHERE universityName = @university;
        END
        IF @applicationExists = 1
        BEGIN
            -- Call update procedure
            EXEC [dbo].[UpdateApplication] @applicationId, @name, @surname, @title, @email,
                @idDocumentName, @raceId, @genderId, @degreeName, @yearOfFunding,
                @amount, @averageGrade, @statusId, @universityDepartmentId, @userId;
        END
        ELSE
        BEGIN
            -- Call insertion procedure
            EXEC [dbo].[InsertApplication] @name, @surname, @title, @email,
                @idDocumentName, @raceId, @genderId, @degreeName, @yearOfFunding,
                @amount, @averageGrade,@motivation ,@statusId, @universityDepartmentId,@userId, @bursaryTypeId;
        END
    END TRY
    BEGIN CATCH
        -- Handle the error
        DECLARE @ErrorMessage NVARCHAR(4000);
        DECLARE @ErrorSeverity INT;
        DECLARE @ErrorState INT;

        SELECT
            @ErrorMessage = ERROR_MESSAGE(),
            @ErrorSeverity = ERROR_SEVERITY(),
            @ErrorState = ERROR_STATE();

    END CATCH;
END