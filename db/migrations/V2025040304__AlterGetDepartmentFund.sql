SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
ALTER PROCEDURE [dbo].[GetDepartmentFund]
    @university NVARCHAR(255),
    @faculty NVARCHAR(255),
    @department NVARCHAR(255),
    @year INT = NULL,
    @role VARCHAR(20),
    @bursaryType VARCHAR(20)
AS
BEGIN
    SET NOCOUNT ON;

    DECLARE @universityDepartmentId INT;
    DECLARE @roleId INT;
    DECLARE @bursaryTypeId INT;

    -- Retrieve universityDepartmentId
    SELECT @universityDepartmentId = universityDepartments.universityDepartmentId 
    FROM universityDepartments
    INNER JOIN faculties ON faculties.facultyId = universityDepartments.facultyId
    INNER JOIN universities ON universities.universityId = universityDepartments.universityId
    WHERE universities.universityName = @university
    AND universityDepartments.universityDepartmentName = @department;

    SELECT @roleId = roleId FROM roles WHERE [role] = @role;
    SELECT @bursaryTypeId = bursaryTypeId FROM bursaryTypes WHERE bursaryType = @bursaryType;

    WITH MinAmountCTE AS (
        SELECT 
            minAmount,
            createdAt,
            ROW_NUMBER() OVER (PARTITION BY minAmount ORDER BY createdAt DESC) AS rn
        FROM maxStudentAllocationAmount msaa
        WHERE msaa.allocatedForRoleId = @roleId 
          AND msaa.bursaryTypeId = @bursaryTypeId
    ),
    MaxAmountCTE AS (
        SELECT 
            maxAmount,
            createdAt,
            ROW_NUMBER() OVER (PARTITION BY maxAmount ORDER BY createdAt DESC) AS rn
        FROM maxStudentAllocationAmount mapd
        WHERE mapd.allocatedForRoleId = @roleId 
          AND mapd.bursaryTypeId = @bursaryTypeId
    ),
    FundData AS (
        SELECT 
            MinAmountCTE.minAmount AS minPerStudent,
            MaxAmountCTE.maxAmount AS maxPerStudent,

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
             INNER JOIN (
                 SELECT applicationId, MAX(invoiceStatusHistory.createdAt) AS latestInvStatusDate
                 FROM invoiceStatusHistory
                 GROUP BY applicationId
             ) AS latestInvStatus ON ua.applicationId = latestStatus.applicationId
             INNER JOIN invoiceStatusHistory ish ON ua.applicationId = ish.applicationId AND ish.createdAt = latestInvStatus.latestInvStatusDate
             INNER JOIN invoiceStatus ist ON ist.statusId = ish.statusId
             WHERE ast.[status] = 'Approved' 
             AND ist.[status] IN ('Approved', 'In Review')
             AND ua.universityDepartmentId = @universityDepartmentId
             AND (@year IS NULL OR ua.yearOfFunding = @year)) AS totalApprovedAmount
        FROM MinAmountCTE
        INNER JOIN MaxAmountCTE ON MinAmountCTE.rn = 1 AND MaxAmountCTE.rn = 1
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

