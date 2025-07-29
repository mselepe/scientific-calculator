IF EXISTS (SELECT * FROM sys.objects 
WHERE object_id = OBJECT_ID(N'[dbo].[locationRequests]') AND type in (N'U'))
BEGIN
  DROP TABLE locationRequests;
END;

CREATE TABLE locationRequests (
  currentNumRequests INT NOT NULL 
);

INSERT INTO locationRequests(currentNumRequests)
VALUES (0)