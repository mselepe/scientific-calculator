SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

ALTER PROCEDURE [dbo].[CreateEvent]
(
	@eventName VARCHAR(255),
	@eventDescription VARCHAR(255),
	@eventImageBlobName VARCHAR(255),
	@eventType VARCHAR(255),
	@startDate DATETIME,
	@endDate DATETIME,
	@userId VARCHAR(255),
	@eventStatus VARCHAR(255),
	@allowDietaryRequirements BIT,
	@allowNotes BIT
)
AS
BEGIN
	SET NOCOUNT ON;
	DECLARE @eventTypeId INT, @eventStatusId INT, @eventId INT;
BEGIN TRY
BEGIN TRANSACTION;
		SET @eventTypeId = (SELECT eventTypeId FROM eventTypes WHERE eventTypeName = @eventType);
		SET @eventStatusId = (SELECT eventStatusId FROM eventStatuses WHERE eventStatus = 'Upcoming');

INSERT INTO events (eventName, eventDescription, eventImageBlobName, eventTypeId, allowDietaryRequirements, allowNotes)
VALUES (@eventName, @eventDescription, @eventImageBlobName, @eventTypeId, @allowDietaryRequirements, @allowNotes);

SET @eventId = SCOPE_IDENTITY();

INSERT INTO eventsStatusHistory (eventId, eventStatusId, userId)
VALUES (@eventId, @eventStatusId, @userId);

INSERT INTO eventsStartDateHistory (eventId, startDate, userId)
VALUES (@eventId, @startDate, @userId);

INSERT INTO eventsEndDateHistory (eventId, endDate, userId)
VALUES (@eventId, @endDate, @userId);

SELECT @eventId AS eventId;

COMMIT TRANSACTION;

END TRY
BEGIN CATCH
IF @@TRANCOUNT > 0
            ROLLBACK TRANSACTION;

        THROW;
END CATCH;
END;
