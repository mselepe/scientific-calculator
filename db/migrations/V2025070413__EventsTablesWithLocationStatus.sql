IF EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'fk_eventLocationsHistory_locationStatusId') AND type IN (N'F'))
BEGIN
ALTER TABLE eventLocationsHistory DROP CONSTRAINT fk_eventLocationsHistory_locationStatusId;
END;

IF EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'locationStatuses') AND type IN (N'U'))
BEGIN
DROP TABLE locationStatuses;
END;

DROP PROCEDURE IF EXISTS [dbo].[UpdateEventDetails];

IF EXISTS (
    SELECT 1 FROM sys.types
    WHERE is_table_type = 1
      AND name = 'inviteesTVP'
      AND SCHEMA_NAME(schema_id) = 'dbo'
)
DROP TYPE [dbo].[inviteesTVP];
GO

IF EXISTS (
	SELECT 1 FROM sys.types
    WHERE is_table_type = 1
      AND name = 'eventLocationsTVP'
      AND SCHEMA_NAME(schema_id) = 'dbo'
)
DROP TYPE [dbo].[eventLocationsTVP];
GO

IF NOT EXISTS (
    SELECT 1
    FROM sys.columns
    WHERE name = 'allowDietaryRequirements'
      AND object_id = OBJECT_ID(N'events')
)
BEGIN
ALTER TABLE events
  ADD allowDietaryRequirements BIT NOT NULL DEFAULT 0;
END;

IF NOT EXISTS (
    SELECT 1
    FROM sys.columns
    WHERE name = 'allowNotes'
      AND object_id = OBJECT_ID(N'events')
)
BEGIN
ALTER TABLE events
  ADD allowNotes BIT NOT NULL DEFAULT 0;
END;

IF NOT EXISTS (
    SELECT 1
    FROM sys.columns
    WHERE name = 'locationStatusId'
      AND object_id = OBJECT_ID(N'eventLocationsHistory')
)
BEGIN
ALTER TABLE eventLocationsHistory
  ADD locationStatusId INT NOT NULL DEFAULT 1;
END;


CREATE TABLE locationStatuses (
  [locationStatusId] INT IDENTITY(1,1) PRIMARY KEY,
  [statusName] [VARCHAR](50) NOT NULL
);


CREATE TYPE inviteesTVP AS TABLE (
  studentId int,
  inviteCategory VARCHAR(50)
  );

CREATE TYPE eventLocationsTVP AS TABLE (
  locationName VARCHAR(255),
  addressLineOne VARCHAR(255),
  addressLineTwo VARCHAR(255),
  suburb VARCHAR(255),
  city VARCHAR(255),
  code VARCHAR(10),
  locationStatus VARCHAR(50)
  );


IF EXISTS (SELECT * FROM sys.objects
WHERE object_id = OBJECT_ID(N'[dbo].[locationStatuses]') AND type in (N'U'))
BEGIN
    IF NOT EXISTS (SELECT 1 FROM locationStatuses WHERE statusName = 'Confirmed')
BEGIN
INSERT INTO locationStatuses (statusName) VALUES ('Confirmed');
END
    IF NOT EXISTS (SELECT 1 FROM locationStatuses WHERE statusName = 'Revoked')
BEGIN
INSERT INTO locationStatuses (statusName) VALUES ('Revoked');
END
END


ALTER TABLE eventLocationsHistory
ADD CONSTRAINT fk_eventLocationsHistory_locationStatusId
FOREIGN KEY (locationStatusId)
REFERENCES locationStatuses(locationStatusId);
