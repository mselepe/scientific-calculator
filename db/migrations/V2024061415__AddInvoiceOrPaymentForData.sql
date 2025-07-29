IF EXISTS (SELECT * FROM sys.objects
WHERE object_id = OBJECT_ID(N'[dbo].[InvoiceOrPaymentFor]') AND type in (N'U'))
BEGIN
    INSERT INTO [dbo].[InvoiceOrPaymentFor] ([for])
    VALUES
            ('tuition'),
            ('accommodation'),
            ('meals'),
            ('other'),
            ('contract');
END;
