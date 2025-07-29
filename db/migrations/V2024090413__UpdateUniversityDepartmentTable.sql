
IF NOT EXISTS (
    SELECT 1 
    FROM INFORMATION_SCHEMA.COLUMNS 
    WHERE TABLE_NAME = 'universityDepartments'
      AND COLUMN_NAME = 'departmentStatusId'
)
BEGIN
    ALTER TABLE [dbo].[universityDepartments]
    ADD [departmentStatusId] INT NOT NULL DEFAULT 1;
END