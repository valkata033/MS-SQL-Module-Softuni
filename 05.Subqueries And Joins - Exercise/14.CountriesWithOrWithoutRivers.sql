SELECT TOP (5) [c].[CountryName], [r].[RiverName]
      FROM [Countries] AS [c]
 LEFT JOIN [CountriesRivers] AS [cr] ON [c].[CountryCode] = [cr].[CountryCode]
 LEFT JOIN [Rivers] AS [r] ON [cr].[RiverId] = [r].[Id]
 LEFT JOIN [Continents] AS co ON [c].[ContinentCode] = [co].[ContinentCode]
     WHERE [co].[ContinentName] = 'Africa'
  ORDER BY [c].[CountryName]
	   