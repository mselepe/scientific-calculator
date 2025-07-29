IF EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[GetActiveEventLocations]') AND type in (N'P', N'PC'))
DROP PROCEDURE [dbo].[GetActiveEventLocations]
GO

CREATE PROCEDURE [dbo].[GetActiveEventLocations]
	@eventGuid UNIQUEIDENTIFIER
AS
BEGIN
	SET NOCOUNT ON;

	WITH LatestMeetingUrl AS (
	  SELECT eventId, meetingUrl,
		ROW_NUMBER() OVER (PARTITION BY eventId ORDER BY createdAt DESC) AS rn_meetingUrl
	  FROM eventMeetingUrlHistory
	),
	LatestLocationStatus AS (
	  SELECT el.*,
		ROW_NUMBER() OVER (PARTITION BY el.eventId, el.locationId ORDER BY el.createdAt DESC) AS rn_locationStatus
	  FROM eventLocationsHistory el
	)
	SELECT (
		SELECT
		  l.locationName AS [location],
		  l.addressLineOne AS [address.addressLine1],
		  l.addressLineTwo AS [address.addressLine2],
		  l.suburb AS [address.suburb],
		  l.city AS [address.city],
		  l.code AS [address.code],
		  emu.meetingUrl AS [meetingUrl]
		FROM LatestLocationStatus el
		INNER JOIN locationStatuses ls ON el.locationStatusId = ls.locationStatusId
		INNER JOIN locations l ON l.locationId = el.locationId
		INNER JOIN events e ON e.eventId = el.eventId
		LEFT JOIN LatestMeetingUrl emu ON emu.eventId = e.eventId AND emu.rn_meetingUrl = 1
		WHERE el.rn_locationStatus = 1
		AND ls.statusName = 'Confirmed'
		AND e.eventGuid = @eventGuid
		FOR JSON PATH
	) AS locations
END