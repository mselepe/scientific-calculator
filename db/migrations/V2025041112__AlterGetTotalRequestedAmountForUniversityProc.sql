
ALTER PROCEDURE [dbo].[GetTotalRequestedAmountForUniversity]
    @universityName NVARCHAR(100),
    @year INT,
	@bursaryType VARCHAR(20) = NULL
AS
BEGIN
    SET NOCOUNT ON;

WITH LatestApplicationStatus AS (
SELECT 
	applicationId,
	statusId,
	createdAt,
	ROW_NUMBER() OVER (PARTITION BY applicationId ORDER BY createdAt DESC) AS rn
FROM applicationStatusHistory
),
LatestInvoiceStatus AS (
SELECT 
    applicationId,
    createdAt,
    ROW_NUMBER() OVER (PARTITION BY applicationId ORDER BY createdAt DESC) AS rn
FROM invoiceStatusHistory
)

SELECT 
    SUM(ua.amount) AS total_requested_amount
FROM universityApplications ua
INNER JOIN LatestApplicationStatus las ON ua.applicationId = las.applicationId AND las.rn = 1
INNER JOIN applicationStatus ast ON las.statusId = ast.statusId
INNER JOIN universityDepartments ud ON ua.universityDepartmentId = ud.universityDepartmentId
INNER JOIN universities university ON ud.universityId = university.universityId
INNER JOIN bursaryTypes bt ON ua.bursaryTypeId = bt.bursaryTypeId
LEFT JOIN LatestInvoiceStatus liv ON ua.applicationId = liv.applicationId AND liv.rn = 1
LEFT JOIN invoiceStatusHistory ihs ON ihs.applicationId = ua.applicationId 
    AND ihs.createdAt = liv.createdAt
WHERE university.universityName = @universityName
  AND (@bursaryType IS NULL OR bt.bursaryType = @bursaryType)
  AND ua.yearOfFunding = @year
  AND ast.status IN ('Awaiting student response', 'Approved', 'In Review', 'Awaiting executive approval', 'Awaiting finance approval')
  AND (
      ihs.statusId IS NULL OR ihs.statusId IN (
          SELECT t_ist.statusId 
          FROM invoiceStatus t_ist 
          WHERE t_ist.status IN ('Pending', 'Awaiting executive approval', 'Awaiting finance approval')
      )
  );

END;