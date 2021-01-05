SELECT TOP 10
			DB_NAME(st.dbid) AS DB,
            creation_time,
            last_execution_time,
			avg_runtime = total_elapsed_time/execution_count,
            avg_cpu_time = (total_worker_time / execution_count) / 1000,
            avg_physical_reads = total_physical_reads / execution_count,
            avg_logical_reads = total_logical_reads / execution_count,
            execution_count,
			st.text,
			total_elapsed_time/execution_count as BadTime
FROM sys.dm_exec_query_stats a
CROSS APPLY sys.dm_exec_sql_text(sql_handle) hnd
CROSS APPLY sys.dm_exec_sql_text(a.sql_handle) st
WHERE
DB_NAME(st.dbid) NOT IN ('master','msdb','ReportServer','ReportServerTempDB')
ORDER BY 
total_elapsed_time/execution_count DESC --Longest Running
--total_logical_reads/execution_count DESC --Most Logical Reads
--total_physical_reads / execution_count DESC --Most Physical Reads
--(total_worker_time/execution_count)/1000 DESC --Most CPU