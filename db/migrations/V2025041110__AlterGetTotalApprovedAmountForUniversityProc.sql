

ALTER PROCEDURE [dbo].[GetTotalApprovedAmountForUniversity]
    @universityName NVARCHAR(100),
	@year INT,
	@bursaryType VARCHAR(20) = NULL,
	@status VARCHAR(20) = 'Approved'
AS
BEGIN
    SET NOCOUNT ON;

    DECLARE @currentYear INT;
    SET @currentYear = DATEPART(yyyy, GETDATE());

WITH LatestApplicationStatus AS (
    SELECT 
        applicationId,
        createdAt,
		statusId,
        ROW_NUMBER() OVER (PARTITION BY applicationId ORDER BY createdAt DESC) AS rn
    FROM applicationStatusHistory
),
LatestInvoiceStatus AS (
    SELECT 
        applicationId,
        createdAt,
		statusId,
        ROW_NUMBER() OVER (PARTITION BY applicationId ORDER BY createdAt DESC) AS rn
    FROM invoiceStatusHistory
    WHERE statusId IN (
        SELECT t_ist.statusId 
        FROM invoiceStatus t_ist 
        WHERE t_ist.status IN ('In Review', 'Approved')
    )
)

SELECT 
    SUM(ua.amount) AS total_approved_amount
FROM universityApplications ua
INNER JOIN bursaryTypes bt on bt.bursaryTypeId = ua.bursaryTypeId
INNER JOIN LatestApplicationStatus las ON ua.applicationId = las.applicationId AND las.rn = 1
INNER JOIN applicationStatus ast ON las.statusId = ast.statusId
INNER JOIN LatestInvoiceStatus liv ON ua.applicationId = liv.applicationId AND liv.rn = 1
INNER JOIN universityDepartments ud ON ua.universityDepartmentId = ud.universityDepartmentId
INNER JOIN universities university ON ud.universityId = university.universityId
WHERE university.universityName = @universityName
  AND ua.yearOfFunding = @year
  AND ast.status = @status
  AND (@bursaryType IS NULL OR bt.bursaryType = @bursaryType);

END;