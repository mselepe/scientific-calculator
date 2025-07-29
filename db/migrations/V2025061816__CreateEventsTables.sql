IF EXISTS (SELECT * FROM sys.objects
WHERE object_id = OBJECT_ID(N'fk_eventsEventTypeId') AND type in (N'F'))
BEGIN
  ALTER TABLE events DROP CONSTRAINT fk_eventsEventTypeId;
END;

IF EXISTS (SELECT * FROM sys.objects
WHERE object_id = OBJECT_ID(N'fk_eventsEventStatusId') AND type in (N'F'))
BEGIN
  ALTER TABLE events DROP CONSTRAINT fk_eventsEventStatusId;
END;

IF EXISTS (SELECT * FROM sys.objects
WHERE object_id = OBJECT_ID(N'fk_eventLocationsEventId') AND type in (N'F'))
BEGIN
  ALTER TABLE eventLocations DROP CONSTRAINT fk_eventLocationsEventId;
END;

IF EXISTS (SELECT * FROM sys.objects
WHERE object_id = OBJECT_ID(N'fk_eventLocationsLocationId') AND type in (N'F'))
BEGIN
  ALTER TABLE eventLocations DROP CONSTRAINT fk_eventLocationsLocationId;
END;

IF EXISTS (SELECT * FROM sys.objects
WHERE object_id = OBJECT_ID(N'fk_rsvpsStudentId') AND type in (N'F'))
BEGIN
  ALTER TABLE rsvps DROP CONSTRAINT fk_rsvpsStudentId;
END;

IF EXISTS (SELECT * FROM sys.objects
WHERE object_id = OBJECT_ID(N'fk_rsvpsEventId') AND type in (N'F'))
BEGIN
  ALTER TABLE rsvps DROP CONSTRAINT fk_rsvpsEventId;
END;

IF EXISTS (SELECT * FROM sys.objects
WHERE object_id = OBJECT_ID(N'fk_rsvpsResponseId') AND type in (N'F'))
BEGIN
  ALTER TABLE rsvps DROP CONSTRAINT fk_rsvpsResponseId;
END;

IF EXISTS (SELECT * FROM sys.objects
WHERE object_id = OBJECT_ID(N'fk_rsvpsDietaryRequirementsId') AND type in (N'F'))
BEGIN
  ALTER TABLE rsvps DROP CONSTRAINT fk_rsvpsDietaryRequirementsId;
END;


IF EXISTS (SELECT * FROM sys.objects
WHERE object_id = OBJECT_ID(N'[dbo].[events]') AND type in (N'U'))
BEGIN
  DROP TABLE events;
END;

IF EXISTS (SELECT * FROM sys.objects
WHERE object_id = OBJECT_ID(N'[dbo].[eventStatuses]') AND type in (N'U'))
BEGIN
  DROP TABLE eventStatuses;
END;

IF EXISTS (SELECT * FROM sys.objects
WHERE object_id = OBJECT_ID(N'[dbo].[eventTypes]') AND type in (N'U'))
BEGIN
  DROP TABLE eventTypes;
END;

IF EXISTS (SELECT * FROM sys.objects
WHERE object_id = OBJECT_ID(N'[dbo].[locations]') AND type in (N'U'))
BEGIN
  DROP TABLE locations;
END;

IF EXISTS (SELECT * FROM sys.objects
WHERE object_id = OBJECT_ID(N'[dbo].[eventLocations]') AND type in (N'U'))
BEGIN
  DROP TABLE eventLocations;
END;

IF EXISTS (SELECT * FROM sys.objects
WHERE object_id = OBJECT_ID(N'[dbo].[dietaryRequirements]') AND type in (N'U'))
BEGIN
  DROP TABLE dietaryRequirements;
END;

IF EXISTS (SELECT * FROM sys.objects
WHERE object_id = OBJECT_ID(N'[dbo].[rsvpResponses]') AND type in (N'U'))
BEGIN
  DROP TABLE rsvpResponses;
END;

IF EXISTS (SELECT * FROM sys.objects
WHERE object_id = OBJECT_ID(N'[dbo].[rsvps]') AND type in (N'U'))
BEGIN
  DROP TABLE rsvps;
END;


CREATE TABLE events (
  [eventId] [INT] IDENTITY(1,1) PRIMARY KEY,
  [eventName] [VARCHAR](255) NOT NULL,
  [eventDescription] [VARCHAR](255) NOT NULL,
  [eventImageBlobName] [VARCHAR](255) NOT NULL,
  [eventGuid] [VARCHAR](255) NOT NULL DEFAULT NEWID(),
  [eventTypeId] [INT] NOT NULL,
  [eventStatusId] [INT] NOT NULL,
  [startDate] [DATETIME] NOT NULL,
  [endDate] [DATETIME] NOT NULL,
  [userId] [INT] NOT NULL,
  [createdAt] [DATETIME] NOT NULL DEFAULT GETDATE()
);

CREATE TABLE eventStatuses (
  [eventStatusId] [INT] IDENTITY(1,1) PRIMARY KEY,
  [eventStatus] [VARCHAR](255) NOT NULL
);

CREATE TABLE eventTypes (
  [eventTypeId] [INT] IDENTITY(1,1) PRIMARY KEY,
  [eventTypeName] [VARCHAR](255) NOT NULL
);

CREATE TABLE locations (
  [locationId] [INT] IDENTITY(1,1) PRIMARY KEY,
  [locationName] [VARCHAR](255) NOT NULL,
  [addressLineOne] [VARCHAR](255) NULL,
  [addressLineTwo] [VARCHAR](255) NOT NULL,
  [suburb] [VARCHAR](255) NOT NULL,
  [city] [VARCHAR](255) NOT NULL,
  [code] [VARCHAR](10) NOT NULL
);


CREATE TABLE eventLocations (
  [eventLocationId] [INT] IDENTITY(1,1) PRIMARY KEY,
  [eventId] [INT] NOT NULL,
  [locationId] [INT] NOT NULL,
  [meetingUrl] [VARCHAR](512) NULL
);

CREATE TABLE dietaryRequirements (
  [dietaryRequirementId] [INT] IDENTITY(1,1) PRIMARY KEY,
  [dietaryRequirement] [VARCHAR](255) NOT NULL
);

CREATE TABLE rsvpResponses (
  [responseId] [INT] IDENTITY(1,1) PRIMARY KEY,
  [response] [VARCHAR](255) NOT NULL
);

CREATE TABLE rsvps (
  [rsvpId] [INT] IDENTITY(1,1) PRIMARY KEY,
  [studentId] [INT] NOT NULL,
  [eventId] [INT] NOT NULL,
  [responseId] [INT] NOT NULL,
  [createdAt] [DATETIME] NOT NULL DEFAULT GETDATE(),
  [inviteCategory] [VARCHAR](255) NOT NULL,
  [dietaryRequirementId] [INT] NOT NULL,
  [allergies] [VARCHAR](255) NULL,
  [notes] [VARCHAR](255) NULL
);


ALTER TABLE events
ADD CONSTRAINT fk_eventsEventTypeId
FOREIGN KEY (eventTypeId)
REFERENCES eventTypes(eventTypeId);

ALTER TABLE events
ADD CONSTRAINT fk_eventsEventStatusId
FOREIGN KEY (eventStatusId)
REFERENCES eventStatuses(eventStatusId);

ALTER TABLE eventLocations
ADD CONSTRAINT fk_eventLocationsEventId
FOREIGN KEY (eventId)
REFERENCES events(eventId);

ALTER TABLE eventLocations
ADD CONSTRAINT fk_eventLocationsLocationId
FOREIGN KEY (locationId)
REFERENCES locations(locationId);

ALTER TABLE rsvps
ADD CONSTRAINT fk_rsvpsStudentId
FOREIGN KEY (studentId)
REFERENCES students(studentId);

ALTER TABLE rsvps
ADD CONSTRAINT fk_rsvpsEventId
FOREIGN KEY (eventId)
REFERENCES events(eventId);

ALTER TABLE rsvps
ADD CONSTRAINT fk_rsvpsResponseId
FOREIGN KEY (responseId)
REFERENCES rsvpResponses(responseId);

ALTER TABLE rsvps
ADD CONSTRAINT fk_rsvpsDietaryRequirementsId
FOREIGN KEY (dietaryRequirementId)
REFERENCES dietaryRequirements(dietaryRequirementId);
