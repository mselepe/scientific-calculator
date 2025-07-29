/****** Object:  StoredProcedure [dbo].[AddUniversity]    Script Date: 2024/11/25 00:08:29 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
ALTER PROCEDURE [dbo].[AddUniversity]
    @universityName NVARCHAR(252),
    @faculty NVARCHAR(252)
AS
BEGIN
    SET NOCOUNT ON;
    DECLARE @universityId INT;
    DECLARE @facultyId INT;
    DECLARE @universityExists BIT = 0;
    DECLARE @facultyExists BIT = 0;

    IF EXISTS (SELECT 1 FROM universities WHERE universityName = @universityName)
    BEGIN
        SELECT @universityId = universityId FROM universities WHERE universityName = @universityName;
        SET @universityExists = 1;
    END
    ELSE
    BEGIN
        INSERT INTO universities (universityName, universityStatusId)
        VALUES (@universityName, (SELECT universityStatusId FROM universityStatus WHERE status = 'Inactive'));

        SET @universityId = SCOPE_IDENTITY();
    END

    IF EXISTS (SELECT 1 FROM faculties WHERE facultyName = @faculty) OR @faculty IS NULL
    BEGIN
        SELECT @facultyId = facultyId FROM faculties WHERE facultyName = @faculty;
        SET @facultyExists = 1;
    END
    ELSE
    BEGIN
        INSERT INTO faculties (facultyName)
        VALUES (@faculty);

        SET @facultyId = SCOPE_IDENTITY();
    END

    IF @universityExists = 1 AND @facultyExists = 1
    BEGIN
   
        RETURN 0; 
    END
    ELSE IF @universityExists = 1
    BEGIN
      
        RETURN 0; 
    END
    ELSE IF @facultyExists = 1
    BEGIN

        RETURN 0; 
    END
    ELSE
    BEGIN
        RETURN 0;
    END
END;