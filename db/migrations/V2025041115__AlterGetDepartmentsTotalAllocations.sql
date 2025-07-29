
ALTER FUNCTION [dbo].[GetDepartmentsTotalAllocations] (@year INT, @bursaryType VARCHAR(20) = NULL)
RETURNS TABLE
AS
RETURN
(
    SELECT SUM(amount) AS departmentTotalAllocationAmount,
	universityDepartmentName,
	universityName
    FROM allocations
	INNER JOIN bursaryTypes ON allocations.bursaryTypeId = bursaryTypes.bursaryTypeId
    INNER JOIN universityDepartments
    ON allocations.universityDepartmentId = universityDepartments.universityDepartmentId
    INNER JOIN universities
    ON universityDepartments.universityId = universities.universityId
    WHERE yearOfFunding = @year AND (@bursaryType IS NULL OR bursaryTypes.bursaryType = @bursaryType)
    GROUP BY universityDepartmentName, universityName 
);