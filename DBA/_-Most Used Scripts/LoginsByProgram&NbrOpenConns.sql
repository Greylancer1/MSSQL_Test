SELECT login_name ,COUNT(session_id) AS session_count   
FROM sys.dm_exec_sessions   
GROUP BY login_name; 

SELECT login_name , [program_name],COUNT(session_id) AS session_count 
FROM sys.dm_exec_sessions   
GROUP BY [program_name], login_name; 

SELECT Top 1 *
FROM sys.dm_exec_sessions   