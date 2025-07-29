IF EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[AllocationsInsert]') AND type in (N'P', N'PC'))
DROP PROCEDURE [dbo].[AllocationsInsert]
GO

CREATE PROCEDURE AllocationsInsert
    @userId VARCHAR(256),
    @amount INT,
	@universityName VARCHAR(256)
AS
BEGIN
    SET NOCOUNT ON;
    BEGIN TRY
        BEGIN TRANSACTION;

		DECLARE @universityDepartmentId INT;

		DECLARE universityDepartmentIdCursor CURSOR FOR
		SELECT DISTINCT(allocations.universityDepartmentId) FROM allocations
		INNER JOIN universityDepartments ON allocations.universityDepartmentId = universityDepartments.universityDepartmentId 
		INNER JOIN universities ON universityDepartments.universityId = universities.universityId
		WHERE universities.universityName = @universityName 
		AND allocations.yearOfFunding = YEAR(GETDATE()) 
		AND universities.universityStatusId = (SELECT universityStatusId FROM universityStatus WHERE [status] = 'Active');

		OPEN universityDepartmentIdCursor;

		FETCH NEXT FROM universityDepartmentIdCursor INTO @universityDepartmentId;

		WHILE @@FETCH_STATUS = 0
		BEGIN
			
			INSERT INTO allocations (universityDepartmentId, yearOfFunding, userId, amount)
			VALUES (@universityDepartmentId, YEAR(GETDATE()), @userId, CAST(@amount / (SELECT COUNT(DISTINCT(allocations.universityDepartmentId)) FROM allocations
			INNER JOIN universityDepartments ON allocations.universityDepartmentId = universityDepartments.universityDepartmentId 
			INNER JOIN universities ON universityDepartments.universityId = universities.universityId
			WHERE universities.universityName = @universityName 
			AND allocations.yearOfFunding = YEAR(GETDATE()) 
			AND universities.universityStatusId = (SELECT universityStatusId FROM universityStatus WHERE [status] = 'Active')) AS INT));

			FETCH NEXT FROM universityDepartmentIdCursor INTO @universityDepartmentId;
		END

		CLOSE universityDepartmentIdCursor;
		DEALLOCATE universityDepartmentIdCursor;


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


