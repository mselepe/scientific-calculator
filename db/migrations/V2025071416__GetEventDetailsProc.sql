SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

ALTER PROCEDURE [dbo].[GetEventDetails]
    @eventGuid UNIQUEIDENTIFIER
AS
BEGIN
    SET NOCOUNT ON;

    WITH latestStartDates AS (
      SELECT eventId, startDate,
        ROW_NUMBER() OVER (PARTITION BY eventId ORDER BY createdAt DESC) AS rn_startDate
      FROM eventsStartDateHistory
    ),
    latestEndDates AS (
      SELECT eventId, endDate,
        ROW_NUMBER() OVER (PARTITION BY eventId ORDER BY createdAt DESC) AS rn_endDate
      FROM eventsEndDateHistory
    ),
    latestStatuses AS (
      SELECT eventId, eventStatusId,
        ROW_NUMBER() OVER (PARTITION BY eventId ORDER BY createdAt DESC) AS rn_status
      FROM eventsStatusHistory
    )

    SELECT (
        SELECT 
            e.eventGuid,
            e.eventName,
			      es.eventStatus,
            et.eventTypeName AS eventType,
            lsd.startDate,
            led.endDate,
            e.eventImageBlobName AS eventImage,
            e.eventDescription
        FROM [events] AS e
        INNER JOIN eventTypes AS et ON e.eventTypeId = et.eventTypeId
        INNER JOIN latestStartDates AS lsd ON lsd.eventId = e.eventId AND lsd.rn_startDate = 1
        INNER JOIN latestEndDates AS led ON led.eventId = e.eventId AND led.rn_endDate = 1
		LEFT JOIN latestStatuses AS ls ON ls.eventId = e.eventId AND ls.rn_status = 1
		INNER JOIN eventStatuses AS es ON es.eventStatusId = ls.eventStatusId
        WHERE e.eventGuid = @eventGuid
        FOR JSON PATH
    ) AS event;
END