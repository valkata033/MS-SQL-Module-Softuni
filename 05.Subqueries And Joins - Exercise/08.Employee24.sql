    SELECT [e].[EmployeeID], [e].[FirstName], [e].[ManagerID], [ee].[FirstName] AS [ManagerName]
	  FROM [Employees] AS [e]
 LEFT JOIN [Employees] AS [ee] ON [e].[ManagerID] = [ee].[EmployeeID]
	 WHERE [e].[ManagerID] IN (3, 7)
  ORDER BY [e].[EmployeeID]
