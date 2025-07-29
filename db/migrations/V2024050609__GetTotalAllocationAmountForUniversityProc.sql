IF EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[GetTotalAllocationAmountForUniversity]') AND type in (N'P', N'PC'))
DROP PROCEDURE [dbo].[GetTotalAllocationAmountForUniversity]
GO
CREATE PROCEDURE [dbo].[GetTotalAllocationAmountForUniversity]
    @universityName NVARCHAR(100)
AS
BEGIN
    SET NOCOUNT ON;

    DECLARE @currentYear INT;
    SET @currentYear = DATEPART(yyyy,GETDATE())

    SELECT SUM(a.amount) AS total_allocation_amount
    FROM allocations AS a
    INNER JOIN universityDepartments AS ud ON a.universityDepartmentId = ud.universityDepartmentId
    INNER JOIN universities AS university ON ud.universityId = university.universityId
    WHERE university.universityName = @universityName
    AND a.yearOfFunding = @currentYear;
END;


GO

