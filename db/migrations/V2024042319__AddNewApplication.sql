IF EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[InsertApplication]') AND type in (N'P', N'PC'))
DROP PROCEDURE [dbo].[InsertApplication]
GO

CREATE PROCEDURE [dbo].[InsertApplication]
(
    @name VARCHAR(747),
    @surname VARCHAR(747),
    @title VARCHAR(276),
    @email VARCHAR(345),
    @idDocumentName VARCHAR(256),
    @raceId INT,
    @genderId INT,
    @degreeName VARCHAR(256),
    @yearOfFunding INT,
    @amount MONEY,
    @averageGrade DECIMAL(5, 2),
    @statusId INT,
	@universityDepartmentId INT,
	@userId VARCHAR(256)
)
AS
BEGIN
    SET NOCOUNT ON;

    DECLARE @studentId INT;
	DECLARE @applicationId INT;

    BEGIN TRY
        BEGIN TRANSACTION;


        INSERT INTO students (name, surname, title, email, idDocumentName, raceId, genderId,contactNumber,streetAddress,suburb,city,postalCode,idNumber)
        VALUES (@name, @surname, @title, @email, @idDocumentName, @raceId, @genderId, '','','','','','');
		
        SET @studentId = SCOPE_IDENTITY();

        INSERT INTO universityApplications (studentId, universityDepartmentId, averageGrade ,degreeName, dateOfApplication, amount, yearOfFunding)
        VALUES (@studentId, @universityDepartmentId,@averageGrade ,@degreeName,GETDATE(), @amount,@yearOfFunding);
	
        SET @applicationId = SCOPE_IDENTITY();

        INSERT INTO applicationStatusHistory (userId,applicationId, statusId, createdAt)
        VALUES (@userId,@applicationId, @statusId, GETDATE()); 
		
		SELECT @applicationId as 'id'

        COMMIT TRANSACTION;
    END TRY
    BEGIN CATCH
        IF @@TRANCOUNT > 0
            ROLLBACK TRANSACTION;

        THROW;
    END CATCH;
END

IF EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[UpdateApplication]') AND type in (N'P', N'PC'))
DROP PROCEDURE [dbo].[UpdateApplication]
GO

CREATE  PROCEDURE [dbo].[UpdateApplication]
(
    @applicationId INT,
    @name VARCHAR(747) = NULL,
    @surname VARCHAR(747) = NULL,
    @title VARCHAR(276) = NULL,
    @email VARCHAR(345) = NULL,
    @idDocumentName VARCHAR(256) = NULL,
    @raceId INT = NULL,
    @genderId INT = NULL,
    @degreeName VARCHAR(345) = NULL,
    @yearOfFunding INT = NULL,
    @amount MONEY = NULL,
    @averageGrade DECIMAL(5, 2) = NULL,
    @statusId INT = NULL,
    @universityDepartmentId INT = NULL,
    @userId VARCHAR(256)
)
AS
BEGIN
    SET NOCOUNT ON;

    BEGIN TRY
        BEGIN TRANSACTION;
		
        IF @name IS NOT NULL
            UPDATE students 
            SET name = @name
            WHERE studentId = (SELECT studentId FROM universityApplications WHERE applicationId = @applicationId);

        IF @surname IS NOT NULL
            UPDATE students 
            SET surname = @surname
            WHERE studentId = (SELECT studentId FROM universityApplications WHERE applicationId = @applicationId);

        IF @title IS NOT NULL
            UPDATE students 
            SET title = @title
            WHERE studentId = (SELECT studentId FROM universityApplications WHERE applicationId = @applicationId);

        IF @email IS NOT NULL
            UPDATE students 
            SET email = @email
            WHERE studentId = (SELECT studentId FROM universityApplications WHERE applicationId = @applicationId);

        IF @idDocumentName IS NOT NULL
            UPDATE students 
            SET idDocumentName = @idDocumentName
            WHERE studentId = (SELECT studentId FROM universityApplications WHERE applicationId = @applicationId);

        IF @raceId IS NOT NULL
            UPDATE students 
            SET raceId = @raceId
            WHERE studentId = (SELECT studentId FROM universityApplications WHERE applicationId = @applicationId);

        IF @genderId IS NOT NULL
            UPDATE students 
            SET genderId = @genderId
            WHERE studentId = (SELECT studentId FROM universityApplications WHERE applicationId = @applicationId);

        IF @universityDepartmentId IS NOT NULL
            UPDATE universityApplications 
            SET universityDepartmentId = @universityDepartmentId
            WHERE applicationId = @applicationId;

        IF @averageGrade IS NOT NULL
            UPDATE universityApplications 
            SET averageGrade = @averageGrade
            WHERE applicationId = @applicationId;

        IF @degreeName IS NOT NULL
            UPDATE universityApplications 
            SET degreeName = @degreeName
            WHERE applicationId = @applicationId;

        IF @yearOfFunding IS NOT NULL
            UPDATE universityApplications 
            SET yearOfFunding = @yearOfFunding
            WHERE applicationId = @applicationId;

        IF @amount IS NOT NULL
            UPDATE universityApplications 
            SET amount = @amount
            WHERE applicationId = @applicationId;

        IF @statusId IS NOT NULL
			UPDATE applicationStatusHistory
			SET statusId=@statusId
			WHERE applicationId = @applicationId;
           
		SELECT @applicationId as 'id'
        COMMIT TRANSACTION;
    END TRY
    BEGIN CATCH
        IF @@TRANCOUNT > 0
            ROLLBACK TRANSACTION;

        THROW;
    END CATCH;
END

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
    @status VARCHAR(10) = NULL,
    @userId VARCHAR(256)
)
AS
BEGIN
    SET NOCOUNT ON;
    DECLARE @applicationExists BIT;
	DECLARE @universityDepartmentId INT;
	DECLARE @raceId INT;
	DECLARE @genderId INT;
	DECLARE @statusId INT;

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
                @amount, @averageGrade, @statusId, @universityDepartmentId, @userId;
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
