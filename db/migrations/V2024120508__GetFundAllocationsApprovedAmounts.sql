IF OBJECT_ID (N'GetDepartmentsApprovedAmounts', N'IF') IS NOT NULL
    DROP FUNCTION GetDepartmentsApprovedAmounts;
GO
CREATE FUNCTION GetDepartmentsApprovedAmounts (@year INT)
RETURNS TABLE
AS
RETURN
(
    SELECT SUM(amount) departmentTotalApprovedAmount, universityDepartmentName, universityName
    FROM universityApplications
    JOIN universityDepartments 
    ON universityApplications.universityDepartmentId = universityDepartments.universityDepartmentId
    JOIN universities
    ON universityDepartments.universityId = universities.universityId
    
    JOIN(
        SELECT rankedApplicationStatusEntries.applicationId
        FROM(
        (SELECT applicationId
        FROM 
        (SELECT applicationId,
                statusId,
                ROW_NUMBER() OVER (PARTITION BY applicationId ORDER BY createdAt DESC) AS rowRank
            FROM applicationStatusHistory)
        rankedEntries
        JOIN applicationStatus
        ON rankedEntries.statusId = applicationStatus.statusId
        WHERE rowRank = 1 AND [status] = 'Approved')
        rankedApplicationStatusEntries
        JOIN(
        SELECT applicationId
        FROM
        (SELECT applicationId,
                statusId,
                ROW_NUMBER() OVER (PARTITION BY applicationId ORDER BY createdAt DESC) AS rowRank
            FROM invoiceStatusHistory)
        AS rankedEntries
        JOIN invoiceStatus
        ON rankedEntries.statusId = invoiceStatus.statusId
        WHERE rowRank = 1 AND [status] IN ('In Review','Approved'))
        rankedInvoiceStatusEntries
        ON rankedApplicationStatusEntries.applicationId = rankedInvoiceStatusEntries.applicationId))
        AS latestApplicationInvoiceStatus
    ON universityApplications.applicationId = latestApplicationInvoiceStatus.applicationId 
    WHERE yearOfFunding = @year
    GROUP BY universityName, universityDepartmentName
);