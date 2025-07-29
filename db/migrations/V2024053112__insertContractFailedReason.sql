IF EXISTS (SELECT * FROM sys.objects 
WHERE object_id = OBJECT_ID(N'[dbo].[declinedReasons]') AND type in (N'U'))
BEGIN
    INSERT INTO [dbo].[declinedReasons] (reason)
    VALUES
            ('Contract failed');
END;