IF EXISTS (SELECT *
FROM sys.objects
WHERE object_id = OBJECT_ID(N'[dbo].[InsertStudentProfilePicture]') AND type in (N'P', N'PC'))
DROP PROCEDURE [dbo].[InsertStudentProfilePicture]
GO

CREATE PROCEDURE [dbo].[InsertStudentProfilePicture]
    @studentId INT,
    @profilePictureBlobName NVARCHAR(255)
AS
BEGIN
    IF EXISTS (SELECT 1
    FROM [dbo].[students]
    WHERE [studentId] = @studentId)
    BEGIN
        UPDATE [dbo].[students]
        SET [profilePictureBlobName] = @profilePictureBlobName
        WHERE [studentId] = @studentId;
    END
END;