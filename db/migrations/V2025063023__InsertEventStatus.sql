IF EXISTS (SELECT * FROM sys.objects
WHERE object_id = OBJECT_ID(N'[dbo].[eventStatuses]') AND type in (N'U'))
BEGIN
  INSERT INTO eventStatuses (eventStatus) VALUES ('Draft');
END;
