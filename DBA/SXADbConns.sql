SELECT     Col001 AS PC, COUNT(Col001) AS NumOfCons
FROM         dbo.SXADBConns
GROUP BY Col001
ORDER BY COUNT(Col001) DESC

SELECT PC, O.NumOfCons, 
(SELECT TOP 100 PERCENT SUM(NumOfCons) FROM PC_Conns WHERE PC <= O.PC AND O.NumOfCons > 3) 'Sub Total'
FROM PC_Conns O
GROUP BY PC, NumOfCons
HAVING O.NumOfCons > 3

Insert into #TmpWho
exec sp_who2 'active'

