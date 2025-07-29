

ALTER PROCEDURE [dbo].[GetFundAllocationsData]
	@year INT,
	@universityName VARCHAR(256) = NULL,
	@bursaryType VARCHAR(20) = NULL
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
		FROM GetDepartmentsTotalAllocations (@year,@bursaryType))
		AS departmentsTotalAllocations
	ON universitiesAndDepartments.departmentName = departmentsTotalAllocations.universityDepartmentName 
		AND universitiesAndDepartments.universityName = departmentsTotalAllocations.universityName

	LEFT JOIN(
		SELECT universityDepartmentName,
			universityName,
			departmentTotalRequestedAmount
		FROM GetDepartmentsRequestedAmounts (@year,@bursaryType))
		AS departmentsRequestedAmounts
	ON universitiesAndDepartments.departmentName = departmentsRequestedAmounts.universityDepartmentName 
		AND universitiesAndDepartments.universityName = departmentsRequestedAmounts.universityName

	LEFT JOIN(
	SELECT universityDepartmentName,
		universityName,
		departmentTotalApprovedAmount
	FROM GetDepartmentsApprovedAmounts (@year, @bursaryType))
	AS departmentsApprovedAmounts
	ON universitiesAndDepartments.departmentName = departmentsApprovedAmounts.universityDepartmentName 
		AND universitiesAndDepartments.universityName = departmentsApprovedAmounts.universityName
	)
END;