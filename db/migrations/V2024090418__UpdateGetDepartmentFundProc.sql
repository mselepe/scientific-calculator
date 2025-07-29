/****** Object:  StoredProcedure [dbo].[GetDepartmentFund]    Script Date: 2024/09/03 14:54:04 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
ALTER PROCEDURE [dbo].[GetDepartmentFund]
    @university NVARCHAR(255),
    @faculty NVARCHAR(255),
    @department NVARCHAR(255),
    @year INT = NULL
AS
BEGIN
    SET NOCOUNT ON;

    DECLARE @universityDepartmentId INT;

    -- Retrieve universityDepartmentId
    SELECT @universityDepartmentId = universityDepartments.universityDepartmentId 
    FROM universityDepartments
    INNER JOIN faculties ON faculties.facultyId = universityDepartments.facultyId
    INNER JOIN universities ON universities.universityId = universityDepartments.universityId
    WHERE universities.universityName = @university
    AND universityDepartments.universityDepartmentName = @department;
    WITH FundData AS (
        SELECT 
            -- minPerStudent and maxPerStudent from maxAllocationPerDepartment table
            (SELECT MIN(minAmount) 
             FROM maxAllocationPerDepartment 
             WHERE universityDepartmentId = @universityDepartmentId) AS minPerStudent,
            (SELECT MAX(maxAmount) 
             FROM maxAllocationPerDepartment 
             WHERE universityDepartmentId = @universityDepartmentId) AS maxPerStudent,
            
            -- Total requested amount
            (SELECT SUM(ua.amount) 
             FROM universityApplications ua
             INNER JOIN (
                 SELECT applicationId, MAX(applicationStatusHistory.createdAt) AS latestStatusDate
                 FROM applicationStatusHistory
                 GROUP BY applicationId
             ) AS latestStatus ON ua.applicationId = latestStatus.applicationId
             INNER JOIN applicationStatusHistory ash ON ua.applicationId = ash.applicationId AND ash.createdAt = latestStatus.latestStatusDate
             INNER JOIN applicationStatus ast ON ash.statusId = ast.statusId
             WHERE NOT ((ast.[status] = 'Rejected') OR (ast.[status] = 'Approved')) 
             AND ua.universityDepartmentId = @universityDepartmentId
             AND (@year IS NULL OR ua.yearOfFunding = @year)) AS totalRequestedAmount,
            
            -- Total allocation amount
            (SELECT SUM(a.amount) 
             FROM allocations AS a
             WHERE a.universityDepartmentId = @universityDepartmentId
             AND (@year IS NULL OR a.[yearOfFunding] = @year)) AS totalAllocationAmount,

            -- Total approved amount
            (SELECT SUM(ua.amount) 
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
             AND (@year IS NULL OR ua.yearOfFunding = @year)) AS totalApprovedAmount
    )
    SELECT
        minPerStudent,
        maxPerStudent,
        totalRequestedAmount,
        totalAllocationAmount,
        totalApprovedAmount,
        -- Calculate available funding amount
        (totalAllocationAmount - (totalApprovedAmount + totalRequestedAmount)) AS availableFundingAmount
    FROM FundData;
END;
