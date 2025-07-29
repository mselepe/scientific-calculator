-- DROP TABLE

IF EXISTS (SELECT * FROM sys.objects 
WHERE object_id = OBJECT_ID(N'[dbo].[totalFundHistory]') AND type in (N'U'))
BEGIN
  DROP TABLE totalFundHistory;
END;

-- CREATE TABLE

CREATE TABLE totalFundHistory (
  [totalFundHistoryId] [INT] IDENTITY(1,1) PRIMARY KEY,
  [amount] [MONEY] NOT NULL,
  [createdAt] [DATETIME] NOT NULL DEFAULT GETDATE(),
  [yearOfFunding] [INT] NOT NULL DEFAULT YEAR(GETDATE()),
  [userId] [NVARCHAR] (256) NOT NULL
);

-- UPDATE TOTAL

INSERT INTO totalFundHistory(amount, yearOfFunding, userId)
SELECT SUM(amount) amount, yearOfFunding,'BBD' AS userId FROM allocations
GROUP BY yearOfFunding
