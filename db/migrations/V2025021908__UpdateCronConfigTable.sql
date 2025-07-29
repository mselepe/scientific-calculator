-- Find and drop table if it exists
IF EXISTS (SELECT * FROM sys.objects 
WHERE object_id = OBJECT_ID(N'[dbo].[cronConfig]') AND type in (N'U'))
BEGIN
  DROP TABLE cronConfig;
END;

IF EXISTS (SELECT * FROM sys.objects 
WHERE object_id = OBJECT_ID(N'[dbo].[systemConfigurations]') AND type in (N'U'))
BEGIN
  DROP TABLE systemConfigurations;
END;

-- Create the table
CREATE TABLE systemConfigurations (
  [configId] [INT] IDENTITY(1,1) PRIMARY KEY,
  [configType] VARCHAR(12) NOT NULL,
  [config] [BIT] NOT NULL
);

-- Add a config value
IF EXISTS(
	SELECT 1 
    FROM INFORMATION_SCHEMA.COLUMNS 
    WHERE TABLE_NAME = 'systemConfigurations'
)
BEGIN
    INSERT INTO systemConfigurations(config, configType)
    VALUES(1, 'Cron Job'),
          (0, 'Maintenance')
END;
