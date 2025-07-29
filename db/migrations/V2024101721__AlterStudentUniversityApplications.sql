IF COL_LENGTH('dbo.universityApplications', 'degreeDuration') IS NULL
BEGIN
	ALTER TABLE universityApplications
	ADD degreeDuration INT NOT NULL DEFAULT 0;
END
IF COL_LENGTH('dbo.studentApplications', 'confirmHonors') IS NULL
BEGIN
	ALTER TABLE studentApplications
	ADD confirmHonors VARCHAR(15) NOT NULL DEFAULT 'No';
END