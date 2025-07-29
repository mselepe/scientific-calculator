IF EXISTS (SELECT * FROM sys.objects 
WHERE object_id = OBJECT_ID(N'fk_departmentStatusId') AND type in (N'F'))
BEGIN
  ALTER TABLE departmentStatusHistory DROP CONSTRAINT fk_departmentStatusId
END;

IF EXISTS (SELECT * FROM sys.objects 
WHERE object_id = OBJECT_ID(N'unique_status') AND type in (N'F'))
BEGIN
  ALTER TABLE departmentStatus DROP CONSTRAINT unique_status
END;

IF EXISTS (SELECT * FROM sys.objects 
WHERE object_id = OBJECT_ID(N'[dbo].[departmentStatus]') AND type in (N'U'))
BEGIN
  DROP TABLE departmentStatus;
END;

CREATE TABLE departmentStatus([departmentStatusId] [INT] IDENTITY(1,1) PRIMARY KEY, [departmentStatus] VARCHAR(20) NOT NULL, [description] VARCHAR(256) NOT NULL)

ALTER TABLE departmentStatus
ADD CONSTRAINT unique_status UNIQUE (departmentStatus);

INSERT INTO departmentStatus(departmentStatus,description)
values('Active','Department currently being funded by BBD'),
('Removed','Department had been removed from the list of departments funded by BBD'),
('Disabled','Department currently not receiving funds from BBD')
