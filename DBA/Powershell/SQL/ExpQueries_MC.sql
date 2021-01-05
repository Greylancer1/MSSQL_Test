SELECT TOP 10
			'Most CPU' AS Order_Type,
			@@SERVERNAME AS Instance,
			DB_NAME(st.dbid) AS DB,
            creation_time,
            last_execution_time,
			avg_runtime = total_elapsed_time/execution_count,
            avg_cpu_time = (total_worker_time / execution_count) / 1000,
            avg_physical_reads = total_physical_reads / execution_count,
            avg_logical_reads = total_logical_reads / execution_count,
            execution_count,
			st.text,
			qp.query_plan,
			total_elapsed_time/execution_count as BadTime
--INTO ExpSQLQueriesMon
FROM 
sys.dm_exec_query_stats a
CROSS APPLY sys.dm_exec_sql_text(a.sql_handle) st
CROSS APPLY sys.dm_exec_query_plan(a.plan_handle) qp
WHERE
DB_NAME(st.dbid) IS NOT NULL AND CASE WHEN st.dbid = 32767 then 'Resource' ELSE DB_NAME(st.dbid)END <> 'msdb'
ORDER BY 
--total_elapsed_time/execution_count DESC --Longest Running
--total_logical_reads/execution_count DESC --Most Logical Reads
--total_physical_reads / execution_count DESC --Most Physical Reads
(total_worker_time/execution_count)/1000 DESC --Most CPU