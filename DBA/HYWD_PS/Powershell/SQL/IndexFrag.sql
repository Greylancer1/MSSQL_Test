CREATE TABLE [dbo].[#TMP] ( 
[SRVRNAME] NVARCHAR(256) NULL,
[DBNAME] NVARCHAR(256) NULL,
[IDXNAME] NVARCHAR(256) NULL,
[FRAG] INT NULL,
[PAGES] INT NULL);

EXEC sp_MSforeachdb 'USE ? INSERT INTO #TMP
SELECT @@servername, ''?'', t.name, ps.avg_fragmentation_in_percent, ps.page_count
FROM sys.dm_db_index_physical_stats (DB_ID(''?''), NULL, NULL, NULL, NULL) ps
INNER JOIN sys.indexes t ON t.object_id = ps.object_id
WHERE ps.avg_fragmentation_in_percent > 40 AND ps.page_count > 1000 AND t.name IS NOT NULL AND ''?'' NOT IN (''master'', ''msdb'', ''tempdb'', ''ReportServer'', ''ReportServerTempDB'')
'
SELECT * FROM #TMP
DROP TABLE #TMP