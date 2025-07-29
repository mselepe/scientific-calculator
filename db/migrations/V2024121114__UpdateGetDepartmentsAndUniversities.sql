SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
ALTER FUNCTION [dbo].[GetDepartmentsAndUniversities] ()
RETURNS TABLE
AS
RETURN
(
    SELECT universityDepartmentName AS departmentName, universityName, universityDepartmentId as departmentID , (SELECT facultyName FROM faculties where facultyId=universityDepartments.facultyId) as faculty
    FROM universityDepartments
    JOIN universities
    ON universityDepartments.universityId = universities.universityId
);