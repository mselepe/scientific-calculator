IF EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[InsertInvitees]') AND type in (N'P', N'PC'))
DROP PROCEDURE [dbo].[InsertInvitees]
GO

CREATE PROCEDURE [dbo].[InsertInvitees]
(
	@eventId INT,
	@studentId INT,
	@userId VARCHAR(255)
)
AS
BEGIN
	SET NOCOUNT ON;
	DECLARE @responseId INT, @dietaryRequirementId INT, @rsvpId INT;
BEGIN TRY
BEGIN TRANSACTION;
		SET @responseId = (SELECT responseId FROM rsvpResponses WHERE response = 'Pending')
		SET @dietaryRequirementId = (SELECT dietaryRequirementId FROM dietaryRequirements WHERE dietaryRequirement = 'None')

		INSERT INTO rsvps (studentId, eventId, inviteCategory, dietaryRequirementId, allergies, notes)
		VALUES (@studentId, @eventId, 'Tier', @dietaryRequirementId, 'N/A', 'N/A')

		SET @rsvpId = SCOPE_IDENTITY()

		INSERT INTO rsvpsResponseHistory (rsvpId, responseId, notes, userId)
		VALUES (@rsvpId, @responseId, 'N/A', @userId)

		COMMIT TRANSACTION;

END TRY
BEGIN CATCH
IF @@TRANCOUNT > 0
            ROLLBACK TRANSACTION;

        THROW;
END CATCH;
END
