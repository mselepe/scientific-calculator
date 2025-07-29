IF EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[ReallocationsInsert]') AND type in (N'P', N'PC'))
DROP PROCEDURE [dbo].[ReallocationsInsert]
GO

CREATE PROCEDURE ReallocationsInsert
    @university VARCHAR(256),
    @entities VARCHAR(15),
    @userId VARCHAR(256),
    @moneyReallocated MONEY,
    @fromOldAllocation MONEY,
    @fromNewAllocation MONEY,
    @toOldAllocation MONEY,
    @toNewAllocation MONEY,
	@from VARCHAR(256),
    @to VARCHAR(256)
AS
BEGIN
    SET NOCOUNT ON;
    BEGIN TRY
        BEGIN TRANSACTION;

        DECLARE @newId INT
        
        IF @entities = 'departments' AND @university IS NOT NULL
            BEGIN

            DECLARE @universityId INT
            SET @universityId = (
                SELECT universityId
                FROM universities
                WHERE universityName = @university
            )

            DECLARE @fromDepartmentId VARCHAR(256)
            SET @fromDepartmentId = (
                SELECT universityDepartmentId
                FROM universityDepartments
                WHERE universityDepartmentName = @from
                AND universityId = @universityId
            )

            DECLARE @toDepartmentId VARCHAR(256)
            SET @toDepartmentId = (
                SELECT universityDepartmentId
                FROM universityDepartments
                WHERE universityDepartmentName = @to
                AND universityId = @universityId
            )

            INSERT INTO departmentReallocations(
                reallocationTo, reallocationFrom,
                fromNewAllocation, fromOldAllocation,
                toNewAllocation, toOldAllocation,
                moneyReallocated, userId
            )
            VALUES(
                    @toDepartmentId, @fromDepartmentId,
                    @fromNewAllocation, @fromOldAllocation,
                    @toNewAllocation, @toOldAllocation,
                    @moneyReallocated, @userId
                )

            SET @newId = SCOPE_IDENTITY()
            END
        ELSE IF @entities = 'universtities' AND @university IS NULL
            BEGIN

            DECLARE @fromUniversityId VARCHAR(256)
            SET @fromUniversityId = (
                SELECT universityId
                FROM universities
                WHERE universityName = @from
            )

            DECLARE @toUniversityId VARCHAR(256)
            SET @toUniversityId = (
                SELECT universityId
                FROM universities
                WHERE universityName = @to)

            INSERT INTO universityReallocations(
                reallocationTo, reallocationFrom,
                fromNewAllocation, fromOldAllocation,
                toNewAllocation, toOldAllocation,
                moneyReallocated, userId
            )
            VALUES(
                    @toUniversityId, @fromUniversityId,
                    @fromNewAllocation, @fromOldAllocation,
                    @toNewAllocation, @toOldAllocation,
                    @moneyReallocated, @userId
                )


            SET @newId = SCOPE_IDENTITY()
            END

        SELECT @newId AS newReallocationId;
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


