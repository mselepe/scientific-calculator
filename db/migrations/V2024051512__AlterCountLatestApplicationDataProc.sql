SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

ALTER PROCEDURE [dbo].[CountLatestApplicationData]
    @userId NVARCHAR(255),
    @year INT = NULL
AS
BEGIN
    DECLARE @resultCount INT;

    SELECT 
        s.status,  
        COUNT(DISTINCT ash.applicationId) AS numberOfApplications 
    INTO 
        #TempApplicationData
    FROM 
        (
            SELECT 
                university.universityName, 
                ua.applicationId, 
                MAX(ash.createdAt) as createdAt
            FROM 
                universities AS university
            INNER JOIN 
                universityDepartments AS department ON university.universityId = department.universityId
            INNER JOIN 
                universityApplications AS ua ON department.universityDepartmentId = ua.universityDepartmentId
            INNER JOIN 
                applicationStatusHistory AS ash ON ua.applicationId = ash.applicationId
            WHERE 
                @year IS NULL OR ua.yearOfFunding = @year
            GROUP BY 
                university.universityName, ua.applicationId
        ) AS a
    INNER JOIN 
        applicationStatusHistory AS ash ON a.createdAt = ash.createdAt
    INNER JOIN 
        applicationStatus AS s ON s.statusId = ash.statusId
    INNER JOIN 
        GetLatestApplicationStatusHistory(@userId) as gte ON gte.applicationId = ash.applicationId
    
    GROUP BY
        s.status;

    SELECT * FROM #TempApplicationData;

    DROP TABLE #TempApplicationData;
END;