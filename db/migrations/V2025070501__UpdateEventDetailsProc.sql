SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

IF EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[UpdateEventDetails]') AND type in (N'P', N'PC'))
DROP PROCEDURE [dbo].[UpdateEventDetails]
GO

CREATE PROCEDURE [dbo].[UpdateEventDetails]
    @eventGuid VARCHAR(255),
    @userId VARCHAR(255),
    @startDate DATETIME,
    @endDate DATETIME,
    @meetingUrl VARCHAR(512),
    @withInvitees BIT,
	@withLocations BIT,
	@isCancelled BIT,
    @inviteesTvp [dbo].[inviteesTVP] READONLY,
	@eventLocationsTVP [dbo].[eventLocationsTVP] READONLY
AS
BEGIN
	DECLARE @XACT_ABORT_STATUS VARCHAR(3) = 'OFF';
	IF ( (16384 & @@OPTIONS) = 16384 )
		SET @XACT_ABORT_STATUS = 'ON';

	SELECT @XACT_ABORT_STATUS AS XactAbortStatus;

    IF @eventGuid IS NULL OR @userId IS NULL
        RETURN;

    SET NOCOUNT OFF;

    BEGIN TRY
    BEGIN TRANSACTION;

    DECLARE @eventId INT = (SELECT eventId FROM events WHERE @eventGuid = eventGuid);
		DECLARE @eventStatusId INT;

		IF @isCancelled = 1
		BEGIN
        SET @eventStatusId = (SELECT eventStatusId FROM eventStatuses WHERE eventStatus = 'Cancelled');

        INSERT INTO eventsStatusHistory (eventId, eventStatusId, userId)
        VALUES (@eventId, @eventStatusId, @userId);
		END
		ELSE
		BEGIN
        IF @startDate IS NOT NULL AND @isCancelled = 0
        BEGIN
            SET @eventStatusId = (SELECT eventStatusId FROM eventStatuses WHERE eventStatus = 'Postponed');

            INSERT INTO eventsStartDateHistory (eventId, startDate, userId)
            VALUES (@eventId, @startDate, @userId);

            INSERT INTO eventsStatusHistory (eventId, eventStatusId, userId)
            VALUES (@eventId, @eventStatusId, @userId);
        END

        IF @endDate IS NOT NULL AND @isCancelled = 0
        BEGIN
            INSERT INTO eventsEndDateHistory (eventId, endDate, userId)
            VALUES (@eventId, @endDate, @userId);
        END

        IF @meetingUrl IS NOT NULL AND @isCancelled = 0
        BEGIN
            INSERT INTO eventMeetingUrlHistory (meetingUrl, eventId, userId)
            VALUES (@meetingUrl, @eventId, @userId);
        END

        IF @withInvitees = 1 AND @isCancelled = 0
        BEGIN
            DECLARE @insertedRsvpIDs TABLE (rsvpId INT);
            DECLARE @responseId INT = (SELECT responseId FROM rsvpResponses WHERE response = 'Pending')
            DECLARE @dietaryRequirementId INT = (SELECT dietaryRequirementId FROM dietaryRequirements WHERE dietaryRequirement = 'None')

            INSERT INTO [dbo].[rsvps] (studentId, eventId, dietaryRequirementId, inviteCategory, allergies)
            OUTPUT INSERTED.rsvpId INTO @insertedRsvpIDs(rsvpId)
            SELECT studentId, @eventId, @dietaryRequirementId, inviteCategory, 'N/A'
            FROM @inviteesTvp;

            INSERT INTO [dbo].[rsvpsResponseHistory] (rsvpId, responseId, notes, userId)
            SELECT rsvpId, @responseId, 'N/A', @userId
            FROM @insertedRsvpIDs;
        END

		IF @withLocations = 1 AND @isCancelled = 0
		BEGIN
			DECLARE @finalLocations TABLE (
				locationId INT,
				locationStatusId INT
			);

			DECLARE @matchedLocations TABLE (
				locationName VARCHAR(255),
				addressLineOne VARCHAR(255),
				addressLineTwo VARCHAR(255),
				suburb VARCHAR(255),
				city VARCHAR(255),
				code VARCHAR(50),
				locationStatusId INT,
				locationId INT
			);

			INSERT INTO @matchedLocations (locationName, addressLineOne, addressLineTwo, suburb, city, code, locationStatusId, locationId)
			SELECT lws.locationName, lws.addressLineOne, lws.addressLineTwo, lws.suburb, lws.city, lws.code, ls.locationStatusId, l.locationId
			FROM @eventLocationsTVP lws
			INNER JOIN locationStatuses ls ON lws.locationStatus = ls.statusName
			LEFT JOIN locations l ON l.locationName = lws.locationName OR l.addressLineTwo = lws.addressLineTwo;

			DECLARE @newLocationsInput TABLE (
				locationName VARCHAR(255),
				addressLineOne VARCHAR(255),
				addressLineTwo VARCHAR(255),
				suburb VARCHAR(255),
				city VARCHAR(255),
				code VARCHAR(50),
				locationStatusId INT
			);

			INSERT INTO @newLocationsInput (locationName, addressLineOne, addressLineTwo, suburb, city, code, locationStatusId)
			SELECT locationName, ISNULL(addressLineOne, ''), addressLineTwo, suburb, city, code, locationStatusId
			FROM @matchedLocations
			WHERE locationId IS NULL;

			DECLARE @insertedNewLocations TABLE (
				locationId INT,
				locationName VARCHAR(255),
				addressLineTwo VARCHAR(255)
			);

			INSERT INTO locations (locationName, addressLineOne, addressLineTwo, suburb, city, code)
			OUTPUT INSERTED.locationId, INSERTED.locationName, INSERTED.addressLineTwo
			INTO @insertedNewLocations(locationId, locationName, addressLineTwo)
			SELECT locationName, addressLineOne, addressLineTwo, suburb, city, code
			FROM @newLocationsInput;

			INSERT INTO @finalLocations (locationId, locationStatusId)
			SELECT inl.locationId, nli.locationStatusId
			FROM @insertedNewLocations inl
			JOIN @newLocationsInput nli
			  ON inl.locationName = nli.locationName
			 AND inl.addressLineTwo = nli.addressLineTwo;

			INSERT INTO @finalLocations (locationId, locationStatusId)
			SELECT locationId, locationStatusId
			FROM @matchedLocations
			WHERE locationId IS NOT NULL;

			INSERT INTO eventLocationsHistory (eventId, userId, locationId, locationStatusId)
			SELECT @eventId, @userId, locationId, locationStatusId
			FROM @finalLocations;
		END
		END
    COMMIT TRANSACTION;
    END TRY
    BEGIN CATCH

        IF XACT_STATE() <> 0
            ROLLBACK TRANSACTION;
        RETURN;
    END CATCH
END
