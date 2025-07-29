/****** Object:  StoredProcedure [dbo].[UpdateApplication]    Script Date: 2024/07/17 14:25:44 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
ALTER  PROCEDURE [dbo].[UpdateApplication]
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
		    INSERT INTO applicationStatusHistory (userId,applicationId, statusId, createdAt)
			VALUES (@userId,@applicationId, @statusId, GETDATE());

		DECLARE @newUpdate INT
		SET @newUpdate = SCOPE_IDENTITY();

		IF @newUpdate IS NOT NULL
			UPDATE universityApplications 
            SET dateOfApplication = GETDATE()
            WHERE applicationId = @applicationId;
           
		SELECT @applicationId as applicationId, applicationGuid FROM universityApplications WHERE applicationId=@applicationId;

        COMMIT TRANSACTION;
    END TRY
    BEGIN CATCH
        IF @@TRANCOUNT > 0
            ROLLBACK TRANSACTION;

        THROW;
    END CATCH;
END