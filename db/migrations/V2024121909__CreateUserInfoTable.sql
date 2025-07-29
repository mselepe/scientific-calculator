IF  EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[userInformation]') AND type in (N'U'))
DROP TABLE [dbo].[userInformation]
GO

SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO

CREATE TABLE [dbo].[userInformation](
	[userInformationId] [int] IDENTITY(1,1) NOT NULL,
	[givenName] [varchar](255) NOT NULL,
	[surname] [varchar](255) NOT NULL,
	[emailAddress] [varchar](255) NOT NULL,
	[id] [varchar](255) NOT NULL,
	[contactNumber] [varchar](15) NULL,
	[role] [varchar](10) NULL,
	[rank] [varchar](15) NULL,
	[Faculty] [varchar](255) NULL,
	[University] [varchar](255) NULL,
	[Department] [varchar](255) NULL,
	[accountEnabled] [bit] NULL
)
GO