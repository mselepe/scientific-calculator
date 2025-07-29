IF EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[GetLatestApplicationData]') AND type in (N'P', N'PC'))
DROP PROCEDURE [dbo].[GetLatestApplicationData]
GO
CREATE PROCEDURE [dbo].[GetLatestApplicationData]
    @userId NVARCHAR(255),
    @status NVARCHAR(50),
    @invoiceStatus NVARCHAR(50),
    @year INT = NULL
AS
BEGIN
    SELECT CONCAT(gtu.name, ' ', gtu.surname) AS fullName,
           gtu.applicationId,
           gtu.lastUpdate AS date,
           up.amount,
           a.status
    FROM GetLatestApplicationStatusHistory(@userId) AS gtu
    INNER JOIN applicationStatusHistory AS ash ON ash.createdAt = gtu.lastUpdate
    INNER JOIN applicationStatus AS a ON ash.statusId = a.statusId
    INNER JOIN universityApplications AS up ON up.applicationId = ash.applicationId
    INNER JOIN (
        SELECT ish.applicationId, ish.statusId, ish.createdAt AS invCreatedAt
        FROM invoiceStatusHistory AS ish
        INNER JOIN (
            SELECT applicationId, MAX(createdAt) AS latestInvCreatedAt
            FROM invoiceStatusHistory
            GROUP BY applicationId
        ) AS latest_inv ON ish.applicationId = latest_inv.applicationId AND ish.createdAt = latest_inv.latestInvCreatedAt
    ) AS latest_inv ON gtu.applicationId = latest_inv.applicationId
    WHERE a.status = @status
      AND latest_inv.statusId = (
          SELECT statusId FROM invoiceStatus WHERE invoiceStatus.status = @invoiceStatus
      )
      AND (@year IS NULL OR up.yearOfFunding = @year) 
    GROUP BY gtu.name, gtu.surname, gtu.applicationId, gtu.lastUpdate, up.amount, a.status, latest_inv.invCreatedAt;
END;
