DROP PROCEDURE IF EXISTS dbo.UpdateNudgeHistory;
GO

CREATE PROCEDURE dbo.UpdateNudgeHistory
  @nudgeReason VARCHAR(50),
  @nudgerUserId VARCHAR(256),
  @nudgeHistoryTVP [dbo].[nudgeHistoryTVP] READONLY
AS
BEGIN
    BEGIN TRANSACTION;
    BEGIN TRY

      INSERT INTO nudgeHistory (
        applicationId, 
        nudgeReasonId, 
        nudgerUserId, 
        nudgedEmail
      )
      SELECT applicationId, (SELECT nudgeReasonId FROM nudgeReason WHERE nudgeReason = @nudgeReason),
      @nudgerUserId, nudgedEmail FROM @nudgeHistoryTVP 
            
      COMMIT TRANSACTION;
    END TRY

    BEGIN CATCH
      IF @@TRANCOUNT > 0
        ROLLBACK TRANSACTION;
        
      THROW;
    END CATCH
END