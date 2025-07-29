IF EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[GetFailedStudentDetails]') AND type in (N'P', N'PC'))
DROP PROCEDURE [dbo].[GetFailedStudentDetails]
GO

CREATE PROCEDURE [dbo].[GetFailedStudentDetails]
  @applicationGuid NVARCHAR(255)
AS
BEGIN
  SELECT s.email,s.name,ua.applicationGuid
  FROM students s
  INNER JOIN universityApplications ua ON s.studentId= ua.studentId
  INNER JOIN applicationStatusHistory ash ON ash.applicationId = ua.applicationId
  INNER JOIN applicationStatus ast ON ash.statusId = ast.statusId
  WHERE ua.applicationGuid = @applicationGuid
    AND ast.status = 'Pending';
END
GO