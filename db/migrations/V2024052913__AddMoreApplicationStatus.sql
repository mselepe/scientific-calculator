IF EXISTS (SELECT * FROM sys.objects 
WHERE object_id = OBJECT_ID(N'[dbo].[applicationStatus]') AND type in (N'U'))
BEGIN
    INSERT INTO [dbo].[applicationStatus] ([status], bbdDescription, universityDescription)
    VALUES
            ('Contract failed', 'A contract was returned to BBD incomplete', 'A student returned the contract to BBD incomplete');
END;