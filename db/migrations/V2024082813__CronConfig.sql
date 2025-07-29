-- Find and drop table if it exists
IF EXISTS (SELECT * FROM sys.objects 
WHERE object_id = OBJECT_ID(N'[dbo].[cronConfig]') AND type in (N'U'))
BEGIN
  DROP TABLE cronConfig;
END;

-- Create the table
CREATE TABLE cronConfig (
  [configId] [INT] IDENTITY(1,1) PRIMARY KEY,
  [config] [BIT] NOT NULL
);

-- Add a config value
IF EXISTS(
	SELECT 1 
    FROM INFORMATION_SCHEMA.COLUMNS 
    WHERE TABLE_NAME = 'cronConfig' 
    AND COLUMN_NAME = 'config'
)
BEGIN
    INSERT INTO cronConfig(config)
    VALUES(1)
END;