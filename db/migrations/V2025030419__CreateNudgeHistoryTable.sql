IF EXISTS (SELECT * FROM sys.foreign_keys WHERE name = 'fk_nudgeHistory_nudgeReasonId')
BEGIN
    ALTER TABLE nudgeHistory
    DROP CONSTRAINT fk_nudgeHistory_nudgeReasonId;
END;

IF EXISTS (SELECT * FROM sys.foreign_keys WHERE name = 'fk_nudgeHistory_applicationId')
BEGIN
    ALTER TABLE nudgeHistory
    DROP CONSTRAINT fk_nudgeHistory_applicationId;
END;


IF EXISTS (SELECT * FROM sys.tables WHERE name = 'nudgeHistory')
BEGIN
    DROP TABLE nudgeHistory;
END;

IF EXISTS (SELECT * FROM sys.tables WHERE name = 'nudgeReason')
BEGIN
    DROP TABLE nudgeReason;
END;

CREATE TABLE nudgeHistory(
	[nudgeHistoryId] INT IDENTITY(1,1) PRIMARY KEY,
	[applicationId] INT NOT NULL,
	[nudgeReasonId] INT NOT NULL,
	[nudgerUserId] VARCHAR(256) NOT NULL,
	[nudgedEmail] VARCHAR(256) NOT NULL,
	[createdAt] [DATETIME] NOT NULL DEFAULT GETDATE()
);

CREATE TABLE nudgeReason(
	[nudgeReasonId] INT IDENTITY(1,1) PRIMARY KEY,
	nudgeReason VARCHAR(50) NOT NULL
);

INSERT INTO nudgeReason(nudgeReason)
VALUES('request student transcripts'),('request renewal'),('request approval')



ALTER TABLE nudgeHistory
ADD CONSTRAINT fk_nudgeHistory_applicationId
FOREIGN KEY (applicationId)
REFERENCES universityApplications(applicationId);

ALTER TABLE nudgeHistory
ADD CONSTRAINT fk_nudgeHistory_nudgeReasonId
FOREIGN KEY (nudgeReasonId)
REFERENCES nudgeReason(nudgeReasonId);
