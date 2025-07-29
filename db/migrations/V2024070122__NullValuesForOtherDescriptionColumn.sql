IF EXISTS (
    SELECT 1
    FROM sys.columns
    WHERE Name = N'otherDescription'
    AND Object_ID = Object_ID(N'[dbo].[expenses]')
)
BEGIN
    UPDATE [dbo].[expenses]
    SET otherDescription = 'Stipend'
    WHERE otherDescription IS NULL;
END;