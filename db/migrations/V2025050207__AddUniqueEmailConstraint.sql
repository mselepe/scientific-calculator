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
	@userId VARCHAR(256),
    @bursaryTypeId INT,
	@bursaryTier INT
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
            (SELECT titleId FROM titles WHERE titles.title = 'Other'), 
            @email, 
            @idDocumentName, 
            @raceId, 
            @genderId,'','','','','','');

        SET @studentId = SCOPE_IDENTITY();

		UPDATE students SET idNumber = @studentId
		WHERE studentId = @studentId;

        INSERT INTO universityApplications (studentId, universityDepartmentId, averageGrade ,degreeName, dateOfApplication, amount, yearOfFunding,motivation, bursaryTypeId)
        VALUES (@studentId, @universityDepartmentId,@averageGrade ,@degreeId,GETDATE(), @amount,@yearOfFunding,@motivation, @bursaryTypeId);

        SET @applicationId = SCOPE_IDENTITY();

        INSERT INTO applicationStatusHistory (userId,applicationId, statusId, createdAt)
        VALUES (@userId,@applicationId, @statusId, GETDATE()); 

		INSERT INTO applicationTiers(tierId,applicationId)
		VALUES((SELECT tierId FROM tiers WHERE tier = @bursaryTier), @applicationId)

		SELECT @applicationId as applicationId, applicationGuid FROM universityApplications WHERE applicationId=@applicationId;
        COMMIT TRANSACTION;
    END TRY
    BEGIN CATCH
        IF @@TRANCOUNT > 0
            ROLLBACK TRANSACTION;

        THROW;
    END CATCH;
END

UPDATE students SET idNumber=studentId
WHERE idNumber = '';

ALTER TABLE students  
ADD CONSTRAINT AK_students_email UNIQUE (email);

ALTER TABLE dbo.students
ADD CONSTRAINT AK_students_idNumber UNIQUE (idNumber);

ALTER TABLE invitedUsers  
ADD CONSTRAINT AK_invitedUsers_email UNIQUE (invitedEmail);