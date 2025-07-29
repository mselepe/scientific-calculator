IF EXISTS (SELECT * FROM sys.objects 
WHERE object_id = OBJECT_ID(N'[dbo].[questions]') AND type in (N'U'))
BEGIN
    INSERT INTO [dbo].[questions] ([question])
    VALUES
            ('What job do you wish to pursue after you have completed your studies?'),
            ('Have you received or are currently receiving any funding for your studies?'),
            ('Please name the bursary/company that provided you with the bursary.'),
            ('Have you worked professionally in the IT industry before?'),
            ('Where in the IT industry have you worked and what role did you play?'),
            ('Do you have a Github Profile/Portfolio?'),
            ('Please provide a link to your profile.'),
            ('Have you completed any additional courses to your degree?');
END;

IF EXISTS (SELECT * FROM sys.objects 
WHERE object_id = OBJECT_ID(N'[dbo].[questionnaireStatuses]') AND type in (N'U'))
BEGIN
    INSERT INTO [dbo].[questionnaireStatuses] ([status])
    VALUES
            ('Complete'),
            ('Incomplete')
END;