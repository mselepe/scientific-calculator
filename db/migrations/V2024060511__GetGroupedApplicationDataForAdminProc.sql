IF EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[GetGroupedApplicationDetails]') AND type in (N'P', N'PC'))
DROP PROCEDURE [dbo].[GetGroupedApplicationDetails]
GO

CREATE PROCEDURE [dbo].[GetGroupedApplicationDetails]
    @universityName NVARCHAR(256) = NULL,
    @year INT = NULL,
    @name VARCHAR(747) = NULL
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
                universityApplication.applicationId AS applicationId,
                universityApplication.applicationGuid AS applicationGuid,
                applicationStatus.status AS status,
                universityDepartment.universityId
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
                AND applicationStatusHistory.createdAt = (
                    SELECT MAX(createdAt)
                    FROM dbo.[applicationStatusHistory] AS ASH
                    WHERE ASH.applicationId = universityApplication.applicationId
                )
                AND (@name IS NULL OR student.name LIKE '%' + @name + '%')
                AND (@year IS NULL OR @year = universityApplication.yearOfFunding)
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
            WHERE (@universityName IS NULL OR @universityName = '' OR university.universityName LIKE '%' + @universityName + '%')
            GROUP BY
                university.universityName,
                university.universityId
        ) AS outerQuery
    GROUP BY
        outerQuery.universityName, outerQuery.universityId;
END;