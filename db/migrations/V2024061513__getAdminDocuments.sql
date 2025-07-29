IF EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[getApplicationDocuments]') AND type in (N'P', N'PC'))
DROP PROCEDURE [dbo].[getApplicationDocuments]
GO

CREATE PROCEDURE [dbo].[getApplicationDocuments]
    @applicationGuid VARCHAR(256),
	@documentType VARCHAR(30),
	@status VARCHAR(30)
AS
BEGIN
    SET NOCOUNT ON;

	SELECT * FROM adminDocuments a,applicationStatus s 
	WHERE a.applicationId = (
		SELECT applicationId 
		FROM universityApplications 
		WHERE applicationGuid = @applicationGuid)
	AND a.documentTypeId = (SELECT documentTypeId FROM documentTypes WHERE [type] = @documentType)
	AND s.status = @status
END;
GO