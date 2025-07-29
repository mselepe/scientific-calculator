IF NOT EXISTS(
    SELECT 1 FROM sys.columns 
    WHERE Name = N'averageToolConfidence'
    AND Object_ID = Object_ID(N'dbo.universities')
    )
    BEGIN
        ALTER TABLE universities
        ADD averageToolConfidence BIT DEFAULT(1) NOT NULL;
    END;
	