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

    SELECT @universityDepartmentId = universityDepartments.universityDepartmentId 
    FROM universityDepartments
    INNER JOIN faculties ON faculties.facultyId = universityDepartments.facultyId
    INNER JOIN universities ON universities.universityId = universityDepartments.universityId
    WHERE universities.universityName = @university
    AND universityDepartments.universityDepartmentName = @department;
    WITH FundData AS (
        SELECT 
            (SELECT MIN(minAmount) 
             FROM maxAllocationPerDepartment 
             WHERE universityDepartmentId = @universityDepartmentId) AS minPerStudent,
            (SELECT MAX(maxAmount) 
             FROM maxAllocationPerDepartment 
             WHERE universityDepartmentId = @universityDepartmentId) AS maxPerStudent,
            
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
            
            (SELECT SUM(a.amount) 
             FROM allocations AS a
             WHERE a.universityDepartmentId = @universityDepartmentId
             AND (@year IS NULL OR a.[yearOfFunding] = @year)) AS totalAllocationAmount,

            (SELECT SUM(ua.amount) 
             FROM universityApplications ua
             INNER JOIN (
                 SELECT applicationId, MAX(applicationStatusHistory.createdAt) AS latestStatusDate
                 FROM applicationStatusHistory
                 GROUP BY applicationId
             ) AS latestStatus ON ua.applicationId = latestStatus.applicationId
			 inner join (
				 SELECT applicationId, MAX(invoiceStatusHistory.createdAt) AS latestInvStatusDate
                 FROM invoiceStatusHistory
                 GROUP BY applicationId
			 ) AS latestInvStatus ON ua.applicationId = latestStatus.applicationId
			 inner join invoiceStatusHistory ish on ua.applicationId = ish.applicationId AND ish.createdAt = latestInvStatus.latestInvStatusDate
			 inner join invoiceStatus ist on ist.statusId = ish.statusId
             INNER JOIN applicationStatusHistory ash ON ua.applicationId = ash.applicationId AND ash.createdAt = latestStatus.latestStatusDate
             INNER JOIN applicationStatus ast ON ash.statusId = ast.statusId
             WHERE ast.[status] = 'Approved' and ist.[status] in ('Approved','In Review')
             AND ua.universityDepartmentId = @universityDepartmentId
             AND (@year IS NULL OR ua.yearOfFunding = @year)) AS totalApprovedAmount
    )
    SELECT
        minPerStudent,
        maxPerStudent,
        totalRequestedAmount,
        totalAllocationAmount,
        totalApprovedAmount,
        (totalAllocationAmount - (totalApprovedAmount + totalRequestedAmount)) AS availableFundingAmount
    FROM FundData;
END;

