SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
ALTER PROCEDURE [dbo].[GetStudentApplicationDetailsByApplicationId]
    @applicationGuid VARCHAR(255)
AS
BEGIN
SELECT TOP 1
    students.studentId AS studentId,
    CONCAT(students.name, ' ', students.surname) AS fullName,
    students.email AS email,
    universities.universityName AS university,
    studentApplications.yearOfStudy AS yearOfStudy,
	universityApplications.yearOfFunding,
    ISNULL(applicationStatus.status, 'Pending') AS status,
    universityApplications.applicationId AS applicationId,
    faculties.facultyName AS faculty,
    MAX(applicationStatusHistory.createdAt) AS lastStatusChangeDate,
    CASE 
        WHEN applicationStatusHistory.statusId <> (SELECT statusId FROM applicationStatus WHERE status = 'Approved') THEN 'Pending'
        ELSE COALESCE(
            (
                SELECT CONVERT(VARCHAR(50), MAX(applicationStatusHistory.createdAt)) 
                FROM applicationStatusHistory 
                WHERE applicationStatusHistory.applicationId = universityApplications.applicationId 
                    AND applicationStatusHistory.statusId = (SELECT statusId FROM applicationStatus WHERE status = 'Approved')
            ),
            'Pending'
        )
    END AS approvedDate,
    CASE 
        WHEN applicationStatusHistory.statusId <> (SELECT statusId FROM applicationStatus WHERE status = 'Approved') THEN 'Pending'
        ELSE COALESCE(
            (
                SELECT CONVERT(VARCHAR(50), MAX(applicationStatusHistory.createdAt)) 
                FROM applicationStatusHistory 
                WHERE applicationStatusHistory.applicationId = universityApplications.applicationId 
                    AND applicationStatusHistory.statusId = (SELECT statusId FROM applicationStatus WHERE status = 'Approved')
            ),
            'Pending'
        )
    END AS commencementDate,
    ISNULL(universityApplications.amount, 0) AS amount,
    ISNULL(universityApplications.dateOfApplication, GETDATE()) AS applicationDate,
    TRY_CAST(CONCAT(
        CASE 
            WHEN CAST(SUBSTRING(students.idNumber, 1, 2) AS int) >= RIGHT(YEAR(GETDATE()), 2) THEN CAST(SUBSTRING(students.idNumber, 1, 2) AS int) + (LEFT(YEAR(GETDATE()), 2)-1)*100
            ELSE CAST(SUBSTRING(students.idNumber, 1, 2) AS int) + (LEFT(YEAR(GETDATE()), 2))*100
        END, 
        '-', 
        CAST(SUBSTRING(students.idNumber, 3, 2) AS int),
        '-', 
        CAST(SUBSTRING(students.idNumber, 5, 2) AS int)
    ) AS DATE) AS dob,
    students.contactNumber AS contactNumber,
    students.streetAddress AS address,
    students.suburb AS suburb,
    students.city AS city,
    students.postalCode AS code,
    students.idDocumentName AS identityDocument,
    studentApplications.academicTranscriptBlobName AS academicTranscript,
    studentApplications.matricCertificateBlobName AS matricCertificate,
    studentApplications.financialStatementBlobName AS financialStatement,
    universityApplications.degreeName AS degree
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
WHERE
    universityApplications.applicationGuid=@applicationGuid
GROUP BY
    students.studentId, CONCAT(students.name, ' ', students.surname), applicationStatus.status, applicationStatusHistory.statusId, amount, contactNumber, universityApplications.degreeName, students.streetAddress, students.suburb, students.city, students.postalCode,universityApplications.yearOfFunding ,students.idDocumentName, studentApplications.academicTranscriptBlobName, studentApplications.matricCertificateBlobName, studentApplications.financialStatementBlobName, universityApplications.dateOfApplication, email, universities.universityName, faculties.facultyName, students.idNumber, yearOfStudy, universityApplications.applicationId
ORDER BY
    yearOfStudy DESC;
END;