SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
ALTER PROCEDURE [dbo].[getApplicationDocuments]
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
	AND a.isDeleted=0
END;