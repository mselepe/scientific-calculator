IF OBJECT_ID (N'GetDepartmentsAndUniversities', N'IF') IS NOT NULL
    DROP FUNCTION GetDepartmentsAndUniversities;
GO
CREATE FUNCTION GetDepartmentsAndUniversities ()
RETURNS TABLE
AS
RETURN
(
    SELECT universityDepartmentName AS departmentName, universityName 
    FROM universityDepartments
    JOIN universities
    ON universityDepartments.universityId = universities.universityId
);