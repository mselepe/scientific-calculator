IF EXISTS (SELECT * FROM sys.objects 
WHERE object_id = OBJECT_ID(N'fk_BursaryType') AND type in (N'F'))
BEGIN
  ALTER TABLE maxStudentAllocationAmount DROP CONSTRAINT fk_BursaryType
END;

IF EXISTS (SELECT * FROM sys.objects 
WHERE object_id = OBJECT_ID(N'fk_AllocatedRole') AND type in (N'F'))
BEGIN
  ALTER TABLE maxStudentAllocationAmount DROP CONSTRAINT fk_AllocatedRole
END;


IF EXISTS (SELECT * FROM sys.objects 
WHERE object_id = OBJECT_ID(N'[dbo].[maxStudentAllocationAmount]') AND type in (N'U'))
BEGIN
  DROP TABLE maxStudentAllocationAmount;
END;

CREATE TABLE maxStudentAllocationAmount(
	maxStudentAllocationAmountId INT IDENTITY (1,1),
	bursaryTypeId INT NOT NULL,
	allocatedForRoleId INT NOT NULL,
	allocatorGuid VARCHAR(255),
	minAmount MONEY NOT NULL,
	maxAmount MONEY NOT NULL,
	createdAt DATETIME NOT NULL DEFAULT GETDATE()
);

ALTER TABLE maxStudentAllocationAmount
ADD CONSTRAINT fk_BursaryType FOREIGN KEY (bursaryTypeId) 
REFERENCES bursaryTypes(bursaryTypeId);

ALTER TABLE maxStudentAllocationAmount
ADD CONSTRAINT fk_AllocatedRole FOREIGN KEY (allocatedForRoleId) 
REFERENCES roles(roleId);

INSERT INTO maxStudentAllocationAmount( bursaryTypeId, allocatedForRoleId, allocatorGuid,minAmount,maxAmount)
VALUES (1, 1, 'Default BBD bursary allocation', 1000,150000),
 (1, 3, 'Default BBD bursary allocation', 1000,135000),
 (2, 1, 'Default BBD bursary allocation', 1000,150000),
 (2, 3, 'Default BBD bursary allocation', 1000,135000)




