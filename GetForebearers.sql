--Select all the elements whose current element is the child:
--Get forebearers of current

SELECT Id, AName, parentage.ToString()
FROM Hierarchy
WHERE CAST('/1/2/1/' as hierarchyid).IsDescendantOf(parentage) = 1