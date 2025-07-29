IF EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[GetGroupedPendingApplicationDetails]') AND type in (N'P', N'PC'))
DROP PROCEDURE [dbo].[GetGroupedPendingApplicationDetails]
GO

IF EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[GetGroupRejectedApplicationDetails]') AND type in (N'P', N'PC'))
DROP PROCEDURE  [dbo].[GetGroupRejectedApplicationDetails]
GO

IF EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[GetGroupedInReviewApplicationDetails]') AND type in (N'P', N'PC'))
DROP PROCEDURE [dbo].[GetGroupedInReviewApplicationDetails]
GO

IF EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[GetGroupedEmailFailedDetails]') AND type in (N'P', N'PC'))
DROP PROCEDURE [dbo].[GetGroupedEmailFailedDetails]
GO

IF EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[GetGroupedApplicationDetailsForContract]') AND type in (N'P', N'PC'))
DROP PROCEDURE [dbo].[GetGroupedApplicationDetailsForContract]
GO

IF EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[GetGroupedApplicationDetailsForFundSpread]') AND type in (N'P', N'PC'))
DROP PROCEDURE [dbo].[GetGroupedApplicationDetailsForFundSpread]
GO

IF EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[GetGroupedApplicationDetailsForInvoice]') AND type in (N'P', N'PC'))
DROP PROCEDURE  [dbo].[GetGroupedApplicationDetailsForInvoice]
GO

IF EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[GetGroupedApplicationDetailsForPayment]') AND type in (N'P', N'PC'))
DROP PROCEDURE  [dbo].[GetGroupedApplicationDetailsForPayment]
GO