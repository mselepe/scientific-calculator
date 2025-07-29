CREATE OR ALTER VIEW dbo.vw_RenewalApplicationsSummary AS
WITH CTE AS (
    SELECT 
        applicationId,
        statusId,
        createdAt,
        userId
    FROM applicationStatusHistory
    WHERE statusId = (SELECT statusId FROM applicationStatus WHERE status = 'Pending')
),
InvoiceCTE AS (
    SELECT
        ish.applicationId,
        (SELECT status FROM dbo.[invoiceStatus] WHERE statusId = ish.statusId) AS inv_status,
        MAX(ish.createdAt) AS latestCreatedAt,
        ish.requestedChange,
        ish.userId
    FROM
        dbo.[invoiceStatusHistory] AS ish
    INNER JOIN 
        (
            SELECT
                applicationId,
                MAX(createdAt) AS latestCreatedAt
            FROM
                dbo.[invoiceStatusHistory]
            GROUP BY
                applicationId
        ) AS latest_inv 
        ON ish.applicationId = latest_inv.applicationId
        AND ish.createdAt = latest_inv.latestCreatedAt
    GROUP BY
        ish.applicationId, ish.statusId, ish.requestedChange, ish.userId
)
SELECT 
    c.userId,
    ua.applicationGuid,
    ui.emailAddress AS HODEmail,
    ui.givenName AS HODName,
    s.name AS studentName,
    s.surname AS studentSurname,
    s.email AS studentEmail,
    MAX(ash.createdAt) AS latestStatusDate
FROM applicationStatusHistory ash
INNER JOIN CTE c ON c.applicationId = ash.applicationId
INNER JOIN universityApplications ua ON ua.applicationId = c.applicationId
INNER JOIN students s ON s.studentId = ua.studentId
INNER JOIN InvoiceCTE latest_inv ON c.applicationId = latest_inv.applicationId
INNER JOIN userInformation ui ON c.userId = ui.id 
WHERE 
    ash.statusId = (SELECT statusId FROM applicationStatus WHERE status = 'Approved') 
    AND latest_inv.inv_status = 'Approved'
    AND (
        SELECT COUNT(StudentID)
        FROM universityApplications
        WHERE StudentID IN (
            SELECT StudentID
            FROM universityApplications
            WHERE applicationGuid = ua.applicationGuid
        )
        AND yearOfFunding IN (YEAR(GETDATE()) - 1, YEAR(GETDATE()))
    ) !>1 
    AND ui.accountEnabled = 1 
GROUP BY 
    c.userId, 
    ui.emailAddress,
    ui.givenName,
    s.name,
    s.surname,
    s.email,
    ua.applicationGuid;