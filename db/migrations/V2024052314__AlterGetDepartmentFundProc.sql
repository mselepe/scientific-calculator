ALTER PROCEDURE [dbo].[GetDepartmentFund]
    @university NVARCHAR(255),
    @faculty NVARCHAR(255),
    @department NVARCHAR(255),
    @year INT = NULL
AS
BEGIN
    SET NOCOUNT ON;

    DECLARE @universityDepartmentId INT;

    SELECT @universityDepartmentId = universityDepartments.universityDepartmentId 
    FROM universityDepartments
    INNER JOIN faculties ON faculties.facultyId = universityDepartments.facultyId
    INNER JOIN universities ON universities.universityId = universityDepartments.universityId
    WHERE universities.universityName = @university
    AND faculties.facultyName = @faculty 
    AND universityDepartments.universityDepartmentName = @department;

 
    SELECT 
        minPerStudent AS minPerStudent,
        maxPerStudent AS maxPerStudent,
        -- Total requested amount
        (SELECT SUM(ua.amount) FROM universityApplications ua
         INNER JOIN (
             SELECT applicationId, MAX(applicationStatusHistory.createdAt) AS latestStatusDate
             FROM applicationStatusHistory
             GROUP BY applicationId
         ) AS latestStatus ON ua.applicationId = latestStatus.applicationId
         INNER JOIN applicationStatusHistory ash ON ua.applicationId = ash.applicationId AND ash.createdAt = latestStatus.latestStatusDate
         INNER JOIN applicationStatus ast ON ash.statusId = ast.statusId
         WHERE NOT ((ast.[status] = 'Pending') OR (ast.[status] = 'Rejected')) 
         AND ua.universityDepartmentId = @universityDepartmentId
         AND (@year IS NULL OR ua.yearOfFunding = @year)) AS totalRequestedAmount,
        -- Total allocation amount
        (SELECT SUM(a.amount) FROM allocations AS a
         WHERE a.universityDepartmentId = @universityDepartmentId
         AND (@year IS NULL OR a.[yearOfFunding] = @year)) AS totalAllocationAmount,
        -- Total approved amount
        (SELECT SUM(total_approved_amount) FROM (
            SELECT SUM(ua.amount) AS total_approved_amount
            FROM universityApplications ua
            INNER JOIN (
                SELECT applicationId, MAX(applicationStatusHistory.createdAt) AS latestStatusDate
                FROM applicationStatusHistory
                GROUP BY applicationId
            ) AS latestStatus ON ua.applicationId = latestStatus.applicationId
            INNER JOIN applicationStatusHistory ash ON ua.applicationId = ash.applicationId AND ash.createdAt = latestStatus.latestStatusDate
            INNER JOIN applicationStatus ast ON ash.statusId = ast.statusId
            WHERE ast.[status] = 'Approved'
            AND ua.universityDepartmentId = @universityDepartmentId
            AND (@year IS NULL OR ua.yearOfFunding = @year)
            GROUP BY ua.applicationId
        ) AS approved_amounts) AS totalApprovedAmount
    FROM (
        SELECT minAmount AS minPerStudent, MAX(maxAllocationPerDepartment.createdAt) AS LatestChange
        FROM maxAllocationPerDepartment 
        WHERE maxAllocationPerDepartment.universityDepartmentId = @universityDepartmentId
        GROUP BY minAmount
    ) AS minPerStudentData
    CROSS JOIN (
        SELECT maxAmount AS maxPerStudent, MAX(maxAllocationPerDepartment.createdAt) AS LatestChange
        FROM maxAllocationPerDepartment 
        WHERE maxAllocationPerDepartment.universityDepartmentId = @universityDepartmentId
        GROUP BY maxAmount
    ) AS maxPerStudentData;
END;
