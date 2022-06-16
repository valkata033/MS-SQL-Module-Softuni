SELECT TOP (5) [FirstName]
		      ,[LastName]
      FROM [Employees]
     WHERE [Salary] < 126000
  ORDER BY [Salary] DESC