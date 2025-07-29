IF EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[UpdateApplicationAmount]') AND type in (N'P', N'PC'))
DROP PROCEDURE[dbo].[UpdateApplicationAmount]
GO
CREATE PROCEDURE UpdateApplicationAmount
    @applicationGuid UNIQUEIDENTIFIER,
    @newAmount MONEY,
    @userId NVARCHAR(255)
AS
BEGIN
 
    DECLARE @applicationId INT;
    DECLARE @currentAmount DECIMAL(18, 2);

   
    SELECT @applicationId = [applicationId],
           @currentAmount = [amount]
    FROM [dbo].[universityApplications]
    WHERE applicationGuid = @applicationGuid;


    INSERT INTO applicationAmountHistory 
    (userId, applicationId, oldAmount,newAmount, createdAt)
    VALUES (@userId, @applicationId, @currentAmount,@newAmount, GETDATE());
    UPDATE [dbo].[universityApplications]
    SET amount = @newAmount
    WHERE applicationGuid = @applicationGuid
    AND EXISTS (
    SELECT 1
    FROM [dbo].[applicationStatusHistory] ash
    INNER JOIN [dbo].[applicationStatus] ast ON ash.StatusId = ast.StatusId
    WHERE ash.applicationId = [dbo].[universityApplications].applicationId
    AND ash.createdAt = (
        SELECT MAX(ash2.createdAt)
        FROM [dbo].[applicationStatusHistory] ash2
        WHERE ash2.applicationId = ash.applicationId
    )
    AND ast.status = 'In Review'
);
	
END
GO