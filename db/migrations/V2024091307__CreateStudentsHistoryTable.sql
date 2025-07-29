

IF EXISTS (SELECT * FROM sys.objects
WHERE object_id = OBJECT_ID(N'[dbo].[studentsHistory]') AND type in (N'U'))
BEGIN
  DROP TABLE studentsHistory;
END;

CREATE TABLE [dbo].[studentsHistory] (
	[studentsHistoryId] [INT] IDENTITY(1,1) PRIMARY KEY,
    [studentId] INT,
    [name] NVARCHAR(255),
    [surname] NVARCHAR(255),
    [email] NVARCHAR(255),
    [contactNumber] NVARCHAR(12),
    [yearOfFunding] NVARCHAR(4),
	[address] NVARCHAR(255),
	[suburb] NVARCHAR(255),
	[city] NVARCHAR(255),
	[postalCode] NVARCHAR(4),
    [changeType] NVARCHAR(20),
    [changeDate] DATETIME DEFAULT GETDATE(),
    [changedBy] NVARCHAR(255),
    [applicationGuid] NVARCHAR(255) 
);
 


