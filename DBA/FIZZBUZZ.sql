SET NOCOUNT ON

DECLARE @NUMBER int;
SET @NUMBER = 1;

WHILE (@NUMBER <= 100)
BEGIN
	IF
		@NUMBER % 3 = 0 AND @NUMBER % 5 = 0
	BEGIN
		PRINT 'FIZZBUZZ'
	END
	ELSE
		IF 
		@NUMBER % 3 = 0
		BEGIN
			PRINT 'FIZZ'
		END
		ELSE
			IF
				@NUMBER % 5 = 0
			BEGIN
				PRINT 'BUZZ'
			END 
			ELSE
				IF
					@NUMBER % 3 <> 0 AND @NUMBER % 5 <> 0
				BEGIN
					PRINT @NUMBER
				END

	SET @NUMBER = @NUMBER + 1
END 

SET NOCOUNT OFF