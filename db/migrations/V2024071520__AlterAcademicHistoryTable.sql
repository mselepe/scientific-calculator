IF EXISTS (
    SELECT 1
    FROM INFORMATION_SCHEMA.COLUMNS
    WHERE TABLE_NAME = 'academicTranscriptsHistory'
    AND COLUMN_NAME = 'semesterGradeAverage'
)
BEGIN
   
    ALTER TABLE academicTranscriptsHistory
    ALTER COLUMN semesterGradeAverage NUMERIC(5, 2);
END
