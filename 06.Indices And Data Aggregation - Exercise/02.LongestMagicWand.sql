SELECT TOP (1) 
           MAX(MagicWandSize) AS [LongestMagicWand]
      FROM WizzardDeposits
  GROUP BY MagicWandSize
  ORDER BY MagicWandSize DESC
