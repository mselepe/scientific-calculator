
IF OBJECT_ID('dbo.GetLatestApplicationStatusHistory', 'FN') IS NOT NULL
BEGIN
    DROP FUNCTION dbo.GetLatestApplicationStatusHistory;
END
GO

CREATE FUNCTION GetLatestApplicationStatusHistory (
    @userId NVARCHAR(256)
)
RETURNS TABLE
AS
RETURN
(
        SELECT 
            student.name AS name,
            student.surname AS surname,
            applicationStatusHistory.applicationId AS applicationId,
            max(applicationStatusHistory.createdAt) AS lastUpdate

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
            applicationStatusHistory.applicationId IN (
                SELECT applicationId
                FROM [dbo].[applicationStatusHistory]
                WHERE applicationStatusHistory.userId = @userId
                GROUP BY [applicationId]
            )
	GROUP BY
	        student.name,
            student.surname,
            applicationStatusHistory.applicationId
);
