IF NOT EXISTS (
    SELECT 1
    FROM INFORMATION_SCHEMA.COLUMNS
    WHERE TABLE_SCHEMA = 'dbo'
      AND TABLE_NAME = 'invoiceStatusHistory' 
      AND COLUMN_NAME = 'requestedChange'
)
BEGIN
    ALTER TABLE [dbo].[invoiceStatusHistory]
    ADD [requestedChange] NVARCHAR(255) NOT NULL DEFAULT '';
END;
