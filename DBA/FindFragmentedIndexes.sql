SELECT OBJECT_NAME(i.object_id) AS [Table Name],
i.name AS [Index Name],
dm.avg_fragmentation_in_percent
FROM sys.dm_db_index_physical_stats (DB_ID(), NULL, NULL, NULL, 'DETAILED') dm
INNER JOIN sys.indexes i ON i.object_id = dm.object_id
AND i.index_id = dm.index_id
WHERE dm.avg_fragmentation_in_percent > 40
order by avg_fragmentation_in_percent desc