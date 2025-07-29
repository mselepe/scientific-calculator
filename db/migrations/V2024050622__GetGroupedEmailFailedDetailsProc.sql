IF EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[GetGroupedEmailFailedDetails]') AND type in (N'P', N'PC'))
DROP PROCEDURE [dbo].[GetGroupedEmailFailedDetails]
GO

CREATE   PROCEDURE [dbo].[GetGroupedEmailFailedDetails]
    @universityName NVARCHAR(100)  
AS
BEGIN
    SET NOCOUNT ON;

    SELECT 
        universityName,
        universityId,
        (
            SELECT 
                CONCAT(student.name, ' ', student.surname) AS fullName,
                universityApplication.amount AS amount,
                applicationStatus.status AS status
            FROM
                dbo.[universityApplications] AS universityApplication
            INNER JOIN 
                dbo.[students] AS student ON universityApplication.studentId = student.studentId
            INNER JOIN 
                dbo.[universityDepartments] AS universityDepartment ON universityApplication.universityDepartmentId = universityDepartment.universityDepartmentId
            INNER JOIN 
                dbo.[universities] AS university ON universityDepartment.universityId = university.universityId
            INNER JOIN 
                dbo.[applicationStatusHistory] AS applicationStatusHistory ON universityApplication.applicationId = applicationStatusHistory.applicationId
            INNER JOIN 
                dbo.[applicationStatus] AS applicationStatus ON applicationStatusHistory.statusId = applicationStatus.statusId
            WHERE 
                university.universityName = outerQuery.universityName
                AND applicationStatus.status = 'Email Failed' 
                AND applicationStatusHistory.createdAt = (
                    SELECT MAX(createdAt)
                    FROM dbo.[applicationStatusHistory] AS ASH
                    WHERE ASH.applicationId = universityApplication.applicationId
                )
            FOR JSON PATH
        ) AS details
    FROM 
        (
            SELECT 
                university.universityName,
                university.universityId
            FROM 
                dbo.[universityApplications] AS universityApplication
            INNER JOIN 
                dbo.[universityDepartments] AS universityDepartment ON universityApplication.universityDepartmentId = universityDepartment.universityDepartmentId
            INNER JOIN 
                dbo.[universities] AS university ON universityDepartment.universityId = university.universityId
            INNER JOIN 
                dbo.[applicationStatusHistory] AS applicationStatusHistory ON universityApplication.applicationId = applicationStatusHistory.applicationId
            INNER JOIN 
                dbo.[applicationStatus] AS applicationStatus ON applicationStatusHistory.statusId = applicationStatus.statusId
            GROUP BY 
                university.universityName,
                university.universityId
        ) AS outerQuery
    WHERE
        outerQuery.universityName = @universityName;
END;

GO


