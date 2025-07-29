IF EXISTS(
	SELECT 1 
    FROM INFORMATION_SCHEMA.COLUMNS 
    WHERE TABLE_NAME = 'questions' 
    AND COLUMN_NAME = 'question'
)
BEGIN
	UPDATE questions
	SET question = 'Have you been employed in the IT industry before?'
	WHERE question = 'Have you worked professionally in the IT industry before?'

	UPDATE questions
	SET question = 'Name of the Company and in what role were you employed.'
	WHERE question = 'Where in the IT industry have you worked and what role did you play?'

	IF NOT EXISTS(
		SELECT question FROM questions
		WHERE question = 'Please name the additional courses completed.'
	)
	BEGIN
		INSERT INTO questions(question)
		VALUES ('Please kindly list all the additional courses you have completed.')
	END;
END;