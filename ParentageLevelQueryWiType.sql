/****** Script for SelectTopNRows command from SSMS  ******/
SELECT        Hierarchy_1.Parentage, Hierarchy_1.Parentage.ToString() AS [Parentage Text], Hierarchy_1.Parentage.GetLevel() AS [Parentage Level], dbo.Types.AType, Hierarchy_1.AName, Hierarchy_1.ACode, Hierarchy_1.ID
FROM            dbo.Hierarchy AS Hierarchy_1 INNER JOIN
                         dbo.[Types] ON Hierarchy_1.TypeID = dbo.[Types].TypeID