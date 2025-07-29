SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
ALTER PROCEDURE [dbo].[GetUniversityStats]
    @universityName NVARCHAR(256) = NULL,
    @year INT = NULL,
    @rank NVARCHAR(30) = NULL 
AS
BEGIN
    SET NOCOUNT ON;

	DECLARE @approvedInvoiceStatus INT = (SELECT statusId FROM invoiceStatus WHERE status = 'Approved');
	DECLARE @awaitingExecInvoiceStatus INT = (SELECT statusId FROM invoiceStatus WHERE status = 'Awaiting executive approval');
	DECLARE @awaitingFinInvoiceStatus INT = (SELECT statusId FROM invoiceStatus WHERE status = 'Awaiting finance approval');

    DECLARE @currentYear INT = YEAR(GETDATE());
    IF @year IS NULL
    BEGIN
        SET @year = @currentYear;
    END

    DECLARE @applicationStatuses TABLE (status NVARCHAR(100));
    IF @rank = 'senior_admin'
    BEGIN
        INSERT INTO @applicationStatuses (status) 
        VALUES ('Awaiting finance approval'), ('Approved');
    END
    ELSE IF @rank = 'admin_officer'
    BEGIN
        INSERT INTO @applicationStatuses (status) 
        VALUES ('Approved'), ('Awaiting executive approval'), ('Awaiting finance approval');
    END
    ELSE
    BEGIN
        INSERT INTO @applicationStatuses (status) 
        VALUES ('Draft'), ('In Review'), ('Awaiting student response'), ('Approved'), ('Email Failed'), ('Awaiting executive approval'), ('Awaiting finance approval'),('Pending renewal');
    END

    DECLARE @invoiceStatuses TABLE (status NVARCHAR(100));
    IF @rank = 'senior_admin'
    BEGIN
        INSERT INTO @invoiceStatuses (status) 
        VALUES ('In Review'),('Approved');  
    END
    ELSE IF @rank = 'admin_officer'
    BEGIN
        INSERT INTO @invoiceStatuses (status) 
        VALUES  (NULL),('Approved'),('Awaiting executive approval'),('Awaiting finance approval'); 
    END
    ELSE
    BEGIN
        INSERT INTO @invoiceStatuses (status) 
        VALUES (NULL), ('Pending'), ('In Review'), ('Approved'),('Awaiting fund distribution'); 
    END

	;WITH CurrentYearApplications AS (
        SELECT studentId
        FROM dbo.[universityApplications]
        WHERE (@year IS NULL OR @year = universityApplications.yearOfFunding)
        GROUP BY studentId
    ),

     UniqueApplications AS (


        SELECT
		DISTINCT
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
        INNER JOIN 
            @applicationStatuses AS appStat ON s.status = appStat.status
        LEFT JOIN 
            @invoiceStatuses AS invStat ON ish.statusId = (SELECT statusId FROM invoiceStatus WHERE status=invStat.status)
        WHERE 
            (univ.universityName = @universityName OR @universityName IS NULL)
             AND (
                    @year IS NULL OR
                    (
                        @year = u.yearOfFunding
                        OR
                        (
                            @year = YEAR(GETDATE()) AND invStat.status = 'Approved' AND u.yearOfFunding <= YEAR(GETDATE())
                        )
                    )
                    OR
                    (
                        @year > YEAR(GETDATE()) AND @year = u.yearOfFunding
                    )
                )
                AND (
                    NOT EXISTS (
                        SELECT 1
                        FROM CurrentYearApplications cya
                        WHERE cya.studentId = u.studentId
                    )
                    OR u.yearOfFunding = @year
                )
    ),

    ApplicationCounts AS (
     SELECT 
    universityName,
    SUM(CASE 
        WHEN applicationStatus = 'Approved' 
             AND invoiceStatusId = @approvedInvoiceStatus 
        THEN 1 ELSE 0 END) AS activeBursaries,
    
    SUM(CASE 
        WHEN @rank = 'assistant_admin' 

            AND (invoiceStatusId IS NULL OR invoiceStatusId != @approvedInvoiceStatus) 
        THEN 1
        WHEN @rank = 'admin_officer'
            AND (invoiceStatusId =@awaitingExecInvoiceStatus OR invoiceStatusId = @awaitingFinInvoiceStatus OR invoiceStatusId IS NULL OR ((applicationStatus = 'Awaiting executive response' or applicationStatus = 'Awaiting finance approval')))
        THEN 1
		WHEN @rank = 'senior_admin'
			AND (invoiceStatusId = @awaitingFinInvoiceStatus OR (applicationStatus = 'Awaiting finance approval'))
		THEN 1
        ELSE 0 END) AS applications
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