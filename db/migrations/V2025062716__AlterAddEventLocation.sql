SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

ALTER PROCEDURE [dbo].[AddEventLocation]
(
	@eventId INT,
	@locationName VARCHAR(255),
	@addressLineOne VARCHAR(255) = '',
	@addressLineTwo VARCHAR(255),
	@suburb VARCHAR(255),
	@city VARCHAR(255),
	@code VARCHAR(10),
	@meetingUrl VARCHAR(255),
	@userId VARCHAR(255)
)
AS
BEGIN
	SET NOCOUNT ON;
	DECLARE @locationId INT, @eventLocationId INT;
BEGIN TRY
BEGIN TRANSACTION;
		SET @addressLineOne = ISNULL(@addressLineOne, '')

SELECT @locationId = locationId
FROM locations
WHERE
  locationName = @locationName
   OR addressLineTwo = @addressLineTwo;

IF @locationId IS NOT NULL
BEGIN
INSERT INTO eventLocationsHistory (eventId, userId, locationId)
VALUES (@eventId, @userId, @locationId)

  IF @meetingUrl IS NOT NULL AND @meetingUrl <> ''
BEGIN
INSERT INTO eventMeetingUrlHistory (meetingUrl, eventId, userId)
VALUES (@meetingUrl, @eventId, @userId)
END

COMMIT TRANSACTION;
RETURN;
END

INSERT INTO locations (locationName, addressLineOne, addressLineTwo, suburb, city, code)
VALUES (@locationName, @addressLineOne, @addressLineTwo, @suburb, @city, @code);

SET @locationId = SCOPE_IDENTITY();

INSERT INTO eventLocationsHistory (eventId, userId, locationId)
VALUES (@eventId, @userId, @locationId)

  IF @meetingUrl IS NOT NULL AND @meetingUrl <> ''
BEGIN
INSERT INTO eventMeetingUrlHistory (meetingUrl, eventId, userId)
VALUES (@meetingUrl, @eventId, @userId)
END

COMMIT TRANSACTION
END TRY
BEGIN CATCH
IF @@TRANCOUNT > 0
            ROLLBACK TRANSACTION;

        THROW;
END CATCH;
END;
