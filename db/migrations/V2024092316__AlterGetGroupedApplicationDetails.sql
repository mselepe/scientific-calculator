/****** Object:  StoredProcedure [dbo].[GetGroupedApplicationDetails]    Script Date: 2024/08/06 08:44:44 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
ALTER PROCEDURE [dbo].[GetGroupedApplicationDetails]
    @universityName NVARCHAR(256) = NULL,
    @year INT = NULL,
    @fullName NVARCHAR(747) = NULL
AS
BEGIN
   SET NOCOUNT ON;

   SELECT 
    outerQuery.universityName,
    outerQuery.universityId,
    (
        SELECT
            CONCAT(student.name, ' ', student.surname) AS fullName,
            universityApplication.amount AS amount,
            universityApplication.applicationId AS applicationId,
            universityApplication.applicationGuid AS applicationGuid,
            applicationStatus.status AS status,
            universityApplication.dateOfApplication AS [date],
            universityDepartment.universityId,
            COALESCE(latest_inv.inv_status, 'Invalid') AS invoiceStatus,
			expense.accommodation, expense.meals, expense.other, expense.tuition,
			Approver.userId AS approver
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
		LEFT JOIN expenses AS expense ON universityApplication.applicationId = expense.applicationId
		LEFT JOIN (SELECT userId, applicationId FROM applicationStatusHistory WHERE applicationStatusHistory.statusId = (SELECT statusId FROM applicationStatus WHERE status='Awaiting executive approval'))
		AS Approver ON  Approver.applicationId=universityApplication.applicationId 
        LEFT JOIN 
            (
                SELECT
                    ish.applicationId,
                    (SELECT status FROM dbo.[invoiceStatus] WHERE statusId = ish.statusId) AS inv_status,
                    MAX(ish.createdAt) AS latestCreatedAt
                FROM
                    dbo.[invoiceStatusHistory] AS ish
                INNER JOIN 
                    (
                        SELECT
                            applicationId,
                            MAX(createdAt) AS latestCreatedAt
                        FROM
                            dbo.[invoiceStatusHistory]
                        GROUP BY
                            applicationId
                    ) AS latest_inv ON ish.applicationId = latest_inv.applicationId
                    AND ish.createdAt = latest_inv.latestCreatedAt
                GROUP BY
                    ish.applicationId, ish.statusId
            ) AS latest_inv ON universityApplication.applicationId = latest_inv.applicationId
        WHERE 
            university.universityName = outerQuery.universityName
            AND applicationStatusHistory.createdAt = (
                SELECT MAX(createdAt)
                FROM dbo.[applicationStatusHistory] AS ASH
                WHERE ASH.applicationId = universityApplication.applicationId
            )
            AND (@fullName IS NULL OR CONCAT(student.name, ' ', student.surname) LIKE '%' + @fullName + '%')
            AND (@year IS NULL OR @year = universityApplication.yearOfFunding)
        ORDER BY
            [date] DESC
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
        WHERE 
            (@universityName IS NULL OR @universityName = '' OR university.universityName LIKE '%' + @universityName + '%')
        GROUP BY
            university.universityName,
            university.universityId
    ) AS outerQuery
GROUP BY
    outerQuery.universityName, outerQuery.universityId;

END;