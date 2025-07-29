IF OBJECT_ID('vw_yearlySpending', 'V') IS NOT NULL
	DROP VIEW vw_yearlySpending
GO
CREATE VIEW vw_yearlySpending
AS
SELECT SUM(dbo.allocations.amount) AS amount, 
	dbo.allocations.yearOfFunding [year], dbo.universities.universityName
FROM dbo.allocations 
INNER JOIN dbo.universityDepartments
ON dbo.allocations.universityDepartmentId = dbo.universityDepartments.universityDepartmentId 
INNER JOIN dbo.universities 
ON dbo.universityDepartments.universityId = dbo.universities.universityId
GROUP BY dbo.allocations.yearOfFunding, dbo.universities.universityName