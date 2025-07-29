IF EXISTS (SELECT *
FROM sys.objects
WHERE object_id = OBJECT_ID(N'[dbo].[applicationStatus]') AND type in (N'U'))
BEGIN
    INSERT INTO [dbo].[applicationStatus]
        ([status], [bbdDescription], [universityDescription])
    SELECT 'Stagnant application ', 'Student failed to complete the additional information step', 'Student failed to complete the additional information step'
    WHERE NOT EXISTS (
    SELECT 1
    FROM [dbo].[applicationStatus]
    WHERE [status] = 'Stagnant application '
        AND [bbdDescription] = 'Student failed to complete the additional information step'
        AND [universityDescription] = 'Student failed to complete the additional information step'
);
END;


