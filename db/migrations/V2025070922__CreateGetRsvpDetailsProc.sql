IF EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[GetRsvpDetails]') AND type in (N'P', N'PC'))
DROP PROCEDURE [dbo].[GetRsvpDetails]
GO

CREATE PROCEDURE [dbo].[GetRsvpDetails]
	@eventGuid UNIQUEIDENTIFIER,
	@email VARCHAR(345)
AS
BEGIN
	SET NOCOUNT ON;

	DECLARE @studentId INT = (SELECT studentId FROM students WHERE email = @email);
	DECLARE @pendingResponseId INT = (SELECT responseId FROM rsvpResponses WHERE response = 'pending');

	WITH latestLocation AS (
		SELECT rsvpId, locationId,
			ROW_NUMBER() OVER (PARTITION BY rsvpId ORDER BY createdAt DESC) AS rn_location
		FROM rsvpsLocationHistory
	),
	latestResponses AS (
		SELECT rsvpId, responseId, notes,
			ROW_NUMBER() OVER (PARTITION BY rsvpId ORDER BY createdAt DESC) AS rn_response
		FROM rsvpsResponseHistory
	)

	SELECT (
		SELECT
			s.studentId,
			e.eventId,
			rr.response AS rsvp,
			[location] = CASE WHEN rr.responseId = @pendingResponseId THEN '-' ELSE l.locationName END,
			dr.dietaryRequirement AS dietaryRequirements,
			r.allergies AS allergies,
			lr.notes
		FROM [rsvps] r
		INNER JOIN students AS s ON s.studentId = r.studentId
		INNER JOIN [events] AS e ON e.eventId = r.eventId
		INNER JOIN dietaryRequirements AS dr ON r.dietaryRequirementId = dr.dietaryRequirementId
		INNER JOIN latestResponses AS lr ON lr.rsvpId = r.rsvpId AND lr.rn_response = 1
		INNER JOIN rsvpResponses AS rr ON lr.responseId = rr.responseId
		LEFT JOIN latestLocation AS ll ON ll.rsvpId = r.rsvpId AND ll.rn_location = 1
		LEFT JOIN locations AS l ON ll.locationId = l.locationId
		WHERE e.eventGuid = @eventGuid AND s.studentId = @studentId
		FOR JSON PATH
	) as rsvp
END