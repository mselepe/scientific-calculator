SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
ALTER   PROCEDURE [dbo].[renewApplication]
(
    @amount MONEY,
	@applicationGuid VARCHAR(256),
	@userId VARCHAR(256),
	@yearOfStudy nchar(10)
)
AS
BEGIN
    SET NOCOUNT ON;

	DECLARE @applicationId INT;
	DECLARE @prevApplicationId INT;
	DECLARE @contractDocumentId INT;
	DECLARE @latestAcademicTranscipt VARCHAR(255);

    BEGIN TRY
		BEGIN TRANSACTION;

		SET @applicationId = (SELECT applicationId FROM universityApplications WHERE applicationGuid=@applicationGuid)
		SET @prevApplicationId = @applicationId

	  INSERT INTO universityApplications(studentId
      ,universityDepartmentId
      ,averageGrade
      ,degreeName
      ,dateOfApplication
      ,amount
      ,yearOfFunding
      ,motivation
      ,degreeDuration
      ,bursaryTypeId)
	  VALUES(
	  (SELECT studentId FROM universityApplications WHERE applicationId = @applicationId),

	  (SELECT universityDepartmentId FROM universityApplications WHERE applicationId = @applicationId),

	  (COALESCE((SELECT top 1 semesterGradeAverage FROM academicTranscriptsHistory ath
	  INNER JOIN studentApplications sa ON sa.studentApplicationId = ath.studentApplicationId
	  WHERE sa.applicationId = @applicationId),
	  (SELECT [averageGrade] FROM universityApplications WHERE applicationId = @applicationId)
	  )),

	   (SELECT [degreeName] FROM universityApplications WHERE applicationId = @applicationId),

	   GETDATE(),
	   @amount,

	   (SELECT yearOfFunding+1 FROM universityApplications WHERE applicationId = @applicationId),
	   
	   (SELECT motivation FROM universityApplications WHERE applicationId = @applicationId),

	   (SELECT degreeDuration FROM universityApplications WHERE applicationId = @applicationId),

	   (SELECT bursaryTypeId FROM universityApplications WHERE applicationId = @applicationId)

	  );

	  SET @applicationId = SCOPE_IDENTITY(); 

	  INSERT INTO applicationStatusHistory(userId,applicationId,statusId)
	  VALUES (@userId,@applicationId,(SELECT statusId FROM applicationStatus WHERE [status] = 'Pending renewal'))

	  SET @latestAcademicTranscipt =(SELECT docBlobName FROM (
		SELECT
		docBlobName,
        createdAt,
		universitySemesterId,
		studentApplicationId,
        ROW_NUMBER() OVER(PARTITION BY studentApplicationId ORDER BY createdAt DESC, universitySemesterId DESC) AS rn
        FROM
        academicTranscriptsHistory
       ) t
       WHERE t.rn = 1 AND  t.studentApplicationId = 
	   (SELECT top 1 studentApplicationId from studentApplications where applicationId = @prevApplicationId )
	   )
	
	   INSERT INTO studentApplications(yearOfStudy,applicationId,academicTranscriptBlobName,questionaireId, matricCertificateBlobName, financialStatementBlobName, citizenShip,termsAndConditions,privacyPolicy,applicationAcceptanceConfirmation,confirmHonors)
	   VALUES(
	   @yearOfStudy,@applicationId,
	   (COALESCE(@latestAcademicTranscipt,
	  (SELECT academicTranscriptBlobName FROM studentApplications WHERE applicationId = @prevApplicationId)
	  )),
	   (SELECT questionaireId FROM studentApplications WHERE applicationId = @prevApplicationId),
	   (SELECT matricCertificateBlobName FROM studentApplications WHERE applicationId = @prevApplicationId),
	   (SELECT financialStatementBlobName FROM studentApplications WHERE applicationId = @prevApplicationId),
	   (SELECT citizenShip FROM studentApplications WHERE applicationId = @prevApplicationId),
	   (SELECT termsAndConditions FROM studentApplications WHERE applicationId = @prevApplicationId),
	   (SELECT privacyPolicy FROM studentApplications WHERE applicationId = @prevApplicationId),
	   (SELECT applicationAcceptanceConfirmation FROM studentApplications WHERE applicationId = @prevApplicationId),
	   (SELECT confirmHonors FROM studentApplications WHERE applicationId = @prevApplicationId)
	   )

	   INSERT INTO adminDocuments(documentBlobName, amount, applicationId, documentTypeId, expenseCategoryId, isDeleted)
		SELECT 
		ad.documentBlobName,
		@amount,
		@applicationId,
		ad.documentTypeId,
		ad.expenseCategoryId,
		ad.isDeleted
		FROM adminDocuments ad
		WHERE ad.applicationId = @prevApplicationId
		AND ad.documentTypeId = 1
		AND ad.expenseCategoryId = 5
		AND ad.isDeleted = 0;

	   SELECT @applicationId as applicationId, applicationGuid FROM universityApplications WHERE applicationId=@applicationId; 

        COMMIT TRANSACTION;
    END TRY
    BEGIN CATCH
        IF @@TRANCOUNT > 0
            ROLLBACK TRANSACTION;

        THROW;
    END CATCH;
END