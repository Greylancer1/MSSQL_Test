DECLARE @CounterPrefix NVARCHAR(30)
SET @CounterPrefix = CASE
WHEN @@SERVICENAME = 'MSSQLSERVER'
THEN 'SQLServer:'
ELSE 'MSSQL$'+@@SERVICENAME+':'
END;

-- Capture the first counter set
SELECT CAST(1 AS INT) AS collection_instance ,[OBJECT_NAME],counter_name ,
instance_name,cntr_value,cntr_type,CURRENT_TIMESTAMP AS collection_time
INTO #perf_counters_init
FROM sys.dm_os_performance_counters
WHERE ( OBJECT_NAME = @CounterPrefix+'Access Methods'
    AND counter_name = 'Full Scans/sec')
   OR ( OBJECT_NAME = @CounterPrefix+'Access Methods'
    AND counter_name = 'Index Searches/sec')
   OR ( OBJECT_NAME = @CounterPrefix+'Buffer Manager'
    AND counter_name = 'Lazy Writes/sec')
   OR ( OBJECT_NAME = @CounterPrefix+'Buffer Manager'
    AND counter_name = 'Page life expectancy')
   OR ( OBJECT_NAME = @CounterPrefix+'General Statistics'
    AND counter_name = 'Processes Blocked')
   OR ( OBJECT_NAME = @CounterPrefix+'General Statistics'
    AND counter_name = 'User Connections')
   OR ( OBJECT_NAME = @CounterPrefix+'Locks'
    AND counter_name = 'Lock Waits/sec')
   OR ( OBJECT_NAME = @CounterPrefix+'Locks'
    AND counter_name = 'Lock Wait Time (ms)')
   OR ( OBJECT_NAME = @CounterPrefix+'SQL Statistics'
    AND counter_name = 'SQL Re-Compilations/sec')
   OR ( OBJECT_NAME = @CounterPrefix+'Memory Manager'
    AND counter_name = 'Memory Grants Pending')
   OR ( OBJECT_NAME = @CounterPrefix+'SQL Statistics'
    AND counter_name = 'Batch Requests/sec')
   OR ( OBJECT_NAME = @CounterPrefix+'SQL Statistics'
    AND counter_name = 'SQL Compilations/sec')

-- Wait on Second between data collection
WAITFOR DELAY '00:00:01'

-- Capture the second counter set
SELECT CAST(2 AS INT) AS collection_instance ,[OBJECT_NAME],counter_name ,
     instance_name,cntr_value,cntr_type,CURRENT_TIMESTAMP AS collection_time
INTO #perf_counters_second
FROM sys.dm_os_performance_counters
WHERE ( OBJECT_NAME = @CounterPrefix+'Access Methods'
     AND counter_name = 'Full Scans/sec')
   OR ( OBJECT_NAME = @CounterPrefix+'Access Methods'
     AND counter_name = 'Index Searches/sec')
   OR ( OBJECT_NAME = @CounterPrefix+'Buffer Manager'
     AND counter_name = 'Lazy Writes/sec')
   OR ( OBJECT_NAME = @CounterPrefix+'Buffer Manager'
    AND counter_name = 'Page life expectancy')
   OR ( OBJECT_NAME = @CounterPrefix+'General Statistics'
    AND counter_name = 'Processes Blocked')
   OR ( OBJECT_NAME = @CounterPrefix+'General Statistics'
    AND counter_name = 'User Connections')
   OR ( OBJECT_NAME = @CounterPrefix+'Locks'
    AND counter_name = 'Lock Waits/sec')
   OR ( OBJECT_NAME = @CounterPrefix+'Locks'
    AND counter_name = 'Lock Wait Time (ms)')
   OR ( OBJECT_NAME = @CounterPrefix+'SQL Statistics'
    AND counter_name = 'SQL Re-Compilations/sec')
   OR ( OBJECT_NAME = @CounterPrefix+'Memory Manager'
    AND counter_name = 'Memory Grants Pending')
   OR ( OBJECT_NAME = @CounterPrefix+'SQL Statistics'
    AND counter_name = 'Batch Requests/sec')
   OR ( OBJECT_NAME = @CounterPrefix+'SQL Statistics'
    AND counter_name = 'SQL Compilations/sec')

-- Calculate the cumulative counter values

SELECT i.OBJECT_NAME , i.counter_name , i.instance_name ,
    CASE WHEN i.cntr_type = 272696576
    THEN s.cntr_value - i.cntr_value
    WHEN i.cntr_type = 65792 THEN s.cntr_value
    END AS cntr_value
FROM #perf_counters_init AS i
JOIN #perf_counters_second AS s
ON i.collection_instance + 1 = s.collection_instance
   AND i.OBJECT_NAME = s.OBJECT_NAME
   AND i.counter_name = s.counter_name
   AND i.instance_name = s.instance_name
ORDER BY OBJECT_NAME

-- Cleanup tables
DROP TABLE #perf_counters_init
DROP TABLE #perf_counters_second 

--After executing this script you need to look to the values of : Full Scans/sec and Index searches/sec
--Index scans should at least 300 times be bigger than Full Scans. To lower the number of Full Scans, you need to identify the queries which are using a table scan in their execution plan. This information can be retrieved from the procedure cache. In the execution plan you need to look for the syntax: 'TableScan'. This can be done with next query.
SELECT TOP 50 st.text AS [SQL], cp.cacheobjtype, cp.objtype, 
   DB_NAME(st.dbid)AS [DatabaseName], cp.usecounts AS [Plan usage] , qp.query_plan 
FROM sys.dm_exec_cached_plans cp 
CROSS APPLY sys.dm_exec_sql_text(cp.plan_handle) st 
CROSS APPLY sys.dm_exec_query_plan(cp.plan_handle) qp 
WHERE CAST(qp.query_plan AS NVARCHAR(MAX)) LIKE ('%Tablescan%')
ORDER BY usecounts DESC 
