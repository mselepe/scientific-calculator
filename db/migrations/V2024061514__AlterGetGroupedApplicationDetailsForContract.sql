/****** Object:  StoredProcedure [dbo].[GetGroupedApplicationDetailsForContract]    Script Date: 2024/06/15 15:30:27 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
ALTER PROCEDURE [dbo].[GetGroupedApplicationDetailsForContract]
    @universityName NVARCHAR(256) = NULL,
    @fullName NVARCHAR(200) = NULL,
    @year INT = NULL
AS
BEGIN
    SET NOCOUNT ON;

    SELECT 
        outerQuery.universityName,
        outerQuery.universityId,
        outerQuery.applicationCount,
        (
            SELECT 
                CONCAT(student.name, ' ', student.surname) AS fullName,
                universityApplication.amount AS amount,
                universityApplication.applicationId AS applicationId,
                universityApplication.applicationGuid AS applicationGuid,
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
                AND universityApplication.yearOfFunding = ISNULL(@year, universityApplication.yearOfFunding)
                AND applicationStatus.status = 'Approved'
                AND (@fullName IS NULL OR student.name + ' ' + student.surname LIKE '%' + @fullName + '%')
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
            university.universityId,
            COUNT(universityApplication.applicationId) AS applicationCount
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
        WHERE
            (@universityName IS NULL OR university.universityName LIKE '%' + @universityName + '%')
            AND universityApplication.yearOfFunding = ISNULL(@year, universityApplication.yearOfFunding)
            AND applicationStatus.status = 'Approved'
            AND applicationStatusHistory.createdAt = (
                SELECT MAX(createdAt)
                FROM dbo.[applicationStatusHistory] AS ASH
                WHERE ASH.applicationId = universityApplication.applicationId
            )
        GROUP BY
            university.universityName,
            university.universityId
    ) AS outerQuery;
END;