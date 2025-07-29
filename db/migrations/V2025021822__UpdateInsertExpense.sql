
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
ALTER PROCEDURE [dbo].[InsertExpense]
    @accommodation MONEY,
    @tuition MONEY,
    @meals MONEY,
    @other MONEY = NULL,  
	@otherDescription VARCHAR(255)=NULL,
    @applicationId INT,
	@userId VARCHAR(255) = NULL
AS
BEGIN
    SET NOCOUNT ON;

 
    DECLARE @totalExpense MONEY = @accommodation + @tuition + @meals + ISNULL(@other, 0);
    DECLARE @totalAmount MONEY;
    DECLARE @returnResult INT;
	DECLARE @latestInvoiceStatusId INT;

   
    SELECT @totalAmount = amount
    FROM universityApplications
    WHERE applicationId = @applicationId;


    IF @totalExpense = @totalAmount
    BEGIN
    
        INSERT INTO expenses (accommodation, tuition, meals, other, otherDescription, applicationId)
        VALUES (@accommodation, @tuition, @meals, @other,@otherDescription, @applicationId); 
       SET @returnResult = SCOPE_IDENTITY();

	   SET @latestInvoiceStatusId = (SELECT latestInv.statusId FROM (SELECT MAX(createdAt) AS latest, statusId FROM invoiceStatusHistory WHERE applicationId = @applicationId
	   GROUP BY statusId) latestInv)
	  
	   IF @latestInvoiceStatusId = 6
	   BEGIN
		 INSERT INTO invoiceStatusHistory(userId,applicationId,statusId)
		 VALUES (@userId,@applicationId,(SELECT statusId FROM invoiceStatus WHERE [status]='Pending'))
	   END

      SELECT @returnResult AS resultValue

    END
    ELSE
    BEGIN
       
        RAISERROR ('The total expense amount does not match the total amount in universityApplications.', 16, 1);
    END
END;