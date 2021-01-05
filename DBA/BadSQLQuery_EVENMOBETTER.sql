select TOP 20
    r.session_id,
    s.login_name,
    c.client_net_address,
    s.host_name,
    s.program_name,
	    GETDATE() AS "Collection Date",
    qs.execution_count AS "Execution Count",
    SUBSTRING(qt.text,qs.statement_start_offset/2 +1, 
                 (CASE WHEN qs.statement_end_offset = -1 
                       THEN LEN(CONVERT(NVARCHAR(MAX), qt.text)) * 2 
                       ELSE qs.statement_end_offset END -
                            qs.statement_start_offset
                 )/2
             ) AS "Query Text", 
     DB_NAME(qt.dbid) AS "DB Name",
     qs.total_worker_time AS "Total CPU Time",
     qs.total_worker_time/qs.execution_count AS "Avg CPU Time (ms)",     
     qs.total_physical_reads AS "Total Physical Reads",
     qs.total_physical_reads/qs.execution_count AS "Avg Physical Reads",
     qs.total_logical_reads AS "Total Logical Reads",
     qs.total_logical_reads/qs.execution_count AS "Avg Logical Reads",
     qs.total_logical_writes AS "Total Logical Writes",
     qs.total_logical_writes/qs.execution_count AS "Avg Logical Writes",
     qs.total_elapsed_time AS "Total Duration",
     qs.total_elapsed_time/qs.execution_count AS "Avg Duration (ms)",
     qp.query_plan AS "Plan"
from sys.dm_exec_requests r
inner join sys.dm_exec_sessions s
on r.session_id = s.session_id
left join sys.dm_exec_connections c
on r.session_id = c.session_id
outer apply sys.dm_exec_sql_text(r.sql_handle) st
inner join sys.dm_exec_query_stats AS qs 
on r.sql_handle = qs.sql_handle
CROSS APPLY sys.dm_exec_sql_text(r.sql_handle) AS qt 
CROSS APPLY sys.dm_exec_query_plan(r.plan_handle) AS qp
WHERE 
DB_NAME(qt.dbid) IS NOT NULL AND
     qs.execution_count > 50 OR
     qs.total_worker_time/qs.execution_count > 100 OR
     qs.total_physical_reads/qs.execution_count > 1000 OR
     qs.total_logical_reads/qs.execution_count > 1000 OR
     qs.total_logical_writes/qs.execution_count > 1000 OR
     qs.total_elapsed_time/qs.execution_count > 1000
ORDER BY 
     qs.execution_count DESC,
     qs.total_elapsed_time/qs.execution_count DESC,
     qs.total_worker_time/qs.execution_count DESC,
     qs.total_physical_reads/qs.execution_count DESC,
     qs.total_logical_reads/qs.execution_count DESC,
     qs.total_logical_writes/qs.execution_count DESC