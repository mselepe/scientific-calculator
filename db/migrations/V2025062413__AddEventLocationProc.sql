IF EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[AddEventLocation]') AND type in (N'P', N'PC'))
DROP PROCEDURE [dbo].[AddEventLocation]
GO

CREATE PROCEDURE [dbo].[AddEventLocation]
(
	@eventId INT,
	@locationName VARCHAR(255),
	@addressLineOne VARCHAR(255) = '',
	@addressLineTwo VARCHAR(255),
	@suburb VARCHAR(255),
	@city VARCHAR(255),
	@code VARCHAR(10),
	@meetingUrl VARCHAR(255) = 'N/A',
	@userId VARCHAR(255)
)
AS
BEGIN
	SET NOCOUNT ON;
	DECLARE @locationId INT, @eventLocationId INT;
BEGIN TRY
BEGIN TRANSACTION;
		SET @meetingUrl = ISNULL(@meetingUrl, 'N/A');
		SET @addressLineOne = ISNULL(@addressLineOne, '')

SELECT @locationId = locationId
FROM locations
WHERE
    locationName = @locationName
   OR addressLineTwo = @addressLineTwo;

IF @locationId IS NOT NULL
BEGIN
INSERT INTO eventLocations (eventId, locationId, meetingUrl)
VALUES (@eventId, @locationId, @meetingUrl);

SET @eventLocationId = SCOPE_IDENTITY();

INSERT INTO eventLocationsHistory (eventLocationId, userId)
VALUES (@eventLocationId, @userId)

    COMMIT TRANSACTION;
RETURN;
END

INSERT INTO locations (locationName, addressLineOne, addressLineTwo, suburb, city, code)
VALUES (@locationName, @addressLineOne, @addressLineTwo, @suburb, @city, @code);

SET @locationId = SCOPE_IDENTITY();

INSERT INTO eventLocations (eventId, locationId, meetingUrl)
VALUES (@eventId, @locationId, @meetingUrl);

SET @eventLocationId = SCOPE_IDENTITY();

INSERT INTO eventLocationsHistory (eventLocationId, userId)
VALUES (@eventLocationId, @userId)

    COMMIT TRANSACTION

END TRY
BEGIN CATCH
IF @@TRANCOUNT > 0
            ROLLBACK TRANSACTION;

        THROW;
END CATCH;
END;
