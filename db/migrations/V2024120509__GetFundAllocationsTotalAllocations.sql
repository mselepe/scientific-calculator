IF OBJECT_ID (N'GetDepartmentsTotalAllocations', N'IF') IS NOT NULL
    DROP FUNCTION GetDepartmentsTotalAllocations;
GO
CREATE FUNCTION GetDepartmentsTotalAllocations (@year INT)
RETURNS TABLE
AS
RETURN
(
    SELECT SUM(amount) AS departmentTotalAllocationAmount,
	universityDepartmentName,
	universityName
    FROM allocations
    JOIN universityDepartments
    ON allocations.universityDepartmentId = universityDepartments.universityDepartmentId
    JOIN universities
    ON universityDepartments.universityId = universities.universityId
    WHERE yearOfFunding = @year
    GROUP BY universityDepartmentName, universityName 
);