/****** Object:  StoredProcedure [dbo].[GetTotalAllocationAmountForUniversity]    Script Date: 2024/07/15 12:06:54 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
ALTER PROCEDURE [dbo].[GetTotalAllocationAmountForUniversity]
    @universityName NVARCHAR(100),
    @year INT = NULL
AS
BEGIN
    SET NOCOUNT ON;

    DECLARE @currentYear INT;
    SET @currentYear = DATEPART(yyyy, GETDATE());

    SELECT SUM(a.amount) AS total_allocation_amount
    FROM allocations AS a
    INNER JOIN universityDepartments AS ud ON a.universityDepartmentId = ud.universityDepartmentId
    INNER JOIN universities AS university ON ud.universityId = university.universityId
    WHERE university.universityName = @universityName
    AND a.yearOfFunding = ISNULL(@year, @currentYear);
END;