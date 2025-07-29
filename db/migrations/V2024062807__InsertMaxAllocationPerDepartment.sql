IF NOT EXISTS (SELECT 1 FROM [dbo].[maxAllocationPerDepartment])
BEGIN
    INSERT INTO [dbo].[maxAllocationPerDepartment] ([userId], [minAmount], [maxAmount], [universityDepartmentId], [createdAt])
    VALUES
    ('BBD', 1000, 250000, 2,GETDATE()),
    ('BBD', 1000, 250000, 1,GETDATE()),
    ('BBD', 1000, 250000, 3,GETDATE()),
    ('BBD', 1000, 250000, 4,GETDATE()),
    ('BBD', 1000, 250000, 5,GETDATE()),
    ('BBD', 1000, 250000, 6,GETDATE()),
    ('BBD', 1000, 250000, 7,GETDATE()),
    ('BBD', 1000, 250000, 8,GETDATE()),
    ('BBD', 1000, 250000, 9,GETDATE());
END
