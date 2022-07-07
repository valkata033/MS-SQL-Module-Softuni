   SELECT COUNT([c].[CountryCode]) AS [Count]
     FROM [Countries] AS [c]
LEFT JOIN [MountainsCountries] AS [mo] 
	   ON [c].[CountryCode] = [mo].[CountryCode]
    WHERE [mo].[MountainId] IS NULL