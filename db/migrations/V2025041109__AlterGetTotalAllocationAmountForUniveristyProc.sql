ALTER PROCEDURE [dbo].[GetTotalAllocationAmountForUniversity]
    @universityName NVARCHAR(100),
    @year INT = NULL,
	@bursaryType VARCHAR(20) = NULL
AS
BEGIN
    SET NOCOUNT ON;

    DECLARE @currentYear INT;
    SET @currentYear = DATEPART(yyyy, GETDATE());

    SELECT SUM(a.amount) AS total_allocation_amount
    FROM allocations AS a
    INNER JOIN universityDepartments AS ud ON a.universityDepartmentId = ud.universityDepartmentId
    INNER JOIN universities AS university ON ud.universityId = university.universityId
	INNER JOIN bursaryTypes AS bt ON bt.bursaryTypeId = a.bursaryTypeId
    WHERE university.universityName = @universityName
	AND (@bursaryType IS NULL OR bt.bursaryType=@bursaryType)
    AND a.yearOfFunding = ISNULL(@year, @currentYear);
END;