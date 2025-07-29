IF NOT EXISTS (
    SELECT 1 FROM invoiceStatus WHERE [status] = 'Awaiting executive approval'
)
BEGIN
    INSERT INTO invoiceStatus([status])
    VALUES ('Awaiting executive approval')
END