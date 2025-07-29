IF EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[GetTotalRequestedAmountForUniversity]') AND type in (N'P', N'PC'))
DROP PROCEDURE [dbo].[GetTotalRequestedAmountForUniversity]
GO

CREATE PROCEDURE [dbo].[GetTotalRequestedAmountForUniversity]
    @universityName NVARCHAR(100)  
AS
BEGIN
    SET NOCOUNT ON;
    
    DECLARE @currentYear INT;
    SET @currentYear = DATEPART(yyyy, GETDATE())

    SELECT SUM(ua.amount) AS total_requested_amount
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
    WHERE (ast.[status] = 'Pending' OR ast.[status] = 'In Review')
    AND university.universityName = @universityName
    AND ua.yearOfFunding = @currentYear;

END;
GO