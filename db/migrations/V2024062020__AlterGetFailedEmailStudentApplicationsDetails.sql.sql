SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
ALTER PROCEDURE [dbo].[GetFailedStudentDetails]
  @applicationGuid NVARCHAR(255)
AS
BEGIN
  SELECT s.email,s.name,ua.applicationGuid, ua.applicationId
  FROM students s
  INNER JOIN universityApplications ua ON s.studentId= ua.studentId
  INNER JOIN applicationStatusHistory ash ON ash.applicationId = ua.applicationId
  INNER JOIN applicationStatus ast ON ash.statusId = ast.statusId
  WHERE ua.applicationGuid = @applicationGuid
    AND ast.status = 'Pending';
END