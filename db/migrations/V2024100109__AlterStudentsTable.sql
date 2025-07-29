
IF NOT EXISTS (
    SELECT 1
FROM INFORMATION_SCHEMA.COLUMNS
WHERE TABLE_NAME = 'students'
    AND COLUMN_NAME = 'profilePictureBlobName'
)
BEGIN
    ALTER TABLE [dbo].[students]
    ADD [profilePictureBlobName] NVARCHAR(255);

    ALTER TABLE [dbo].[students]
    ADD CONSTRAINT DF_profilePictureBlobName 
    DEFAULT 'students/b6a8f294-a214-4a40-87cf-b73a17a125b4.png' FOR [profilePictureBlobName];
END;