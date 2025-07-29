
ALTER PROCEDURE [dbo].[GetStudentApplicationDetailsByApplicationId]
    @applicationGuid VARCHAR(256)
AS
BEGIN
    SELECT TOP 1
        students.studentId AS studentId,
        CONCAT(students.name, ' ', students.surname) AS fullName,
        students.email AS email,
        students.dateOfBirth AS dateOfBirth,
        universities.universityName AS university,
        studentApplications.yearOfStudy AS yearOfStudy,
        universityApplications.yearOfFunding,
        ISNULL(applicationStatus.status, 'Pending') AS status,
        latest_inv.inv_status AS invoiceStatus,
        universityApplications.applicationId AS applicationId,
        faculties.facultyName AS faculty,
        ISNULL(expenses.accommodation, 0) AS accommodation,
        ISNULL(expenses.tuition, 0) AS tuition,
        ISNULL(expenses.meals, 0) AS meals,
        ISNULL(expenses.other, 0) AS other,
        ISNULL(expenses.otherDescription, '') AS otherDescription,
        FORMAT(MAX(applicationStatusHistory.createdAt) AT TIME ZONE 'UTC' AT TIME ZONE 'South Africa Standard Time', 'MMM dd, yyyy hh:mm tt') AS lastStatusChangeDate,
        CASE 
        WHEN applicationStatusHistory.statusId <> (SELECT statusId
        FROM applicationStatus
        WHERE status = 'Approved') THEN 'Pending'
        ELSE COALESCE(
            (
                SELECT FORMAT(MAX(applicationStatusHistory.createdAt) AT TIME ZONE 'UTC' AT TIME ZONE 'South Africa Standard Time', 'MMM dd, yyyy hh:mm tt') 
                FROM applicationStatusHistory 
                WHERE applicationStatusHistory.applicationId = universityApplications.applicationId 
                    AND applicationStatusHistory.statusId = (SELECT statusId FROM applicationStatus WHERE status = 'Approved')
            ),
            'Pending'
        )
    END AS approvedDate,
        (
        SELECT FORMAT(MIN(createdAt AT TIME ZONE 'UTC' AT TIME ZONE 'South Africa Standard Time'), 'MMM dd, yyyy hh:mm tt')
        FROM applicationStatusHistory
        WHERE applicationId = universityApplications.applicationId
            AND statusId = (SELECT statusId
            FROM applicationStatus
            WHERE status = 'In Review')
    ) AS commencementDate,
        ISNULL(universityApplications.amount, 0) AS amount,
        ISNULL(FORMAT(universityApplications.dateOfApplication AT TIME ZONE 'UTC' AT TIME ZONE 'South Africa Standard Time', 'MMM dd, yyyy hh:mm tt'), FORMAT(GETDATE() AT TIME ZONE 'UTC' AT TIME ZONE 'South Africa Standard Time', 'MMM dd, yyyy hh:mm tt')) AS applicationDate,
        CASE
        WHEN LEN(students.idNumber) = 13 THEN 
            TRY_CAST(CONCAT(
                CASE 
                    WHEN CAST(SUBSTRING(students.idNumber, 1, 2) AS int) >= RIGHT(YEAR(GETDATE()), 2) THEN CAST(SUBSTRING(students.idNumber, 1, 2) AS int) + (LEFT(YEAR(GETDATE()), 2) - 1) * 100
                    ELSE CAST(SUBSTRING(students.idNumber, 1, 2) AS int) + (LEFT(YEAR(GETDATE()), 2)) * 100
                END, 
                '-', 
                CAST(SUBSTRING(students.idNumber, 3, 2) AS int),
                '-', 
                CAST(SUBSTRING(students.idNumber, 5, 2) AS int)
            ) AS DATE)
        ELSE NULL
    END AS dob,
        students.contactNumber AS contactNumber,
        students.streetAddress AS address,
        students.suburb AS suburb,
        students.city AS city,
        students.postalCode AS code,
        students.idDocumentName AS identityDocument,
        students.profilePictureBlobName As profilephoto,
        studentApplications.academicTranscriptBlobName AS academicTranscript,
        studentApplications.matricCertificateBlobName AS matricCertificate,
        studentApplications.financialStatementBlobName AS financialStatement,
        universityApplications.degreeName AS degree,
        declinedReasonsHistory.reason,
        declinedReasonsHistory.motivation,
        CAST(universityApplications.motivation AS NVARCHAR(max)) AS applicatioMotivation
    FROM
        students
        LEFT JOIN universityApplications ON students.studentId = universityApplications.studentId
        LEFT JOIN universityDepartments ON universityApplications.universityDepartmentId = universityDepartments.universityDepartmentId
        LEFT JOIN universities ON universityDepartments.universityId = universities.universityId
        LEFT JOIN faculties ON universityDepartments.facultyId = faculties.facultyId
        LEFT JOIN (
    SELECT
            applicationId,
            MAX(createdAt) AS latestCreatedAt
        FROM
            applicationStatusHistory
        GROUP BY 
        applicationId
) AS latestStatus ON universityApplications.applicationId = latestStatus.applicationId
        LEFT JOIN applicationStatusHistory ON applicationStatusHistory.applicationId = latestStatus.applicationId AND applicationStatusHistory.createdAt = latestStatus.latestCreatedAt
        LEFT JOIN studentApplications ON applicationStatusHistory.applicationId = studentApplications.applicationId
        LEFT JOIN applicationStatus ON applicationStatus.statusId = applicationStatusHistory.statusId
        LEFT JOIN (
    SELECT ish.applicationId, (SELECT status
            FROM invoiceStatus
            WHERE invoiceStatus.statusId = ish.statusId) as inv_status, ish.statusId, ish.createdAt AS invCreatedAt
        FROM invoiceStatusHistory AS ish
            INNER JOIN (
        SELECT applicationId, MAX(createdAt) AS latestInvCreatedAt
            FROM invoiceStatusHistory
            GROUP BY applicationId
    ) AS latest_inv ON ish.applicationId = latest_inv.applicationId AND ish.createdAt = latest_inv.latestInvCreatedAt
) AS latest_inv ON latestStatus.applicationId = latest_inv.applicationId
        LEFT JOIN expenses ON universityApplications.applicationId = expenses.applicationId
OUTER APPLY (
    SELECT TOP 1
            dr.reason,
            dm.motivation
        FROM
            declinedReasonsHistory AS drh
            INNER JOIN declinedReasons AS dr ON drh.reasonId = dr.reasonId
            INNER JOIN declinedMotivations AS dm ON drh.declinedReasonsHistoryId = dm.declinedReasonsHistoryId
        WHERE
        drh.applicationStatusHistoryId = applicationStatusHistory.applicationStatusHistoryId
        ORDER BY
        drh.declinedReasonsHistoryId DESC 
) AS declinedReasonsHistory
    WHERE
    universityApplications.applicationGuid = @applicationGuid
    GROUP BY
    students.studentId, CONCAT(students.name, ' ', students.surname), latest_inv.inv_status, applicationStatus.status, applicationStatusHistory.statusId, amount, 
    contactNumber, universityApplications.degreeName, students.streetAddress, students.suburb, students.city, students.postalCode,
    universityApplications.yearOfFunding, students.idDocumentName,students.profilePictureBlobName,studentApplications.academicTranscriptBlobName,
    studentApplications.matricCertificateBlobName, studentApplications.financialStatementBlobName, universityApplications.dateOfApplication, 
    email, universities.universityName, faculties.facultyName, students.idNumber, yearOfStudy, universityApplications.applicationId,
    declinedReasonsHistory.reason, declinedReasonsHistory.motivation, expenses.accommodation, expenses.tuition, expenses.meals, expenses.other, expenses.otherDescription, dateOfBirth,	CAST(universityApplications.motivation AS NVARCHAR(max))
    ORDER BY
    yearOfStudy DESC;
END
