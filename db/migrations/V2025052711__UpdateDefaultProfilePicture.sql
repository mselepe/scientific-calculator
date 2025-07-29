IF EXISTS (SELECT * FROM sys.objects 
WHERE object_id = OBJECT_ID(N'DF_profilePictureBlobName') AND type in (N'F'))
BEGIN
  ALTER TABLE students DROP CONSTRAINT DF_profilePictureBlobName;
END;

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
    DEFAULT 'students/DEFAULT_PROFILE_PICTURE.png' FOR [profilePictureBlobName];
END;