--InstanceInfo
SELECT SERVERPROPERTY('ServerName') AS ServerName
,SERVERPROPERTY('ProductVersion') AS ProductVersion
,SERVERPROPERTY('ProductLevel') AS ProductLevel
,SERVERPROPERTY('Edition') AS Edition
,SERVERPROPERTY('EngineEdition') AS EngineEdition


--InstanceConfig
SELECT @@servername as ServerName,SERVERPROPERTY('ProductVersion') AS Version, name, value, minimum, maximum, value_in_use as [Value in use], description, is_dynamic AS [Dynamic?], is_advanced AS [Advanced?]
FROM    sys.configurations ORDER BY name


--InstanceStats Snapshot
DECLARE @SQLProcessUtilization int;
DECLARE @PageReadsPerSecond bigint
DECLARE @PageWritesPerSecond bigint
DECLARE @CheckpointPagesPerSecond bigint
DECLARE @LazyWritesPerSecond bigint
DECLARE @BatchRequestsPerSecond bigint
DECLARE @CompilationsPerSecond bigint
DECLARE @ReCompilationsPerSecond bigint
DECLARE @PageLookupsPerSecond bigint
DECLARE @TransactionsPerSecond bigint
DECLARE @stat_date datetime
-- Table for First Sample
DECLARE @RatioStatsX TAbLE(
[object_name] varchar(128)
,[counter_name] varchar(128)
,[instance_name] varchar(128)
,[cntr_value] bigint
,[cntr_type] int
)
-- Table for Second Sample
DECLARE @RatioStatsY TAbLE(
[object_name] varchar(128)
,[counter_name] varchar(128)
,[instance_name] varchar(128)
,[cntr_value] bigint
,[cntr_type] int
)
INSERT INTO @RatioStatsX (
[object_name]
,[counter_name]
,[instance_name]
,[cntr_value]
,[cntr_type] )
SELECT [object_name]
,[counter_name]
,[instance_name]
,[cntr_value]
,[cntr_type] FROM sys.dm_os_performance_counters
SET @stat_date = getdate()
SELECT TOP 1 @PageReadsPerSecond=cntr_value
FROM @RatioStatsX
WHERE counter_name = 'Page reads/sec'
AND object_name = CASE WHEN @@SERVICENAME = 'MSSQLSERVER'
THEN 'SQLServer:Buffer Manager'
ELSE 'MSSQL$' + rtrim(@@SERVICENAME) + ':Buffer Manager' END
SELECT TOP 1 @PageWritesPerSecond= cntr_value
FROM @RatioStatsX
WHERE counter_name = 'Page writes/sec'
AND object_name = CASE WHEN @@SERVICENAME = 'MSSQLSERVER'
THEN 'SQLServer:Buffer Manager'
ELSE 'MSSQL$' + rtrim(@@SERVICENAME) + ':Buffer Manager' END
SELECT TOP 1 @CheckpointPagesPerSecond = cntr_value
FROM @RatioStatsX
WHERE counter_name = 'Checkpoint pages/sec'
AND object_name = CASE WHEN @@SERVICENAME = 'MSSQLSERVER'
THEN 'SQLServer:Buffer Manager'
ELSE 'MSSQL$' + rtrim(@@SERVICENAME) + ':Buffer Manager' END
SELECT TOP 1 @LazyWritesPerSecond = cntr_value
FROM @RatioStatsX
WHERE counter_name = 'Lazy writes/sec'
AND object_name = CASE WHEN @@SERVICENAME = 'MSSQLSERVER'
THEN 'SQLServer:Buffer Manager'
ELSE 'MSSQL$' + rtrim(@@SERVICENAME) + ':Buffer Manager' END
SELECT TOP 1 @BatchRequestsPerSecond = cntr_value
FROM @RatioStatsX
WHERE counter_name = 'Batch Requests/sec'
AND object_name = CASE WHEN @@SERVICENAME = 'MSSQLSERVER'
THEN 'SQLServer:SQL Statistics'
ELSE 'MSSQL$' + rtrim(@@SERVICENAME) + ':SQL Statistics' END
SELECT TOP 1 @CompilationsPerSecond = cntr_value
FROM @RatioStatsX
WHERE counter_name = 'SQL Compilations/sec'
AND object_name = CASE WHEN @@SERVICENAME = 'MSSQLSERVER'
THEN 'SQLServer:SQL Statistics'
ELSE 'MSSQL$' + rtrim(@@SERVICENAME) + ':SQL Statistics' END
SELECT TOP 1 @ReCompilationsPerSecond = cntr_value
FROM @RatioStatsX
WHERE counter_name = 'SQL Re-Compilations/sec'
AND object_name = CASE WHEN @@SERVICENAME = 'MSSQLSERVER'
THEN 'SQLServer:SQL Statistics'
ELSE 'MSSQL$' + rtrim(@@SERVICENAME) + ':SQL Statistics' END
SELECT TOP 1 @PageLookupsPerSecond=cntr_value
FROM @RatioStatsX
WHERE counter_name = 'Page lookups/sec'
AND object_name = CASE WHEN @@SERVICENAME = 'MSSQLSERVER'
THEN 'SQLServer:Buffer Manager'
ELSE 'MSSQL$' + rtrim(@@SERVICENAME) + ':Buffer Manager' END
SELECT TOP 1 @TransactionsPerSecond=cntr_value
FROM @RatioStatsX
WHERE counter_name = 'Transactions/sec' AND instance_name = '_Total'
AND object_name = CASE WHEN @@SERVICENAME = 'MSSQLSERVER'
THEN 'SQLServer:Databases'
ELSE 'MSSQL$' + rtrim(@@SERVICENAME) + ':Databases' END
-- Wait for 5 seconds before taking second sample
WAITFOR DELAY '00:00:05'
-- Table for second sample
INSERT INTO @RatioStatsY (
[object_name]
,[counter_name]
,[instance_name]
,[cntr_value]
,[cntr_type] )
SELECT [object_name]
,[counter_name]
,[instance_name]
,[cntr_value]
,[cntr_type] FROM sys.dm_os_performance_counters
SELECT @@servername AS ServerName, (a.cntr_value * 1.0 / b.cntr_value) * 100.0 [BufferCacheHitRatio]
,c.[PageReadPerSec] [PageReadsPerSec]
,d.[PageWritesPerSecond] [PageWritesPerSecond]
,e.cntr_value [UserConnections]
,f.cntr_value [PageLifeExpectency]
,g.[CheckpointPagesPerSecond] [CheckpointPagesPerSecond]
,h.[LazyWritesPerSecond] [LazyWritesPerSecond]
,i.cntr_value [FreeSpaceInTempdbKB]
,j.[BatchRequestsPerSecond] [BatchRequestsPerSecond]
,k.[SQLCompilationsPerSecond] [SQLCompilationsPerSecond]
,l.[SQLReCompilationsPerSecond] [SQLReCompilationsPerSecond]
,m.cntr_value [Target Server Memory (KB)]
,n.cntr_value [Total Server Memory (KB)]
,GETDATE() AS [MeasurementTime]
,o.[AvgTaskCount]
,o.[AvgRunnableTaskCount]
,o.[AvgPendingDiskIOCount]
,p.PercentSignalWait AS [PercentSignalWait]
,q.PageLookupsPerSecond As [PageLookupsPerSecond]
,r.TransactionsPerSecond AS [TransactionsPerSecond]
,s.cntr_value [MemoryGrantsPending]
FROM (SELECT *, 1 x FROM @RatioStatsY
WHERE counter_name = 'Buffer cache hit ratio'
AND object_name = CASE WHEN @@SERVICENAME = 'MSSQLSERVER' THEN 'SQLServer:Buffer Manager' 
	ELSE 'MSSQL$' + rtrim(@@SERVICENAME) + ':Buffer Manager' END ) a
join
(SELECT *, 1 x FROM @RatioStatsY
WHERE counter_name = 'Buffer cache hit ratio base'
AND object_name = CASE WHEN @@SERVICENAME = 'MSSQLSERVER' THEN 'SQLServer:Buffer Manager' 
	ELSE 'MSSQL$' + rtrim(@@SERVICENAME) + ':Buffer Manager' END ) b
on a.x = b.x
join
(SELECT (cntr_value - @PageReadsPerSecond) / (CASE WHEN datediff(ss,@stat_date, getdate()) = 0 THEN 1 
	ELSE datediff(ss,@stat_date, getdate()) end) as [PageReadPerSec], 1 x
FROM @RatioStatsY
WHERE counter_name = 'Page reads/sec'
AND object_name = CASE WHEN @@SERVICENAME = 'MSSQLSERVER' THEN 'SQLServer:Buffer Manager' 
	ELSE 'MSSQL$' + rtrim(@@SERVICENAME) + ':Buffer Manager' END
)c on a.x = c.x
join
(SELECT (cntr_value - @PageWritesPerSecond) / (CASE WHEN datediff(ss,@stat_date, getdate()) = 0 THEN 1 
	ELSE datediff(ss,@stat_date, getdate()) end) as [PageWritesPerSecond], 1 x
FROM @RatioStatsY
WHERE counter_name = 'Page writes/sec'
AND object_name = CASE WHEN @@SERVICENAME = 'MSSQLSERVER' THEN 'SQLServer:Buffer Manager' 
	ELSE 'MSSQL$' + rtrim(@@SERVICENAME) + ':Buffer Manager' END
) d on a.x = d.x
join
(SELECT *, 1 x FROM @RatioStatsY
WHERE counter_name = 'User Connections'
AND object_name = CASE WHEN @@SERVICENAME = 'MSSQLSERVER' THEN 'SQLServer:General Statistics' 
	ELSE 'MSSQL$' + rtrim(@@SERVICENAME) + ':General Statistics' END ) e
on a.x = e.x
join
(SELECT *, 1 x FROM @RatioStatsY
WHERE counter_name = 'Page life expectancy '
AND object_name = CASE WHEN @@SERVICENAME = 'MSSQLSERVER' THEN 'SQLServer:Buffer Manager' ELSE 'MSSQL$' + rtrim(@@SERVICENAME) + ':Buffer Manager' END ) f
on a.x = f.x
join
(SELECT (cntr_value - @CheckpointPagesPerSecond) / (CASE WHEN datediff(ss,@stat_date, getdate()) = 0 THEN 1 
	ELSE datediff(ss,@stat_date, getdate()) end) as [CheckpointPagesPerSecond], 1 x
FROM @RatioStatsY
WHERE counter_name = 'Checkpoint pages/sec'
AND object_name = CASE WHEN @@SERVICENAME = 'MSSQLSERVER' THEN 'SQLServer:Buffer Manager' 
	ELSE 'MSSQL$' + rtrim(@@SERVICENAME) + ':Buffer Manager' END
) g on a.x = g.x
join
(SELECT (cntr_value - @LazyWritesPerSecond) / (CASE WHEN datediff(ss,@stat_date, getdate()) = 0 THEN 1 
	ELSE datediff(ss,@stat_date, getdate()) end) as [LazyWritesPerSecond], 1 x
FROM @RatioStatsY
WHERE counter_name = 'Lazy writes/sec'
AND object_name = CASE WHEN @@SERVICENAME = 'MSSQLSERVER' THEN 'SQLServer:Buffer Manager' 
	ELSE 'MSSQL$' + rtrim(@@SERVICENAME) + ':Buffer Manager' END
) h
on a.x = h.x
join
(SELECT *, 1 x FROM @RatioStatsY
WHERE counter_name = 'Free Space in tempdb (KB)'
AND object_name = CASE WHEN @@SERVICENAME = 'MSSQLSERVER' THEN 'SQLServer:Transactions' 
	ELSE 'MSSQL$' + rtrim(@@SERVICENAME) + ':Transactions' end) i
on a.x = i.x
join
(SELECT (cntr_value - @BatchRequestsPerSecond) / (CASE WHEN datediff(ss,@stat_date, getdate()) = 0 THEN 1 
	ELSE datediff(ss,@stat_date, getdate()) end) as [BatchRequestsPerSecond], 1 x
FROM @RatioStatsY
WHERE counter_name = 'Batch Requests/sec'
AND object_name = CASE WHEN @@SERVICENAME = 'MSSQLSERVER' THEN 'SQLServer:SQL Statistics' 
	ELSE 'MSSQL$' + rtrim(@@SERVICENAME) + ':SQL Statistics' END
) j
on a.x = j.x
join
(SELECT (cntr_value - @CompilationsPerSecond) / (CASE WHEN datediff(ss,@stat_date,getdate()) = 0 THEN 1 
	ELSE datediff(ss,@stat_date, getdate()) end) as [SQLCompilationsPerSecond], 1 x
FROM @RatioStatsY
WHERE counter_name = 'SQL Compilations/sec'
AND object_name = CASE WHEN @@SERVICENAME = 'MSSQLSERVER' THEN 'SQLServer:SQL Statistics' 
	ELSE 'MSSQL$' + rtrim(@@SERVICENAME) + ':SQL Statistics' END
) k on a.x = k.x
join
(SELECT (cntr_value - @ReCompilationsPerSecond) / (CASE WHEN datediff(ss,@stat_date, getdate()) = 0 THEN 1 
	ELSE datediff(ss,@stat_date, getdate()) end) as [SQLReCompilationsPerSecond], 1 x
FROM @RatioStatsY
WHERE counter_name = 'SQL Re-Compilations/sec'
AND object_name = CASE WHEN @@SERVICENAME = 'MSSQLSERVER' THEN 'SQLServer:SQL Statistics' 
	ELSE 'MSSQL$' + rtrim(@@SERVICENAME) + ':SQL Statistics' END
) l
on a.x = l.x
join
(SELECT *, 1 x FROM @RatioStatsY
WHERE counter_name = 'Target Server Memory (KB)'
AND object_name = CASE WHEN @@SERVICENAME = 'MSSQLSERVER' THEN 'SQLServer:Memory Manager' 
	ELSE 'MSSQL$' + rtrim(@@SERVICENAME) + ':Memory Manager' END ) m
on a.x = m.x
join
(SELECT *, 1 x FROM @RatioStatsY
WHERE counter_name = 'Total Server Memory (KB)'
AND object_name = CASE WHEN @@SERVICENAME = 'MSSQLSERVER' THEN 'SQLServer:Memory Manager' 
	ELSE 'MSSQL$' + rtrim(@@SERVICENAME) + ':Memory Manager' END ) n
on a.x = n.x
JOIN
(SELECT 1 AS x
, AVG(current_tasks_count)AS [AvgTaskCount]
, AVG(runnable_tasks_count)AS [AvgRunnableTaskCount]
, AVG(pending_disk_io_count) AS [AvgPendingDiskIOCount]
FROM sys.dm_os_schedulers
WHERE scheduler_id < 255) o
on a.x = o.x
JOIN
( SELECT 1 AS x, SUM(signal_wait_time_ms) / sum (wait_time_ms) AS PercentSignalWait
FROM sys.dm_os_wait_stats) p
ON a.x = p.x
join
(SELECT (cntr_value - @PageLookupsPerSecond) / (CASE WHEN datediff(ss,@stat_date, getdate()) = 0 THEN 1 
	ELSE datediff(ss,@stat_date, getdate()) end) as [PageLookupsPerSecond], 1 x
FROM @RatioStatsY
WHERE counter_name = 'Page Lookups/sec'
AND object_name = CASE WHEN @@SERVICENAME = 'MSSQLSERVER' THEN 'SQLServer:Buffer Manager' 
	ELSE 'MSSQL$' + rtrim(@@SERVICENAME) + ':Buffer Manager' END
) q
on a.x = q.x
join
(SELECT (cntr_value - @TransactionsPerSecond) / (CASE WHEN datediff(ss,@stat_date, getdate()) = 0 THEN 1 
	ELSE datediff(ss,@stat_date, getdate()) end) as [TransactionsPerSecond], 1 x
FROM @RatioStatsY
WHERE counter_name = 'Transactions/sec' AND instance_name = '_Total'
AND object_name = CASE WHEN @@SERVICENAME = 'MSSQLSERVER'
THEN 'SQLServer:Databases'
ELSE 'MSSQL$' + rtrim(@@SERVICENAME) + ':Databases' END ) r
on a.x = r.x
join
(SELECT *, 1 x FROM @RatioStatsY
WHERE counter_name = 'Memory Grants Pending'
AND object_name = CASE WHEN @@SERVICENAME = 'MSSQLSERVER' THEN 'SQLServer:Memory Manager' 
	ELSE 'MSSQL$' + rtrim(@@SERVICENAME) + ':Memory Manager' END ) s
on a.x = s.x


--SQL Jobs
USE msdb    
SELECT  
   @@Servername,
   j.[name] AS [JobName],  
   run_status = CASE h.run_status  
   WHEN 0 THEN 'Failed' 
   WHEN 1 THEN 'Succeeded' 
   WHEN 2 THEN 'Retry' 
   WHEN 3 THEN 'Canceled' 
   WHEN 4 THEN 'In progress' 
   END, 
   [RunDateTime] = dbo.agent_datetime(h.run_date,h.run_time)
FROM sysjobhistory h  
   INNER JOIN sysjobs j ON h.job_id = j.job_id  
       WHERE --h.run_status = 0 AND 
	   j.enabled = 1   
       AND h.instance_id IN  
       (SELECT MAX(h.instance_id)  
           FROM sysjobhistory h GROUP BY (h.job_id))


--Error Log
DECLARE @sqlStatement1 VARCHAR(200)
SET @sqlStatement1 = 'master.dbo.xp_readerrorlog'
        CREATE TABLE #Errors (LogDate DATETIME,ProcessInfo NVARCHAR(50),vchMessage varchar(2000))
INSERT #Errors EXEC @sqlStatement1
SELECT @@servername as ServerName, LogDate, RTRIM(LTRIM(vchMessage)) FROM #Errors WHERE 
([vchMessage] like '%error%'
   or  [vchMessage] like '%fail%'
   or  [vchMessage] like '%Warning%'
   or  [vchMessage] like '%The SQL Server cannot obtain a LOCK resource at this time%'
   or  [vchMessage] like '%Autogrow of file%in database%cancelled or timed out after%'
   or  [vchMessage] like '%Consider using ALTER DATABASE to set smaller FILEGROWTH%'
   or  [vchMessage] like '% is full%'
   or  [vchMessage] like '% blocking processes%'
   or  [vchMessage] like '%SQL Server has encountered%IO requests taking longer%to complete%'
)
and [vchMessage] not like '%\ERRORLOG%'
and [vchMessage] not like '%Attempting to cycle errorlog%'
and [vchMessage] not like '%Errorlog has been reinitialized.%' 
and [vchMessage] not like '%found 0 errors and repaired 0 errors.%'
and [vchMessage] not like '%without errors%'
and [vchMessage] not like '%This is an informational message%'
and [vchMessage] not like '%WARNING:%Failed to reserve contiguous memory%'
and [vchMessage] not like '%The error log has been reinitialized%'
and [vchMessage] not like '%Setting database option ANSI_WARNINGS%'
and [vchMessage] not like '%Error: 15457, Severity: 0, State: 1%'
and [vchMessage] <>  'Error: 18456, Severity: 14, State: 16.'
AND Logdate > GETDATE() - 2
  
DROP TABLE #Errors


--DB Config
SELECT @@servername, name,  
    DATABASEPROPERTYEX(name, 'Recovery') AS RecoveryMode, 
    DATABASEPROPERTYEX(name, 'Status') AS [Status],
	DATABASEPROPERTYEX(name, 'IsAutoClose') AS [AutoClose],
	DATABASEPROPERTYEX(name, 'IsAutoCreateStatistics') AS [AutoStats],
	DATABASEPROPERTYEX(name, 'IsAutoShrink') AS [AutoShrink],
	DATABASEPROPERTYEX(name, 'IsFullTextEnabled') AS [FullText]
FROM   master.dbo.sysdatabases 


--Table List
CREATE TABLE [dbo].[#TMP] ( 
[SRVRNAME] NVARCHAR(256) NULL,
[DBNAME] NVARCHAR(256) NULL,
[TABLENAME] NVARCHAR(256) NULL);

EXEC sp_MSforeachdb 'USE ? INSERT INTO #TMP SELECT @@Servername, ''?'', Name AS TableName FROM sysobjects WHERE xtype = ''U'' AND ''?'' NOT IN (''master'', ''msdb'', ''tempdb'', ''ReportServer'', ''ReportServerTempDB'') ORDER BY name'
SELECT * FROM #TMP
DROP TABLE #TMP


-- Shows all user tables and row counts for the current database 
CREATE TABLE #output( 
server_name varchar(128), 
dbname varchar(128), 
tablename varchar(260), 
dt datetime, 
[Rows] int) 

EXEC sp_MSForEachDB @command1='USE [?];
INSERT #output SELECT @@Servername AS ServerName, DB_name() AS DBName, o.name AS TableName, GETDATE(), 
  ddps.row_count 
FROM sys.indexes AS i
  INNER JOIN sys.objects AS o ON i.OBJECT_ID = o.OBJECT_ID
  INNER JOIN sys.dm_db_partition_stats AS ddps ON i.OBJECT_ID = ddps.OBJECT_ID
  AND i.index_id = ddps.index_id 
WHERE DB_name() NOT IN (''master'', ''msdb'', ''tempdb'', ''model'') AND i.index_id < 2  AND o.is_ms_shipped = 0 
ORDER BY o.NAME'

SELECT * FROM #output
DROP TABLE #output


--TableSizes
CREATE TABLE #temp(
	DBName		varchar(50),
	table_name	varchar(128),
	SchemaName varchar(50),
	nbr_of_rows	int,
	Total_space	int,
	Used_space	int,
	Unused_size	int
)
EXEC sp_msforeachdb @command1=
'IF ''?'' NOT IN(''master'', ''model'', ''msdb'', ''tempdb'') BEGIN USE ? 
insert into #temp(DBName, Table_name, SchemaName, nbr_of_rows, Total_space, Used_space, Unused_size) 
SELECT 
	''?'' AS DB,
	t.NAME AS TableName,
    s.Name AS SchemaName,
    p.rows AS RowCounts,
    SUM(a.total_pages) * 8 AS TotalSpaceKB, 
    SUM(a.used_pages) * 8 AS UsedSpaceKB, 
    (SUM(a.total_pages) - SUM(a.used_pages)) * 8 AS UnusedSpaceKB
FROM 
    sys.tables t
INNER JOIN      
    sys.indexes i ON t.OBJECT_ID = i.object_id
INNER JOIN 
    sys.partitions p ON i.object_id = p.OBJECT_ID AND i.index_id = p.index_id
INNER JOIN 
    sys.allocation_units a ON p.partition_id = a.container_id
LEFT OUTER JOIN 
    sys.schemas s ON t.schema_id = s.schema_id
WHERE 
    t.NAME NOT LIKE ''dt%'' 
    AND t.is_ms_shipped = 0
    AND i.OBJECT_ID > 255 
GROUP BY 
    t.Name, s.Name, p.Rows
ORDER BY 
    t.Name
END'

-- Get the data
SELECT getdate() as Dtm, @@servername as ServerName, *
FROM #temp
ORDER BY total_space DESC
-- Comment out the following line if you want to do further querying
DROP TABLE #temp


--Space Usage by file
CREATE TABLE #output( 
server_name varchar(128), 
dbname varchar(128), 
physical_name varchar(260), 
dt datetime, 
file_group_name varchar(128), 
size_mb int, 
free_mb int)  
 
exec sp_MSforeachdb @command1= 
'USE [?]; INSERT #output 
SELECT CAST(SERVERPROPERTY(''ServerName'') AS varchar(128)) AS server_name, 
''?'' AS dbname, 
f.filename AS physical_name, 
CAST(FLOOR(CAST(getdate() AS float)) AS datetime) AS dt, 
g.groupname, 
CAST (size*8.0/1024.0 AS int) AS ''size_mb'', 
CAST((size - FILEPROPERTY(f.name,''SpaceUsed''))*8.0/1024.0 AS int) AS ''free_mb'' 
FROM sysfiles f 
JOIN sysfilegroups g 
ON f.groupid = g.groupid' 
 
SELECT * FROM #output
DROP TABLE #output


--Log file info
SET NOCOUNT ON

DECLARE @Result Table (
	[DBName] Varchar(100),
	[size] int,
	Log_Size float,
	Log_Space float
)
DECLARE @DBName Varchar(100)
DECLARE @SIZE int

declare @RECCNT varchar(500)
declare @DeviceName varchar(500)
declare @CMD Nvarchar(500)

DECLARE tmpcursor CURSOR FOR select DBName from @Result

INSERT INTO @Result (DBName)
Select [name] from sysdatabases where [status] <> 536

IF EXISTS (Select [name] from sysobjects where xtype = 'u' and [name] = '#temp_table')
	DROP TABLE #temp_table

create table #temp_table (
	Database_Name varchar(100),
	Log_Size float,
	Log_Space float,
	Status varchar(100)
)
insert into #temp_table
EXEC ('DBCC sqlperf(LOGSPACE) WITH NO_INFOMSGS')

declare @temp_table table (
	Database_Name varchar(100),
	Log_Size float,
	Log_Space float,
	Status varchar(100)
)
insert into @temp_table
select * from #temp_table

drop table #temp_table

OPEN tmpcursor

FETCH NEXT FROM tmpcursor INTO @DBName
WHILE (@@fetch_status <> -1)
BEGIN
	IF (@@fetch_status <> -2)
	BEGIN
		SET @CMD = N'use ' +  quotename(@DBName) + N' SELECT @SIZE=(SUM([size]) * 8) from sysfiles'-- where [name] = @RECCNT'
		exec sp_executesql @CMD,
                   N'@DeviceName varchar(100) out, @SIZE int out, @RECCNT varchar(100)', 
                   @DBName,
		   @SIZE out,
		   @RECCNT
		update @Result
		set [size] = LTRIM(RTRIM(@SIZE))
		where DBName = @DBName
		update @Result set Log_Size = (Select Log_Size from @temp_table where Database_Name = @DBName) where DBName = @DBName
		update @Result set Log_Space = (Select Log_Space from @temp_table where Database_Name = @DBName) where DBName = @DBName
	END
	FETCH NEXT FROM tmpcursor INTO @DBName
END
select DBName, getdate() AS Dtm, CONVERT(char,CAST([size] AS money),1) AS 'TotalSize(MB)', CONVERT(char,CAST([Log_Size] as money),1) AS 'LogSize(MB)', CONVERT(char,CAST([Log_Space] as money),1)  AS 'LogSpaceUsed(%)' from @Result
order by size DESC

CLOSE tmpcursor
DEALLOCATE tmpcursor

SET NOCOUNT OFF
GO


--Index Frag
CREATE TABLE [dbo].[#TMP] ( 
[SRVRNAME] NVARCHAR(256) NULL,
[DBNAME] NVARCHAR(256) NULL,
[IDXNAME] NVARCHAR(256) NULL,
[FRAG] INT NULL,
[PAGES] INT NULL);

EXEC sp_MSforeachdb 'USE ? INSERT INTO #TMP
SELECT @@servername, ''?'', t.name, ps.avg_fragmentation_in_percent, ps.page_count
FROM sys.dm_db_index_physical_stats (DB_ID(''?''), NULL, NULL, NULL, NULL) ps
INNER JOIN sys.indexes t ON t.object_id = ps.object_id
WHERE ps.avg_fragmentation_in_percent > 40 AND ps.page_count > 1000 AND t.name IS NOT NULL AND ''?'' NOT IN (''master'', ''msdb'', ''tempdb'', ''ReportServer'', ''ReportServerTempDB'')
'
SELECT * FROM #TMP
DROP TABLE #TMP