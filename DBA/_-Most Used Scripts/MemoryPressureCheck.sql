SELECT object_name, counter_name, cntr_value
FROM sys.dm_os_performance_counters
WHERE [object_name] LIKE '%Buffer Manager%'
AND [counter_name] = 'Buffer cache hit ratio'


SELECT base.cntr_value * 1.0 / rat.cntr_value * 100.0 AS [Buffer Cache Hit Ratio]
, base.cntr_value AS [Buffer cache hit ratio base]
, rat.cntr_value AS [Buffer cache hit ratio]
FROM sys.dm_os_performance_counters base CROSS JOIN sys.dm_os_performance_counters rat
WHERE base.counter_name = 'Buffer cache hit ratio base'
AND rat.counter_name = 'Buffer cache hit ratio'


SELECT [cntr_value]
FROM sys.dm_os_performance_counters
WHERE
	[object_name] LIKE '%Buffer Manager%'
	AND [counter_name] = 'Page life expectancy'


SELECT [counter_name], [cntr_value]
FROM sys.dm_os_performance_counters
WHERE
	[object_name] LIKE '%Buffer Manager%'
AND [counter_name] IN ('Page reads/sec', 'Page writes/sec', 'Lazy writes/sec')



DECLARE @LazyWrites1 bigint;
SELECT @LazyWrites1 = cntr_value
  FROM sys.dm_os_performance_counters
  WHERE counter_name = 'Lazy writes/sec';
 
WAITFOR DELAY '00:00:10';
 
SELECT(cntr_value - @LazyWrites1) / 10 AS 'LazyWrites/sec'
  FROM sys.dm_os_performance_counters
  WHERE counter_name = 'Lazy writes/sec';


SELECT object_name, counter_name, cntr_value
FROM sys.dm_os_performance_counters
WHERE [object_name] LIKE '%Memory Manager%'
AND [counter_name] = 'Memory Grants Pending'



SELECT [counter_name], [cntr_value]
FROM sys.dm_os_performance_counters
WHERE
	[object_name] LIKE '%Memory Manager%'
AND [counter_name] IN ('Total Server Memory (KB)', 'Target Server Memory (KB)')



SELECT ROUND(100.0 * (
	SELECT CAST([cntr_value] AS FLOAT)
	FROM sys.dm_os_performance_counters
        WHERE		
		[object_name] LIKE '%Memory Manager%'
		AND [counter_name] = 'Total Server Memory (KB)'
	) / (
		SELECT CAST([cntr_value] AS FLOAT)
	FROM sys.dm_os_performance_counters
	WHERE
		[object_name] LIKE '%Memory Manager%'
		AND [counter_name] = 'Target Server Memory (KB)')
	, 2)AS [Ratio]


SELECT total_page_file_kb, available_page_file_kb, 
system_memory_state_desc
FROM sys.dm_os_sys_memory 


SELECT object_name, counter_name, cntr_value
FROM sys.dm_os_performance_counters
WHERE [counter_name] = 'Stolen Server Memory (KB)'