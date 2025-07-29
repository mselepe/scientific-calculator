IF EXISTS (SELECT * FROM sys.objects
WHERE object_id = OBJECT_ID(N'[dbo].[applicationStatus]') AND type = (N'U'))
BEGIN
    IF NOT EXISTS (SELECT 1 FROM [dbo].[applicationStatus]
    WHERE [status] = 'Awaiting fund distribution')
    BEGIN
        INSERT INTO [dbo].[applicationStatus] ([status], bbdDescription, universityDescription)
        VALUES ('Awaiting fund distribution', 'BBD needs to distribute funds to the student', 'Funds are to be distributed to the student');
    END;

    IF NOT EXISTS (SELECT 1 FROM [dbo].[applicationStatus]
    WHERE [status] = 'Contract')
    BEGIN
        INSERT INTO [dbo].[applicationStatus] ([status], bbdDescription, universityDescription)
        VALUES ('Contract', 'BBD needs to approve the contract', 'Contract is being reviewed by BBD');
    END;
END;
