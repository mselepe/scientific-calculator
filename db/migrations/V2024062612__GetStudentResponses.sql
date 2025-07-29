IF EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[GetStudentResponses]') AND type in (N'P', N'PC'))
DROP PROCEDURE [dbo].[GetStudentResponses]
GO

CREATE PROCEDURE [dbo].[GetStudentResponses]
    @applicationId VARCHAR(256)
AS
BEGIN
    SET NOCOUNT ON;

    SELECT response, questions.question 
    FROM responses
    INNER JOIN questions ON responses.questionId = questions.questionId
    INNER JOIN studentApplications ON responses.questionnaireId = studentApplications.questionaireId
    WHERE studentApplications.applicationId = @applicationId
    
END;
GO

