IF EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[StoreUserData]') AND type in (N'P', N'PC'))
DROP PROCEDURE [dbo].[StoreUserData]
GO

CREATE PROCEDURE StoreUserData
    @inviterUserId NVARCHAR(256),
    @invitedEmail NVARCHAR(256),
    @university NVARCHAR(256),
    @department NVARCHAR(256),
    @faculty NVARCHAR(256),
    @role NVARCHAR(10),
    @rank NVARCHAR(20)
AS
BEGIN
    SET NOCOUNT ON;
    BEGIN TRY
        BEGIN TRANSACTION;


        IF NOT EXISTS (SELECT 1
        FROM invitedUsers
        WHERE invitedEmail = @invitedEmail
        )
        BEGIN
            DECLARE @invitedUserId INT

            INSERT INTO invitedUsers (inviterUserId, invitedEmail,universityId, CreatedAt, roleId, rankId, facultyId)
            VALUES (@inviterUserId, @invitedEmail,
            (SELECT universityId FROM universities WHERE universityName = @university),
            GETDATE(), (SELECT roleId FROM roles WHERE role = @role),
            (SELECT rankId FROM ranks WHERE rank = @rank),
            (SELECT facultyId 
                FROM faculties 
                WHERE (facultyName = @faculty)));

            IF @department IS NOT NULL
            BEGIN
                SET @invitedUserId = SCOPE_IDENTITY();
                INSERT INTO invitedUsersDepartments(invitedUserId, universityDepartmentId)
                VALUES (@invitedUserId, (SELECT universityDepartmentId 
                FROM universityDepartments 
                JOIN universities
                ON universityDepartments.universityId = universities.universityId
                WHERE universityDepartmentName = @department
                AND universityName = @university))
            END
        END;

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


