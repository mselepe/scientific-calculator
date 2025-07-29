IF EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[GetFundAllocationsData]') AND type in (N'P', N'PC'))
DROP PROCEDURE [dbo].[GetFundAllocationsData]
GO

CREATE PROCEDURE [dbo].[GetFundAllocationsData]
    @universityName NVARCHAR(256),
	@year INT
AS
BEGIN
    SET NOCOUNT ON;

    SELECT SUM(allocations.amount) 
    AS department_total_allocation_amount,
    universities.universityName,
    universityDepartments.universityDepartmentName,
    latestStatusRequested.university_total_requested_amount,
    latestStatusApproved.university_total_approved_amount,
    universityTotalAllocation.university_total_allocation_amount,
    universityDepartmentsRequested.department_total_requested_amount,
    universityDepartmentsApproved.department_total_approved_amount
    FROM allocations
    INNER JOIN universityDepartments ON allocations.universityDepartmentId = universityDepartments.universityDepartmentId
    INNER JOIN universities ON universityDepartments.universityId = universities.universityId
    LEFT JOIN (
        SELECT 
        SUM(ua.amount) AS university_total_requested_amount, universityName
    FROM universityApplications ua
    INNER JOIN (
        SELECT applicationId, MAX(createdAt) AS latestStatusDate
        FROM applicationStatusHistory
        GROUP BY applicationId
    ) AS latestStatus ON ua.applicationId = latestStatus.applicationId
    INNER JOIN applicationStatusHistory ash ON ua.applicationId = ash.applicationId 
        AND ash.createdAt = latestStatus.latestStatusDate
    INNER JOIN applicationStatus ast ON ash.statusId = ast.statusId
    LEFT JOIN invoiceStatusHistory ihs ON ihs.applicationId = ua.applicationId
    LEFT JOIN (
        SELECT applicationId, MAX(createdAt) AS lsv
        FROM invoiceStatusHistory 
        GROUP BY applicationId
    ) AS latestInv ON ua.applicationId = latestInv.applicationId 
        AND latestInv.lsv = ihs.createdAt
    INNER JOIN universityDepartments AS ud ON ua.universityDepartmentId = ud.universityDepartmentId
    INNER JOIN universities AS university ON ud.universityId = university.universityId
    WHERE university.universityName = @universityName
      AND ua.yearOfFunding = @year
      AND (ast.status IN ('Awaiting student response', 'Approved','In Review', 'Awaiting executive approval', 'Awaiting finance approval'))
      AND (
          (ihs.statusId IS NULL) OR (ihs.statusId IN 
		  (SELECT t_ist.statusId FROM invoiceStatus t_ist WHERE t_ist.status IN (
		  'Pending','Awaiting executive approval','Awaiting finance approval')) AND ihs.createdAt = latestInv.lsv)
      )
        GROUP BY university.universityName, yearOfFunding
    ) AS latestStatusRequested ON universities.universityName = latestStatusRequested.universityName

    LEFT JOIN (
        SELECT 
    SUM(ua.amount) AS university_total_approved_amount, universityName
		FROM universityApplications ua
		INNER JOIN (
    SELECT applicationId, MAX(createdAt) AS latestStatusDate
    FROM applicationStatusHistory
    GROUP BY applicationId) AS latestStatus ON ua.applicationId = latestStatus.applicationId
		INNER JOIN applicationStatusHistory ash ON ua.applicationId = ash.applicationId 
		AND ash.createdAt = latestStatus.latestStatusDate
		INNER JOIN applicationStatus ast ON ash.statusId = ast.statusId
		INNER JOIN (
    SELECT applicationId, MAX(createdAt) AS lsv
    FROM invoiceStatusHistory 
    WHERE statusId IN (SELECT t_ist.statusId FROM invoiceStatus t_ist WHERE t_ist.status IN ('In Review','Approved'))
    GROUP BY applicationId
	) AS latestInv ON ua.applicationId = latestInv.applicationId
	INNER JOIN universityDepartments AS ud ON ua.universityDepartmentId = ud.universityDepartmentId
	INNER JOIN universities AS university ON ud.universityId = university.universityId
	WHERE university.universityName = @universityName
	AND ua.yearOfFunding = @year
	AND ast.status = 'Approved'
        GROUP BY university.universityName, yearOfFunding
    ) AS latestStatusApproved ON universities.universityName = latestStatusApproved.universityName

    LEFT JOIN (
        SELECT SUM(a.amount) 
		AS university_total_allocation_amount, 
		university.universityName, yearOfFunding
        FROM allocations AS a
        INNER JOIN universityDepartments AS ud ON a.universityDepartmentId = ud.universityDepartmentId
        INNER JOIN universities AS university ON ud.universityId = university.universityId
		WHERE a.yearOfFunding = @year
        GROUP BY university.universityName, yearOfFunding
    ) AS universityTotalAllocation ON universities.universityName = universityTotalAllocation.universityName

    LEFT JOIN (
        SELECT 
        SUM(ua.amount) AS department_total_requested_amount, universityDepartmentName
    FROM universityApplications ua
    INNER JOIN (
        SELECT applicationId, MAX(createdAt) AS latestStatusDate
        FROM applicationStatusHistory
        GROUP BY applicationId
    ) AS latestStatus ON ua.applicationId = latestStatus.applicationId
    INNER JOIN applicationStatusHistory ash ON ua.applicationId = ash.applicationId 
        AND ash.createdAt = latestStatus.latestStatusDate
    INNER JOIN applicationStatus ast ON ash.statusId = ast.statusId
    LEFT JOIN invoiceStatusHistory ihs ON ihs.applicationId = ua.applicationId
    LEFT JOIN (
        SELECT applicationId, MAX(createdAt) AS lsv
        FROM invoiceStatusHistory 
        GROUP BY applicationId
    ) AS latestInv ON ua.applicationId = latestInv.applicationId 
        AND latestInv.lsv = ihs.createdAt
    INNER JOIN universityDepartments AS ud ON ua.universityDepartmentId = ud.universityDepartmentId
    INNER JOIN universities AS university ON ud.universityId = university.universityId
    WHERE university.universityName = @universityName
      AND ua.yearOfFunding = @year
      AND (ast.status IN ('Awaiting student response', 'Approved','In Review', 'Awaiting executive approval', 'Awaiting finance approval'))
      AND (
          (ihs.statusId IS NULL) OR (ihs.statusId IN 
		  (SELECT t_ist.statusId FROM invoiceStatus t_ist WHERE t_ist.status IN (
		  'Pending','Awaiting executive approval','Awaiting finance approval')) AND ihs.createdAt = latestInv.lsv)
      )
        GROUP BY ud.universityDepartmentName, yearOfFunding
    ) AS universityDepartmentsRequested ON universityDepartments.universityDepartmentName = universityDepartmentsRequested.universityDepartmentName

    LEFT JOIN (
        SELECT 
    SUM(ua.amount) AS department_total_approved_amount, universityDepartmentName
		FROM universityApplications ua
		INNER JOIN (
    SELECT applicationId, MAX(createdAt) AS latestStatusDate
    FROM applicationStatusHistory
    GROUP BY applicationId) AS latestStatus ON ua.applicationId = latestStatus.applicationId
		INNER JOIN applicationStatusHistory ash ON ua.applicationId = ash.applicationId 
		AND ash.createdAt = latestStatus.latestStatusDate
		INNER JOIN applicationStatus ast ON ash.statusId = ast.statusId
		INNER JOIN (
    SELECT applicationId, MAX(createdAt) AS lsv
    FROM invoiceStatusHistory 
    WHERE statusId IN (SELECT t_ist.statusId FROM invoiceStatus t_ist WHERE t_ist.status IN ('In Review','Approved'))
    GROUP BY applicationId
	) AS latestInv ON ua.applicationId = latestInv.applicationId
	INNER JOIN universityDepartments AS ud ON ua.universityDepartmentId = ud.universityDepartmentId
	INNER JOIN universities AS university ON ud.universityId = university.universityId
	WHERE university.universityName = @universityName
	AND ua.yearOfFunding = @year
	AND ast.status = 'Approved'
        GROUP BY ud.universityDepartmentName, yearOfFunding
    ) AS universityDepartmentsApproved ON universityDepartments.universityDepartmentName = universityDepartmentsApproved.universityDepartmentName

    WHERE universities.universityName = @universityName
	AND allocations.yearOfFunding = @year
    AND universityDepartments.departmentStatusId = (
	SELECT departmentStatus.departmentStatusId FROM departmentStatus WHERE departmentStatus.departmentStatus='Active')
    GROUP BY universities.universityName,
    universityDepartments.universityDepartmentName, 
    latestStatusRequested.university_total_requested_amount,
    latestStatusApproved.university_total_approved_amount,
    universityTotalAllocation.university_total_allocation_amount,
    universityDepartmentsRequested.department_total_requested_amount,
	universityDepartmentsApproved.department_total_approved_amount;
END;
GO
