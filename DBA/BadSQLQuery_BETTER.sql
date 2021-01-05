SELECT TOP 100
			DB_NAME(st.dbid) AS DB,
            [Object_Name] = object_name(st.objectid),
            creation_time,
            last_execution_time,
            total_cpu_time = total_worker_time / 1000, 
            avg_cpu_time = (total_worker_time / execution_count) / 1000,
            min_cpu_time = min_worker_time / 1000,
            max_cpu_time = max_worker_time / 1000,
            last_cpu_time = last_worker_time / 1000,
            total_time_elapsed = total_elapsed_time / 1000 ,
            avg_time_elapsed = (total_elapsed_time / execution_count) / 1000,
            min_time_elapsed = min_elapsed_time / 1000,
            max_time_elapsed = max_elapsed_time / 1000,
            avg_physical_reads = total_physical_reads / execution_count,
            avg_logical_reads = total_logical_reads / execution_count,
            execution_count,
            SUBSTRING(st.text, (a.statement_start_offset/2) + 1,
                  (
                        (
                              CASE statement_end_offset
                                    WHEN -1 THEN DATALENGTH(st.text)
                                    ELSE a.statement_end_offset
                              END
                              - a.statement_start_offset
                        ) /2
                  ) + 1
           ) as statement_text,
			total_elapsed_time/execution_count as BadTime
FROM sys.dm_exec_query_stats a
CROSS APPLY sys.dm_exec_sql_text(sql_handle) hnd
CROSS APPLY
            sys.dm_exec_sql_text(a.sql_handle) st
WHERE
            Object_Name(st.objectid) IS NOT NULL
            AND DB_NAME(st.dbid) NOT IN ('master','msdb','ReportServer','ReportServerTempDB')
ORDER BY total_elapsed_time/execution_count DESC