ALTER PROCEDURE [dbo].[GetTotalApprovedAmountForDepartments]
    @universityName NVARCHAR(100),
	@bursaryType VARCHAR(20) = 'Ukukhula'
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
	INNER JOIN bursaryTypes AS bt ON bt.bursaryType = ua.bursaryTypeId
    WHERE (ast.[status] = 'Approved') AND university.universityName = @universityName
	AND bt.bursaryType = @bursaryType
    AND ua.yearOfFunding = YEAR(GETDATE())
    GROUP BY ud.universityDepartmentName

END;