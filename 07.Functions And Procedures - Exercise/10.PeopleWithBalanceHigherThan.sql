CREATE PROCEDURE usp_GetHoldersWithBalanceHigherThan (@number DECIMAL(18,4))
AS
BEGIN
	SELECT [FirstName][First Name], [LastName][Last Name]
	  FROM [AccountHolders] AS [ah]	
 LEFT JOIN [Accounts] AS [a] ON [ah].[Id] = [a].[AccountHolderId]
  GROUP BY [ah].[Id], [ah].[FirstName], [ah].[LastName]
	HAVING SUM([a].[Balance]) > @number
  ORDER BY [First Name], [Last Name]
END
