SELECT TOP (5) [e].[EmployeeID], [FirstName], [p].[Name]
	  FROM [Employees] AS [e]
      JOIN [EmployeesProjects] AS [ep] ON [e].[EmployeeID] = [ep].[EmployeeID]
      JOIN [Projects] AS [p] ON [ep].[ProjectID] = [p].[ProjectID]
	 WHERE [p].[EndDate] IS NULL 
		   AND [p].[StartDate] > '2002-08-13'
  ORDER BY [e].[EmployeeID]

