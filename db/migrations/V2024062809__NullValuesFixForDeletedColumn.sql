IF EXISTS (
    SELECT 1
    FROM sys.columns
    WHERE Name = N'isDeleted'
    AND Object_ID = Object_ID(N'[dbo].[adminDocuments]')
)
BEGIN
    UPDATE [dbo].[adminDocuments]
    SET isDeleted = 0
    WHERE isDeleted IS NULL;
END