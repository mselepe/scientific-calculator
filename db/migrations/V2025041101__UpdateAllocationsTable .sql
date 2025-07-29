IF NOT EXISTS(
SELECT 1 FROM INFORMATION_SCHEMA.COLUMNS
WHERE TABLE_NAME = 'allocations' AND COLUMN_NAME = 'bursaryTypeId'
)
BEGIN
  ALTER TABLE allocations
  ADD bursaryTypeId INT NOT NULL DEFAULT 1;
END

IF EXISTS (SELECT * FROM sys.objects 
WHERE object_id = OBJECT_ID(N'fk_allocation_bursaryTypeId') AND type in (N'F'))
BEGIN
  ALTER TABLE allocations DROP CONSTRAINT fk_allocation_bursaryTypeId;
END;

ALTER TABLE allocations
ADD CONSTRAINT fk_allocation_bursaryTypeId
FOREIGN KEY (bursaryTypeId)
REFERENCES bursaryTypes(bursaryTypeId);