IF EXISTS (SELECT * FROM sys.objects 
WHERE object_id = OBJECT_ID(N'[dbo].[degrees]') AND type in (N'U'))
BEGIN
  DROP TABLE [dbo].[degrees];
END;


CREATE TABLE [dbo].[degrees] (
  [degreeId] [INT] IDENTITY(1,1) PRIMARY KEY,
  [degreeName] [VARCHAR](256) NOT NULL
);

INSERT INTO[dbo].[degrees] (degreeName)
VALUES 
  ('BSC Computer Science'),
  ('BSC Information Systems'),
  ('BSC Information Technology'),
  ('BIT Information Systems'),
  ('BCOM Informatics'),
  ('BSC Game Design'),
  ('BENG Software Engineering'),
  ('BENG Computer Engineering'),
  ('Other');
