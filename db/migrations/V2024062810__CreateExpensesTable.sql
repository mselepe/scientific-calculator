IF EXISTS (SELECT * FROM sys.objects 
WHERE object_id = OBJECT_ID(N'fk_expenseApplicationId') AND type in (N'F'))
BEGIN
  ALTER TABLE [dbo].[expenses] DROP CONSTRAINT fk_expenseApplicationId;
END;

IF EXISTS (SELECT * FROM sys.objects 
WHERE object_id = OBJECT_ID(N'[dbo].[expenses]') AND type in (N'U'))
BEGIN
  DROP TABLE [dbo].[expenses] ;
END;

CREATE TABLE [dbo].[expenses] (
 [expensesId] [int] IDENTITY(1,1) NOT NULL,
	[accommodation] [money] NOT NULL,
	[tuition] [money] NOT NULL,
	[meals] [money] NOT NULL,
	[other] [money] NULL,
	[applicationId] [int] NOT NULL,
);

ALTER TABLE [dbo].[expenses] 
WITH CHECK ADD  CONSTRAINT [fk_expenseApplicationId] 
FOREIGN KEY([applicationId])
REFERENCES [dbo].[universityApplications] ([applicationId])
GO