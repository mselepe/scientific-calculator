IF EXISTS (SELECT * FROM sys.objects 
WHERE object_id = OBJECT_ID(N'[dbo].[students]') AND type in (N'U'))
BEGIN
  ALTER TABLE students
  ALTER COLUMN contactNumber [VARCHAR](12) NOT NULL
END;