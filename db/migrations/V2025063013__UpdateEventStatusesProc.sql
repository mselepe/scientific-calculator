IF EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[UpdateEventStatus]') AND type in (N'P', N'PC'))
DROP PROCEDURE [dbo].[UpdateEventStatus]
GO

CREATE PROCEDURE [dbo].[UpdateEventStatus]
	@eventId INT,
	@startDate DATETIME,
	@endDate DATETIME
AS
BEGIN
	SET NOCOUNT ON;

	DECLARE @now DATETIME = GETDATE();
	DECLARE @status NVARCHAR(50);
	DECLARE @eventStatusId INT;
	DECLARE @latestEventStatusId INT;

	WITH LatestStatuses AS (
		SELECT eventId, eventStatusId,
		ROW_NUMBER() OVER (PARTITION BY eventId ORDER BY createdAt DESC) AS rn_status
		FROM eventsStatusHistory
	)
	SELECT @latestEventStatusId = eventStatusId
	FROM LatestStatuses
	WHERE eventId = @eventId AND rn_status = 1;

	IF @now < @startDate
		SET @status = 'Upcoming';
	ELSE IF @now BETWEEN @startDate AND @endDate
		SET @status = 'Ongoing';
	ELSE IF @now > @endDate
		SET @status = 'Past';

	SELECT @eventStatusId = eventStatusId
	FROM eventStatuses
	WHERE eventStatus = @status;

	IF @eventStatusId IS NOT NULL AND @eventStatusId <> @latestEventStatusId
	BEGIN
		INSERT INTO eventsStatusHistory (eventId, eventStatusId, userId)
		VALUES (@eventId, @eventStatusId, 'system');
	END
END;