SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
ALTER PROCEDURE [dbo].[GetGroupedApplicationDetails]
    @universityName NVARCHAR(256) = NULL,
    @year INT = NULL,
    @fullName NVARCHAR(747) = NULL,
    @bursaryType VARCHAR(20) = NULL
AS
BEGIN
    SET NOCOUNT ON;

    ;WITH LatestStudentApplications AS (
  SELECT
    ua.applicationId,
    ua.studentId,
    ua.dateOfApplication,
    ROW_NUMBER() OVER (PARTITION BY ua.studentId ORDER BY ua.dateOfApplication DESC, ua.applicationId DESC) AS rn_student_app
  FROM
    dbo.[universityApplications] AS ua
               ),
               LatestApplicationStatus AS (
     SELECT
               ash.applicationId,
               aps.status,
               ash.userId AS statusChangedByUserId,
               ROW_NUMBER() OVER (PARTITION BY ash.applicationId ORDER BY ash.createdAt DESC, ash.applicationStatusHistoryId DESC) AS rn_status
     FROM
               dbo.[applicationStatusHistory] AS ash
               INNER JOIN
               dbo.[applicationStatus] AS aps ON ash.statusId = aps.statusId
               ),
               LatestInvoiceDetails AS (
     SELECT
               ish.applicationId,
               inv_s.status AS invoiceStatus,
               ish.requestedChange,
               ish.userId AS invoiceStatusChangedByUserId,
               ROW_NUMBER() OVER (PARTITION BY ish.applicationId ORDER BY ish.createdAt DESC, ish.invoiceStatusHistoryId DESC) AS rn_invoice
     FROM
               dbo.[invoiceStatusHistory] AS ish
               INNER JOIN
               dbo.[invoiceStatus] AS inv_s ON ish.statusId = inv_s.statusId
               ),
               LatestApplicationExpenses AS (
     SELECT
               [exp].applicationId,
               [exp].accommodation,
               [exp].meals,
               [exp].other,
               [exp].tuition,
               ROW_NUMBER() OVER (PARTITION BY [exp].applicationId ORDER BY [exp].expensesId DESC) AS rn_expense
     FROM dbo.expenses AS [exp]
               ),
               LatestApplicationNudges AS (
     SELECT
               nh.applicationId,
               nh.createdAt AS lastNudgeTimestamp,
               ROW_NUMBER() OVER (PARTITION BY nh.applicationId ORDER BY nh.createdAt DESC, nh.nudgeHistoryId DESC) AS rn_nudge
     FROM dbo.nudgeHistory AS nh
               ),
               StudentsWithApplicationsInSpecifiedYear AS (
     SELECT studentId
     FROM dbo.[universityApplications] ua_year_filter
     WHERE (@year IS NULL OR ua_year_filter.yearOfFunding = @year)
     GROUP BY studentId
               )

SELECT
  outerUni.universityName,
  outerUni.universityId,
  (
    SELECT
      CONCAT(s.name, ' ', s.surname) AS fullName,
      ua.amount AS amount,
      ua.applicationId AS applicationId,
      ua.applicationGuid AS applicationGuid,
      las.status AS status,
      ua.dateOfApplication AS [date],
  ud.universityId,
  COALESCE(lid.invoiceStatus, 'Invalid') AS invoiceStatus,
      lae.accommodation, lae.meals, lae.other, lae.tuition,
      las.statusChangedByUserId AS approverUserId,
      lid.requestedChange AS changeRequested,
      lid.invoiceStatusChangedByUserId AS changeRequesterUserId,
      lan.lastNudgeTimestamp AS lastEmailSentTime,
      bt.bursaryType,
      ud.universityDepartmentName,
	  u.universityName
FROM
  dbo.[universityApplications] AS ua
INNER JOIN
  dbo.[students] AS s ON ua.studentId = s.studentId
INNER JOIN
  dbo.[universityDepartments] AS ud ON ua.universityDepartmentId = ud.universityDepartmentId
INNER JOIN
  dbo.[universities] AS u ON ud.universityId = u.universityId
INNER JOIN
  dbo.bursaryTypes bt ON bt.bursaryTypeId = ua.bursaryTypeId
INNER JOIN
  LatestApplicationStatus las ON ua.applicationId = las.applicationId AND las.rn_status = 1
LEFT JOIN
  LatestInvoiceDetails lid ON ua.applicationId = lid.applicationId AND lid.rn_invoice = 1
LEFT JOIN
  LatestApplicationExpenses lae ON ua.applicationId = lae.applicationId AND lae.rn_expense = 1
LEFT JOIN
  LatestApplicationNudges lan ON ua.applicationId = lan.applicationId AND lan.rn_nudge = 1
WHERE
  u.universityName = outerUni.universityName
  AND (@fullName IS NULL OR CONCAT(s.name, ' ', s.surname) LIKE '%' + @fullName + '%')
  AND (@bursaryType IS NULL OR bt.bursaryType = @bursaryType)
  AND (
  @year IS NULL OR
  ua.yearOfFunding = @year OR
    (
  @year = YEAR(GETDATE()) AND lid.invoiceStatus = 'Approved' AND ua.yearOfFunding < @year
  )
  )
  AND (
  @year IS NULL OR
  NOT EXISTS (SELECT 1 FROM StudentsWithApplicationsInSpecifiedYear swaisy
  WHERE swaisy.studentId = ua.studentId) OR
  ua.yearOfFunding = @year
  )
ORDER BY
  ua.dateOfApplication DESC
  FOR JSON PATH
  ) AS details
FROM
  (
  SELECT
      u_outer.universityName,
      u_outer.universityId
  FROM
      dbo.[universities] AS u_outer
  WHERE
      (@universityName IS NULL OR @universityName = '' OR u_outer.universityName LIKE '%' + @universityName + '%')
  GROUP BY
      u_outer.universityName, u_outer.universityId
  ) AS outerUni
GROUP BY
  outerUni.universityName, outerUni.universityId;
END;