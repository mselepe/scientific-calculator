ALTER PROCEDURE [dbo].[GetStudentApplicationDetailsByApplicationId]
    @applicationGuid VARCHAR(256)
AS
BEGIN

WITH LatestTranscriptCTE AS (
    SELECT
        studentApplicationId,
        docBlobName,
        ROW_NUMBER() OVER(PARTITION BY studentApplicationId ORDER BY academicTranscriptsHistoryId DESC) AS rn
    FROM
        academicTranscriptsHistory
),

StatusHistoryAggregates AS (
    SELECT
        ash.applicationId,
        s.status,
        ash.applicationStatusHistoryId,
        ash.createdAt,
        MIN(CASE WHEN s.status = 'In Review' THEN ash.createdAt END) OVER (PARTITION BY ash.applicationId) AS commencementDate,
        MAX(CASE WHEN s.status = 'Approved' THEN ash.createdAt END) OVER (PARTITION BY ash.applicationId) AS approvedDate,
        ROW_NUMBER() OVER (PARTITION BY ash.applicationId ORDER BY ash.createdAt DESC) as rn
    FROM 
        applicationStatusHistory ash
    INNER JOIN 
        applicationStatus s ON ash.statusId = s.statusId
),

InvoiceHistory AS (
    SELECT
        ish.applicationId,
        s.status as inv_status,
        ROW_NUMBER() OVER (PARTITION BY ish.applicationId ORDER BY ish.createdAt DESC) as rn
    FROM 
        invoiceStatusHistory ish
    INNER JOIN 
        invoiceStatus s ON ish.statusId = s.statusId
),

DeclineHistory as (
    SELECT
        drh.applicationStatusHistoryId,
        dr.reason,
        dm.motivation,
        ROW_NUMBER() OVER (PARTITION BY drh.applicationStatusHistoryId ORDER BY drh.declinedReasonsHistoryId DESC) as rn
    FROM
        declinedReasonsHistory AS drh
    INNER JOIN 
        declinedReasons AS dr ON drh.reasonId = dr.reasonId
    INNER JOIN 
        declinedMotivations AS dm ON drh.declinedReasonsHistoryId = dm.declinedReasonsHistoryId
)

SELECT
      s.studentId,
      s.name,
      s.surname,
      s.email,
      s.dateOfBirth,
      u.universityName AS university,
      sa.yearOfStudy,
      ua.yearOfFunding,
      ISNULL(latestStatus.status, 'Pending') AS status,
      inv.inv_status AS invoiceStatus,
      ua.applicationId,
      f.facultyName AS faculty,
      ISNULL(ex.accommodation, 0) AS accommodation,
      ISNULL(ex.tuition, 0) AS tuition,
      ISNULL(ex.meals, 0) AS meals,
      ISNULL(ex.other, 0) AS other,
      ISNULL(ex.otherDescription, '') AS otherDescription,
      FORMAT(latestStatus.createdAt AT TIME ZONE 'UTC' AT TIME ZONE 'South Africa Standard Time', 'MMM dd, yyyy hh:mm tt') AS lastStatusChangeDate,
      ISNULL(FORMAT(latestStatus.approvedDate AT TIME ZONE 'UTC' AT TIME ZONE 'South Africa Standard Time', 'MMM dd, yyyy hh:mm tt'), 'Pending') AS approvedDate,
      FORMAT(latestStatus.commencementDate AT TIME ZONE 'UTC' AT TIME ZONE 'South Africa Standard Time', 'MMM dd, yyyy hh:mm tt') AS commencementDate,
      ISNULL(ua.amount, 0) AS amount,
      ISNULL(FORMAT(ua.dateOfApplication AT TIME ZONE 'UTC' AT TIME ZONE 'South Africa Standard Time', 'MMM dd, yyyy hh:mm tt'), FORMAT(GETDATE() AT TIME ZONE 'UTC' AT TIME ZONE 'South Africa Standard Time', 'MMM dd, yyyy hh:mm tt')) AS applicationDate,
      CASE
          WHEN LEN(s.idNumber) = 13 THEN
              TRY_CAST(CONCAT(
                  CASE
                      WHEN CAST(SUBSTRING(s.idNumber, 1, 2) AS int) >= RIGHT(YEAR(GETDATE()), 2) THEN CAST(SUBSTRING(s.idNumber, 1, 2) AS int) + (LEFT(YEAR(GETDATE()), 2) - 1) * 100
                      ELSE CAST(SUBSTRING(s.idNumber, 1, 2) AS int) + (LEFT(YEAR(GETDATE()), 2)) * 100
                  END,
                  '-',
                  CAST(SUBSTRING(s.idNumber, 3, 2) AS int),
                  '-',
                  CAST(SUBSTRING(s.idNumber, 5, 2) AS int)
              ) AS DATE)
          ELSE NULL
      END AS dob,
      s.contactNumber,
      s.streetAddress AS address,
      s.suburb,
      s.city,
      s.postalCode AS code,
      s.idDocumentName AS identityDocument,
      s.profilePictureBlobName AS profilephoto,
      COALESCE(lt.docBlobName, sa.academicTranscriptBlobName) AS academicTranscript,
      sa.matricCertificateBlobName AS matricCertificate,
      sa.financialStatementBlobName AS financialStatement,
      sa.confirmHonors,
      COALESCE(ua.degreeName,' ') AS degree,
      COALESCE(ua.degreeDuration,-1) AS degreeDuration,
      dh.reason AS reason,
      dh.motivation AS motivation,
      COALESCE(CAST(ua.motivation AS NVARCHAR(max)),' ') AS applicatioMotivation
FROM 
    universityApplications ua
INNER JOIN 
    students s ON ua.studentId = s.studentId
INNER JOIN 
    universityDepartments ud ON ua.universityDepartmentId = ud.universityDepartmentId
INNER JOIN 
    universities u ON ud.universityId = u.universityId
INNER JOIN 
    faculties f ON ud.facultyId = f.facultyId
INNER JOIN
    StatusHistoryAggregates latestStatus ON ua.applicationId = latestStatus.applicationId AND latestStatus.rn = 1
LEFT JOIN 
    studentApplications sa ON ua.applicationId = sa.applicationId
LEFT JOIN
    expenses ex ON ua.applicationId = ex.applicationId
LEFT JOIN 
    InvoiceHistory inv ON ua.applicationId = inv.applicationId AND inv.rn = 1
LEFT JOIN 
    LatestTranscriptCTE lt ON sa.studentApplicationId = lt.studentApplicationId AND lt.rn = 1
LEFT JOIN
    DeclineHistory dh ON latestStatus.applicationStatusHistoryId = dh.applicationStatusHistoryId AND dh.rn = 1
WHERE 
    ua.applicationGuid = @applicationGuid;
END