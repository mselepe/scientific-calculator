IF EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[GetDepartmentFund]') AND type in (N'P', N'PC'))
DROP PROCEDURE [dbo].[GetDepartmentFund]
GO

CREATE PROCEDURE [dbo].[GetDepartmentFund]
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

    SELECT 'Total Requested Amount' AS metric, SUM(ua.amount) AS amount
    FROM universityApplications ua
    INNER JOIN (
        SELECT applicationId, MAX(applicationStatusHistory.createdAt) AS latestStatusDate
        FROM applicationStatusHistory
        GROUP BY applicationId
    ) AS latestStatus ON ua.applicationId = latestStatus.applicationId
    INNER JOIN applicationStatusHistory ash ON ua.applicationId = ash.applicationId AND ash.createdAt = latestStatus.latestStatusDate
    INNER JOIN applicationStatus ast ON ash.statusId = ast.statusId
    WHERE NOT (ast.[status] = 'Pending')
    AND ua.universityDepartmentId = @universityDepartmentId
    AND (@year IS NULL OR ua.yearOfFunding = @year)

    UNION

    SELECT 'Total Allocation Amount' AS metric, SUM(a.amount) AS amount
    FROM allocations AS a
    WHERE a.universityDepartmentId = @universityDepartmentId
    AND (@year IS NULL OR a.[yearOfFunding] = @year)

    UNION

    SELECT 'Total Approved Amount' AS metric, SUM(total_approved_amount) AS amount
    FROM (
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
    ) AS approved_amounts;
END;
