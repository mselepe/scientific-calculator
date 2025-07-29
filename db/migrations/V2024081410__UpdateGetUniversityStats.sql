/****** Object:  StoredProcedure [dbo].[GetUniversityStats]    Script Date: 2024/08/14 16:27:09 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
ALTER PROCEDURE [dbo].[GetUniversityStats]
    @universityName NVARCHAR(256) = NULL,
    @year INT = NULL
AS
BEGIN
    SET NOCOUNT ON;

    DECLARE @currentYear INT = YEAR(GETDATE());
    IF @year IS NULL
        SET @year = @currentYear;

   ;WITH UniqueApplications AS (
    SELECT DISTINCT
        u.applicationId,
        univ.universityName,
        s.status AS applicationStatus,
        ish.statusId AS invoiceStatusId
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
),

ApplicationCounts AS (
    SELECT 
        universityName,
        SUM(CASE WHEN applicationStatus = 'Approved' AND invoiceStatusId = 3 THEN 1 ELSE 0 END) AS activeBursaries,
        SUM(CASE WHEN applicationStatus NOT IN ('Rejected','Removed', 'Draft', 'Contract failed','Email failed') AND (invoiceStatusId IS NULL OR invoiceStatusId != 3) THEN 1 ELSE 0 END) AS applications
    FROM 
        UniqueApplications
    GROUP BY
        universityName
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