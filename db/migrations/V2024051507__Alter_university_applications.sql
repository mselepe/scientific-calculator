IF NOT EXISTS (
    SELECT 1
    FROM INFORMATION_SCHEMA.COLUMNS
    WHERE TABLE_NAME = 'universityApplications'
      AND COLUMN_NAME = 'applicationGuid'
)
BEGIN
    ALTER TABLE universityApplications
    ADD applicationGuid VARCHAR(255) NOT NULL DEFAULT NEWID();
END;