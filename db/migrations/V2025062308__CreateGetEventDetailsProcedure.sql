IF EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[GetEventDetails]') AND type in (N'P', N'PC'))
DROP PROCEDURE [dbo].[GetEventDetails]
GO

CREATE PROCEDURE [dbo].[GetEventDetails]
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
    )

    SELECT (
        SELECT 
            e.eventGuid,
            e.eventName,
            et.eventTypeName AS eventType,
            lsd.startDate,
            led.endDate,
            e.eventImageBlobName AS eventImage,
            e.eventDescription
        FROM [events] AS e
        INNER JOIN eventTypes AS et ON e.eventTypeId = et.eventTypeId
        INNER JOIN latestStartDates AS lsd ON lsd.eventId = e.eventId AND lsd.rn_startDate = 1
        INNER JOIN latestEndDates AS led ON led.eventId = e.eventId AND led.rn_endDate = 1
        WHERE e.eventGuid = @eventGuid
        FOR JSON PATH
    ) AS event;
END