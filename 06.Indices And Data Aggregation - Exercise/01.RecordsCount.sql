SELECT TOP (1)
           MAX([Id]) AS Count
      FROM WizzardDeposits AS [wd]
  GROUP BY [wd].[Id]
  ORDER BY [Id] DESC