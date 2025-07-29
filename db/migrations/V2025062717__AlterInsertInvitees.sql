SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

ALTER PROCEDURE [dbo].[InsertInvitees]
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

		INSERT INTO rsvps (studentId, eventId, inviteCategory, dietaryRequirementId, allergies)
		VALUES (@studentId, @eventId, 'Tier', @dietaryRequirementId, 'N/A')

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
