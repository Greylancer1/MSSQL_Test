declare @version varchar(4)
select @version = substring(@@version,22,4)

IF CONVERT(SMALLINT, @version) >= 2012
EXEC ('SELECT	
		SERVERPROPERTY(''ServerName'') AS [InstanceName],
		CASE LEFT(CONVERT(VARCHAR, SERVERPROPERTY(''ProductVersion'')),4) 
			WHEN ''11.0'' THEN ''SQL Server 2012''
			WHEN ''12.0'' THEN ''SQL Server 2014''
			ELSE ''Newer than SQL Server 2014''
		END AS [VersionBuild],
		SERVERPROPERTY (''Edition'') AS [Edition],
		SERVERPROPERTY(''ProductLevel'') AS [SP],
		CASE SERVERPROPERTY(''IsIntegratedSecurityOnly'') 
			WHEN 0 THEN ''SQL Server and Windows Authentication mode''
			WHEN 1 THEN ''Windows Authentication mode''
		END AS [ServerAuthentication],
		CASE SERVERPROPERTY(''IsClustered'') 
			WHEN 0 THEN ''False''
			WHEN 1 THEN ''True''
		END AS [Cluster],
		SERVERPROPERTY(''ComputerNamePhysicalNetBIOS'') AS [CurrentNodeName],
		SERVERPROPERTY(''Collation'') AS [Collation],
		[cpu_count] AS [CPUCount],
		[physical_memory_kb]/1024 AS [MemoryMB)]
	FROM	
		[sys].[dm_os_sys_info]')
ELSE IF CONVERT(SMALLINT, @version) >= 2005
EXEC ('SELECT	
		SERVERPROPERTY(''ServerName'') AS [InstanceName],
		CASE LEFT(CONVERT(VARCHAR, SERVERPROPERTY(''ProductVersion'')),4) 
			WHEN ''9.00'' THEN ''SQL Server 2005''
			WHEN ''10.0'' THEN ''SQL Server 2008''
			WHEN ''10.5'' THEN ''SQL Server 2008 R2''
		END AS [VersionBuild],
		SERVERPROPERTY (''Edition'') AS [Edition],
		SERVERPROPERTY(''ProductLevel'') AS [SP],
		CASE SERVERPROPERTY(''IsIntegratedSecurityOnly'') 
			WHEN 0 THEN ''SQL Server and Windows Authentication mode''
			WHEN 1 THEN ''Windows Authentication mode''
		END AS [ServerAuthentication],
		CASE SERVERPROPERTY(''IsClustered'') 
			WHEN 0 THEN ''False''
			WHEN 1 THEN ''True''
		END AS [Cluster],
		SERVERPROPERTY(''ComputerNamePhysicalNetBIOS'') AS [CurrentNodeName],
		SERVERPROPERTY(''Collation'') AS [ SQL Collation],
		[cpu_count] AS [CPUCount],
		[physical_memory_in_bytes]/1048576 AS [MemoryMB]
	FROM	
		[sys].[dm_os_sys_info]')
ELSE 
SELECT 'This SQL Server instance is running SQL Server 2000 or lower! You will need alternative methods in getting the SQL Server instance level information.'