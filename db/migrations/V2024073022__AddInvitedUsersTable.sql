IF EXISTS (
    SELECT * 
    FROM sys.objects 
    WHERE object_id = OBJECT_ID(N'fk_invitedUsers_university') 
    AND type in (N'F')
)
BEGIN
    ALTER TABLE invitedUsers DROP CONSTRAINT fk_invitedUsers_university;
END;

IF EXISTS (
    SELECT * 
    FROM sys.objects 
    WHERE object_id = OBJECT_ID(N'[dbo].[invitedUsers]') 
    AND type in (N'U')
)
BEGIN
    DROP TABLE [dbo].[invitedUsers];
END;

CREATE TABLE [dbo].[invitedUsers] (
    invitedUsersId INT IDENTITY(1,1) PRIMARY KEY,
    inviterUserId VARCHAR(256) NOT NULL,
    invitedEmail VARCHAR(256) NOT NULL,
	universityId INT NOT NULL,
    createdAt DATETIME NOT NULL DEFAULT GETDATE()
);

 ALTER TABLE invitedUsers
 ADD CONSTRAINT fk_invitedUsers_university
 FOREIGN KEY (universityId)
 REFERENCES universities(universityId)