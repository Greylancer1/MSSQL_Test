  SELECT  DB_NAME (database_id),
  database_id,
		session_id ,
           request_id ,
           percent_complete ,
           estimated_completion_time ,
           DATEADD(ms,estimated_completion_time,GETDATE()) AS EstimatedEndTime, 
           start_time ,
           status ,
           command 
  FROM sys.dm_exec_requests
  WHERE percent_complete <> '0' AND database_id = 42