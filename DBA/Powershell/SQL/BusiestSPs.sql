SELECT TOP 20 @@SERVERNAME AS Instance
	  ,CASE WHEN database_id = 32767 then 'Resource' ELSE DB_NAME(database_id)END AS DBName
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
   --INTO BusiestSPsMon 
FROM sys.dm_exec_procedure_stats 
WHERE OBJECT_SCHEMA_NAME(object_id,database_id) IS NOT NULL AND CASE WHEN database_id = 32767 then 'Resource' ELSE DB_NAME(database_id)END <> 'msdb'
ORDER BY AVG_LOGICAL_READS DESC