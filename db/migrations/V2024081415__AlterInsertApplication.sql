/****** Object:  StoredProcedure [dbo].[InsertApplication]    Script Date: 2024/05/15 07:47:18 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
ALTER PROCEDURE [dbo].[InsertApplication]
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
    @motivation NTEXT,
    @statusId INT,
	@universityDepartmentId INT,
	@userId VARCHAR(256)
)
AS
BEGIN
    SET NOCOUNT ON;

    DECLARE @studentId INT;
	DECLARE @applicationId INT;
	DECLARE @invoiceId INT;

    BEGIN TRY
        BEGIN TRANSACTION;

        INSERT INTO students (name, surname, titleId, email, idDocumentName, raceId, genderId,contactNumber,streetAddress,suburb,city,postalcode,idNumber)

        VALUES (
            @name, 
            @surname, 
            (SELECT titleId FROM titles WHERE titles.title = @title), 
            @email, 
            @idDocumentName, 
            @raceId, 
            @genderId,'','','','','','');
		
        SET @studentId = SCOPE_IDENTITY();

        INSERT INTO universityApplications (studentId, universityDepartmentId, averageGrade ,degreeName, dateOfApplication, amount, yearOfFunding,motivation)
        VALUES (@studentId, @universityDepartmentId,@averageGrade ,@degreeId,GETDATE(), @amount,@yearOfFunding,@motivation);
	
        SET @applicationId = SCOPE_IDENTITY();

        INSERT INTO applicationStatusHistory (userId,applicationId, statusId, createdAt)
        VALUES (@userId,@applicationId, @statusId, GETDATE()); 

		
		SELECT @applicationId as applicationId, applicationGuid FROM universityApplications WHERE applicationId=@applicationId;

        COMMIT TRANSACTION;
    END TRY
    BEGIN CATCH
        IF @@TRANCOUNT > 0
            ROLLBACK TRANSACTION;

        THROW;
    END CATCH;
END