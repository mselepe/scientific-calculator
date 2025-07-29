IF EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[InsertExpense]') AND type in (N'P', N'PC'))
DROP PROCEDURE [dbo].[InsertExpense]
GO

CREATE PROCEDURE [dbo].[InsertExpense]
    @accommodation MONEY,
    @tuition MONEY,
    @meals MONEY,
    @other MONEY = NULL,  
    @applicationId INT
AS
BEGIN
    SET NOCOUNT ON;

 
    DECLARE @totalExpense MONEY = @accommodation + @tuition + @meals + ISNULL(@other, 0);
    DECLARE @totalAmount MONEY;
    DECLARE @returnResult INT;

   
    SELECT @totalAmount = amount
    FROM universityApplications
    WHERE applicationId = @applicationId;


    IF @totalExpense = @totalAmount
    BEGIN
    
        INSERT INTO expenses (accommodation, tuition, meals, other, applicationId)
        VALUES (@accommodation, @tuition, @meals, @other, @applicationId);
       SET @returnResult = SCOPE_IDENTITY();
      SELECT @returnResult AS resultValue

    END
    ELSE
    BEGIN
       
        RAISERROR ('The total expense amount does not match the total amount in universityApplications.', 16, 1);
    END
END;

