IF EXISTS (SELECT * FROM sys.objects
WHERE object_id = OBJECT_ID(N'[dbo].[eventTypes]') AND type in (N'U'))
BEGIN
    IF NOT EXISTS (SELECT 1 FROM eventTypes WHERE eventTypeName = 'Conference')
    BEGIN
        INSERT INTO eventTypes(eventTypeName) VALUES ('Conference');
    END

	IF NOT EXISTS (SELECT 1 FROM eventTypes WHERE eventTypeName = 'Social Event')
	BEGIN
		  INSERT INTO eventTypes(eventTypeName) VALUES ('Social Event');
	END

	IF NOT EXISTS (SELECT 1 FROM eventTypes WHERE eventTypeName = 'Networking Event')
	BEGIN
		  INSERT INTO eventTypes(eventTypeName) VALUES ('Networking Event');
	END
END
