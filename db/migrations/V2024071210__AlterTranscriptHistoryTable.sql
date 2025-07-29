IF EXISTS (
    SELECT 1
    FROM INFORMATION_SCHEMA.COLUMNS
    WHERE TABLE_NAME = 'academicTranscriptsHistory'
    AND COLUMN_NAME = 'yearOfStudy'
)
BEGIN
   
    ALTER TABLE academicTranscriptsHistory
    ALTER COLUMN yearOfStudy VARCHAR(10);
END
