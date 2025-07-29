IF OBJECT_ID('dbo.UpdateEventDetails', 'P') IS NOT NULL
    DROP PROCEDURE [dbo].[UpdateEventDetails];
GO

CREATE PROCEDURE [dbo].[UpdateEventDetails]
    @eventGuid VARCHAR(255),
    @userId VARCHAR(255),
    @startDate DATETIME,
    @endDate DATETIME,
    @locationName VARCHAR(255),
    @meetingUrl VARCHAR(512),
    @withInvitees BIT,
    @inviteesTvp [dbo].[inviteesTVP] READONLY
AS
BEGIN
    IF @eventGuid IS NULL OR @userId IS NULL
        RETURN;
    
    SET NOCOUNT OFF;

    BEGIN TRY
        BEGIN TRANSACTION;

        DECLARE @eventId INT = (SELECT eventId FROM events WHERE @eventGuid = eventGuid)

        IF @startDate IS NOT NULL
        BEGIN
            DECLARE @eventStatusId INT = (SELECT eventStatusId FROM eventStatuses WHERE eventStatus = 'Postponed')

            INSERT INTO eventsStartDateHistory (eventId, startDate, userId)
            VALUES (@eventId, @startDate, @userId);

            INSERT INTO eventsStatusHistory (eventId, eventStatusId, userId)
            VALUES (@eventId, @eventStatusId, @userId);
        END

        IF @endDate IS NOT NULL
        BEGIN
            INSERT INTO eventsEndDateHistory (eventId, endDate, userId)
            VALUES (@eventId, @endDate, @userId);
        END

        IF @locationName IS NOT NULL
            BEGIN
                DECLARE @locationId INT = (SELECT locationId FROM locations WHERE locationName = @locationName);
                INSERT INTO eventLocationsHistory(eventId, userId, locationId)
                VALUES(@eventId, @userId, @locationId)
            END

        IF @meetingUrl IS NOT NULL
        BEGIN
            INSERT INTO eventMeetingUrlHistory (meetingUrl, eventId, userId)
            VALUES (@meetingUrl, @eventId, @userId);
        END

        IF @withInvitees = 1
        BEGIN
            DECLARE @insertedRsvpIDs TABLE (rsvpId INT);
            DECLARE @responseId INT = (SELECT responseId FROM rsvpResponses WHERE response = 'Pending')
            DECLARE @dietaryRequirementId INT = (SELECT dietaryRequirementId FROM dietaryRequirements WHERE dietaryRequirement = 'None')
            
            INSERT INTO [dbo].[rsvps] (studentId, eventId, dietaryRequirementId, inviteCategory, allergies)
            OUTPUT INSERTED.rsvpId INTO @insertedRsvpIDs(rsvpId)
            SELECT studentId, @eventId, @dietaryRequirementId, inviteCategory, 'None'
            FROM @inviteesTvp;

            INSERT INTO [dbo].[rsvpsResponseHistory] (rsvpId, responseId, notes, userId)
            SELECT rsvpId, @responseId, 'None', @userId
            FROM @insertedRsvpIDs;
        END

        COMMIT TRANSACTION;
    END TRY
    BEGIN CATCH

        IF XACT_STATE() <> 0
            ROLLBACK TRANSACTION;
        RETURN;
    END CATCH
END
GO
