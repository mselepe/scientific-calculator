SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
ALTER PROCEDURE [dbo].[update_application_fields]
    @applicationGuid NVARCHAR(255),
    @name NVARCHAR(255) = NULL,
    @surname NVARCHAR(255) = NULL,
    @email NVARCHAR(255) = NULL,
    @contactNumber NVARCHAR(12) = NULL,
    @yearOfFunding NVARCHAR(4) = NULL,
    @address NVARCHAR(255) = NULL,
    @code NVARCHAR(4) = NULL,
    @city NVARCHAR(255) = NULL,
    @suburb NVARCHAR(255) = NULL,
    @university NVARCHAR(255) = NULL,
    @faculty NVARCHAR(255) = NULL,
    @degree NVARCHAR(255) = NULL,
    @yearOfStudy NVARCHAR(20),
    @degreeDuration INT,
    @confirmHonors VARCHAR(3),
    @department NVARCHAR(50),
    @userId NVARCHAR(255) = NULL
AS
BEGIN
    SET NOCOUNT ON;
    BEGIN TRY
        BEGIN TRANSACTION;

        DECLARE @currentName NVARCHAR(255),
                @currentSurname NVARCHAR(255),
                @currentEmail NVARCHAR(255),
                @currentContactNumber NVARCHAR(12),
                @currentAddress NVARCHAR(255),
                @currentSuburb NVARCHAR(255),
                @currentCity NVARCHAR(255),
                @currentPostalCode NCHAR(4),
                @universityDepartmentId INT;

        SELECT
            @currentName = s.name,
            @currentSurname = s.surname,
            @currentEmail = s.email,
            @currentContactNumber = s.contactNumber,
            @currentAddress = s.streetAddress,
            @currentSuburb = s.suburb,
            @currentCity = s.city,
            @currentPostalCode = s.postalCode
        FROM students s
        INNER JOIN universityApplications u ON u.studentId = s.studentId
        WHERE u.applicationGuid = @applicationGuid;

        INSERT INTO [dbo].[studentsHistory] (
            [studentId], [name], [surname], [email], [contactNumber],
            [yearOfFunding],[address],[suburb],[city],[postalCode], [changeType], [changeDate], [changedBy], [applicationGuid]
        )
        SELECT
            s.studentId, @currentName, @currentSurname, @currentEmail, @currentContactNumber,
            u.yearOfFunding,@currentAddress,@currentSuburb,@currentCity,@currentPostalCode, 'PRE_UPDATE', GETDATE(), @userId, @applicationGuid
        FROM students s
        INNER JOIN universityApplications u ON u.studentId = s.studentId
        WHERE u.applicationGuid = @applicationGuid;

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

        IF @contactNumber IS NOT NULL
            UPDATE students
            SET contactNumber = @contactNumber
            WHERE studentId = (SELECT studentId FROM universityApplications WHERE applicationGuid = @applicationGuid);

        IF @yearOfFunding IS NOT NULL
            UPDATE universityApplications
            SET yearOfFunding = @yearOfFunding
            WHERE applicationGuid = @applicationGuid;

        IF @address IS NOT NULL
            UPDATE students
            SET streetAddress = @address
            WHERE studentId = (SELECT studentId FROM universityApplications WHERE applicationGuid = @applicationGuid);

        IF @suburb IS NOT NULL
            UPDATE students
            SET suburb = @suburb
            WHERE studentId = (SELECT studentId FROM universityApplications WHERE applicationGuid = @applicationGuid);

        IF @city IS NOT NULL
            UPDATE students
            SET city = @city
            WHERE studentId = (SELECT studentId FROM universityApplications WHERE applicationGuid = @applicationGuid);

        IF @code IS NOT NULL
            UPDATE students
            SET postalCode = @code
            WHERE studentId = (SELECT studentId FROM universityApplications WHERE applicationGuid = @applicationGuid);

        IF @university IS NOT NULL AND @faculty IS NOT NULL AND @department IS NOT NULL
        BEGIN
            SELECT @universityDepartmentId = ud.universityDepartmentId
            FROM universityDepartments ud
            INNER JOIN universities u ON ud.universityId = u.universityId
            INNER JOIN faculties f ON ud.facultyId = f.facultyId
            WHERE u.universityName = @university
              AND f.facultyName = @faculty
              AND ud.universityDepartmentName = @department;

            IF @universityDepartmentId IS NOT NULL
                UPDATE universityApplications
                SET universityDepartmentId = @universityDepartmentId
                WHERE applicationGuid = @applicationGuid;
            ELSE
                THROW 50001, 'The specified university, faculty, and department combination was not found.', 1;
        END

        IF @degree IS NOT NULL
            UPDATE universityApplications
            SET degreeName = @degree
            WHERE applicationGuid = @applicationGuid;

        IF @yearOfStudy IS NOT NULL
            UPDATE studentApplications
            SET yearOfStudy = @yearOfStudy
            WHERE applicationId = (SELECT applicationId FROM universityApplications WHERE applicationGuid=@applicationGuid);

        IF @degreeDuration IS NOT NULL
            UPDATE universityApplications
            SET degreeDuration = @degreeDuration
            WHERE applicationGuid = @applicationGuid;

        IF @confirmHonors IS NOT NULL
            UPDATE studentApplications
            SET confirmHonors = @confirmHonors
            WHERE applicationId = (SELECT applicationId FROM universityApplications WHERE applicationGuid=@applicationGuid);

        INSERT INTO [dbo].[studentsHistory] (
            [studentId], [name], [surname], [email], [contactNumber],
            [yearOfFunding],[address],[suburb],[city],[postalCode], [changeType], [changeDate], [changedBy], [applicationGuid]
        )
        SELECT
            s.studentId, s.name, s.surname, s.email, s.contactNumber,
            u.yearOfFunding,s.streetAddress ,s.suburb,s.city,s.postalCode,'POST_UPDATE', GETDATE(), @userId, @applicationGuid
        FROM students s
        INNER JOIN universityApplications u ON u.studentId = s.studentId
        WHERE u.applicationGuid = @applicationGuid;

        SELECT @applicationGuid AS applicationGuid, s.name AS name, s.surname AS surname, @currentEmail AS initialEmail
        FROM universityApplications u
        INNER JOIN students s ON u.studentId = s.studentId
        WHERE u.applicationGuid = @applicationGuid;

        COMMIT TRANSACTION;
    END TRY
    BEGIN CATCH
        IF @@TRANCOUNT > 0
            ROLLBACK TRANSACTION;

        THROW;
    END CATCH
END;
