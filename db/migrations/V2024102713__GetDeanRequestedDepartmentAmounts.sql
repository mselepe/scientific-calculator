IF EXISTS (SELECT * 
FROM sys.objects 
WHERE object_id = OBJECT_ID(N'[dbo].[GetDeanRequestedDepartmentAmounts]') 
AND type in (N'P', N'PC'))
DROP PROCEDURE [dbo].[GetDeanRequestedDepartmentAmounts]
GO

CREATE PROCEDURE [dbo].[GetDeanRequestedDepartmentAmounts]
    @universityName NVARCHAR(256),
    @facultyName NVARCHAR(256),
    @year INT
AS
BEGIN
    SET NOCOUNT ON;

    SELECT total_requested_amount, universityDepartmentName, facultyName
    FROM
    (SELECT 
            SUM(ua.amount) AS total_requested_amount, ua.universityDepartmentId
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
        AND ((ihs.statusId IS NULL) OR (ihs.statusId IN (SELECT t_ist.statusId FROM invoiceStatus t_ist WHERE t_ist.status IN ('Pending','Awaiting executive approval','Awaiting finance approval')) AND ihs.createdAt = latestInv.lsv))
        GROUP BY ua.universityDepartmentId) AS totalRequestedPerDepartment
    JOIN universityDepartments
    ON totalRequestedPerDepartment.universityDepartmentId = universityDepartments.universityDepartmentId
    JOIN faculties
    ON universityDepartments.facultyId = faculties.facultyId
    WHERE facultyName = @facultyName
END;
GO

