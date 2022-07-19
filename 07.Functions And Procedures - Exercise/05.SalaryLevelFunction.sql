CREATE FUNCTION ufn_GetSalaryLevel (@salary DECIMAL(18,4))
RETURNS VARCHAR(10)
AS
BEGIN
	DECLARE @levelOfSalary NVARCHAR(10) = 'High'

	IF (@salary < 30000)
	BEGIN
		SET @levelOfSalary = 'Low'
	END

	ELSE IF (@salary BETWEEN 30000 AND 50000)
	BEGIN
		SET @levelOfSalary = 'Average'
	END

	RETURN @levelOfSalary
END

SELECT [Salary],
	   [dbo].[ufn_GetSalaryLevel]([Salary])
    AS [Salary Level]
  FROM [Employees]
