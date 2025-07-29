IF EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[GetUniversityStats]') AND type in (N'P', N'PC'))
DROP PROCEDURE [dbo].[GetUniversityStats]
GO
CREATE PROCEDURE [dbo].[GetUniversityStats]
    @universityName NVARCHAR(256) = NULL,
    @year INT = NULL
AS
BEGIN
    SET NOCOUNT ON;

    DECLARE @currentYear INT = YEAR(GETDATE());
    IF @year IS NULL
        SET @year = @currentYear;

    ;WITH ApplicationCounts AS (
        SELECT 
            univ.universityName,
            SUM(CASE WHEN s.status = 'Approved' AND ish.statusId = 3 THEN 1 ELSE 0 END) AS activeBursaries,
            SUM(CASE WHEN s.status NOT IN ('Approved', 'Rejected') AND (ish.statusId IS NULL OR ish.statusId != 3) THEN 1 ELSE 0 END) AS applications
        FROM 
            universityApplications AS u
        INNER JOIN (
            SELECT 
                applicationId, 
                MAX(createdAt) AS maxCreatedAt
            FROM 
                applicationStatusHistory
            GROUP BY 
                applicationId
        ) AS ast ON ast.applicationId = u.applicationId
        INNER JOIN 
            applicationStatusHistory AS ash ON ash.applicationId = ast.applicationId AND ash.createdAt = ast.maxCreatedAt
        INNER JOIN 
            applicationStatus AS s ON ash.statusId = s.statusId
        INNER JOIN 
            universityDepartments AS ud ON u.universityDepartmentId = ud.universityDepartmentId
        LEFT JOIN 
            universities AS univ ON ud.universityId = univ.universityId
        LEFT JOIN (
            SELECT 
                applicationId,
                MAX(createdAt) AS maxCreatedAt
            FROM 
                invoiceStatusHistory
            GROUP BY 
                applicationId
        ) AS ist ON ist.applicationId = u.applicationId
        LEFT JOIN 
            invoiceStatusHistory AS ish ON ish.applicationId = ist.applicationId AND ish.createdAt = ist.maxCreatedAt
        WHERE 
            (univ.universityName = @universityName OR @universityName IS NULL)
            AND u.yearOfFunding = @year
            AND s.status NOT IN ('Rejected')
        GROUP BY
            univ.universityName
    ),

    TotalAllocations AS (
        SELECT 
            university.universityName,
            SUM(a.amount) AS totalAllocationAmount
        FROM 
            allocations AS a
        INNER JOIN 
            universityDepartments AS ud ON a.universityDepartmentId = ud.universityDepartmentId
        INNER JOIN 
            universities AS university ON ud.universityId = university.universityId
        WHERE 
            (university.universityName = @universityName OR @universityName IS NULL)
            AND a.yearOfFunding = ISNULL(@year, @currentYear)
        GROUP BY
            university.universityName
    )

    SELECT 
        ac.universityName,
        ac.activeBursaries,
        ac.applications,
        COALESCE(ta.totalAllocationAmount, 0) AS totalAllocationAmount
    FROM 
        ApplicationCounts AS ac
    LEFT JOIN 
        TotalAllocations AS ta ON ac.universityName = ta.universityName;
END;
