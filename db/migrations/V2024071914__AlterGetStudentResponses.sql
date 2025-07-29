/****** Object:  StoredProcedure [dbo].[GetStudentResponses]    Script Date: 2024/07/19 13:40:34 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
ALTER PROCEDURE [dbo].[GetStudentResponses]
    @applicationGuid VARCHAR(256)
AS
BEGIN
    SET NOCOUNT ON;
    SELECT 
    responses.response, 
    questions.question 
	FROM responses
	INNER JOIN questions ON responses.questionId = questions.questionId
	INNER JOIN studentApplications ON responses.questionnaireId = studentApplications.questionaireId
	INNER JOIN universityApplications ON universityApplications.applicationId = studentApplications.applicationId
	WHERE universityApplications.applicationGuid = @applicationGuid;
END;