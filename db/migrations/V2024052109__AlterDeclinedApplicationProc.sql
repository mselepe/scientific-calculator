SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
ALTER PROCEDURE [dbo].[updateTablesAfterDecline]
    @status VARCHAR (250),
    @applicationGuid VARCHAR(255),
    @userId VARCHAR(276),
    @reason VARCHAR(256),
	@motivation VARCHAR(250)
    
AS
BEGIN
    SET NOCOUNT ON;
    BEGIN TRY
        BEGIN TRANSACTION;

        INSERT INTO applicationStatusHistory (userId, applicationId, statusId)
        VAlUES (@userId,
                (SELECT applicationId FROM universityApplications WHERE applicationGuid=@applicationGuid),
                (SELECT statusId FROM applicationStatus WHERE status= @status)
        )

		DECLARE @scopeApplicationStatusHistoryId INT;
		SET @scopeApplicationStatusHistoryId = SCOPE_IDENTITY();

        INSERT INTO declinedReasonsHistory (applicationStatusHistoryId, reasonId)
        VALUES (
			@scopeApplicationStatusHistoryId,
			(SELECT reasonId FROM declinedReasons WHERE reason = @reason)
		);

		IF @motivation IS NOT NULL
		BEGIN
			DECLARE @scopeDeclinedReasonHistoryId INT;
			SET @scopeDeclinedReasonHistoryId = SCOPE_IDENTITY();

			INSERT INTO declinedMotivations ( motivation, declinedReasonsHistoryId)
			VALUES (
			@motivation, @scopeDeclinedReasonHistoryId
			);
		END;

		SELECT students.name, students.email FROM students
		INNER JOIN universityApplications
		ON universityApplications.studentId=students.studentId
		WHERE universityApplications.applicationGuid = @applicationGuid;

        COMMIT TRANSACTION;
    END TRY
    BEGIN CATCH
        IF @@TRANCOUNT > 0
            ROLLBACK TRANSACTION;
            
        DECLARE @ErrorMessage NVARCHAR(4000);
        DECLARE @ErrorSeverity INT;
        DECLARE @ErrorState INT;

        SELECT 
            @ErrorMessage = ERROR_MESSAGE(),
            @ErrorSeverity = ERROR_SEVERITY(),
            @ErrorState = ERROR_STATE();

        RAISERROR (@ErrorMessage, @ErrorSeverity, @ErrorState);
    END CATCH;
END;