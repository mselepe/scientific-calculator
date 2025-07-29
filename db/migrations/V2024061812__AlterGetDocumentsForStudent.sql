ALTER PROCEDURE [dbo].[getIndividualStudentDocuments]
    @applicationId int
AS
BEGIN
    SET NOCOUNT ON;

    SELECT latestDocumentStatus.amount,
	latestDocumentStatus.documentBlobName,
	latestDocumentStatus.applicationId,
	latestDocumentStatus.documentUploadDate,
	(SELECT [type] FROM documentTypes WHERE latestDocumentStatus.documentTypeId = documentTypes.documentTypeId) AS documentType
    FROM (
        SELECT adminDocuments.amount, adminDocuments.documentBlobName AS documentBlobName,
        adminDocuments.documentTypeId,
        invoiceStatusHistory.applicationId,
        MAX(invoiceStatusHistory.createdAt) AS documentUploadDate

        FROM invoiceStatusHistory
        INNER JOIN adminDocuments ON invoiceStatusHistory.applicationId = adminDocuments.applicationId

        WHERE invoiceStatusHistory.applicationId = @applicationId

        GROUP BY adminDocuments.amount,
        adminDocuments.documentBlobName,
        adminDocuments.adminDocumentId,
        adminDocuments.documentTypeId,
        invoiceStatusHistory.applicationId

    ) AS latestDocumentStatus

    INNER JOIN universityApplications ON latestDocumentStatus.applicationId = universityApplications.applicationId
    INNER JOIN students ON universityApplications.studentId = students.studentId
END;
GO
