IF EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[AllocationsInsert]') AND type in (N'P', N'PC'))
DROP PROCEDURE [dbo].[AllocationsInsert]
GO

CREATE PROCEDURE AllocationsInsert
    @userId VARCHAR(256),
    @amount MONEY,
	@universityName VARCHAR(256),
    @year INT,
    @action VARCHAR(14)
AS
BEGIN
    SET NOCOUNT ON;
    BEGIN TRY
        BEGIN TRANSACTION;

		DECLARE @universityDepartmentId INT;

		DECLARE universityDepartmentIdCursor CURSOR FOR
		SELECT DISTINCT(universityDepartments.universityDepartmentId) FROM universityDepartments
		INNER JOIN universities ON universityDepartments.universityId = universities.universityId
		WHERE universities.universityName = @universityName;

		OPEN universityDepartmentIdCursor;

		FETCH NEXT FROM universityDepartmentIdCursor INTO @universityDepartmentId;

		WHILE @@FETCH_STATUS = 0
		BEGIN
			
			INSERT INTO allocations (universityDepartmentId, yearOfFunding, userId, amount)
			VALUES (@universityDepartmentId, @year, @userId, @amount / (SELECT COUNT(DISTINCT(universityDepartments.universityDepartmentId)) FROM universityDepartments
			INNER JOIN universities ON universityDepartments.universityId = universities.universityId
			WHERE universities.universityName = @universityName));

			FETCH NEXT FROM universityDepartmentIdCursor INTO @universityDepartmentId;
		END

		CLOSE universityDepartmentIdCursor;
		DEALLOCATE universityDepartmentIdCursor;

        IF @action = 'add'
        BEGIN
            EXEC TotalFundInsert @userId, @amount, @year
        END


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


