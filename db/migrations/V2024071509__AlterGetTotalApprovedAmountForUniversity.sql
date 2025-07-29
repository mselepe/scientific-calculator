SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

ALTER   PROCEDURE [dbo].[GetTotalApprovedAmountForUniversity]
    @universityName NVARCHAR(100),
	@year INT
AS
BEGIN
    SET NOCOUNT ON;

    DECLARE @currentYear INT;
    SET @currentYear = DATEPART(yyyy, GETDATE())

    SELECT SUM(ua.amount) AS total_approved_amount
    FROM universityApplications ua
    INNER JOIN (
        SELECT applicationId, MAX(applicationStatusHistory.createdAt) AS latestStatusDate
        FROM applicationStatusHistory
        GROUP BY applicationId
    ) AS latestStatus ON ua.applicationId = latestStatus.applicationId
    INNER JOIN applicationStatusHistory ash ON ua.applicationId = ash.applicationId AND ash.createdAt = latestStatus.latestStatusDate
    INNER JOIN applicationStatus ast ON ash.statusId = ast.statusId
    INNER JOIN universityDepartments AS ud ON ua.universityDepartmentId = ud.universityDepartmentId
    INNER JOIN universities AS university ON ud.universityId = university.universityId
    WHERE ast.[status] = 'Approved'
    AND university.universityName = @universityName
    AND ua.yearOfFunding = @year;

END;
