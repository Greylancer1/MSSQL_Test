SELECT CASE WHEN database_id = 32767 then 'Resource' ELSE DB_NAME(database_id)END AS DBName
      ,OBJECT_SCHEMA_NAME(object_id,database_id) AS [SCHEMA_NAME]  
      ,OBJECT_NAME(object_id,database_id) AS [OBJECT_NAME]  
      ,*  FROM sys.dm_exec_procedure_stats
	  ORDER BY DBName, [OBJECT_NAME]