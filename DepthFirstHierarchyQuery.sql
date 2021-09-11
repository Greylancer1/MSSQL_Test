-- sort by Path Text or Path to get depth-first order of Paths
select 
 Parentage
,Parentage.ToString() AS [Parentage Text]
,Parentage.GetLevel() [Parentage Level]
,[AName]
,[TypeID]   
from Hierarchy
order by [Parentage Text]  -- order by Path Text or Path to get depth-first list	