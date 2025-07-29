/****** Object:  StoredProcedure [dbo].[getIndividualStudentDocuments]    Script Date: 2024/07/19 14:38:55 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
ALTER PROCEDURE [dbo].[getIndividualStudentDocuments]
    @applicationguid varchar(250),
	@year INT
AS
BEGIN
   SET NOCOUNT ON;

   IF @year = YEAR(GETDATE())
	BEGIN
	SELECT 
		latestDocumentStatus.amount,
		latestDocumentStatus.documentBlobName,
		latestDocumentStatus.applicationId,
		latestDocumentStatus.documentUploadDate,
		invoiceOrPaymentFor.[for] AS expenseCategory,
		documentTypes.type AS documentType
	FROM (
		SELECT 
			adminDocuments.amount, 
			adminDocuments.documentBlobName,
			adminDocuments.documentTypeId,
			invoiceStatusHistory.applicationId,
			adminDocuments.expenseCategoryId AS expenseCategory,
			MAX(invoiceStatusHistory.createdAt) AS documentUploadDate
		FROM 
			invoiceStatusHistory
		INNER JOIN 
			adminDocuments ON invoiceStatusHistory.applicationId = adminDocuments.applicationId
		WHERE 
			invoiceStatusHistory.applicationId = (
				SELECT applicationId 
				FROM universityApplications 
				WHERE applicationGuid = @applicationguid
			)
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
	WHERE YEAR(latestDocumentStatus.documentUploadDate) = CASE WHEN @year IS NOT NULL THEN @year ELSE YEAR(GETDATE()) END
	END
	ELSE
	BEGIN
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
	END
END;