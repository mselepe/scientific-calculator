BEGIN TRY
  -- Start the transaction
  BEGIN TRANSACTION;
    -- DROP CONSTRAINTS

    IF EXISTS (SELECT * FROM sys.objects 
    WHERE object_id = OBJECT_ID(N'fk_studentTitleId') AND type in (N'F'))
    BEGIN
      ALTER TABLE students DROP CONSTRAINT fk_studentTitleId;
    END;

    IF EXISTS (SELECT * FROM sys.objects 
    WHERE object_id = OBJECT_ID(N'fk_customTitleStudentId') AND type in (N'F'))
    BEGIN
      ALTER TABLE customTitles DROP CONSTRAINT fk_customTitleStudentId;
    END;

    -- DROP TABLES

    IF EXISTS (SELECT * FROM sys.objects 
    WHERE object_id = OBJECT_ID(N'[dbo].[titles]') AND type in (N'U'))
    BEGIN
      DROP TABLE titles;
    END;

    IF EXISTS (SELECT * FROM sys.objects 
    WHERE object_id = OBJECT_ID(N'[dbo].[customTitles]') AND type in (N'U'))
    BEGIN
      DROP TABLE customTitles;
    END;

    -- CREATE TABLES

    CREATE TABLE titles (
      [titleId] [INT] IDENTITY(1,1) PRIMARY KEY,
      [title] [VARCHAR](256) NOT NULL 
    );

    CREATE TABLE customTitles (
      [customTitleId] [INT] IDENTITY(1,1) PRIMARY KEY,
      [customTitle] [VARCHAR](256) NOT NULL,
      [studentId] [INT] NOT NULL
    );


    -- POPULATE titles

    INSERT INTO titles(title)
    VALUES ('Mr'), ('Mrs'), ('Miss'),
	         ('Dr'), ('Prof'), ('Other')

    -- ALTER students

    IF NOT EXISTS(
	    SELECT 1 
        FROM INFORMATION_SCHEMA.COLUMNS 
        WHERE TABLE_NAME = 'students' 
        AND COLUMN_NAME = 'titleId'
    )
    BEGIN
	    ALTER TABLE students 
	    ADD titleId INT NOT NULL DEFAULT 6;
    END;

    -- DROP title COLUMN
    IF EXISTS(
	    SELECT 1 
        FROM INFORMATION_SCHEMA.COLUMNS 
        WHERE TABLE_NAME = 'students' 
        AND COLUMN_NAME = 'title'
    )
    BEGIN
      ALTER TABLE students
      DROP COLUMN title
    END

    ALTER TABLE students
    ADD CONSTRAINT fk_studentTitleId
    FOREIGN KEY (titleId)
    REFERENCES titles(titleId);

    ALTER TABLE customTitles
    ADD CONSTRAINT fk_customTitleStudentId
    FOREIGN KEY (studentId)
    REFERENCES students(studentId);
END TRY
BEGIN CATCH
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
