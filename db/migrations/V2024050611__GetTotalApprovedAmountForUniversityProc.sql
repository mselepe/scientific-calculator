IF EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[GetTotalApprovedAmountForUniversity]') AND type in (N'P', N'PC'))
DROP PROCEDURE [dbo].[GetTotalApprovedAmountForUniversity]
GO
CREATE   PROCEDURE [dbo].[GetTotalApprovedAmountForUniversity]
    @universityName NVARCHAR(100)  
AS
BEGIN
    SET NOCOUNT ON;
    
    DECLARE @currentYear INT;
    SET @currentYear = DATEPART(yyyy,GETDATE())


    SELECT SUM(ua.amount) AS total_approved_amount
    FROM universityApplications ua
    INNER JOIN applicationStatusHistory ash ON ua.applicationId = ash.applicationId
    INNER JOIN applicationStatus ast ON ash.statusId = ast.statusId
    INNER JOIN universityDepartments AS ud ON ua.universityDepartmentId = ud.universityDepartmentId
    INNER JOIN universities AS university ON ud.universityId = university.universityId
    WHERE ast.[status] = 'Approved'
    AND university.universityName = @universityName
    AND ua.yearOfFunding = @currentYear;

END;
GO

