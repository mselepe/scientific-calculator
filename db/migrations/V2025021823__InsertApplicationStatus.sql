IF NOT EXISTS (SELECT 1 FROM invoiceStatus WHERE status = 'Awaiting fund distribution')
BEGIN
    INSERT INTO invoiceStatus (status)
    VALUES ('Awaiting fund distribution');
END

IF NOT EXISTS (SELECT 1 FROM applicationStatus WHERE status = 'Pending renewal')
BEGIN
    INSERT INTO applicationStatus (status, bbdDescription, universityDescription)
    VALUES ('Pending renewal', 'BBD needs to start the renewal process', 'Application is being reviewed by BBD');
END