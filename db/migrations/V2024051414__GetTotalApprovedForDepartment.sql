IF EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[GetTotalApprovedAmountForDepartments]') AND type in (N'P', N'PC'))
DROP PROCEDURE [dbo].[GetTotalApprovedAmountForDepartments]
GO

CREATE PROCEDURE [dbo].[GetTotalApprovedAmountForDepartments]
    @universityName NVARCHAR(100)  
AS
BEGIN
    SET NOCOUNT ON;

    SELECT SUM(ua.amount) AS total_requested_amount, ud.universityDepartmentName
    FROM universityApplications ua
    INNER JOIN (
        SELECT applicationId, MAX(applicationStatusHistory.createdAt) AS latestStatusDate
        FROM applicationStatusHistory
        GROUP BY applicationId
    ) AS latestStatus ON ua.applicationId = latestStatus.applicationId
    INNER JOIN applicationStatusHistory ash ON ua.applicationId = ash.applicationId AND ash.createdAt= latestStatus.latestStatusDate
    INNER JOIN applicationStatus ast ON ash.statusId = ast.statusId
    INNER JOIN universityDepartments AS ud ON ua.universityDepartmentId = ud.universityDepartmentId
    INNER JOIN universities AS university ON ud.universityId = university.universityId
    WHERE (ast.[status] = 'Approved') AND university.universityName = @universityName
    AND ua.yearOfFunding = YEAR(GETDATE())
    GROUP BY ud.universityDepartmentName

END;
GO