IF EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[GetStudentDetailsForNudging]') AND type in (N'P', N'PC'))
DROP PROCEDURE[dbo].[GetStudentDetailsForNudging]
GO

CREATE PROCEDURE[dbo].[GetStudentDetailsForNudging]
    @Year INT,
    @SemesterDescription NVARCHAR(255)
AS
BEGIN
    SELECT TOP 2
        YEAR(applicationStatusHistory.createdAt) AS year,
        students.[name] + ' ' + students.surname AS fullName,
        students.email AS email,
        universities.universityId AS id,
        universities.universityName AS universityName,
        universityApplications.applicationGuid AS applicationGuid,
        universityApplications.applicationId AS applicationId,
        CASE
            WHEN EXISTS (
                SELECT 1
                FROM academicTranscriptsHistory ath
                INNER JOIN universitySemesters us ON ath.universitySemesterId = us.semesterId
                WHERE ath.studentApplicationId = universityApplications.applicationId
                AND ath.yearOfStudy = @Year
                AND us.semesterDescription = @SemesterDescription
            ) THEN 'Exists'
            ELSE 'Not Exists'
        END AS transcriptExists
    FROM 
        universityApplications
    INNER JOIN 
        applicationStatusHistory ON universityApplications.applicationId = applicationStatusHistory.applicationId
    INNER JOIN 
        universityDepartments ON universityApplications.universityDepartmentId = universityDepartments.universityDepartmentId
    INNER JOIN 
        students ON universityApplications.studentId = students.studentId
    INNER JOIN 
        universities ON universityDepartments.universityId = universities.universityId
    INNER JOIN 
        applicationStatus ON applicationStatusHistory.statusId = applicationStatus.statusId
    INNER JOIN 
        (
            SELECT 
                ish.applicationId,
                ish.statusId,
                ish.createdAt
            FROM 
                invoiceStatusHistory AS ish
            INNER JOIN 
                (
                    SELECT 
                        applicationId,
                        MAX(createdAt) AS latestInvCreatedAt
                    FROM 
                        invoiceStatusHistory
                    GROUP BY 
                        applicationId
                ) AS latest_inv ON ish.applicationId = latest_inv.applicationId AND ish.createdAt = latest_inv.latestInvCreatedAt
            INNER JOIN 
                invoiceStatus ON ish.statusId = invoiceStatus.statusId
            WHERE 
                invoiceStatus.status = 'Approved'
        ) AS latest_inv ON universityApplications.applicationId = latest_inv.applicationId
    WHERE 
        applicationStatus.[status] = 'Approved'
        AND applicationStatusHistory.createdAt = (
            SELECT MAX(createdAt)
            FROM applicationStatusHistory AS ash
            WHERE ash.applicationId = universityApplications.applicationId
        )
    ORDER BY 
        year DESC;
END;
