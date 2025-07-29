IF EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[GetFundAllocationsData]') AND type in (N'P', N'PC'))
DROP PROCEDURE [dbo].[GetFundAllocationsData]
GO

CREATE PROCEDURE [dbo].[GetFundAllocationsData]
    @universityName NVARCHAR(100),
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
        SELECT SUM(ua.amount) 
		AS university_total_requested_amount,
		university.universityName,
		yearOfFunding

        FROM universityApplications ua
        INNER JOIN (
            SELECT applicationId, MAX(applicationStatusHistory.createdAt) AS latestStatusDate
            FROM applicationStatusHistory
            GROUP BY applicationId
        ) AS latestStatus ON ua.applicationId = latestStatus.applicationId
        INNER JOIN applicationStatusHistory ash ON ua.applicationId = ash.applicationId AND ash.createdAt= latestStatus.latestStatusDate
        INNER JOIN applicationStatus ast ON ash.statusId = ast.statusId
        INNER JOIN universityDepartments AS ud ON ua.universityDepartmentId = ud.universityDepartmentId
        INNER JOIN universities AS university ON ud.universityId = university.universityId
        WHERE NOT (ast.[status] = 'Approved' OR ast.[status] = 'Rejected') 
        AND university.universityName = @universityName
		AND ua.yearOfFunding = @year
        GROUP BY university.universityName, yearOfFunding
    ) AS latestStatusRequested ON universities.universityName = latestStatusRequested.universityName

    LEFT JOIN (
        SELECT SUM(ua.amount) 
		AS university_total_approved_amount, 
		university.universityName, yearOfFunding

        FROM universityApplications ua
        INNER JOIN (
            SELECT applicationId, MAX(applicationStatusHistory.createdAt) AS latestStatusDate
            FROM applicationStatusHistory
            GROUP BY applicationId
        ) AS latestStatus ON ua.applicationId = latestStatus.applicationId
        INNER JOIN applicationStatusHistory ash ON ua.applicationId = ash.applicationId AND ash.createdAt= latestStatus.latestStatusDate
        INNER JOIN applicationStatus ast ON ash.statusId = ast.statusId
        INNER JOIN universityDepartments AS ud ON ua.universityDepartmentId = ud.universityDepartmentId
        INNER JOIN universities AS university ON ud.universityId = university.universityId
        WHERE ast.[status] = 'Approved'
        AND university.universityName = @universityName
		AND ua.yearOfFunding = @year
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
        SELECT SUM(ua.amount) 
		AS department_total_requested_amount, 
		ud.universityDepartmentName, yearOfFunding
        FROM universityApplications ua
        INNER JOIN (
            SELECT applicationId, MAX(applicationStatusHistory.createdAt) AS latestStatusDate
            FROM applicationStatusHistory
            GROUP BY applicationId
        ) AS latestStatus ON ua.applicationId = latestStatus.applicationId
        INNER JOIN applicationStatusHistory ash ON ua.applicationId = ash.applicationId AND ash.createdAt= latestStatus.latestStatusDate
        INNER JOIN applicationStatus ast ON ash.statusId = ast.statusId
        INNER JOIN universityDepartments AS ud ON ua.universityDepartmentId = ud.universityDepartmentId
        INNER JOIN universities AS university ON ud.universityId = university.universityId
        WHERE NOT (ast.[status] = 'Approved' OR ast.[status] = 'Rejected')
        AND university.universityName = @universityName
		AND ua.yearOfFunding = @year
        GROUP BY ud.universityDepartmentName, yearOfFunding
    ) AS universityDepartmentsRequested ON universityDepartments.universityDepartmentName = universityDepartmentsRequested.universityDepartmentName

    LEFT JOIN (
        SELECT SUM(ua.amount) 
		AS department_total_approved_amount, 
		ud.universityDepartmentName, yearOfFunding
        FROM universityApplications ua
        INNER JOIN (
            SELECT applicationId, MAX(applicationStatusHistory.createdAt) AS latestStatusDate
            FROM applicationStatusHistory
            GROUP BY applicationId
        ) AS latestStatus ON ua.applicationId = latestStatus.applicationId
        INNER JOIN applicationStatusHistory ash ON ua.applicationId = ash.applicationId AND ash.createdAt= latestStatus.latestStatusDate
        INNER JOIN applicationStatus ast ON ash.statusId = ast.statusId
        INNER JOIN universityDepartments AS ud ON ua.universityDepartmentId = ud.universityDepartmentId
        INNER JOIN universities AS university ON ud.universityId = university.universityId
        WHERE (ast.[status] = 'Approved') 
        AND university.universityName = @universityName
		AND ua.yearOfFunding = @year
        GROUP BY ud.universityDepartmentName, yearOfFunding
    ) AS universityDepartmentsApproved ON universityDepartments.universityDepartmentName = universityDepartmentsApproved.universityDepartmentName

    WHERE universities.universityName = @universityName
	AND allocations.yearOfFunding = @year
    GROUP BY universities.universityName,
    universityDepartments.universityDepartmentName, 
    latestStatusRequested.university_total_requested_amount,
    latestStatusApproved.university_total_approved_amount,
    universityTotalAllocation.university_total_allocation_amount,
    universityDepartmentsRequested.department_total_requested_amount,
	universityDepartmentsApproved.department_total_approved_amount;
END;
GO
