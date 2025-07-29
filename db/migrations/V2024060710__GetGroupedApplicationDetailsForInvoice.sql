IF EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[GetGroupedApplicationDetailsForInvoice]') AND type in (N'P', N'PC'))
DROP PROCEDURE [dbo].[GetGroupedApplicationDetailsForInvoice]
GO

CREATE PROCEDURE [dbo].[GetGroupedApplicationDetailsForInvoice]
    @universityName NVARCHAR(100) = NULL,
    @year INT = NULL,
    @fullName NVARCHAR(200) = NULL
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
                applicationStatus.status AS status,
                latest_inv.inv_status AS invoiceStatus
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
            INNER JOIN (
                SELECT
                    ish.applicationId,
                    invoiceStatus.status AS inv_status,
                    ish.statusId,
                    ish.createdAt AS invCreatedAt
                FROM
                    invoiceStatusHistory AS ish
                INNER JOIN (
                    SELECT
                        applicationId,
                        MAX(createdAt) AS latestInvCreatedAt
                    FROM
                        invoiceStatusHistory
                    GROUP BY
                        applicationId
                ) AS latest_inv ON ish.applicationId = latest_inv.applicationId
                AND ish.createdAt = latest_inv.latestInvCreatedAt
                INNER JOIN
                    invoiceStatus ON ish.statusId = invoiceStatus.statusId
            ) AS latest_inv ON universityApplication.applicationId = latest_inv.applicationId
            WHERE
                university.universityName = outerQuery.universityName
                AND universityApplication.yearOfFunding = ISNULL(@year, universityApplication.yearOfFunding)
                  AND (applicationStatus.status = 'Approved' AND latest_inv.statusId= (SELECT statusId FROM invoiceStatus WHERE status='Pending') )
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
            AND applicationStatusHistory.createdAt = (
                SELECT MAX(createdAt)
                FROM dbo.[applicationStatusHistory] AS ASH
                WHERE ASH.applicationId = universityApplication.applicationId
            )
            AND applicationStatus.status = 'Approved'
        GROUP BY
            university.universityName,
            university.universityId
    ) AS outerQuery;
END;
GO