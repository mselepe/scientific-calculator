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

ALTER TABLE rsvpResponses  
ADD CONSTRAINT AK_rsvpResponses_response UNIQUE (response);

ALTER TABLE eventStatuses
ADD CONSTRAINT AK_eventStatuses_eventStatus UNIQUE (eventStatus);

ALTER TABLE eventTypes  
ADD CONSTRAINT AK_eventTypes_eventTypeName UNIQUE (eventTypeName);

ALTER TABLE dietaryRequirements  
ADD CONSTRAINT AK_dietaryRequirements_dietaryRequirement UNIQUE (dietaryRequirement);

ALTER TABLE locations  
ADD CONSTRAINT AK_locations_locationName UNIQUE (locationName);