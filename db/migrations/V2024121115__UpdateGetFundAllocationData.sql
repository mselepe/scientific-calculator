IF EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[GetFundAllocationsData]') AND type in (N'P', N'PC'))
DROP PROCEDURE [dbo].[GetFundAllocationsData]
GO

CREATE PROCEDURE [dbo].[GetFundAllocationsData]
	@year INT,
	@universityName VARCHAR(256) = NULL 
AS
BEGIN
	SELECT universitiesAndDepartments.departmentName,
		universitiesAndDepartments.universityName,
		universitiesAndDepartments.departmentID,
		universitiesAndDepartments.faculty,
		departmentsTotalAllocations.departmentTotalAllocationAmount,
		departmentsRequestedAmounts.departmentTotalRequestedAmount,
		departmentsApprovedAmounts.departmentTotalApprovedAmount
	FROM(
	(SELECT departmentName, universityName,
			departmentID,faculty
	FROM GetDepartmentsAndUniversities() WHERE @universityName IS NULL OR @universityName= universityName)
	AS universitiesAndDepartments
	
	LEFT JOIN(
		SELECT universityDepartmentName,
			universityName,
			departmentTotalAllocationAmount
		FROM GetDepartmentsTotalAllocations (@year))
		AS departmentsTotalAllocations
	ON universitiesAndDepartments.departmentName = departmentsTotalAllocations.universityDepartmentName 
		AND universitiesAndDepartments.universityName = departmentsTotalAllocations.universityName

	LEFT JOIN(
		SELECT universityDepartmentName,
			universityName,
			departmentTotalRequestedAmount
		FROM GetDepartmentsRequestedAmounts (@year))
		AS departmentsRequestedAmounts
	ON universitiesAndDepartments.departmentName = departmentsRequestedAmounts.universityDepartmentName 
		AND universitiesAndDepartments.universityName = departmentsRequestedAmounts.universityName

	LEFT JOIN(
	SELECT universityDepartmentName,
		universityName,
		departmentTotalApprovedAmount
	FROM GetDepartmentsApprovedAmounts (@year))
	AS departmentsApprovedAmounts
	ON universitiesAndDepartments.departmentName = departmentsApprovedAmounts.universityDepartmentName 
		AND universitiesAndDepartments.universityName = departmentsApprovedAmounts.universityName
	)
END;
GO
