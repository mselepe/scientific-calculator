/*Create roles and ranks tables*/

-- Drop constraints
IF EXISTS (SELECT * FROM sys.objects 
WHERE object_id = OBJECT_ID(N'fk_invitedUsersRoleId') AND type in (N'F'))
BEGIN
  ALTER TABLE invitedUsers DROP CONSTRAINT fk_invitedUsersRoleId;
END;

IF EXISTS (SELECT * FROM sys.objects 
WHERE object_id = OBJECT_ID(N'fk_invitedUsersRankId') AND type in (N'F'))
BEGIN
  ALTER TABLE invitedUsers DROP CONSTRAINT fk_invitedUsersRankId;
END;

IF EXISTS (SELECT * FROM sys.objects 
WHERE object_id = OBJECT_ID(N'fk_invitedUsersDepartmentsInvitedUserId') AND type in (N'F'))
BEGIN
  ALTER TABLE invitedUsersDepartments DROP CONSTRAINT fk_invitedUsersDepartmentsInvitedUserId;
END;

-- Drop table
IF EXISTS (SELECT * FROM sys.objects 
WHERE object_id = OBJECT_ID(N'[dbo].[roles]') AND type in (N'U'))
BEGIN
  DROP TABLE roles;
END;

IF EXISTS (SELECT * FROM sys.objects 
WHERE object_id = OBJECT_ID(N'[dbo].[ranks]') AND type in (N'U'))
BEGIN
  DROP TABLE ranks;
END;

IF EXISTS (SELECT * FROM sys.objects 
WHERE object_id = OBJECT_ID(N'[dbo].[invitedUsersDepartments]') AND type in (N'U'))
BEGIN
  DROP TABLE invitedUsersDepartments;
END;

-- Create tables

CREATE TABLE roles (
  [roleId] [INT] IDENTITY(1,1) PRIMARY KEY,
  [role] [VARCHAR](10) NOT NULL,
  CONSTRAINT ak_role UNIQUE([role]) 
);

CREATE TABLE ranks (
  [rankId] [INT] IDENTITY(1,1) PRIMARY KEY,
  [rank] [VARCHAR](20) NOT NULL,
  CONSTRAINT ak_rank UNIQUE([rank])
);

CREATE TABLE invitedUsersDepartments (
  [invitedUsersDepartmentId] [INT] IDENTITY(1,1) PRIMARY KEY,
  [invitedUserId] INT NOT NULL,
  [universityDepartmentId] INT NOT NULL
);

-- Insert into roles and ranks

IF EXISTS (SELECT * FROM sys.objects 
WHERE object_id = OBJECT_ID(N'[dbo].[roles]') AND type in (N'U'))
BEGIN
    INSERT INTO [dbo].[roles] ([role])
    VALUES
      ('admin'),
			('dean'),
			('HOD'),
			('student')
END;

IF EXISTS (SELECT * FROM sys.objects 
WHERE object_id = OBJECT_ID(N'[dbo].[ranks]') AND type in (N'U'))
BEGIN
    INSERT INTO [dbo].[ranks] ([rank])
    VALUES
      ('admin_officer'),
			('assistant_admin'),
			('no_rank'),
			('senior_admin'),
      ('dual_admin'),
      ('chief_admin')
END;

-- Add constraint
ALTER TABLE invitedUsersDepartments
ADD CONSTRAINT fk_invitedUsersDepartmentsInvitedUserId
FOREIGN KEY (invitedUserId)
REFERENCES invitedUsers(invitedUsersId);
