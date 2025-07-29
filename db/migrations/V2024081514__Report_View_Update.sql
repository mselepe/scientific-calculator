GO
IF OBJECT_ID('applicationsReportView', 'V') IS NOT NULL
    DROP VIEW applicationsReportView;
GO
CREATE VIEW applicationsReportView AS 
SELECT students.name AS [First Name], students.surname AS [Surname], CASE
        WHEN students.titleId = (SELECT titleId FROM titles WHERE title = 'Other') THEN customTitles.customTitle
        ELSE titles.title
    END AS Title,
	students.email AS [Email], students.idNumber AS [ID Number], races.race AS [Race], genders.gender AS [Gender],
	students.idDocumentName AS [ID Url],
	students.contactNumber AS [Contact Number], students.streetAddress AS [Street Address], students.suburb AS [Suburb],
	students.city AS [City], students.postalCode AS [Postal Code], ua.amount AS Amount, ua.averageGrade AS [Average Grade],
	ua.degreeName AS [Degree], ua.yearOfFunding AS [Year of Funding], ua.motivation AS [Application Motivation], ua.dateOfApplication AS [Date of Application],
	universities.universityName AS [University], faculties.facultyName AS [Faculty], ud.universityDepartmentName AS [Department],
	sa.yearOfStudy AS [Year of Study], sa.academicTranscriptBlobName AS [Academic Transcript Url], sa.matricCertificateBlobName AS [Matric Certificate Url], 
	financialStatementBlobName AS [Financial Statement Url],
	sa.citizenship AS [Citizenship], sa.termsAndConditions AS [Agreed to Terms and Conditions], sa.privacyPolicy AS [Read Privacy Policy], 
	applicationStatus.status, applicationStatus.bbdDescription AS [BBD Description], applicationStatus.universityDescription AS [University Description],
	applicationStatusHistory.createdAt AS [Status Date],
	declinedReasons.reason AS [Reason], declinedMotivations.motivation AS [Declined Reason Motivation]
FROM students
INNER JOIN races ON races.raceId=students.raceId
INNER JOIN titles ON titles.titleId=students.titleId
INNER JOIN genders ON genders.genderId=students.genderId
INNER JOIN universityApplications AS ua ON ua.studentId=students.studentId
INNER JOIN universityDepartments AS ud ON ud.universityDepartmentId=ua.universityDepartmentId
INNER JOIN universities ON ud.universityId=universities.universityId
INNER JOIN faculties ON ud.facultyId=faculties.facultyId
INNER JOIN applicationStatusHistory ON applicationStatusHistory.applicationId = ua.applicationId
INNER JOIN (
      SELECT 
          applicationId, 
          MAX(createdAt) AS latestCreatedAt
      FROM 
          applicationStatusHistory 
      GROUP BY 
          applicationId
  ) AS latestStatus 
ON ua.applicationId = latestStatus.applicationId 
    AND latestStatus.latestCreatedAt=applicationStatusHistory.createdAt
INNER JOIN applicationStatus ON applicationStatus.statusId=applicationStatusHistory.statusId
LEFT JOIN studentApplications AS sa ON ua.applicationId = sa.applicationId
LEFT JOIN declinedReasonsHistory ON declinedReasonsHistory.applicationStatusHistoryId=applicationStatusHistory.applicationStatusHistoryId
LEFT JOIN declinedReasons ON declinedReasons.reasonId=declinedReasonsHistory.reasonId
LEFT JOIN declinedMotivations ON declinedMotivations.declinedReasonsHistoryId=declinedReasonsHistory.declinedReasonsHistoryId
LEFT JOIN customTitles ON customTitles.studentId=students.studentId

