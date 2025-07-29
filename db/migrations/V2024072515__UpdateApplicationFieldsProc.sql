/****** Object:  StoredProcedure [dbo].[update_application_fields]    Script Date: 2024/07/25 21:05:39 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE PROCEDURE [dbo].[update_application_fields]
    @applicationGuid NVARCHAR(255),
	 @name NVARCHAR(255),
    @surname NVARCHAR(255),
    @email NVARCHAR(255),
    @phoneNumber NVARCHAR(12) NULL,
    @yearOfFunding NVARCHAR(4) NULL
AS
BEGIN
    SET NOCOUNT ON;

    BEGIN TRY
        BEGIN TRANSACTION;

        IF @name IS NOT NULL
            UPDATE students
            SET name = @name
            WHERE studentId = (SELECT studentId FROM universityApplications WHERE applicationGuid = @applicationGuid);

        IF @surname IS NOT NULL
            UPDATE students
            SET surname = @surname
            WHERE studentId = (SELECT studentId FROM universityApplications WHERE applicationGuid = @applicationGuid);

        IF @email IS NOT NULL
            UPDATE students
            SET email = @email
            WHERE studentId = (SELECT studentId FROM universityApplications WHERE applicationGuid = @applicationGuid);

        IF @phoneNumber IS NOT NULL
            UPDATE students
            SET contactNumber = @phoneNumber  -- Assuming contactNumber is the correct column name
            WHERE studentId = (SELECT studentId FROM universityApplications WHERE applicationGuid = @applicationGuid);

        IF @yearOfFunding IS NOT NULL
            UPDATE universityApplications
            SET yearOfFunding = @yearOfFunding
            WHERE applicationGuid = @applicationGuid;

        SELECT @applicationGuid AS applicationGuid, applicationGuid
        FROM universityApplications
        WHERE applicationGuid = @applicationGuid;

        COMMIT TRANSACTION;
    END TRY
    BEGIN CATCH
        IF @@TRANCOUNT > 0
            ROLLBACK TRANSACTION;

        THROW;
    END CATCH
END;
