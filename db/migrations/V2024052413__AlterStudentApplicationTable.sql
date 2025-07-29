IF EXISTS (
    SELECT 1 
    FROM INFORMATION_SCHEMA.COLUMNS 
    WHERE TABLE_NAME = 'StudentApplications' 
    AND COLUMN_NAME = 'yearOfStudy'
)
BEGIN
    ALTER TABLE [dbo].[StudentApplications]
    ALTER COLUMN [yearOfStudy] NCHAR(10) NOT NULL;
END;
