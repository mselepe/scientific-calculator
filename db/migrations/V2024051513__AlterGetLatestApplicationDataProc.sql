SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
ALTER PROCEDURE [dbo].[GetLatestApplicationData]
    @userId NVARCHAR(255),
    @status NVARCHAR(50),
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
     AND (@year IS NULL OR up.yearOfFunding = @year)  AND a.status=@status
    GROUP BY gtu.name, gtu.surname, gtu.applicationId, gtu.lastUpdate, up.amount, a.status
END;
