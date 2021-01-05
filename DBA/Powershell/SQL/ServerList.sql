select DISTINCT TargetObjectDisplayName
from RelationshipGenericView
where isDeleted=0
AND SourceObjectDisplayName like 'SQL Server Computers'
ORDER BY TargetObjectDisplayName