CREATE PROCEDURE usp_GetEmployeesFromTown (@townName VARCHAR(30))
AS
BEGIN

	SELECT [FirstName],
	       [LastName]
	  FROM [Employees] AS [e]
 LEFT JOIN [Addresses] As [a] ON [e].[AddressID] = [a].[AddressID]
 LEFT JOIN [Towns] AS [t] ON [a].[TownID] = [t].[TownID]
     WHERE @townName = [t].[Name]
END

