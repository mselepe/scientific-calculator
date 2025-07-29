SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
ALTER PROCEDURE [dbo].[GetEventInvitees]
	@eventGuid UNIQUEIDENTIFIER = NULL
AS
BEGIN
	SET NOCOUNT ON;

	WITH latestLocation AS (
		SELECT rsvpId, locationId,
			ROW_NUMBER() OVER (PARTITION BY rsvpId ORDER BY createdAt DESC) AS rn_location
		FROM rsvpsLocationHistory
	),
	latestResponses AS (
		SELECT rsvpId, responseId, notes,
			ROW_NUMBER() OVER (PARTITION BY rsvpId ORDER BY createdAt DESC) AS rn_response
		FROM rsvpsResponseHistory
	),
	latestUniversityApplication AS (
		SELECT studentId, universityDepartmentId,
			ROW_NUMBER() OVER (PARTITION BY studentId ORDER BY applicationId DESC) AS rn_application
		FROM universityApplications
	)

	SELECT ISNULL ((
		SELECT
			s.name AS firstName,
			s.surname AS surname,
			s.studentId,
			u.universityName,
			rr.response AS rsvp,
			[location] = CASE WHEN rr.responseId = 3 THEN '-' ELSE l.locationName END,
			dr.dietaryRequirement AS dietaryRequirements,
			r.allergies AS allergies,
			lr.notes
		FROM [rsvps] r
		INNER JOIN students AS s ON s.studentId = r.studentId
		INNER JOIN latestUniversityApplication AS ua ON s.studentId = ua.studentId AND ua.rn_application = 1
		INNER JOIN universityDepartments AS ud ON ua.universityDepartmentId = ud.universityDepartmentId
		INNER JOIN universities AS u ON ud.universityId = u.universityId
		INNER JOIN [events] AS e ON e.eventId = r.eventId
		INNER JOIN dietaryRequirements AS dr ON r.dietaryRequirementId = dr.dietaryRequirementId
		INNER JOIN latestResponses AS lr ON lr.rsvpId = r.rsvpId AND lr.rn_response = 1
		INNER JOIN rsvpResponses AS rr ON lr.responseId = rr.responseId
		LEFT JOIN latestLocation AS ll ON ll.rsvpId = r.rsvpId AND ll.rn_location = 1
		LEFT JOIN locations AS l ON ll.locationId = l.locationId
		WHERE e.eventGuid = @eventGuid
		FOR JSON PATH
	), '[]') AS invitees
END