IF COL_LENGTH('dbo.universities', 'universityName') IS NOT NULL
BEGIN
    IF NOT EXISTS (
        SELECT 1
    FROM [dbo].[universities]
    WHERE universityName = 'BBD'
    )
    BEGIN
        INSERT INTO [dbo].[universities]
            (universityName, universityStatusId, averageToolConfidence)
        VALUES
            ('BBD',
                (SELECT universityStatusId
                FROM universityStatus
                WHERE [status] = 'Active'),
                0)
    END
END;

IF COL_LENGTH('dbo.faculties', 'facultyName') IS NOT NULL
BEGIN
    IF NOT EXISTS (
        SELECT 1
    FROM [dbo].[faculties]
    WHERE facultyName = 'Admin'
    )
    BEGIN
        INSERT INTO [dbo].[faculties]
            (facultyName)
        VALUES
            ('Admin')
    END
END;