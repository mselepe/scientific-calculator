IF OBJECT_ID('vw_activeApplicationsReportDetails', 'V') IS NOT NULL
DROP VIEW vw_activeApplicationsReportDetails
  GO
CREATE VIEW [dbo].[vw_activeApplicationsReportDetails]
AS
SELECT
    universityApplications.applicationId,
    universityApplications.amount,
	universityApplications.degreeDuration,
	studentApplications.yearOfStudy,
    orderedInvoiceStatusHistory.[year],
    studentRace.race,
    studentRace.[name],
    studentRace.surname,
    studentRace.email,
    universitiesDepartments.universityName,
	bursaryTypes.bursaryType
FROM (
    SELECT
        applicationStatusHistoryId,
        applicationId,
        [status],
        ROW_NUMBER() OVER (PARTITION BY applicationId ORDER BY createdAt DESC) AS rowRank,
		YEAR(createdAt) [year]
        FROM applicationStatusHistory
    INNER JOIN applicationStatus
        ON applicationStatusHistory.statusId = applicationStatus.statusId
    WHERE [status] IN ('Approved', 'Active')
) AS orderedApplicationStatusHistory
INNER JOIN (
    SELECT
        invoiceStatusHistoryId,
        applicationId,
        [status],
		YEAR(createdAt) [year],
        ROW_NUMBER() OVER (PARTITION BY applicationId ORDER BY createdAt DESC) AS rowRank
    FROM invoiceStatusHistory
    INNER JOIN invoiceStatus
        ON invoiceStatusHistory.statusId = invoiceStatus.statusId
    WHERE [status] = 'Approved'
) AS orderedInvoiceStatusHistory
    ON orderedApplicationStatusHistory.applicationId = orderedInvoiceStatusHistory.applicationId
INNER JOIN universityApplications
    ON orderedApplicationStatusHistory.applicationId = universityApplications.applicationId
INNER JOIN (
    SELECT studentId, race, [name], surname, email
    FROM students
  INNER JOIN races
    ON students.raceId = races.raceId
) AS studentRace
    ON universityApplications.studentId = studentRace.studentId
INNER JOIN (
    SELECT
      universityName,
      universityDepartmentId
    FROM universities
    INNER JOIN universityDepartments
        ON universities.universityId = universityDepartments.universityId
) AS universitiesDepartments
  ON universityApplications.universityDepartmentId = universitiesDepartments.universityDepartmentId
INNER JOIN studentApplications
	ON universityApplications.applicationId = studentApplications.applicationId
INNER JOIN bursaryTypes
	ON universityApplications.bursaryTypeId = bursaryTypes.bursaryTypeId
WHERE
  orderedApplicationStatusHistory.rowRank = 1 AND orderedInvoiceStatusHistory.rowRank = 1;
GO
