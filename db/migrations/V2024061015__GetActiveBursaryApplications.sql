IF EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[GetActiveBursaryApplications]') AND type in (N'P', N'PC'))
DROP PROCEDURE [dbo].[GetActiveBursaryApplications]
GO

CREATE PROCEDURE [dbo].[GetActiveBursaryApplications]
    @universityName NVARCHAR(100) = NULL,
    @year INT = NULL,
    @fullName NVARCHAR(200) = NULL
AS
BEGIN
    SET NOCOUNT ON;

    SELECT 
        universityApplications.amount AS amount,
        CAST(applicationStatusHistory.createdAt AT TIME ZONE 'UTC' AT TIME ZONE 'South Africa Standard Time' AS DATETIME) AS date,
        students.[name] + ' ' + students.surname AS fullName,
        universities.universityId AS id,
        universityApplications.applicationGuid AS applicationGuid,
        universityApplications.applicationId AS applicationId
    FROM 
        universityApplications
    INNER JOIN 
        applicationStatusHistory ON universityApplications.applicationId = applicationStatusHistory.applicationId
    INNER JOIN 
        universityDepartments ON universityApplications.universityDepartmentId = universityDepartments.universityDepartmentId
    INNER JOIN 
        students ON universityApplications.studentId = students.studentId
    INNER JOIN 
        universities ON universityDepartments.universityId = universities.universityId
    INNER JOIN 
        applicationStatus ON applicationStatusHistory.statusId = applicationStatus.statusId
    INNER JOIN 
        (
            SELECT 
                ish.applicationId,
                ish.statusId,
                ish.createdAt
            FROM 
                invoiceStatusHistory AS ish
            INNER JOIN 
                (
                    SELECT 
                        applicationId,
                        MAX(createdAt) AS latestInvCreatedAt
                    FROM 
                        invoiceStatusHistory
                    GROUP BY 
                        applicationId
                ) AS latest_inv ON ish.applicationId = latest_inv.applicationId AND ish.createdAt = latest_inv.latestInvCreatedAt
            INNER JOIN 
                invoiceStatus ON ish.statusId = invoiceStatus.statusId
            WHERE 
                invoiceStatus.status = 'Approved'
        ) AS latest_inv ON universityApplications.applicationId = latest_inv.applicationId
    WHERE 
        applicationStatus.[status] = 'Approved'
        AND applicationStatusHistory.createdAt = (
            SELECT MAX(createdAt)
            FROM applicationStatusHistory AS ash
            WHERE ash.applicationId = universityApplications.applicationId
        )
        AND (@universityName IS NULL OR universities.universityName LIKE '%' + @universityName + '%')
        AND (@year IS NULL OR universityApplications.yearOfFunding = @year)
        AND (@fullName IS NULL OR students.[name] + ' ' + students.surname LIKE '%' + @fullName + '%');
END;
GO


