IF EXISTS (SELECT * FROM sys.objects 
WHERE object_id = OBJECT_ID(N'fk_applicationAmountHistoryApplicationId') AND type in (N'F'))
BEGIN
  ALTER TABLE applicationAmountHistory DROP CONSTRAINT fk_applicationAmountHistoryApplicationId
END;

IF OBJECT_ID('applicationAmountHistory', 'U') IS NULL

CREATE TABLE applicationAmountHistory (
    [applicationAmountHistoryId] [INT] IDENTITY(1,1) PRIMARY KEY NOT NULL,
    [userId] VARCHAR(256) NOT NULL,
    [applicationId] [INT] NOT NULL,
    [oldAmount] [MONEY] NOT NULL,
    [newAmount] [MONEY] NOT NULL,
    [createdAt] [DATETIME] NOT NULL DEFAULT GETDATE()
);

ALTER TABLE applicationAmountHistory
ADD CONSTRAINT fk_applicationAmountHistoryApplicationId
FOREIGN KEY (applicationId)
REFERENCES universityApplications(applicationId);