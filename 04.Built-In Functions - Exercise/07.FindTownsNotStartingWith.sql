  SELECT [TownID], [Name]
    FROM [Towns]
   WHERE LEFT([Name], 1) NOT IN ('R', 'D', 'B')
ORDER BY [Name]
