-- Drop constraints

IF EXISTS (SELECT * FROM sys.objects 
WHERE object_id = OBJECT_ID(N'fk_responsesQuestionId') AND type in (N'F'))
BEGIN
  ALTER TABLE responses DROP CONSTRAINT fk_responsesQuestionId;
END;

IF EXISTS (SELECT * FROM sys.objects 
WHERE object_id = OBJECT_ID(N'fk_responsesQuestionnaireId') AND type in (N'F'))
BEGIN
  ALTER TABLE responses DROP CONSTRAINT fk_responsesQuestionnaireId;
END;

IF EXISTS (SELECT * FROM sys.objects 
WHERE object_id = OBJECT_ID(N'fk_questionnaresQuestionnaireStatusId') AND type in (N'F'))
BEGIN
  ALTER TABLE questionnaires DROP CONSTRAINT fk_questionnaresQuestionnaireStatusId;
END;

-- Drop tables

IF EXISTS (SELECT * FROM sys.objects 
WHERE object_id = OBJECT_ID(N'[dbo].[questions]') AND type in (N'U'))
BEGIN
  DROP TABLE questions;
END;

IF EXISTS (SELECT * FROM sys.objects 
WHERE object_id = OBJECT_ID(N'[dbo].[responses]') AND type in (N'U'))
BEGIN
  DROP TABLE responses;
END;

IF EXISTS (SELECT * FROM sys.objects 
WHERE object_id = OBJECT_ID(N'[dbo].[questionnaires]') AND type in (N'U'))
BEGIN
  DROP TABLE questionnaires;
END;

IF EXISTS (SELECT * FROM sys.objects 
WHERE object_id = OBJECT_ID(N'[dbo].[questionnaireStatuses]') AND type in (N'U'))
BEGIN
  DROP TABLE questionnaireStatuses;
END;

-- Create tables

CREATE TABLE questions (
  [questionId] [INT] IDENTITY(1,1) PRIMARY KEY,
  [question] [VARCHAR](MAX) NOT NULL
);

CREATE TABLE questionnaires (
  [questionnaireId] [INT] IDENTITY(1,1) PRIMARY KEY,
  [questionnaireStatusId] [INT] NOT NULL
);

CREATE TABLE responses (
  [responseId] [INT] IDENTITY(1,1) PRIMARY KEY,
  [response] [VARCHAR](MAX) NOT NULL,
  [questionId] [INT] NOT NULL,
  [questionnaireId] [INT] NOT NULL,
  [responseDate] [DATETIME] NOT NULL DEFAULT GETDATE()
);

CREATE TABLE questionnaireStatuses (
  [questionnaireStatusId] [INT] IDENTITY(1,1) PRIMARY KEY,
  [status] [VARCHAR](15) NOT NULL
);

-- Create constraints

ALTER TABLE responses
ADD CONSTRAINT fk_responsesQuestionId
FOREIGN KEY (questionId)
REFERENCES questions(questionId);

ALTER TABLE responses
ADD CONSTRAINT fk_responsesQuestionnaireId
FOREIGN KEY (questionnaireId)
REFERENCES questionnaires(questionnaireId);

ALTER TABLE questionnaires
ADD CONSTRAINT fk_questionnaresQuestionnaireStatusId
FOREIGN KEY (questionnaireStatusId)
REFERENCES questionnaireStatuses(questionnaireStatusId);
