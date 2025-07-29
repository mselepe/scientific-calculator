IF EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[GetAverages]') AND type in (N'P', N'PC'))
DROP PROCEDURE[dbo].[GetAverages]
GO

CREATE PROCEDURE[dbo].[GetAverages]
    @applicationGuid VARCHAR(256)
AS
BEGIN
    SELECT docBlobName, semesterGradeAverage,
    universitySemesters.semesterDescription,
    MAX(createdAt) AS uploadDate, academicTranscriptsHistory.studentApplicationId
    FROM academicTranscriptsHistory
    INNER JOIN studentApplications 
    ON academicTranscriptsHistory.studentApplicationId = studentApplications.studentApplicationId
    INNER JOIN universityApplications 
    ON studentApplications.applicationId = universityApplications.applicationId
	INNER JOIN universitySemesters 
	ON academicTranscriptsHistory.universitySemesterId = universitySemesters.semesterId 
    WHERE universityApplications.applicationGuid = @applicationGuid
    GROUP BY academicTranscriptsHistory.docBlobName,
        academicTranscriptsHistory.semesterGradeAverage,
        academicTranscriptsHistory.studentApplicationId,
        universitySemesterId, universitySemesters.semesterDescription
END;
