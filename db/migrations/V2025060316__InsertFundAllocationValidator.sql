IF EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[maxStudentAllocationAmount]') AND type = N'U')
    BEGIN
        IF NOT EXISTS (SELECT 1 FROM maxStudentAllocationAmount WHERE allocatorGuid = 'Fund allocation')
        BEGIN
        INSERT INTO maxStudentAllocationAmount (bursaryTypeId, allocatedForRoleId, allocatorGuid, minAmount, maxAmount)
        VALUES
            (
              (SELECT TOP 1 bursaryTypeId FROM bursaryTypes WHERE bursaryType = 'Ukukhula'),
              (SELECT TOP 1 roleId FROM roles WHERE role = 'admin'),
              'Fund allocation',
              0,
              3000000
            ),
            (
              (SELECT TOP 1 bursaryTypeId FROM bursaryTypes WHERE bursaryType = 'BBD'),
              (SELECT TOP 1 roleId FROM roles WHERE role = 'admin'),
              'Fund allocation',
              0,
              3000000
            )
    END
END;
