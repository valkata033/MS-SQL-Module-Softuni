   SELECT [EmployeeID], [FirstName], [LastName], [d].[Name]
	 FROM [Employees] AS [e]
LEFT JOIN [Departments] AS [d] ON [e].[DepartmentID] = [d].[DepartmentID]
    WHERE [d].[Name] = 'Sales'
 ORDER BY [EmployeeID]