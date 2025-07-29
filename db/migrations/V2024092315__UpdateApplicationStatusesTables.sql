ALTER TABLE invoiceStatus
ALTER COLUMN [status] varchar(50)

IF NOT EXISTS (
    SELECT 1 FROM invoiceStatus WHERE [status] = 'Awaiting finance approval'
)
BEGIN
    INSERT INTO invoiceStatus([status])
    VALUES ('Awaiting finance approval')
END



IF NOT EXISTS (
	SELECT 1 FROM applicationStatus WHERE [status]='Awaiting executive approval'
	)
BEGIN
	INSERT INTO applicationStatus (status,bbdDescription,universityDescription)
	VALUES ('Awaiting executive approval','BBD executive needs to approve the application','Application accepted and will now be reviewed by BBD executives')
END


IF NOT EXISTS (
	SELECT 1 FROM applicationStatus WHERE [status]='Awaiting finance approval'
	)
BEGIN
	INSERT INTO applicationStatus (status,bbdDescription,universityDescription)
	VALUES ('Awaiting finance approval','BBD finance needs to approve the application','Application accepted and will now be reviewed by BBD finance')
END


