-- sort by Parentage Level to get breadth-first order of Parentages
select 
 Parentage
,Parentage.ToString() AS [Parentage Text]
,Parentage.GetLevel() [Parentage Level]
,AName
,TypeID   
from Hierarchy
order by [Parentage Level] -- order by Parentage Level gets breadth-first list