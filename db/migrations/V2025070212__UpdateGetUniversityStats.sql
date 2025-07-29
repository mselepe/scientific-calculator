SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

ALTER PROCEDURE [dbo].[GetUniversityStats]
    @universityName NVARCHAR(256) = NULL,
    @year INT = NULL,
    @rank VARCHAR(30) = NULL,
    @bursaryType VARCHAR(20) = NULL
AS
BEGIN
    SET NOCOUNT ON;

    DECLARE @approvedInvoiceStatus INT = (SELECT statusId FROM invoiceStatus WHERE status = 'Approved');
    DECLARE @awaitingExecInvoiceStatus INT = (SELECT statusId FROM invoiceStatus WHERE status = 'Awaiting executive approval');
    DECLARE @awaitingFinInvoiceStatus INT = (SELECT statusId FROM invoiceStatus WHERE status = 'Awaiting finance approval');

    IF @year IS NULL
    BEGIN
        SET @year = YEAR(GETDATE());
    END

    DECLARE @applicationStatuses TABLE (status NVARCHAR(100) PRIMARY KEY);
    IF @rank = 'senior_admin'
    BEGIN
        INSERT INTO @applicationStatuses (status)
        VALUES ('Awaiting finance approval'), ('Approved'),('Onboarded'), ('Payment'), ('Active');
    END
    ELSE IF @rank = 'admin_officer'
    BEGIN
        INSERT INTO @applicationStatuses (status)
        VALUES ('Approved'), ('Awaiting executive approval'), ('Awaiting finance approval'),('Onboarded'), ('Active');
    END
    ELSE 
    BEGIN
        INSERT INTO @applicationStatuses (status)
        VALUES ('Draft'), ('In Review'), ('Awaiting student response'), ('Approved'), ('Email Failed'), ('Awaiting executive approval'), ('Awaiting finance approval'),('Pending renewal')
                ,('Onboarded'),('Completing_Internal_Assessment'),('Conducting_Interview'), ('Awaiting fund distribution'), ('Contract'), ('Invoice'), ('Payment'), ('Active');
    END;

    WITH LatestApplicationHistory AS (
        SELECT
            applicationId,
            statusId,
            ROW_NUMBER() OVER(PARTITION BY applicationId ORDER BY createdAt DESC) as rn
        FROM dbo.applicationStatusHistory
    ),
    LatestInvoiceHistory AS (
        SELECT
            applicationId,
            statusId,
            ROW_NUMBER() OVER(PARTITION BY applicationId ORDER BY createdAt DESC) as rn
        FROM dbo.invoiceStatusHistory
    ),
    RankedApplications AS (
        SELECT
            u.applicationId,
            u.studentId,
            univ.universityName,
            appStatus.status AS applicationStatus,
            invStatus.statusId AS invoiceStatusId,
            ROW_NUMBER() OVER(PARTITION BY u.studentId ORDER BY u.applicationId DESC) as rn
        FROM dbo.universityApplications AS u
        INNER JOIN dbo.bursaryTypes bt ON bt.bursaryTypeId = u.bursaryTypeId
        INNER JOIN dbo.universityDepartments AS ud ON u.universityDepartmentId = ud.universityDepartmentId
        INNER JOIN dbo.universities AS univ ON ud.universityId = univ.universityId
        
        INNER JOIN LatestApplicationHistory ash ON u.applicationId = ash.applicationId AND ash.rn = 1
        INNER JOIN dbo.applicationStatus appStatus ON ash.statusId = appStatus.statusId
        
        LEFT JOIN LatestInvoiceHistory ish ON u.applicationId = ish.applicationId AND ish.rn = 1
        LEFT JOIN dbo.invoiceStatus invStatus ON ish.statusId = invStatus.statusId

        WHERE
            (univ.universityName = @universityName OR @universityName IS NULL)
            AND (@bursaryType IS NULL OR bt.bursaryType = @bursaryType)
            AND appStatus.status IN (SELECT status FROM @applicationStatuses)
            AND (
                u.yearOfFunding = @year
                OR 
                (@year = YEAR(GETDATE()) AND u.yearOfFunding < @year AND invStatus.statusId = @approvedInvoiceStatus)
            )
    ),
    UniqueApplications AS (
        SELECT applicationId, studentId, universityName, applicationStatus, invoiceStatusId
        FROM RankedApplications
        WHERE rn = 1
    ),
    ApplicationCounts AS (
        SELECT
            universityName,
            SUM(CASE
                    WHEN applicationStatus = 'Onboarded' THEN 1
                    WHEN applicationStatus IN ('Approved', 'Active') AND invoiceStatusId = @approvedInvoiceStatus THEN 1
                    ELSE 0
                END) AS activeBursaries,

            SUM(CASE
                    WHEN applicationStatus = 'Onboarded' THEN 0 
                    WHEN @rank = 'senior_admin' AND (applicationStatus = 'Awaiting finance approval' OR invoiceStatusId = @awaitingFinInvoiceStatus) THEN 1
                    WHEN @rank = 'admin_officer' AND (applicationStatus IN ('Awaiting executive approval', 'Awaiting finance approval') OR invoiceStatusId IN (@awaitingExecInvoiceStatus, @awaitingFinInvoiceStatus)) THEN 1
                    WHEN @rank = 'assistant_admin' AND (invoiceStatusId IS NULL OR invoiceStatusId != @approvedInvoiceStatus) THEN 1
                    ELSE 0
                END) AS applications
        FROM UniqueApplications
        GROUP BY universityName
    ),
    TotalAllocations AS (
        SELECT
            university.universityName,
            SUM(a.amount) AS totalAllocationAmount
        FROM dbo.allocations AS a
        INNER JOIN dbo.universityDepartments AS ud ON a.universityDepartmentId = ud.universityDepartmentId
        INNER JOIN dbo.universities AS university ON ud.universityId = university.universityId
        INNER JOIN dbo.bursaryTypes bt ON bt.bursaryTypeId = a.bursaryTypeId
        WHERE
            (university.universityName = @universityName OR @universityName IS NULL)
            AND a.yearOfFunding = @year
            AND (@bursaryType IS NULL OR bt.bursaryType = @bursaryType)
        GROUP BY university.universityName
    )

    SELECT
        ac.universityName,
        ac.activeBursaries,
        ac.applications,
        COALESCE(ta.totalAllocationAmount, 0) AS totalAllocationAmount
    FROM ApplicationCounts AS ac
    LEFT JOIN TotalAllocations AS ta ON ac.universityName = ta.universityName;

END;
GO
