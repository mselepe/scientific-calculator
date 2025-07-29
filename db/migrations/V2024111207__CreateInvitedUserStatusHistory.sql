
 
IF EXISTS (
    SELECT 1
    FROM sys.foreign_keys 
    WHERE name = 'fk_statusHistoryId' 
    AND parent_object_id = OBJECT_ID('invitedUserStatusHistory')
)
BEGIN
    ALTER TABLE invitedUserStatusHistory
    DROP CONSTRAINT fk_statusHistoryId;
END
  DROP TABLE IF EXISTS invitedUserStatus;

  DROP TABLE IF EXISTS invitedUserStatusHistory;

IF NOT EXISTS (
    SELECT 1 
    FROM sys.columns 
    WHERE name = 'invitedStatusHistoryId' 
    AND object_id = OBJECT_ID('invitedUsers')
)
BEGIN
    ALTER TABLE invitedUsers
    ADD invitedStatusHistoryId INT;
END

  CREATE TABLE invitedUserStatus(
  invitedUserStatusId INT IDENTITY(1,1) PRIMARY KEY,
  [status] [VARCHAR](10) NOT NULL,
  [description] [VARCHAR](256) NOT NULL
  );

  INSERT INTO invitedUserStatus(status,description)
  VALUES ('Pending', 'BBD is reviewing the invite'),
  ('Accepted','BBD has approved the invitation'),
  ('Rejected','BBD rejected the user invite')

  CREATE TABLE invitedUserStatusHistory(
  statusHistoryId INT IDENTITY(1,1) PRIMARY KEY,
  createdAt [DATETIME] NOT NULL DEFAULT GETDATE(),
  userId VARCHAR(255) NOT NULL,
  invitedUserStatusId INT NOT NULL
  );

  ALTER TABLE invitedUserStatusHistory
  ADD CONSTRAINT fk_statusHistoryId
  FOREIGN KEY (invitedUserStatusId)
  REFERENCES invitedUserStatus(invitedUserStatusId)




