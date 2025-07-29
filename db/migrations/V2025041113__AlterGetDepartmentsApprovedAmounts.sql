
ALTER FUNCTION [dbo].[GetDepartmentsApprovedAmounts] (@year INT, @bursaryType VARCHAR(20) = NULL)
RETURNS TABLE
AS
RETURN
(
    SELECT SUM(amount) departmentTotalApprovedAmount, universityDepartmentName, universityName
    FROM universityApplications
    INNER JOIN universityDepartments 
    ON universityApplications.universityDepartmentId = universityDepartments.universityDepartmentId
    INNER JOIN universities
    ON universityDepartments.universityId = universities.universityId
    INNER JOIN bursaryTypes ON bursaryTypes.bursaryTypeId = universityApplications.bursaryTypeId
    INNER JOIN(
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
    WHERE yearOfFunding = @year AND (@bursaryType IS NULL OR bursaryTypes.bursaryType = @bursaryType)
    GROUP BY universityName, universityDepartmentName
);