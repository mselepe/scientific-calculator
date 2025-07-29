IF (EXISTS (SELECT * 
    FROM INFORMATION_SCHEMA.TABLES 
    WHERE TABLE_SCHEMA = 'dbo' 
    AND  TABLE_NAME = 'invitedUsers'))
BEGIN
    IF COL_LENGTH('dbo.invitedUsers', 'roleId') IS NULL AND COL_LENGTH('dbo.roles', 'role') IS NOT NULL
	BEGIN
		ALTER TABLE invitedUsers
		ADD roleId INT NOT NULL DEFAULT 3;

		ALTER TABLE invitedUsers
		ADD CONSTRAINT fk_invitedUsersRoleId
		FOREIGN KEY (roleId)
		REFERENCES roles(roleId);
	END

	IF COL_LENGTH('dbo.invitedUsers', 'rankId') IS NULL AND COL_LENGTH('dbo.ranks', 'rank') IS NOT NULL
	BEGIN
		ALTER TABLE invitedUsers
		ADD rankId INT NOT NULL DEFAULT 3;

		ALTER TABLE invitedUsers
		ADD CONSTRAINT fk_invitedUsersRankId
		FOREIGN KEY (rankId)
		REFERENCES ranks(rankId);
	END

	IF COL_LENGTH('dbo.invitedUsers', 'facultyId') IS NULL AND COL_LENGTH('dbo.faculties', 'facultyId') IS NOT NULL
	BEGIN
		ALTER TABLE invitedUsers
		ADD facultyId INT NULL;

		ALTER TABLE invitedUsers
		ADD CONSTRAINT fk_invitedUsersFacultyId
		FOREIGN KEY (facultyId)
		REFERENCES faculties(facultyId);
	END
END

