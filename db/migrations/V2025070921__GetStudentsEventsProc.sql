IF EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[GetStudentEvents]') AND type in (N'P', N'PC'))
DROP PROCEDURE [dbo].[GetStudentEvents]
GO

CREATE PROCEDURE [dbo].[GetStudentEvents]
	@studentId INT
AS
BEGIN
    ;WITH LatestResponse AS (
        SELECT rsvpId, responseId,
            ROW_NUMBER() OVER (PARTITION BY rsvpId ORDER BY createdAt DESC) AS rn_response
        FROM rsvpsResponseHistory
    ),
    latestStartDate AS (
        SELECT eventId, startDate,
           ROW_NUMBER() OVER (PARTITION BY eventId ORDER BY createdAt DESC) AS rn_startDate
        FROM eventsStartDateHistory
    ),
    latestEndDate AS (
        SELECT eventId, endDate,
           ROW_NUMBER() OVER (PARTITION BY eventId ORDER BY createdAt DESC) AS rn_endDate
        FROM eventsEndDateHistory
    )

    SELECT
        e.eventName,
        e.eventImageBlobName AS eventImage,
        e.eventGuid,
        lsd.startDate,
        led.endDate,
        rr.response AS rsvp
    FROM events e
    INNER JOIN rsvps r ON r.eventId = e.eventId
    INNER JOIN latestStartDate lsd ON lsd.eventId = e.eventId AND lsd.rn_startDate = 1
    INNER JOIN latestEndDate led ON led.eventId = e.eventId AND led.rn_endDate = 1
    INNER JOIN LatestResponse lr ON lr.rsvpId = r.rsvpId AND lr.rn_response = 1
    INNER JOIN rsvpResponses rr ON rr.responseId = lr.responseId
    WHERE r.studentId = @studentId
END
