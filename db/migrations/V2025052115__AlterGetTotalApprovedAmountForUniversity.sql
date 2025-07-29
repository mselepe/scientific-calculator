ALTER PROCEDURE [dbo].[GetTotalApprovedAmountForUniversity]
    @universityName NVARCHAR(100),
    @year INT,
    @bursaryType VARCHAR(20) = NULL
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
    )
    SELECT
      SUM(ua.amount) AS total_approved_amount
    FROM universityApplications ua
        INNER JOIN bursaryTypes bt ON bt.bursaryTypeId = ua.bursaryTypeId
        INNER JOIN LatestApplicationStatus las ON ua.applicationId = las.applicationId AND las.rn = 1
        INNER JOIN applicationStatus ast ON las.statusId = ast.statusId
        INNER JOIN universityDepartments ud ON ua.universityDepartmentId = ud.universityDepartmentId
        INNER JOIN universities university ON ud.universityId = university.universityId
    WHERE university.universityName = @universityName
        AND ua.yearOfFunding = @year
        AND ast.status IN ('Approved', 'Invoice', 'Payment', 'Active')
        AND (@bursaryType IS NULL OR bt.bursaryType = @bursaryType);
END;
