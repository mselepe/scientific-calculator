/****** Object:  StoredProcedure [dbo].[StoreUserData]    Script Date: 2024/11/18 09:06:40 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
ALTER PROCEDURE [dbo].[StoreUserData]
    @inviterUserId NVARCHAR(256),
    @invitedEmail NVARCHAR(256),
    @university NVARCHAR(256),
    @department NVARCHAR(256),
    @faculty NVARCHAR(256),
    @role NVARCHAR(10),
    @rank NVARCHAR(20),
    @invitedUserStatus NVARCHAR(20)

AS
BEGIN
    SET NOCOUNT ON;
    BEGIN TRY
        BEGIN TRANSACTION;

        IF NOT EXISTS (
            SELECT 1
            FROM invitedUsers
            WHERE invitedEmail = @invitedEmail
        )
        BEGIN
            DECLARE @invitedUserId INT;

            INSERT INTO invitedUsers (inviterUserId, invitedEmail, universityId, CreatedAt, roleId, rankId, facultyId,invitedStatusId)
            VALUES (
                @inviterUserId, 
                @invitedEmail,
                (SELECT universityId FROM universities WHERE universityName = @university),
                GETDATE(), 
                (SELECT roleId FROM roles WHERE role = @role),
                (SELECT rankId FROM ranks WHERE rank = @rank),
                (SELECT facultyId FROM faculties WHERE facultyName = @faculty),
				(SELECT invitedUserStatusId FROM invitedUserStatus WHERE [status] = @invitedUserStatus)
            );

            SET @invitedUserId = SCOPE_IDENTITY();

            INSERT INTO invitedUserStatusHistory (userId, invitedUserStatusId, createdAt)
            VALUES (
                @invitedUserId,
                (SELECT invitedUserStatusId FROM invitedUserStatus WHERE [status] = @invitedUserStatus),
                GETDATE()
            );

            IF @department IS NOT NULL
            BEGIN
                INSERT INTO invitedUsersDepartments (invitedUserId, universityDepartmentId)
                VALUES (
                    @invitedUserId, 
                    (SELECT universityDepartmentId 
                     FROM universityDepartments 
                     JOIN universities ON universityDepartments.universityId = universities.universityId
                     WHERE universityDepartmentName = @department
                     AND universityName = @university)
                );
            END

        END;
		ELSE
        BEGIN
            DECLARE @existingUserId INT;

            SELECT @existingUserId = invitedUsersId 
            FROM invitedUsers
            WHERE invitedEmail = @invitedEmail;

        
            UPDATE invitedUsers
            SET invitedStatusId = (SELECT invitedUserStatusId FROM invitedUserStatus WHERE [status] = @invitedUserStatus)
            WHERE invitedUsersId = @existingUserId;

            INSERT INTO invitedUserStatusHistory (userId, invitedUserStatusId, createdAt)
            VALUES (
                @existingUserId,
                (SELECT invitedUserStatusId FROM invitedUserStatus WHERE [status] = @invitedUserStatus),
                GETDATE()
            );
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