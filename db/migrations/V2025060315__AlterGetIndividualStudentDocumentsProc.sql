
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
ALTER PROCEDURE [dbo].[getIndividualStudentDocuments]
    @applicationguid varchar(250),
	@year int,
	@userRole varchar(50)

AS
BEGIN
   SET NOCOUNT ON;

   DECLARE @applicationId INT;
   SELECT @applicationId = applicationId FROM universityApplications WHERE applicationGuid = @applicationguid;

    IF @applicationId IS NULL
        RETURN;

		IF @userRole NOT IN ('admin', 'student')
    	RETURN;


	SELECT 
		latestDocumentStatus.amount,
		latestDocumentStatus.documentBlobName,
		latestDocumentStatus.applicationId,
		latestDocumentStatus.documentUploadDate,
		invoiceOrPaymentFor.[for] AS expenseCategory,
		documentTypes.type AS documentType
	FROM (
		SELECT 
		DISTINCT(adminDocuments.documentBlobName),
			adminDocuments.amount, 
			adminDocuments.documentTypeId,
			adminDocuments.applicationId,
			adminDocuments.expenseCategoryId AS expenseCategory,
			MAX(adminDocuments.createdAt) AS documentUploadDate
		FROM 
			adminDocuments 
		WHERE 
            adminDocuments.applicationId = @applicationId
            AND adminDocuments.isDeleted = 0
		GROUP BY 
			adminDocuments.amount,
			adminDocuments.documentBlobName,
			adminDocuments.adminDocumentId,
			adminDocuments.documentTypeId,
			adminDocuments.expenseCategoryId,
			adminDocuments.applicationId
	) AS latestDocumentStatus
	INNER JOIN 
		universityApplications ON latestDocumentStatus.applicationId = universityApplications.applicationId
	INNER JOIN 
		students ON universityApplications.studentId = students.studentId
	INNER JOIN 
		invoiceOrPaymentFor ON latestDocumentStatus.expenseCategory = invoiceOrPaymentFor.InvoicePaymentForId
	INNER JOIN 
		documentTypes ON latestDocumentStatus.documentTypeId = documentTypes.documentTypeId
	
	SELECT academicTranscriptsHistory.docBlobName AS academicTranscript,
		studentApplications.applicationId,
		MAX(universityApplications.dateOfApplication) AS uploadDate FROM studentApplications
		INNER JOIN universityApplications
		ON universityApplications.applicationId = studentApplications.applicationId
		INNER JOIN academicTranscriptsHistory 
		ON academicTranscriptsHistory.studentApplicationId = studentApplications.studentApplicationId
		
				
		WHERE studentApplications.applicationId = (SELECT applicationId
				FROM universityApplications 
				WHERE applicationGuid = @applicationGuid)
		AND YEAR(universityApplications.dateOfApplication) = @year
		GROUP BY studentApplications.applicationId,
				academicTranscriptsHistory.docBlobName
END;

