IF EXISTS (SELECT * FROM sys.objects
WHERE object_id = OBJECT_ID(N'[dbo].[rsvpResponses]') AND type in (N'U'))
BEGIN
INSERT INTO rsvpResponses (response) VALUES ('Yes'), ('No'), ('Pending');
END;

IF EXISTS (SELECT * FROM sys.objects
WHERE object_id = OBJECT_ID(N'[dbo].[eventStatuses]') AND type in (N'U'))
BEGIN
INSERT INTO eventStatuses (eventStatus) VALUES ('Ongoing'), ('Upcoming'), ('Postponed'), ('Cancelled'), ('Past');
END;

IF EXISTS (SELECT * FROM sys.objects
WHERE object_id = OBJECT_ID(N'[dbo].[eventTypes]') AND type in (N'U'))
BEGIN
INSERT INTO eventTypes (eventTypeName) VALUES ('Vacation Week')
END;

IF EXISTS (SELECT * FROM sys.objects
WHERE object_id = OBJECT_ID(N'[dbo].[dietaryRequirements]') AND type in (N'U'))
BEGIN
INSERT INTO dietaryRequirements (dietaryRequirement)
VALUES ('None'), ('Vegetarian'), ('Vegan'), ('Kosher'), ('Halal'), ('Other');
END;

IF EXISTS (SELECT * FROM sys.objects
WHERE object_id = OBJECT_ID(N'[dbo].[locations]') AND type in (N'U'))
BEGIN
INSERT INTO locations (locationName, addressLineOne, addressLineTwo, suburb, city, code)
VALUES ('BBD Johannesburg', 'The Zone Boulevard', ' Cnr Cradock & Tyrwhitt Ave', 'Rosebank', 'Johannesburg', '2196'),
       ('BBD Pretoria', '', '121 Boshoff Street', 'Nieuw Muckleneuk', 'Pretoria', '0181'),
       ('BBD Cape Town', '3rd Floor, Northbank Building', '1 Northbank Lane', 'Century City', 'Cape Town', '7441'),
       ('Online Meeting', 'N/A', 'N/A', 'N/A', 'N/A', 'N/A')
END;
