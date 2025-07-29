ALTER PROCEDURE [dbo].[GetStudentDetailsForNudging]
    @Year INT,
    @SemesterDescription NVARCHAR(255)
AS
BEGIN
    SELECT
        YEAR(applicationStatusHistory.createdAt) AS year,
        students.[name] + ' ' + students.surname AS fullName,
        students.email AS email,
        universities.universityId AS id,
        universities.universityName AS universityName,
        universityApplications.applicationGuid AS applicationGuid,
        universityApplications.applicationId AS applicationId,
        'Not Exists' AS transcriptExists
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
        AND NOT EXISTS (
            SELECT 1
        FROM academicTranscriptsHistory ath
            INNER JOIN universitySemesters us ON ath.universitySemesterId = us.semesterId
            INNER JOIN studentApplications sa ON sa.studentApplicationId = ath.studentApplicationId
        WHERE sa.applicationId = universityApplications.applicationId
            AND YEAR(ath.createdAt) = @Year
            AND us.semesterDescription = @SemesterDescription
        )
    ORDER BY 
        applicationStatusHistory.createdAt DESC;
END;