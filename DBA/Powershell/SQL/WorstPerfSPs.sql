CREATE TABLE [dbo].[#TMP] ( 
[SRVR_Name] NVARCHAR(256) NULL,
[DB_Name] NVARCHAR(256) NULL,
[Schema_Name] NVARCHAR(256) NULL,
[SP_Name] NVARCHAR(256) NULL,
CachedTm datetime,
LastExecTm datetime,
ExecCount bigint,
TotWorkerTm bigint,
TotElapsedTm bigint,
TotLogicalRds bigint,
TotLogicalWrites bigint,
TotPhysReads bigint
)

EXEC sp_MSforeachdb 'USE ? INSERT INTO #TMP 
SELECT TOP 20 
	@@Servername
	, ''?'' AS DBName
    ,OBJECT_SCHEMA_NAME(object_id,database_id) AS [SCHEMA_NAME] 
    ,OBJECT_NAME(object_id,database_id)AS [OBJECT_NAME]
    ,cached_time
    ,last_execution_time
    ,execution_count
    ,total_worker_time / execution_count AS AVG_CPU
    ,total_elapsed_time / execution_count AS AVG_ELAPSED
    ,total_logical_reads / execution_count AS AVG_LOGICAL_READS
    ,total_logical_writes / execution_count AS AVG_LOGICAL_WRITES
    ,total_physical_reads  / execution_count AS AVG_PHYSICAL_READS
FROM sys.dm_exec_procedure_stats 
WHERE OBJECT_SCHEMA_NAME(object_id,database_id) IS NOT NULL AND ''?'' NOT IN (''master'', ''msdb'', ''tempdb'', ''model'', ''ReportServer'', ''ReportServerTempDB'')
ORDER BY AVG_LOGICAL_READS DESC'
SELECT * FROM #TMP
DROP TABLE #TMP