CREATE PROCEDURE usp_GetTownsStartingWith (@string VARCHAR(20))
AS
BEGIN
	DECLARE @inputLength INT = LEN(@string)

	SELECT [Name]
	  FROM [Towns]
	 WHERE LEFT([Name], @inputLength) = @string
END

