IF EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'applicationStatus') AND type IN (N'U'))
BEGIN
    IF NOT EXISTS (SELECT 1 FROM applicationStatus WHERE status = 'Terminated')
    BEGIN
        INSERT INTO applicationStatus (status, bbdDescription, universityDescription) VALUES
          ('Terminated', 'BBD terminated the bursary', 'Bursary has been terminated');
    END
END;

IF EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'declinedReasons') AND type IN (N'U'))
BEGIN
    IF NOT EXISTS (SELECT 1 FROM declinedReasons WHERE reason = 'Application is inactive.')
    BEGIN
        INSERT INTO declinedReasons (reason) VALUES ('Application is inactive.');
    END
END
