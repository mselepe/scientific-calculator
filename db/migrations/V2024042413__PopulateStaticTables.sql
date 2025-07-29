-- Populate tables with data

IF EXISTS (SELECT * FROM sys.objects 
WHERE object_id = OBJECT_ID(N'[dbo].[invoiceStatus]') AND type in (N'U'))
BEGIN
    INSERT INTO [dbo].[invoiceStatus] ([status])
    VALUES
            ('Pending'),
            ('In Review'),
            ('Approved');
END;

IF EXISTS (SELECT * FROM sys.objects 
WHERE object_id = OBJECT_ID(N'[dbo].[universityStatus]') AND type in (N'U'))
BEGIN
    INSERT INTO [dbo].[universityStatus] ([status])
    VALUES
            ('Inactive'),
            ('Active');
END;

IF EXISTS (SELECT * FROM sys.objects 
WHERE object_id = OBJECT_ID(N'[dbo].[applicationStatus]') AND type in (N'U'))
BEGIN
    INSERT INTO [dbo].[applicationStatus] ([status], bbdDescription, universityDescription)
    VALUES
            ('Pending', 'Students need to upload documents', 'Application is still to be reviewed by BBD'),
            ('In Review', 'BBD needs to start the review process', 'Application is being reviewed by BBD'),
            ('Approved', 'Application has been successfully reviewed', 'Application is approved by BBD'),
            ('Draft', 'HOD needs to complete the application', 'Application is still to be completed by HOD'),
            ('Removed', 'HOD has removed the application', 'Application has been removed by HOD'),
            ('Awaiting student response', 'Student needs to complete the additional information step', 'Student needs to complete the additional information step'),
            ('Rejected', 'BBD Rejected the application', 'Application has been rejected'),
            ('Email Failed', 'Failed to send the email link to the student.', 'Failed to send the email link to the student.');
END;

IF EXISTS (SELECT * FROM sys.objects 
WHERE object_id = OBJECT_ID(N'[dbo].[races]') AND type in (N'U'))
BEGIN
    INSERT INTO [dbo].[races] (race)
    VALUES
            ('White'),
            ('Black'),
            ('Indian'),
            ('Coloured'),
            ('Asian');
END;

IF EXISTS (SELECT * FROM sys.objects 
WHERE object_id = OBJECT_ID(N'[dbo].[genders]') AND type in (N'U'))
BEGIN
    INSERT INTO [dbo].[genders] (gender)
    VALUES ('Male'),
           ('Female'),
           ('Non-binary'),
           ('Prefer not to say');
END;

IF EXISTS (SELECT * FROM sys.objects 
WHERE object_id = OBJECT_ID(N'[dbo].[universities]') AND type in (N'U'))
BEGIN
    INSERT INTO [dbo].[universities] (universityName, universityStatusId)
    VALUES ('Nelson Mandela University', 1),
           ('University of the Free State', 1),
           ('University of the Witwatersrand', 1),
           ('University of Johannesburg', 1);
END;


IF EXISTS (SELECT * FROM sys.objects 
WHERE object_id = OBJECT_ID(N'[dbo].[faculties]') AND type in (N'U'))
BEGIN
    INSERT INTO [dbo].[faculties] (facultyName)
    VALUES ('Engineering'),
           ('Science');
END;

IF EXISTS (SELECT * FROM sys.objects 
WHERE object_id = OBJECT_ID(N'[dbo].[universityDepartments]') AND type in (N'U'))
BEGIN
    INSERT INTO universityDepartments(universityId, facultyId, universityDepartmentName)
    VALUES (1, 1, 'Computer Engineering'),
           (1, 2, 'Computer Science'),
           (1, 1, 'Electrical Engineering'),
           (2, 1, 'Computer Engineering'),
           (2, 2, 'Computer Science'),
           (2, 1, 'Electrical Engineering'),
           (3, 1, 'Computer Engineering'),
           (3, 2, 'Computer Science'),
           (3, 1, 'Electrical Engineering')
END;

IF EXISTS (SELECT * FROM sys.objects 
WHERE object_id = OBJECT_ID(N'[dbo].[declinedReasons]') AND type in (N'U'))
BEGIN
    INSERT INTO [dbo].[declinedReasons] (reason)
    VALUES
            ('Average is below 65%.'),
            ('Student is currently receiving other funding.'),
            ('Other');
END;
