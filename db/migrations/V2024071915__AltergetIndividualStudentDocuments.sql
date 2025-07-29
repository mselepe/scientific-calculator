/****** Object:  StoredProcedure [dbo].[getIndividualStudentDocuments]    Script Date: 2024/07/19 14:38:55 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
ALTER PROCEDURE [dbo].[getIndividualStudentDocuments]
    @applicationguid varchar(250)
AS
BEGIN
    SET NOCOUNT ON;

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
    documentTypes ON latestDocumentStatus.documentTypeId = documentTypes.documentTypeId;

END;