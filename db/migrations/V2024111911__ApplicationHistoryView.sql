IF OBJECT_ID('vw_ApplicationStatusHistoryWithDates', 'V') IS NOT NULL
    DROP VIEW vw_ApplicationStatusHistoryWithDates;
GO

CREATE VIEW vw_ApplicationStatusHistoryWithDates AS
SELECT 
    ash.applicationStatusHistoryId,
    ash.userId,
    ash.applicationId,
	ua.applicationGuid,
    s.status,
     FORMAT(
        (ash.createdAt AT TIME ZONE 'UTC') AT TIME ZONE 'South Africa Standard Time', 
        'MMM dd, yyyy hh:mm tt'
    ) AS fromDate,
    FORMAT(
        LEAD(ash.createdAt, 1, '9999-12-31') OVER (
            PARTITION BY ash.applicationId 
            ORDER BY ash.createdAt
        ) AT TIME ZONE 'UTC' AT TIME ZONE 'South Africa Standard Time', 
        'MMM dd, yyyy hh:mm tt'
    ) AS ToDate
FROM 
    applicationStatusHistory ash
INNER JOIN 
    applicationStatus s ON s.statusId = ash.statusId
INNER JOIN 
    universityApplications ua ON ua.applicationId = ash.applicationId;