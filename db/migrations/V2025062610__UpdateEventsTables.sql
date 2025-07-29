-- Drop Constraints

IF EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'fk_eventsEventTypeId') AND type in (N'F'))
BEGIN
ALTER TABLE events DROP CONSTRAINT fk_eventsEventTypeId;
END;

IF EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'fk_eventsEventStatusId') AND type in (N'F'))
BEGIN
ALTER TABLE events DROP CONSTRAINT fk_eventsEventStatusId;
END;

IF EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'fk_eventLocationsEventId') AND type in (N'F'))
BEGIN
ALTER TABLE eventLocations DROP CONSTRAINT fk_eventLocationsEventId;
END;

IF EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'fk_eventLocationsLocationId') AND type in (N'F'))
BEGIN
ALTER TABLE eventLocations DROP CONSTRAINT fk_eventLocationsLocationId;
END;

IF EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'fk_rsvpsStudentId') AND type in (N'F'))
BEGIN
ALTER TABLE rsvps DROP CONSTRAINT fk_rsvpsStudentId;
END;

IF EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'fk_rsvpsEventId') AND type in (N'F'))
BEGIN
ALTER TABLE rsvps DROP CONSTRAINT fk_rsvpsEventId;
END;

IF EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'fk_rsvpsResponseId') AND type in (N'F'))
BEGIN
ALTER TABLE rsvps DROP CONSTRAINT fk_rsvpsResponseId;
END;

IF EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'fk_rsvpsDietaryRequirementsId') AND type in (N'F'))
BEGIN
ALTER TABLE rsvps DROP CONSTRAINT fk_rsvpsDietaryRequirementsId;
END;

IF EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'fk_eventLocations_eventId') AND type IN (N'F'))
BEGIN
ALTER TABLE eventLocations DROP CONSTRAINT fk_eventLocations_eventId;
END;

IF EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'fk_eventLocations_locationId') AND type IN (N'F'))
BEGIN
ALTER TABLE eventLocations DROP CONSTRAINT fk_eventLocations_locationId;
END;

IF EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'fk_eventsStatusHistory_eventStatusId') AND type IN (N'F'))
BEGIN
ALTER TABLE eventsStatusHistory DROP CONSTRAINT fk_eventsStatusHistory_eventStatusId;
END;

IF EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'fk_events_eventTypeId') AND type IN (N'F'))
BEGIN
ALTER TABLE events DROP CONSTRAINT fk_events_eventTypeId;
END;

IF EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'fk_rsvps_studentId') AND type IN (N'F'))
BEGIN
ALTER TABLE rsvps DROP CONSTRAINT fk_rsvps_studentId;
END;

IF EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'fk_rsvps_dietaryRequirementId') AND type IN (N'F'))
BEGIN
ALTER TABLE rsvps DROP CONSTRAINT fk_rsvps_dietaryRequirementId;
END;

IF EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'fk_rsvps_eventId') AND type IN (N'F'))
BEGIN
ALTER TABLE rsvps DROP CONSTRAINT fk_rsvps_eventId;
END;

IF EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'fk_eventsStatusHistory_eventId') AND type IN (N'F'))
BEGIN
ALTER TABLE eventsStatusHistory DROP CONSTRAINT fk_eventsStatusHistory_eventId;
END;

IF EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'fk_eventLocationsHistory_eventLocationId') AND type IN (N'F'))
BEGIN
ALTER TABLE eventLocationsHistory DROP CONSTRAINT fk_eventLocationsHistory_eventLocationId;
END;

IF EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'fk_eventsEndDateHistory_eventId') AND type IN (N'F'))
BEGIN
ALTER TABLE eventsEndDateHistory DROP CONSTRAINT fk_eventsEndDateHistory_eventId;
END;

IF EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'fk_eventsStartDateHistory_eventId') AND type IN (N'F'))
BEGIN
ALTER TABLE eventsStartDateHistory DROP CONSTRAINT fk_eventsStartDateHistory_eventId;
END;

IF EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'fk_rsvpsResponseHistory_rsvpId') AND type IN (N'F'))
BEGIN
ALTER TABLE rsvpsResponseHistory DROP CONSTRAINT fk_rsvpsResponseHistory_rsvpId;
END;

IF EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'fk_rsvpsResponseHistory_responseId') AND type IN (N'F'))
BEGIN
ALTER TABLE rsvpsResponseHistory DROP CONSTRAINT fk_rsvpsResponseHistory_responseId;
END;

IF EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'fk_rsvpsLocationHistory_rsvpId') AND type IN (N'F'))
BEGIN
ALTER TABLE rsvpsLocationHistory DROP CONSTRAINT fk_rsvpsLocationHistory_rsvpId;
END;

IF EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'fk_rsvpsLocationHistory_eventLocationId') AND type IN (N'F'))
BEGIN
ALTER TABLE rsvpsLocationHistory DROP CONSTRAINT fk_rsvpsLocationHistory_eventLocationId;
END;

IF EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'fk_rsvpsLocationHistory_locationId') AND type IN (N'F'))
BEGIN
ALTER TABLE rsvpsLocationHistory DROP CONSTRAINT fk_rsvpsLocationHistory_locationId;
END;

IF EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'fk_eventLocationsHistory_locationId') AND type IN (N'F'))
BEGIN
ALTER TABLE eventLocationsHistory DROP CONSTRAINT fk_eventLocationsHistory_locationId;
END;

IF EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'AK_rsvpResponses_response') AND type IN (N'UQ'))
BEGIN
ALTER TABLE rsvpResponses DROP CONSTRAINT AK_rsvpResponses_response;
END;

IF EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'AK_eventStatuses_eventStatus') AND type IN (N'UQ'))
BEGIN
ALTER TABLE eventStatuses DROP CONSTRAINT AK_eventStatuses_eventStatus;
END;

IF EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'AK_eventTypes_eventTypeName') AND type IN (N'UQ'))
BEGIN
ALTER TABLE eventTypes DROP CONSTRAINT AK_eventTypes_eventTypeName;
END;

IF EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'AK_dietaryRequirements_dietaryRequirement') AND type IN (N'UQ'))
BEGIN
ALTER TABLE dietaryRequirements DROP CONSTRAINT AK_dietaryRequirements_dietaryRequirement;
END;

IF EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'AK_locations_locationName') AND type IN (N'UQ'))
BEGIN
ALTER TABLE locations DROP CONSTRAINT AK_locations_locationName;
END;

IF EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'fk_eventMeetingUrlHistory_eventId') AND type IN (N'F'))
BEGIN
ALTER TABLE eventMeetingUrlHistory DROP CONSTRAINT fk_eventMeetingUrlHistory_eventId;
END;

-- Drop Tables

IF EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'events') AND type IN (N'U'))
BEGIN
DROP TABLE events;
END;

IF EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'locations') AND type IN (N'U'))
BEGIN
DROP TABLE locations;
END;

IF EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'eventLocations') AND type IN (N'U'))
BEGIN
DROP TABLE eventLocations;
END;

IF EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'eventStatuses') AND type IN (N'U'))
BEGIN
DROP TABLE eventStatuses;
END;

IF EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'eventTypes') AND type IN (N'U'))
BEGIN
DROP TABLE eventTypes;
END;

IF EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'dietaryRequirements') AND type IN (N'U'))
BEGIN
DROP TABLE dietaryRequirements;
END;

IF EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'rsvpResponses') AND type IN (N'U'))
BEGIN
DROP TABLE rsvpResponses;
END;

IF EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'eventsStatusHistory') AND type IN (N'U'))
BEGIN
DROP TABLE eventsStatusHistory;
END;

IF EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'rsvps') AND type IN (N'U'))
BEGIN
DROP TABLE rsvps;
END;

IF EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'rsvpsResponseHistory') AND type IN (N'U'))
BEGIN
DROP TABLE rsvpsResponseHistory;
END;

IF EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'eventLocationsHistory') AND type IN (N'U'))
BEGIN
DROP TABLE eventLocationsHistory;
END;

IF EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'eventsStartDateHistory') AND type IN (N'U'))
BEGIN
DROP TABLE eventsStartDateHistory;
END;

IF EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'eventsEndDateHistory') AND type IN (N'U'))
BEGIN
DROP TABLE eventsEndDateHistory;
END;

IF EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'rsvpsLocationHistory') AND type IN (N'U'))
BEGIN
DROP TABLE rsvpsLocationHistory;
END;

IF EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'eventMeetingUrlHistory') AND type IN (N'U'))
BEGIN
DROP TABLE eventMeetingUrlHistory;
END;

-- Drop proc referencing the TVP type and drop TVP type

DROP PROCEDURE IF EXISTS [dbo].[UpdateEventDetails];

IF EXISTS (
    SELECT 1 FROM sys.types 
    WHERE is_table_type = 1 
      AND name = 'inviteesTVP' 
      AND SCHEMA_NAME(schema_id) = 'dbo'
)
    DROP TYPE [dbo].[inviteesTVP];
GO

-- Create Tables

CREATE TABLE events (
  [eventId] [INT] IDENTITY(1,1) PRIMARY KEY,
  [eventName] [VARCHAR](255) NOT NULL,
  [eventDescription] [VARCHAR](255) NOT NULL,
  [eventImageBlobName] [VARCHAR](255) NOT NULL,
  [eventGuid] [VARCHAR](255) NOT NULL DEFAULT NEWID(),
  [eventTypeId] [INT] NOT NULL
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

CREATE TABLE eventStatuses (
  [eventStatusId] [INT] IDENTITY(1,1) PRIMARY KEY,
  [eventStatus] [VARCHAR](255) NOT NULL
);

CREATE TABLE eventTypes (
  [eventTypeId] [INT] IDENTITY(1,1) PRIMARY KEY,
  [eventTypeName] [VARCHAR](255) NOT NULL
);

CREATE TABLE dietaryRequirements (
  [dietaryRequirementId] [INT] IDENTITY(1,1) PRIMARY KEY,
  [dietaryRequirement] [VARCHAR](255) NOT NULL
);

CREATE TABLE rsvpResponses (
  [responseId] [INT] IDENTITY(1,1) PRIMARY KEY,
  [response] [VARCHAR](255) NOT NULL
);

CREATE TABLE eventsStatusHistory (
  [eventStatusHistoryId] [INT] IDENTITY(1,1) PRIMARY KEY,
  [eventId] [INT] NOT NULL,
  [eventStatusId] [INT] NOT NULL,
  [userId] [VARCHAR](255) NOT NULL,
  [createdAt] [DATETIME] NOT NULL DEFAULT GETDATE()
);

CREATE TABLE rsvps (
  [rsvpId] [INT] IDENTITY(1,1) PRIMARY KEY,
  [studentId] [INT] NOT NULL,
  [eventId] [INT] NOT NULL,
  [inviteCategory] [VARCHAR](255) NOT NULL,
  [dietaryRequirementId] [INT] NOT NULL,
  [allergies] [VARCHAR](255) NULL,
  [createdAt] [DATETIME] NOT NULL DEFAULT GETDATE()
);

CREATE TABLE rsvpsResponseHistory (
  [rsvpResponseHistoryId] [INT] IDENTITY(1,1) PRIMARY KEY,
  [rsvpId] [INT] NOT NULL,
  [responseId] [INT] NOT NULL,
  [notes] [VARCHAR](255) NULL,
  [userId] [VARCHAR](255) NOT NULL,
  [createdAt] [DATETIME] NOT NULL DEFAULT GETDATE()
);

CREATE TABLE eventLocationsHistory (
  [eventLocationHistoryId] [INT] IDENTITY(1,1) PRIMARY KEY,
  [eventId] [INT] NOT NULL,
  [userId] [VARCHAR](255) NOT NULL,
  [locationId] [INT] NOT NULL,
  [createdAt] [DATETIME] NOT NULL DEFAULT GETDATE()
);

CREATE TABLE eventsStartDateHistory (
  [eventStartDateHistoryId] [INT] IDENTITY(1,1) PRIMARY KEY,
  [eventId] [INT] NOT NULL,
  [startDate] [DATETIME] NOT NULL,
  [userId] [VARCHAR](255) NOT NULL,
  [createdAt] [DATETIME] NOT NULL DEFAULT GETDATE()
);

CREATE TABLE eventsEndDateHistory (
  [eventEndDateHistoryId] [INT] IDENTITY(1,1) PRIMARY KEY,
  [eventId] [INT] NOT NULL,
  [endDate] [DATETIME] NOT NULL,
  [userId] [VARCHAR](255) NOT NULL,
  [createdAt] [DATETIME] NOT NULL DEFAULT GETDATE()
);

CREATE TABLE rsvpsLocationHistory (
  [rsvpsLocationHistoryId] [INT] IDENTITY(1,1) PRIMARY KEY,
  [rsvpId] [INT] NOT NULL,
  [locationId] [INT] NOT NULL,
  [userId] [VARCHAR](255) NOT NULL,
  [createdAt] [DATETIME] NOT NULL DEFAULT GETDATE()
);

CREATE TABLE eventMeetingUrlHistory (
  [eventMeetingUrlHistoryId] [INT] IDENTITY(1,1) PRIMARY KEY,
  [meetingUrl] [VARCHAR](512) NOT NULL,
  [eventId] [INT] NOT NULL,
  [userId] [VARCHAR](255) NOT NULL,
  [createdAt] [DATETIME] NOT NULL DEFAULT GETDATE()
)

-- Create TVP type

CREATE TYPE inviteesTVP AS TABLE (
    studentId int,
    inviteCategory VARCHAR(50)
);

-- Add Constraints

ALTER TABLE eventsStatusHistory
ADD CONSTRAINT fk_eventsStatusHistory_eventStatusId
FOREIGN KEY (eventStatusId)
REFERENCES eventStatuses(eventStatusId);

ALTER TABLE [events]
ADD CONSTRAINT fk_events_eventTypeId
FOREIGN KEY (eventTypeId)
REFERENCES eventTypes(eventTypeId);

ALTER TABLE rsvps
ADD CONSTRAINT fk_rsvps_studentId
FOREIGN KEY (studentId)
REFERENCES students(studentId);

ALTER TABLE rsvps
ADD CONSTRAINT fk_rsvps_dietaryRequirementId
FOREIGN KEY (dietaryRequirementId)
REFERENCES dietaryRequirements(dietaryRequirementId);

ALTER TABLE rsvps
ADD CONSTRAINT fk_rsvps_eventId
FOREIGN KEY (eventId)
REFERENCES events(eventId);

ALTER TABLE eventsStatusHistory
ADD CONSTRAINT fk_eventsStatusHistory_eventId
FOREIGN KEY (eventId)
REFERENCES events(eventId);

ALTER TABLE eventLocationsHistory
ADD CONSTRAINT fk_eventLocationsHistory_locationId
FOREIGN KEY (locationId)
REFERENCES locations(locationId);

ALTER TABLE eventsEndDateHistory
ADD CONSTRAINT fk_eventsEndDateHistory_eventId
FOREIGN KEY (eventId)
REFERENCES events(eventId);

ALTER TABLE eventsStartDateHistory
ADD CONSTRAINT fk_eventsStartDateHistory_eventId
FOREIGN KEY (eventId)
REFERENCES events(eventId);

ALTER TABLE rsvpsResponseHistory
ADD CONSTRAINT fk_rsvpsResponseHistory_rsvpId
FOREIGN KEY (rsvpId)
REFERENCES rsvps(rsvpId);

ALTER TABLE rsvpsResponseHistory
ADD CONSTRAINT fk_rsvpsResponseHistory_responseId
FOREIGN KEY (responseId)
REFERENCES rsvpResponses(responseId);

ALTER TABLE rsvpsLocationHistory
ADD CONSTRAINT fk_rsvpsLocationHistory_rsvpId
FOREIGN KEY (rsvpId)
REFERENCES rsvps(rsvpId);

ALTER TABLE rsvpsLocationHistory
ADD CONSTRAINT fk_rsvpsLocationHistory_locationId
FOREIGN KEY (locationId)
REFERENCES locations(locationId);

ALTER TABLE rsvpResponses  
ADD CONSTRAINT AK_rsvpResponses_response 
UNIQUE (response);

ALTER TABLE eventStatuses
ADD CONSTRAINT AK_eventStatuses_eventStatus 
UNIQUE (eventStatus);

ALTER TABLE eventTypes  
ADD CONSTRAINT AK_eventTypes_eventTypeName 
UNIQUE (eventTypeName);

ALTER TABLE dietaryRequirements  
ADD CONSTRAINT AK_dietaryRequirements_dietaryRequirement 
UNIQUE (dietaryRequirement);

ALTER TABLE locations  
ADD CONSTRAINT AK_locations_locationName 
UNIQUE (locationName);

ALTER TABLE eventMeetingUrlHistory
ADD CONSTRAINT fk_eventMeetingUrlHistory_eventId
FOREIGN KEY (eventId)
REFERENCES events(eventId);
