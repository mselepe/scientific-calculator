ALTER FUNCTION [dbo].[GetDepartmentsRequestedAmounts] (
    @year INT,
    @bursaryType VARCHAR(20)
)
RETURNS TABLE
AS
RETURN
(
    SELECT
        SUM(amount) AS departmentTotalRequestedAmount,
        universityDepartmentName,
        universityName
    FROM universityApplications
    JOIN universityDepartments
        ON universityApplications.universityDepartmentId = universityDepartments.universityDepartmentId
    JOIN universities
        ON universityDepartments.universityId = universities.universityId
    JOIN (
        SELECT applicationId
        FROM (
            SELECT
                applicationId,
                statusId,
                ROW_NUMBER() OVER (PARTITION BY applicationId ORDER BY createdAt DESC) AS rowRank
            FROM applicationStatusHistory
        ) rankedEntries
        JOIN applicationStatus
            ON rankedEntries.statusId = applicationStatus.statusId
        WHERE rowRank = 1
            AND [status] IN ('Awaiting student response', 'In Review', 'Awaiting executive approval', 'Awaiting finance approval', 'Awaiting fund distribution', 'Contract')
    ) rankedApplicationStatusEntries
        ON universityApplications.applicationId = rankedApplicationStatusEntries.applicationId
    JOIN bursaryTypes
        ON universityApplications.bursaryTypeId = bursaryTypes.bursaryTypeId
    WHERE
        yearOfFunding = @year
        AND (@bursaryType IS NULL OR bursaryTypes.bursaryType = @bursaryType)
    GROUP BY
        universityName,
        universityDepartmentName
);
