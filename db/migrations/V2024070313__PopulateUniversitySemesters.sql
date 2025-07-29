IF EXISTS (SELECT * FROM sys.objects 
WHERE object_id = OBJECT_ID(N'[dbo].[universitySemesters]') AND type in (N'U'))
BEGIN
    INSERT INTO [dbo].[universitySemesters] ([semesterDescription])
    VALUES
            ('First semester'),
            ('Second semester');
END;