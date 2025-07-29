IF EXISTS (SELECT * FROM sys.objects 
           WHERE object_id = OBJECT_ID(N'[dbo].[expenses]') 
           AND type in (N'U'))
BEGIN
    IF EXISTS (SELECT * FROM sys.columns 
               WHERE object_id = OBJECT_ID(N'[dbo].[expenses]') 
               AND name = 'otherDescription')
    BEGIN
        ALTER TABLE [dbo].[expenses]
        DROP COLUMN otherDescription;
    END
    
    ALTER TABLE [dbo].[expenses]
    ADD otherDescription NVARCHAR(255);
END
