
ALTER PROCEDURE [dbo].[GetLatestHODApplicationData]
    @userId NVARCHAR(255), -- 'ffca0f81-e075-4f7c-80c2-b25c61651865'
    @year INT = NULL
AS
BEGIN
     SELECT
    CONCAT(gtu.name, ' ', gtu.surname) AS fullName,
    gtu.applicationId,
    gtu.lastUpdate AS date,
    up.amount,
    a.status,
    up.applicationGuid,
    COALESCE(latest_inv.inv_status, 'Invalid') AS invoiceStatus,
	expense.accommodation, expense.meals, expense.other, expense.tuition

FROM
    GetLatestApplicationStatusHistory(@userId) AS gtu
    INNER JOIN applicationStatusHistory AS ash ON ash.createdAt = gtu.lastUpdate
    INNER JOIN applicationStatus AS a ON ash.statusId = a.statusId
    INNER JOIN universityApplications AS up ON up.applicationId = ash.applicationId
    LEFT JOIN (
        SELECT
            ish.applicationId,
            (SELECT status FROM invoiceStatus WHERE invoiceStatus.statusId = ish.statusId) AS inv_status,
            ish.statusId,
            ish.createdAt AS invCreatedAt
        FROM
            invoiceStatusHistory AS ish
        INNER JOIN (
            SELECT
                applicationId,
                MAX(createdAt) AS latestInvCreatedAt
            FROM
                invoiceStatusHistory
            GROUP BY
                applicationId
        ) AS latest_inv ON ish.applicationId = latest_inv.applicationId
        AND ish.createdAt = latest_inv.latestInvCreatedAt
    ) AS latest_inv ON gtu.applicationId = latest_inv.applicationId
	LEFT JOIN expenses AS expense ON up.applicationId = expense.applicationId
WHERE
    (@year IS NULL OR up.yearOfFunding = @year)
GROUP BY
    gtu.name, gtu.surname, gtu.applicationId, gtu.lastUpdate, inv_status, up.amount, a.status, up.applicationGuid, expense.accommodation, expense.meals, expense.other, expense.tuition
ORDER BY
    gtu.lastUpdate DESC;
END;
GO

