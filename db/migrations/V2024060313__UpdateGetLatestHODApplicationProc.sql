IF EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[GetLatestHODApplicationData]') AND type in (N'P', N'PC'))
DROP PROCEDURE [dbo].[GetLatestHODApplicationData]
GO

CREATE PROCEDURE [dbo].[GetLatestHODApplicationData]
    @userId NVARCHAR(255),
    @year INT = NULL
AS
BEGIN
    SELECT CONCAT(gtu.name, ' ', gtu.surname) AS fullName,
           gtu.applicationId,
           gtu.lastUpdate AS date,
           up.amount,
           a.status,
           up.applicationGuid
    FROM GetLatestApplicationStatusHistory(@userId) AS gtu
    INNER JOIN applicationStatusHistory AS ash ON ash.createdAt = gtu.lastUpdate
    INNER JOIN applicationStatus AS a ON ash.statusId = a.statusId
    INNER JOIN universityApplications AS up ON up.applicationId = ash.applicationId
     AND (@year IS NULL OR up.yearOfFunding = @year)
    GROUP BY gtu.name, gtu.surname, gtu.applicationId, gtu.lastUpdate, up.amount, a.status, up.applicationGuid
    ORDER BY
    gtu.lastUpdate
    DESC
END;