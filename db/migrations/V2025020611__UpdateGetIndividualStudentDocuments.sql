/****** Object:  StoredProcedure [dbo].[getIndividualStudentDocuments]    Script Date: 2025/02/06 22:01:49 ******/
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
			invoiceStatusHistory.applicationId,
			adminDocuments.expenseCategoryId AS expenseCategory,
			MAX(invoiceStatusHistory.createdAt) AS documentUploadDate
		FROM 
			invoiceStatusHistory
		INNER JOIN 
			adminDocuments ON invoiceStatusHistory.applicationId = adminDocuments.applicationId
		WHERE 
            invoiceStatusHistory.applicationId = @applicationId
            AND adminDocuments.isDeleted = 0
		GROUP BY 
			adminDocuments.amount,
			adminDocuments.documentBlobName,
			adminDocuments.adminDocumentId,
			adminDocuments.documentTypeId,
			invoiceStatusHistory.applicationId,
			adminDocuments.expenseCategoryId 
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