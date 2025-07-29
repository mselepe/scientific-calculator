IF EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[MoveFundsProc]') AND type in (N'P', N'PC'))
DROP PROCEDURE [dbo].[MoveFundsProc]
GO

CREATE PROCEDURE MoveFundsProc
    @userId VARCHAR(256),
    @amount MONEY,
	@departmentName VARCHAR(256),
    @universityName VARCHAR(256)
AS
BEGIN
    SET NOCOUNT ON;
    BEGIN TRY
        BEGIN TRANSACTION;

		INSERT INTO allocations(universityDepartmentId, yearOfFunding, userId, amount)
        VALUES (
            (SELECT universityDepartments.universityDepartmentId FROM universityDepartments
            INNER JOIN universities ON universityDepartments.universityId = universities.universityId
            WHERE (universities.universityName = @universityName
            AND universityDepartments.universityDepartmentName = @departmentName)),
            YEAR(GETDATE()), @userId, @amount
        )

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


