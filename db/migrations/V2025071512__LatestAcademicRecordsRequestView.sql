-- Drop the view if it exists

IF OBJECT_ID('vw_latestNudgedStudents', 'V') IS NOT NULL
	DROP VIEW vw_latestNudgedStudents
GO

-- Create view

CREATE VIEW vw_latestNudgedStudents
AS
SELECT nudgeReasonId, createdAt, applicationId, nudgedEmail
FROM (
    SELECT nudgeReasonId, createdAt, applicationId, nudgedEmail,
           ROW_NUMBER() OVER (
               PARTITION BY applicationId
               ORDER BY createdAt DESC
           ) as rowNumber
    FROM nudgeHistory
) ranked
WHERE rowNumber = 1 
AND nudgeReasonId = (SELECT nudgeReasonId FROM nudgeReason WHERE nudgeReason = 'request student transcripts')
AND (SELECT DATEDIFF(DAY, ranked.createdAt, GETDATE()) AS days_between) > 7;

