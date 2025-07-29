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
    @degreeId INT,
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


        INSERT INTO students (name, surname, title, email, idDocumentName, raceId, genderId,contactNumber,streetAddress,suburb,city,postalcode,idNumber)

        VALUES (@name, @surname, @title, @email, @idDocumentName, @raceId, @genderId,'','','','','','');
		
        SET @studentId = SCOPE_IDENTITY();

        INSERT INTO universityApplications (studentId, universityDepartmentId, averageGrade ,degreeName, dateOfApplication, amount, yearOfFunding)
        VALUES (@studentId, @universityDepartmentId,@averageGrade ,@degreeId,GETDATE(), @amount,@yearOfFunding);
	
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