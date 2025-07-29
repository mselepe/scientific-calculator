SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
ALTER PROCEDURE [dbo].[GetLatestHODApplicationData]
    @userId NVARCHAR(255),
    @year INT = NULL
AS
BEGIN

   ;WITH CurrentYearApplications AS (
        SELECT studentId
        FROM dbo.[universityApplications]
        WHERE (@year IS NULL OR @year = universityApplications.yearOfFunding)
        GROUP BY studentId
    )
    SELECT
        CONCAT(gtu.name, ' ', gtu.surname) AS fullName,
        gtu.applicationId,
        gtu.lastUpdate AS date,
        up.amount,
        a.status,
        up.applicationGuid,
        COALESCE(latest_inv.inv_status, 'Invalid') AS invoiceStatus,
        latest_exp.accommodation, latest_exp.meals, latest_exp.other, latest_exp.tuition
    FROM
        GetLatestApplicationStatusHistory(@userId) AS gtu
    INNER JOIN 
        applicationStatusHistory AS ash ON ash.createdAt = gtu.lastUpdate
    INNER JOIN 
        applicationStatus AS a ON ash.statusId = a.statusId
    INNER JOIN 
        universityApplications AS up ON up.applicationId = ash.applicationId
    LEFT JOIN (
        SELECT
            ish.applicationId,
            (SELECT status FROM invoiceStatus WHERE invoiceStatus.statusId = ish.statusId) AS inv_status,
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
    ) AS latest_inv ON gtu.applicationId = latest_inv.applicationId
    LEFT JOIN (
        SELECT
            expense.applicationId,
            expense.accommodation,
            expense.meals,
            expense.other,
            expense.tuition,
            ROW_NUMBER() OVER (PARTITION BY expense.applicationId ORDER BY expense.expensesId DESC) AS rn
        FROM
            expenses AS expense
    ) AS latest_exp ON up.applicationId = latest_exp.applicationId AND latest_exp.rn = 1
    WHERE
        (@year IS NULL OR (
                @year = up.yearOfFunding
                OR
                (
                    @year = YEAR(GETDATE()) AND latest_inv.inv_status = 'Approved' AND up.yearOfFunding <= YEAR(GETDATE())
                )
            )
            OR
            (
                @year > YEAR(GETDATE()) AND @year = up.yearOfFunding
            ))AND (
            NOT EXISTS (
                SELECT 1
                FROM CurrentYearApplications cya
                WHERE cya.studentId = up.studentId
            )
            OR up.yearOfFunding = @year
        )
    GROUP BY
        gtu.name, gtu.surname, gtu.applicationId, gtu.lastUpdate, latest_inv.inv_status, up.amount, a.status, up.applicationGuid, latest_exp.accommodation, latest_exp.meals, latest_exp.other, latest_exp.tuition
    ORDER BY
        gtu.lastUpdate DESC;
END;