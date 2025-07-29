IF EXISTS (SELECT * FROM sys.objects
WHERE object_id = OBJECT_ID(N'[dbo].[documentTypes]') AND type in (N'U'))
BEGIN
  INSERT INTO [dbo].[documentTypes] ([type])
VALUES ('Contract'),('Invoice'),('Payment')
END;