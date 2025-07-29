DROP PROCEDURE IF EXISTS dbo.UpdateNudgeHistory;
GO

IF EXISTS (
	SELECT 1 FROM sys.types
    WHERE is_table_type = 1
      AND name = 'nudgeHistoryTVP'
      AND SCHEMA_NAME(schema_id) = 'dbo'
)
DROP TYPE [dbo].[nudgeHistoryTVP];
GO

CREATE TYPE nudgeHistoryTVP AS TABLE (
  applicationId INT,
  nudgedEmail VARCHAR(256)
);