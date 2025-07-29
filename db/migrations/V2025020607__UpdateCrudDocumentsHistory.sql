IF EXISTS (SELECT * FROM sys.objects 
WHERE object_id = OBJECT_ID(N'fk_previousAdminDocumentId') AND type in (N'F'))
BEGIN
  ALTER TABLE adminDocumentsHistory DROP CONSTRAINT fk_previousAdminDocumentId;
END;

IF EXISTS (SELECT * FROM sys.objects 
WHERE object_id = OBJECT_ID(N'fk_newAdminDocumentId') AND type in (N'F'))
BEGIN
  ALTER TABLE adminDocumentsHistory DROP CONSTRAINT fk_newAdminDocumentId;
END;

--DROP TABLE
IF EXISTS (SELECT * FROM sys.objects 
WHERE object_id = OBJECT_ID(N'[dbo].[adminDocumentsHistory]') AND type in (N'U'))
BEGIN
  DROP TABLE adminDocumentsHistory;
END;

--check if exist
IF NOT EXISTS (SELECT 1 FROM documentTypes WHERE [type] = 'Matric Certificate') 
BEGIN 
    INSERT INTO documentTypes ([type]) VALUES ('Matric Certificate'); 
END 

IF NOT EXISTS (SELECT 1 FROM documentTypes WHERE [type] = 'Academic Record') 
BEGIN 
    INSERT INTO documentTypes ([type]) VALUES ('Academic Record'); 
END 

IF NOT EXISTS (SELECT 1 FROM documentTypes WHERE [type] = 'Proof of Identification') 
BEGIN 
    INSERT INTO documentTypes ([type]) VALUES ('Proof of Identification'); 
END 

IF NOT EXISTS (SELECT 1 FROM documentTypes WHERE [type] = 'Financial Statement') 
BEGIN 
    INSERT INTO documentTypes ([type]) VALUES ('Financial Statement'); 
END 

IF EXISTS (SELECT * FROM sys.objects 
WHERE object_id = OBJECT_ID(N'fk_actionTypeId') AND type in (N'F'))
BEGIN
  ALTER TABLE documentHistory DROP CONSTRAINT fk_actionTypeId;
END;

IF EXISTS (SELECT * FROM sys.objects 
WHERE object_id = OBJECT_ID(N'[dbo].[actionTypes]') AND type in (N'U'))
BEGIN
  DROP TABLE actionTypes;
END;

CREATE TABLE actionTypes(
	actionTypeId INT IDENTITY(1,1) PRIMARY KEY,
	actionType VARCHAR(255) NOT NULL
);


IF NOT EXISTS (SELECT 1 FROM actionTypes WHERE [actionType] = 'update') 
BEGIN 
    INSERT INTO actionTypes ([actionType]) VALUES ('update'); 
END 

IF NOT EXISTS (SELECT 1 FROM actionTypes WHERE [actionType] = 'amend') 
BEGIN 
    INSERT INTO actionTypes ([actionType]) VALUES ('amend'); 
END

IF NOT EXISTS (SELECT 1 FROM actionTypes WHERE [actionType] = 'delete') 
BEGIN 
    INSERT INTO actionTypes ([actionType]) VALUES ('delete'); 
END

IF EXISTS (SELECT * FROM sys.objects 
WHERE object_id = OBJECT_ID(N'fk_documentHistoryId') AND type in (N'F'))
BEGIN
  ALTER TABLE documentHistory DROP CONSTRAINT fk_documentHistoryId;
END;


IF EXISTS (SELECT * FROM sys.objects 
WHERE object_id = OBJECT_ID(N'[dbo].[documentHistory]') AND type in (N'U'))
BEGIN
  DROP TABLE documentHistory;
END;


CREATE TABLE documentHistory(
	documentHistoryId INT IDENTITY(1,1) PRIMARY KEY,
	documentTypeId INT NOT NULL,
	applicationId INT NOT NULL,
	previousFile VARCHAR(256) NOT NULL,
	newFile VARCHAR(256) NOT NULL,
	userId VARCHAR(256) NOT NULL,
	changeReason VARCHAR(MAX) NOT NULL,
	actionTypeId INT NOT NULL,
	createdAt DATETIME NOT NULL DEFAULT GETDATE()
);

ALTER TABLE documentHistory
ADD CONSTRAINT fk_documentHistoryId
FOREIGN KEY (applicationId)
REFERENCES universityApplications(applicationId);

ALTER TABLE documentHistory
ADD CONSTRAINT fk_actionTypeId
FOREIGN KEY (actionTypeId)
REFERENCES actionTypes(actionTypeId);