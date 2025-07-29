IF EXISTS (
    SELECT 1
    FROM INFORMATION_SCHEMA.COLUMNS
    WHERE TABLE_NAME = 'maxAllocationPerDepartment'
      AND COLUMN_NAME = 'maxAmount'
)
BEGIN
   UPDATE maxAllocationPerDepartment
   SET maxAmount=135000
END;