IF OBJECT_ID('vw_InvoiceStatusHistoryWithDates', 'V') IS NOT NULL
    DROP VIEW vw_InvoiceStatusHistoryWithDates;
GO
CREATE VIEW vw_InvoiceStatusHistoryWithDates AS 
SELECT 
    ish.invoiceStatusHistoryId,
    ish.userId,
    ish.applicationId,
    ua.applicationGuid,
    s.status,
    FORMAT(
        (ish.createdAt AT TIME ZONE 'UTC') AT TIME ZONE 'South Africa Standard Time', 
        'MMM dd, yyyy hh:mm tt'
    ) AS fromDate,
    FORMAT(
        LEAD(ish.createdAt, 1, '9999-12-31') OVER (
            PARTITION BY ish.applicationId 
            ORDER BY ish.createdAt
        ) AT TIME ZONE 'UTC' AT TIME ZONE 'South Africa Standard Time', 
        'MMM dd, yyyy hh:mm tt'
    ) AS ToDate
FROM 
    invoiceStatusHistory ish
INNER JOIN 
    invoiceStatus s ON s.statusId = ish.statusId
INNER JOIN 
    universityApplications ua ON ua.applicationId = ish.applicationId;