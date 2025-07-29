IF NOT EXISTS(SELECT 1 FROM sys.columns
    WHERE Name = N'isDeleted'
    AND Object_ID = Object_ID(N'[dbo].[adminDocuments]'))
BEGIN
   ALTER TABLE adminDocuments
   ADD isDeleted BIT DEFAULT 0;
END