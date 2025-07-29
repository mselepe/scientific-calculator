SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
ALTER PROCEDURE [dbo].[GetEvents] 
	@year INT = NULL
AS
BEGIN
	SET NOCOUNT ON;

	WITH LatestStartDates AS (
		SELECT eventId, startDate,
			ROW_NUMBER() OVER (PARTITION BY eventId ORDER BY createdAt DESC) AS rn_startDate
		FROM eventsStartDateHistory
	),
	LatestEndDates AS (
		SELECT eventId, endDate,
			ROW_NUMBER() OVER (PARTITION BY eventId ORDER BY createdAt DESC) AS rn_endDate
		FROM eventsEndDateHistory
	),
	LatestResponses AS (
		SELECT rsvpId, responseId,
			ROW_NUMBER() OVER (PARTITION BY rsvpId ORDER BY createdAt DESC) AS rn_response
		FROM rsvpsResponseHistory
	)

	SELECT (
		SELECT 
			e.eventGuid,
			e.eventName,
			et.eventTypeName AS eventType,
			lsd.startDate,
			led.endDate,
			COUNT(r.rsvpId) AS [RsvpNumbers.totalInvites],
			SUM(CASE WHEN lr.responseId = 1 THEN 1 ELSE 0 END) AS [RsvpNumbers.confirmedRsvps],
			SUM(CASE WHEN lr.responseId = 2 THEN 1 ELSE 0 END) AS [RsvpNumbers.declinedRsvps],
			SUM(CASE WHEN lr.responseId = 3 THEN 1 ELSE 0 END) AS [RsvpNumbers.outstandingRsvps]
		FROM events AS e
		INNER JOIN eventTypes AS et ON e.eventTypeId = et.eventTypeId
		INNER JOIN LatestStartDates AS lsd ON lsd.eventId = e.eventId AND lsd.rn_startDate = 1
		INNER JOIN LatestEndDates AS led ON led.eventId = e.eventId AND led.rn_endDate = 1
		LEFT JOIN rsvps AS r ON r.eventId = e.eventId
		LEFT JOIN LatestResponses AS lr ON lr.rsvpId = r.rsvpId AND lr.rn_response = 1

		WHERE (@year IS NULL OR YEAR(lsd.startDate) = @year)

		GROUP BY 
			e.eventGuid,
			e.eventName,
			et.eventTypeName,
			lsd.startDate,
			led.endDate

		ORDER BY lsd.startDate ASC
		FOR JSON PATH
	) AS events;
END