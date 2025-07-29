IF EXISTS (SELECT * FROM sys.objects
WHERE object_id = OBJECT_ID(N'[dbo].[applicationStatus]') AND type = (N'U'))
BEGIN
    IF NOT EXISTS (SELECT 1 FROM [dbo].[applicationStatus]
    WHERE [status] = 'Invoice')
BEGIN
INSERT INTO [dbo].[applicationStatus] ([status], bbdDescription, universityDescription)
VALUES ('Invoice', 'BBD needs to upload the invoice', 'Invoice is being reviewed by BBD');
END;

    IF NOT EXISTS (SELECT 1 FROM [dbo].[applicationStatus]
    WHERE [status] = 'Payment')
BEGIN
INSERT INTO [dbo].[applicationStatus] ([status], bbdDescription, universityDescription)
VALUES ('Payment', 'BBD needs to process payments', 'Payments are being processed by BBD');
END;

	IF NOT EXISTS (SELECT 1 FROM [dbo].[applicationStatus]
    WHERE [status] = 'Active')
BEGIN
INSERT INTO [dbo].[applicationStatus] ([status], bbdDescription, universityDescription)
VALUES ('Active', 'Application is now active', 'Application is now active');
END;
END;