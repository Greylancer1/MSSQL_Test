SELECT DISTINCT dbo.Users.Username, SUBSTRING(dbo.Perms.ParentagePerm, 1, 3) AS ClientParentage, Hierarchy_1.AName
FROM            dbo.Perms INNER JOIN
                         dbo.Users ON dbo.Perms.UserID = dbo.Users.UserID INNER JOIN
                         dbo.Hierarchy AS Hierarchy_1 ON SUBSTRING(dbo.Perms.ParentagePerm, 1, 3) = Hierarchy_1.Parentage