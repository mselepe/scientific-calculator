ALTER PROCEDURE [dbo].[InsertExpense]
    @accommodation MONEY,
    @tuition MONEY,
    @meals MONEY,
    @other MONEY = NULL,  
	@otherDescription VARCHAR(255)=NULL,
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
    
        INSERT INTO expenses (accommodation, tuition, meals, other, otherDescription, applicationId)
        VALUES (@accommodation, @tuition, @meals, @other,@otherDescription, @applicationId);
       SET @returnResult = SCOPE_IDENTITY();
      SELECT @returnResult AS resultValue

    END
    ELSE
    BEGIN
       
        RAISERROR ('The total expense amount does not match the total amount in universityApplications.', 16, 1);
    END
END;
GO