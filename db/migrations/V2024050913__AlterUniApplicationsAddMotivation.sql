IF NOT EXISTS(SELECT 1 FROM sys.columns
    WHERE Name = N'motivation'
    AND Object_ID = Object_ID(N'[dbo].[universityApplications]'))
BEGIN
    ALTER TABLE universityApplications
    ADD motivation NTEXT DEFAULT '' NULL;
END
