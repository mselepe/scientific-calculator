IF EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'fk_rsvpsLocationHistory_rsvpId') AND type IN (N'F'))
BEGIN
ALTER TABLE rsvpsLocationHistory DROP CONSTRAINT fk_rsvpsLocationHistory_rsvpId;
END;

IF EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'fk_rsvpsLocationHistory_eventLocationId') AND type IN (N'F'))
BEGIN
ALTER TABLE rsvpsLocationHistory DROP CONSTRAINT fk_rsvpsLocationHistory_eventLocationId;
END;

IF EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'rsvpsLocationHistory') AND type IN (N'U'))
BEGIN
DROP TABLE rsvpsLocationHistory;
END;

CREATE TABLE rsvpsLocationHistory (
  [rsvpsLocationHistoryId] [INT] IDENTITY(1,1) PRIMARY KEY,
  [rsvpId] [INT] NOT NULL,
  [eventLocationId] [INT] NOT NULL,
  [userId] [VARCHAR](255) NOT NULL,
  [createdAt] [DATETIME] NOT NULL DEFAULT GETDATE()
);

ALTER TABLE rsvpsLocationHistory
ADD CONSTRAINT fk_rsvpsLocationHistory_rsvpId
FOREIGN KEY (rsvpId)
REFERENCES rsvps(rsvpId);

ALTER TABLE rsvpsLocationHistory
ADD CONSTRAINT fk_rsvpsLocationHistory_eventLocationId
FOREIGN KEY (eventLocationId)
REFERENCES eventLocations(eventLocationId);
