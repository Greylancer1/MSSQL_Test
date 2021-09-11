SELECT REPLICATE('--', parentage.GetLevel()) + AName , parentage.ToString()
FROM Hierarchy
ORDER BY parentage