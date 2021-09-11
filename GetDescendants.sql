SELECT [Id], [AName], [parentage].ToString()
FROM [Hierarchy]
WHERE [parentage].IsDescendantOf(CAST('/' AS hierarchyid)) = 1