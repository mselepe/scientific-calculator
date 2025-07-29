
ALTER FUNCTION [dbo].[GetDepartmentsRequestedAmounts] (@year INT, @bursaryType VARCHAR(20))
RETURNS TABLE
AS
RETURN
(
    SELECT SUM(amount) departmentTotalRequestedAmount, universityDepartmentName, universityName
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
        WHERE rowRank = 1 AND [status] IN ('Awaiting student response', 'Approved','In Review', 'Awaiting executive approval', 'Awaiting finance approval'))
        rankedApplicationStatusEntries
        LEFT JOIN(
        SELECT applicationId
        FROM
        (SELECT applicationId,
                statusId,
                ROW_NUMBER() OVER (PARTITION BY applicationId ORDER BY createdAt DESC) AS rowRank
            FROM invoiceStatusHistory)
        AS rankedEntries
        JOIN invoiceStatus
        ON rankedEntries.statusId = invoiceStatus.statusId
        WHERE rowRank = 1 AND [status] IN ('Pending','Awaiting executive approval','Awaiting finance approval'))
        rankedInvoiceStatusEntries
        ON rankedApplicationStatusEntries.applicationId = rankedInvoiceStatusEntries.applicationId))
        AS latestApplicationInvoiceStatus
    ON universityApplications.applicationId = latestApplicationInvoiceStatus.applicationId 
	INNER JOIN bursaryTypes ON universityApplications.bursaryTypeId = bursaryTypes.bursaryTypeId
    WHERE yearOfFunding = @year AND (@bursaryType IS NULL OR bursaryTypes.bursaryType = @bursaryType)
    GROUP BY universityName, universityDepartmentName
);