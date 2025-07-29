SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
ALTER PROCEDURE [dbo].[GetTotalRequestedAmountForUniversity]
    @universityName NVARCHAR(100),
    @year INT
AS
BEGIN
    SET NOCOUNT ON;

    DECLARE @currentYear INT;
    SET @currentYear = DATEPART(yyyy, GETDATE());

    SELECT 
        SUM(ua.amount) AS total_requested_amount
    FROM universityApplications ua
    INNER JOIN (
        SELECT applicationId, MAX(createdAt) AS latestStatusDate
        FROM applicationStatusHistory
        GROUP BY applicationId
    ) AS latestStatus ON ua.applicationId = latestStatus.applicationId
    INNER JOIN applicationStatusHistory ash ON ua.applicationId = ash.applicationId 
        AND ash.createdAt = latestStatus.latestStatusDate
    INNER JOIN applicationStatus ast ON ash.statusId = ast.statusId
    LEFT JOIN invoiceStatusHistory ihs ON ihs.applicationId = ua.applicationId
    LEFT JOIN (
        SELECT applicationId, MAX(createdAt) AS lsv
        FROM invoiceStatusHistory 
        GROUP BY applicationId
    ) AS latestInv ON ua.applicationId = latestInv.applicationId 
        AND latestInv.lsv = ihs.createdAt
    INNER JOIN universityDepartments AS ud ON ua.universityDepartmentId = ud.universityDepartmentId
    INNER JOIN universities AS university ON ud.universityId = university.universityId
    WHERE university.universityName = @universityName
      AND ua.yearOfFunding = @year
      AND (ast.status IN ('Awaiting student response', 'Approved','In Review', 'Awaiting executive approval', 'Awaiting finance approval'))
      AND (
          (ihs.statusId IS NULL) OR (ihs.statusId IN (SELECT t_ist.statusId FROM invoiceStatus t_ist WHERE t_ist.status IN ('Pending','Awaiting executive approval','Awaiting finance approval')) AND ihs.createdAt = latestInv.lsv)
      );
END;