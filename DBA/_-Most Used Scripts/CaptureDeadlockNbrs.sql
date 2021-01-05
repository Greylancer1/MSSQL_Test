declare @v1 bigint, @v2 bigint
select @v1 = cntr_value from master.sys.dm_os_performance_counters
where counter_name='Number of Deadlocks/sec'
waitfor delay '00:00:01'
select @v2 = cntr_value from master.sys.dm_os_performance_counters
where counter_name='Number of Deadlocks/sec'
select @v2 - @v1


*****


SELECT cntr_value AS NumOfDeadLocks
  FROM sys.dm_os_performance_counters
 WHERE object_name = 'SQLServer:Locks'
   AND counter_name = 'Number of Deadlocks/sec'
   AND instance_name = '_Total'