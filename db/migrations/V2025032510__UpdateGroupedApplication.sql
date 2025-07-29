
CREATE OR ALTER PROCEDURE [dbo].[GetGroupedApplicationDetails]
    @universityName NVARCHAR(256) = NULL,
    @year INT = NULL,
    @fullName NVARCHAR(747) = NULL
AS
BEGIN
    SET NOCOUNT ON;

    ;WITH LatestApplications AS (
        SELECT 
            universityApplication.applicationId,
            universityApplication.studentId,
            MAX(universityApplication.dateOfApplication) AS latestDate
        FROM 
            dbo.[universityApplications] AS universityApplication
        GROUP BY 
            universityApplication.studentId, universityApplication.applicationId
    ),
    LatestApprovers AS (
        SELECT 
            ash.applicationId,
            ash.userId
        FROM 
            dbo.[applicationStatusHistory] AS ash
        INNER JOIN 
            (
                SELECT 
                    applicationId,
                    MAX(createdAt) AS maxCreatedAt
                FROM 
                    dbo.[applicationStatusHistory]
                GROUP BY 
                    applicationId
            ) AS latest ON ash.applicationId = latest.applicationId 
                       AND ash.createdAt = latest.maxCreatedAt
    ),
    LatestExpenses AS (
        SELECT
            expense.applicationId,
            expense.accommodation, 
            expense.meals, 
            expense.other, 
            expense.tuition,
            ROW_NUMBER() OVER (PARTITION BY expense.applicationId ORDER BY expense.expensesId DESC) AS rn
        FROM dbo.expenses AS expense
    ),

    CurrentYearApplications AS (
        SELECT studentId
        FROM dbo.[universityApplications]
        WHERE (@year IS NULL OR @year = universityApplications.yearOfFunding)
        GROUP BY studentId
    )

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
                latest_exp.accommodation, latest_exp.meals, latest_exp.other, latest_exp.tuition,
                Approver.userId AS approver,
                latest_inv.requestedChange AS changeRequested,
                latest_inv.userId AS changeRequester
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
            LEFT JOIN LatestExpenses AS latest_exp ON universityApplication.applicationId = latest_exp.applicationId AND latest_exp.rn = 1
            LEFT JOIN LatestApplications AS la ON universityApplication.studentId = la.studentId 
                AND universityApplication.dateOfApplication = la.latestDate
            LEFT JOIN LatestApprovers AS Approver ON universityApplication.applicationId = Approver.applicationId
            LEFT JOIN 
                (
                    SELECT
                        ish.applicationId,
                        (SELECT status FROM dbo.[invoiceStatus] WHERE statusId = ish.statusId) AS inv_status,
                        MAX(ish.createdAt) AS latestCreatedAt,
                        ish.requestedChange,
                        ish.userId
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
                        ish.applicationId, ish.statusId, ish.requestedChange, ish.userId
                ) AS latest_inv ON universityApplication.applicationId = latest_inv.applicationId
            WHERE 
                university.universityName = outerQuery.universityName
                AND applicationStatusHistory.createdAt = (
                    SELECT MAX(createdAt)
                    FROM dbo.[applicationStatusHistory] AS ASH
                    WHERE ASH.applicationId = universityApplication.applicationId
                )
                AND (@fullName IS NULL OR CONCAT(student.name, ' ', student.surname) LIKE '%' + @fullName + '%')
                AND (
                    @year IS NULL OR
                    (
                        @year = universityApplication.yearOfFunding
                        OR
                        (
                            @year = YEAR(GETDATE()) AND latest_inv.inv_status = 'Approved' AND universityApplication.yearOfFunding <= YEAR(GETDATE())
                        )
                    )
                    OR
                    (
                        @year > YEAR(GETDATE()) AND @year = universityApplication.yearOfFunding
                    )
                )
                AND (
                    NOT EXISTS (
                        SELECT 1
                        FROM CurrentYearApplications cya
                        WHERE cya.studentId = universityApplication.studentId
                    )
                    OR universityApplication.yearOfFunding = @year
                )
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