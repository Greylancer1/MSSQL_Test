USE [msdb]
GO

/****** Object:  Job [DBA Weekly Restore]    Script Date: 3/2/2018 10:34:56 AM ******/
BEGIN TRANSACTION
DECLARE @ReturnCode INT
SELECT @ReturnCode = 0
/****** Object:  JobCategory [[Uncategorized (Local)]]    Script Date: 3/2/2018 10:34:56 AM ******/
IF NOT EXISTS (SELECT name FROM msdb.dbo.syscategories WHERE name=N'[Uncategorized (Local)]' AND category_class=1)
BEGIN
EXEC @ReturnCode = msdb.dbo.sp_add_category @class=N'JOB', @type=N'LOCAL', @name=N'[Uncategorized (Local)]'
IF (@@ERROR <> 0 OR @ReturnCode <> 0) GOTO QuitWithRollback

END

DECLARE @jobId BINARY(16)
EXEC @ReturnCode =  msdb.dbo.sp_add_job @job_name=N'DBA Weekly Restore', 
		@enabled=1, 
		@notify_level_eventlog=0, 
		@notify_level_email=0, 
		@notify_level_netsend=0, 
		@notify_level_page=0, 
		@delete_level=0, 
		@description=N'Restores aaData_CA and Customers', 
		@category_name=N'[Uncategorized (Local)]', 
		@owner_login_name=N'HYWD\dba.keith', @job_id = @jobId OUTPUT
IF (@@ERROR <> 0 OR @ReturnCode <> 0) GOTO QuitWithRollback
/****** Object:  Step [aaData_CA]    Script Date: 3/2/2018 10:34:56 AM ******/
EXEC @ReturnCode = msdb.dbo.sp_add_jobstep @job_id=@jobId, @step_name=N'aaData_CA', 
		@step_id=1, 
		@cmdexec_success_code=0, 
		@on_success_action=3, 
		@on_success_step_id=0, 
		@on_fail_action=2, 
		@on_fail_step_id=0, 
		@retry_attempts=0, 
		@retry_interval=0, 
		@os_run_priority=0, @subsystem=N'TSQL', 
		@command=N'Declare @FileName varChar(255)
Declare @cmdText varChar(255)
Declare @BKFolder varchar(255)
DECLARE @cmd NVARCHAR(500) 

set @FileName = null
set @cmdText = null
set @BKFolder = ''\\VHYDPM01.hywd.ipzo.net\SQLBackups\CHYSQL1CL$SimsSqlHA1\aaData_CA\FULL\''


create table #FileList (
FileName varchar(255),
DepthFlag int,
FileFlag int
)


--get all the files and folders in the backup folder and put them in temporary table
insert into #FileList exec xp_dirtree @BKFolder,0,1
--select * from #filelist

--get the latest backup file name
select top 1 @FileName = @BKFolder + FileName from #FileList where Filename like ''%.bak'' order by filename desc
--select @filename


--kick off current users/processes
ALTER DATABASE aaData_CA
SET SINGLE_USER WITH ROLLBACK IMMEDIATE;


--execute the restore
EXEC (''RESTORE DATABASE [aaData_CA] FROM  DISK = '''''' + @filename + '''''' WITH REPLACE'')
--SET @cmd = (''RESTORE DATABASE [Test] FROM  DISK = '''''' + @filename + '''''' WITH REPLACE'')
--EXEC @CMD

--Let people/processes back in!
ALTER DATABASE aaData_CA
SET MULTI_USER WITH ROLLBACK IMMEDIATE;
--PRINT @cmd
DROP TABLE #FileList
go', 
		@database_name=N'master', 
		@flags=0
IF (@@ERROR <> 0 OR @ReturnCode <> 0) GOTO QuitWithRollback
/****** Object:  Step [aaData_CA security]    Script Date: 3/2/2018 10:34:56 AM ******/
EXEC @ReturnCode = msdb.dbo.sp_add_jobstep @job_id=@jobId, @step_name=N'aaData_CA security', 
		@step_id=2, 
		@cmdexec_success_code=0, 
		@on_success_action=3, 
		@on_success_step_id=0, 
		@on_fail_action=2, 
		@on_fail_step_id=0, 
		@retry_attempts=0, 
		@retry_interval=0, 
		@os_run_priority=0, @subsystem=N'TSQL', 
		@command=N'-- [-- DB USERS --] --
CREATE ROLE db_executor

-- Grant execute rights to the new role
GRANT EXECUTE TO db_executor
IF NOT EXISTS (SELECT [name] FROM sys.database_principals WHERE [name] =  ''dbo'') BEGIN CREATE USER  [dbo] FOR LOGIN [sa] WITH DEFAULT_SCHEMA = [dbo] END; 
IF NOT EXISTS (SELECT [name] FROM sys.database_principals WHERE [name] =  ''DS_ETL'') BEGIN CREATE USER  [DS_ETL] FOR LOGIN [DS_ETL] WITH DEFAULT_SCHEMA = [dbo] END; 
IF NOT EXISTS (SELECT [name] FROM sys.database_principals WHERE [name] =  ''guest'') BEGIN CREATE USER  [guest] WITHOUT LOGIN WITH DEFAULT_SCHEMA = [guest] END; 
IF NOT EXISTS (SELECT [name] FROM sys.database_principals WHERE [name] =  ''HYWD\bayleem'') BEGIN CREATE USER  [HYWD\bayleem] FOR LOGIN [HYWD\bayleek] WITH DEFAULT_SCHEMA = [dbo] END; 
IF NOT EXISTS (SELECT [name] FROM sys.database_principals WHERE [name] =  ''HYWD\brandonw'') BEGIN CREATE USER  [HYWD\brandonw] FOR LOGIN [HYWD\brandonw] WITH DEFAULT_SCHEMA = [dbo] END; 
IF NOT EXISTS (SELECT [name] FROM sys.database_principals WHERE [name] =  ''HYWD\dashboard_app'') BEGIN CREATE USER  [HYWD\dashboard_app] FOR LOGIN [HYWD\dashboard_app] WITH DEFAULT_SCHEMA = [dbo] END; 
IF NOT EXISTS (SELECT [name] FROM sys.database_principals WHERE [name] =  ''HYWD\djj'') BEGIN CREATE USER  [HYWD\djj] FOR LOGIN [HYWD\djj] WITH DEFAULT_SCHEMA = [dbo] END; 
IF NOT EXISTS (SELECT [name] FROM sys.database_principals WHERE [name] =  ''HYWD\garyg'') BEGIN CREATE USER  [HYWD\garyg] FOR LOGIN [HYWD\garyg] WITH DEFAULT_SCHEMA = [dbo] END; 
IF NOT EXISTS (SELECT [name] FROM sys.database_principals WHERE [name] =  ''HYWD\henryp'') BEGIN CREATE USER  [HYWD\henryp] FOR LOGIN [HYWD\henryp] WITH DEFAULT_SCHEMA = [dbo] END; 
IF NOT EXISTS (SELECT [name] FROM sys.database_principals WHERE [name] =  ''HYWD\HYWD_DEVOPS_SQLTEST'') BEGIN CREATE USER  [HYWD\HYWD_DEVOPS_SQLTEST] FOR LOGIN [HYWD\HYWD_DEVOPS_SQLTEST] WITH DEFAULT_SCHEMA = [HYWD\HYWD_DEVOPS_SQLTEST] END; 
IF NOT EXISTS (SELECT [name] FROM sys.database_principals WHERE [name] =  ''HYWD\HYWD_PHBSQL01_RW'') BEGIN CREATE USER  [HYWD\HYWD_PHBSQL01_RW] FOR LOGIN [HYWD\HYWD_PHBSQL01_RW] WITH DEFAULT_SCHEMA = [dbo] END; 
IF NOT EXISTS (SELECT [name] FROM sys.database_principals WHERE [name] =  ''HYWD\iarinam'') BEGIN CREATE USER  [HYWD\iarinam] FOR LOGIN [HYWD\iarinam] WITH DEFAULT_SCHEMA = [dbo] END; 
IF NOT EXISTS (SELECT [name] FROM sys.database_principals WHERE [name] =  ''HYWD\Jareds'') BEGIN CREATE USER  [HYWD\Jareds] FOR LOGIN [HYWD\Jareds] WITH DEFAULT_SCHEMA = [dbo] END; 
IF NOT EXISTS (SELECT [name] FROM sys.database_principals WHERE [name] =  ''HYWD\JeremyW'') BEGIN CREATE USER  [HYWD\JeremyW] FOR LOGIN [HYWD\JeremyW] WITH DEFAULT_SCHEMA = [dbo] END; 
IF NOT EXISTS (SELECT [name] FROM sys.database_principals WHERE [name] =  ''HYWD\leadAlerts_App'') BEGIN CREATE USER  [HYWD\leadAlerts_App] FOR LOGIN [HYWD\leadAlerts_App] WITH DEFAULT_SCHEMA = [dbo] END; 
IF NOT EXISTS (SELECT [name] FROM sys.database_principals WHERE [name] =  ''HYWD\michaelo'') BEGIN CREATE USER  [HYWD\michaelo] FOR LOGIN [HYWD\michaelo] WITH DEFAULT_SCHEMA = [dbo] END; 
IF NOT EXISTS (SELECT [name] FROM sys.database_principals WHERE [name] =  ''HYWD\neilh'') BEGIN CREATE USER  [HYWD\neilh] FOR LOGIN [HYWD\neilh] WITH DEFAULT_SCHEMA = [dbo] END; 
IF NOT EXISTS (SELECT [name] FROM sys.database_principals WHERE [name] =  ''HYWD\patrickf'') BEGIN CREATE USER  [HYWD\patrickf] FOR LOGIN [HYWD\patrickf] WITH DEFAULT_SCHEMA = [dbo] END; 
IF NOT EXISTS (SELECT [name] FROM sys.database_principals WHERE [name] =  ''HYWD\PROD_BU_SQLAccess_RWE'') BEGIN CREATE USER  [HYWD\PROD_BU_SQLAccess_RWE] FOR LOGIN [HYWD\PROD_BU_SQLAccess_RWE] WITH DEFAULT_SCHEMA = [dbo] END; 
IF NOT EXISTS (SELECT [name] FROM sys.database_principals WHERE [name] =  ''HYWD\russp'') BEGIN CREATE USER  [HYWD\russp] FOR LOGIN [HYWD\russp] WITH DEFAULT_SCHEMA = [dbo] END; 
IF NOT EXISTS (SELECT [name] FROM sys.database_principals WHERE [name] =  ''HYWD\seand'') BEGIN CREATE USER  [HYWD\seand] FOR LOGIN [HYWD\seand] WITH DEFAULT_SCHEMA = [dbo] END; 
IF NOT EXISTS (SELECT [name] FROM sys.database_principals WHERE [name] =  ''HYWD\SimsDBWorker'') BEGIN CREATE USER  [HYWD\SimsDBWorker] FOR LOGIN [HYWD\SimsDBWorker] WITH DEFAULT_SCHEMA = [dbo] END; 
IF NOT EXISTS (SELECT [name] FROM sys.database_principals WHERE [name] =  ''HYWD\SQLAccessFSG'') BEGIN CREATE USER  [HYWD\SQLAccessFSG] FOR LOGIN [HYWD\SQLAccessFSG] WITH DEFAULT_SCHEMA = [dbo] END; 
IF NOT EXISTS (SELECT [name] FROM sys.database_principals WHERE [name] =  ''HYWD\TomCat_App'') BEGIN CREATE USER  [HYWD\TomCat_App] FOR LOGIN [HYWD\TomCat_App] WITH DEFAULT_SCHEMA = [dbo] END; 
IF NOT EXISTS (SELECT [name] FROM sys.database_principals WHERE [name] =  ''HYWD\VictorR'') BEGIN CREATE USER  [HYWD\VictorR] FOR LOGIN [HYWD\VictorR] WITH DEFAULT_SCHEMA = [dbo] END; 
IF NOT EXISTS (SELECT [name] FROM sys.database_principals WHERE [name] =  ''HYWD\zgridworker'') BEGIN CREATE USER  [HYWD\zgridworker] FOR LOGIN [HYWD\zGridWorker] WITH DEFAULT_SCHEMA = [dbo] END; 
IF NOT EXISTS (SELECT [name] FROM sys.database_principals WHERE [name] =  ''HYWD\zgridworker'') BEGIN CREATE USER  [HYWD\HYWD_PHB_Cluj_Devs] FOR LOGIN [HYWD\HYWD_PHB_Cluj_Devs] WITH DEFAULT_SCHEMA = [dbo] END; 
-- [-- ORPHANED USERS --] --
-- [-- DB ROLES --] --
EXEC sp_addrolemember @rolename = ''db_datareader'', @membername = ''DS_ETL''
EXEC sp_addrolemember @rolename = ''db_datareader'', @membername = ''HYWD\_MarketingAnalyticsS''
EXEC sp_addrolemember @rolename = ''db_datareader'', @membername = ''HYWD\_metrics''
EXEC sp_addrolemember @rolename = ''db_datareader'', @membername = ''HYWD\Application Support Group''
EXEC sp_addrolemember @rolename = ''db_datareader'', @membername = ''HYWD\bayleem''
EXEC sp_addrolemember @rolename = ''db_datareader'', @membername = ''HYWD\brandonw''
EXEC sp_addrolemember @rolename = ''db_datareader'', @membername = ''HYWD\dashboard_app''
EXEC sp_addrolemember @rolename = ''db_datareader'', @membername = ''HYWD\garyg''
EXEC sp_addrolemember @rolename = ''db_datareader'', @membername = ''HYWD\henryp''
EXEC sp_addrolemember @rolename = ''db_datareader'', @membername = ''HYWD\HYWD_PHBSQL01_RW''
EXEC sp_addrolemember @rolename = ''db_datareader'', @membername = ''HYWD\JeremyW''
EXEC sp_addrolemember @rolename = ''db_datareader'', @membername = ''HYWD\michaelo''
EXEC sp_addrolemember @rolename = ''db_datareader'', @membername = ''HYWD\neilh''
EXEC sp_addrolemember @rolename = ''db_datareader'', @membername = ''HYWD\patrickf''
EXEC sp_addrolemember @rolename = ''db_datareader'', @membername = ''HYWD\PROD_BU_SQLAccess_RWE''
EXEC sp_addrolemember @rolename = ''db_datareader'', @membername = ''HYWD\russp''
EXEC sp_addrolemember @rolename = ''db_datareader'', @membername = ''HYWD\VictorR''
EXEC sp_addrolemember @rolename = ''db_datareader'', @membername = ''HYWD\HYWD_PHB_Cluj_Devs''
EXEC sp_addrolemember @rolename = ''db_datawriter'', @membername = ''HYWD\garyg''
EXEC sp_addrolemember @rolename = ''db_datawriter'', @membername = ''HYWD\HYWD_PHBSQL01_RW''
EXEC sp_addrolemember @rolename = ''db_datawriter'', @membername = ''HYWD\michaelo''
EXEC sp_addrolemember @rolename = ''db_datawriter'', @membername = ''HYWD\neilh''
EXEC sp_addrolemember @rolename = ''db_datawriter'', @membername = ''HYWD\patrickf''
EXEC sp_addrolemember @rolename = ''db_datawriter'', @membername = ''HYWD\PROD_BU_SQLAccess_RWE''
EXEC sp_addrolemember @rolename = ''db_datawriter'', @membername = ''HYWD\HYWD_PHB_Cluj_Devs''
EXEC sp_addrolemember @rolename = ''db_ddladmin'', @membername = ''HYWD\_SQL_Monitor''
EXEC sp_addrolemember @rolename = ''db_ddladmin'', @membername = ''HYWD\HYWD_PHB_Cluj_Devs''
EXEC sp_addrolemember @rolename = ''db_executor'', @membername = ''HYWD\PROD_BU_SQLAccess_RWE''
EXEC sp_addrolemember @rolename = ''db_executor'', @membername = ''HYWD\HYWD_PHB_Cluj_Devs''
EXEC sp_addrolemember @rolename = ''db_owner'', @membername = ''danan''
EXEC sp_addrolemember @rolename = ''db_owner'', @membername = ''HYWD\_simsmobilesvc''
EXEC sp_addrolemember @rolename = ''db_owner'', @membername = ''HYWD\aaApi_App''
EXEC sp_addrolemember @rolename = ''db_owner'', @membername = ''HYWD\aaApiSQL''
EXEC sp_addrolemember @rolename = ''db_owner'', @membername = ''HYWD\AgentsAlly_App''
EXEC sp_addrolemember @rolename = ''db_owner'', @membername = ''HYWD\danan''
EXEC sp_addrolemember @rolename = ''db_owner'', @membername = ''HYWD\henryp''
EXEC sp_addrolemember @rolename = ''db_owner'', @membername = ''HYWD\HYWD_DEVOPS_SQLTEST''
EXEC sp_addrolemember @rolename = ''db_owner'', @membername = ''HYWD\iarinam''
EXEC sp_addrolemember @rolename = ''db_owner'', @membername = ''HYWD\Jareds''
EXEC sp_addrolemember @rolename = ''db_owner'', @membername = ''HYWD\leadAlerts_App''
EXEC sp_addrolemember @rolename = ''db_owner'', @membername = ''HYWD\patrickf''
EXEC sp_addrolemember @rolename = ''db_owner'', @membername = ''HYWD\seand''
EXEC sp_addrolemember @rolename = ''db_owner'', @membername = ''HYWD\SimsDBWorker''
EXEC sp_addrolemember @rolename = ''db_owner'', @membername = ''HYWD\SQLAccessFSG''
EXEC sp_addrolemember @rolename = ''db_owner'', @membername = ''HYWD\TomCat_App''
EXEC sp_addrolemember @rolename = ''db_owner'', @membername = ''HYWD\zgridworker''
EXEC sp_addrolemember @rolename = ''db_owner'', @membername = ''tomcat''
 
-- [-- OBJECT LEVEL PERMISSIONS --] --
DENY EXECUTE ON [dbo].[fn_diagramobjects] TO [guest]
DENY EXECUTE ON [dbo].[sp_alterdiagram] TO [guest]
DENY EXECUTE ON [dbo].[sp_creatediagram] TO [guest]
DENY EXECUTE ON [dbo].[sp_dropdiagram] TO [guest]
DENY EXECUTE ON [dbo].[sp_helpdiagramdefinition] TO [guest]
DENY EXECUTE ON [dbo].[sp_helpdiagrams] TO [guest]
DENY EXECUTE ON [dbo].[sp_renamediagram] TO [guest]
GRANT EXECUTE ON [dbo].[fn_diagramobjects] TO [public]
GRANT EXECUTE ON [dbo].[sp_alterdiagram] TO [public]
GRANT EXECUTE ON [dbo].[sp_creatediagram] TO [public]
GRANT EXECUTE ON [dbo].[sp_dropdiagram] TO [public]
GRANT EXECUTE ON [dbo].[sp_helpdiagramdefinition] TO [public]
GRANT EXECUTE ON [dbo].[sp_helpdiagrams] TO [public]
GRANT EXECUTE ON [dbo].[sp_renamediagram] TO [public]
-- [-- TYPE LEVEL PERMISSIONS --] --
 
-- [--DB LEVEL PERMISSIONS --] --
GRANT CONNECT TO [danan]
GRANT CONNECT TO [DS_ETL]
GRANT CONNECT TO [HYWD\_MarketingAnalyticsS]
GRANT CONNECT TO [HYWD\_metrics]
GRANT CONNECT TO [HYWD\_simsmobilesvc]
GRANT CONNECT TO [HYWD\_SQL_Monitor]
GRANT CONNECT TO [HYWD\aaApi_App]
GRANT CONNECT TO [HYWD\aaApiSQL]
GRANT CONNECT TO [HYWD\AgentsAlly_App]
GRANT CONNECT TO [HYWD\Application Support Group]
GRANT CONNECT TO [HYWD\bayleem]
GRANT CONNECT TO [HYWD\brandonw]
GRANT CONNECT TO [HYWD\danan]
GRANT CONNECT TO [HYWD\dashboard_app]
GRANT CONNECT TO [HYWD\djj]
GRANT CONNECT TO [HYWD\garyg]
GRANT CONNECT TO [HYWD\henryp]
GRANT CONNECT TO [HYWD\HYWD_PHBSQL01_RW]
GRANT CONNECT TO [HYWD\iarinam]
GRANT CONNECT TO [HYWD\Jareds]
GRANT CONNECT TO [HYWD\JeremyW]
GRANT CONNECT TO [HYWD\leadAlerts_App]
GRANT CONNECT TO [HYWD\michaelo]
GRANT CONNECT TO [HYWD\neilh]
GRANT CONNECT TO [HYWD\patrickf]
GRANT CONNECT TO [HYWD\PROD_BU_SQLAccess_RWE]
GRANT CONNECT TO [HYWD\russp]
GRANT CONNECT TO [HYWD\seand]
GRANT CONNECT TO [HYWD\SimsDBWorker]
GRANT CONNECT TO [HYWD\SQLAccessFSG]
GRANT CONNECT TO [HYWD\TomCat_App]
GRANT CONNECT TO [HYWD\VictorR]
GRANT CONNECT TO [HYWD\zgridworker]
GRANT CONNECT TO [HYWD\HYWD_PHB_Cluj_Devs]
GRANT CONNECT TO [tomcat]
GRANT UPDATE TO [HYWD\djj]
 
-- [--DB LEVEL SCHEMA PERMISSIONS --] --
', 
		@database_name=N'aaData_CA', 
		@flags=0
IF (@@ERROR <> 0 OR @ReturnCode <> 0) GOTO QuitWithRollback
/****** Object:  Step [Customers]    Script Date: 3/2/2018 10:34:56 AM ******/
EXEC @ReturnCode = msdb.dbo.sp_add_jobstep @job_id=@jobId, @step_name=N'Customers', 
		@step_id=3, 
		@cmdexec_success_code=0, 
		@on_success_action=3, 
		@on_success_step_id=0, 
		@on_fail_action=2, 
		@on_fail_step_id=0, 
		@retry_attempts=0, 
		@retry_interval=0, 
		@os_run_priority=0, @subsystem=N'TSQL', 
		@command=N'Declare @FileName varChar(255)
Declare @cmdText varChar(255)
Declare @BKFolder varchar(255)
DECLARE @cmd NVARCHAR(500) 

set @FileName = null
set @cmdText = null
set @BKFolder = ''\\VHYDPM01.hywd.ipzo.net\SQLBackups\CHYSQL1CL$SimsSqlHA3\Customers\FULL\''


create table #FileList (
FileName varchar(255),
DepthFlag int,
FileFlag int
)


--get all the files and folders in the backup folder and put them in temporary table
insert into #FileList exec xp_dirtree @BKFolder,0,1
--select * from #filelist

--get the latest backup file name
select top 1 @FileName = @BKFolder + FileName from #FileList where Filename like ''%.bak'' order by filename desc
--select @filename


--kick off current users/processes
ALTER DATABASE Customers
SET SINGLE_USER WITH ROLLBACK IMMEDIATE;


--execute the restore
EXEC (''RESTORE DATABASE [Customers] FROM  DISK = '''''' + @filename + '''''' WITH REPLACE'')
--SET @cmd = (''RESTORE DATABASE [Test] FROM  DISK = '''''' + @filename + '''''' WITH REPLACE'')
--EXEC @CMD

--Let people/processes back in!
ALTER DATABASE Customers
SET MULTI_USER WITH ROLLBACK IMMEDIATE;
--PRINT @cmd
DROP TABLE #FileList
go', 
		@database_name=N'master', 
		@flags=0
IF (@@ERROR <> 0 OR @ReturnCode <> 0) GOTO QuitWithRollback
/****** Object:  Step [Customers_security]    Script Date: 3/2/2018 10:34:56 AM ******/
EXEC @ReturnCode = msdb.dbo.sp_add_jobstep @job_id=@jobId, @step_name=N'Customers_security', 
		@step_id=4, 
		@cmdexec_success_code=0, 
		@on_success_action=1, 
		@on_success_step_id=0, 
		@on_fail_action=2, 
		@on_fail_step_id=0, 
		@retry_attempts=0, 
		@retry_interval=0, 
		@os_run_priority=0, @subsystem=N'TSQL', 
		@command=N'-- [-- DB USERS --] --
 CREATE ROLE db_executor

-- Grant execute rights to the new role
GRANT EXECUTE TO db_executor
IF NOT EXISTS (SELECT [name] FROM sys.database_principals WHERE [name] =  ''dbo'') BEGIN CREATE USER  [dbo] FOR LOGIN [sa] WITH DEFAULT_SCHEMA = [dbo] END; 
IF NOT EXISTS (SELECT [name] FROM sys.database_principals WHERE [name] =  ''DS_ETL'') BEGIN CREATE USER  [DS_ETL] FOR LOGIN [DS_ETL] WITH DEFAULT_SCHEMA = [dbo] END; 
IF NOT EXISTS (SELECT [name] FROM sys.database_principals WHERE [name] =  ''guest'') BEGIN CREATE USER  [guest] WITHOUT LOGIN WITH DEFAULT_SCHEMA = [guest] END;
IF NOT EXISTS (SELECT [name] FROM sys.database_principals WHERE [name] =  ''HYWD\_MarketingAnalyticsS'') BEGIN CREATE USER  [HYWD\_MarketingAnalyticsS] FOR LOGIN [HYWD\_MarketingAnalyticsS] WITH DEFAULT_SCHEMA = [dbo] END; 
IF NOT EXISTS (SELECT [name] FROM sys.database_principals WHERE [name] =  ''HYWD\_metrics'') BEGIN CREATE USER  [HYWD\_metrics] FOR LOGIN [HYWD\_metrics] WITH DEFAULT_SCHEMA = [dbo] END; 
IF NOT EXISTS (SELECT [name] FROM sys.database_principals WHERE [name] =  ''HYWD\_simsmobilesvc'') BEGIN CREATE USER  [HYWD\_simsmobilesvc] FOR LOGIN [HYWD\_simsmobilesvc] WITH DEFAULT_SCHEMA = [dbo] END; 
IF NOT EXISTS (SELECT [name] FROM sys.database_principals WHERE [name] =  ''HYWD\_SQL_Monitor'') BEGIN CREATE USER  [HYWD\_SQL_Monitor] FOR LOGIN [HYWD\_SQL_Monitor] WITH DEFAULT_SCHEMA = [dbo] END; 
IF NOT EXISTS (SELECT [name] FROM sys.database_principals WHERE [name] =  ''HYWD\aaApi_App'') BEGIN CREATE USER  [HYWD\aaApi_App] FOR LOGIN [HYWD\aaApi_App] WITH DEFAULT_SCHEMA = [dbo] END; 
IF NOT EXISTS (SELECT [name] FROM sys.database_principals WHERE [name] =  ''HYWD\aaApiSQL'') BEGIN CREATE USER  [HYWD\aaApiSQL] FOR LOGIN [HYWD\aaApiSQL] WITH DEFAULT_SCHEMA = [HYWD\aaApiSQL] END; 
IF NOT EXISTS (SELECT [name] FROM sys.database_principals WHERE [name] =  ''HYWD\AgentsAlly_App'') BEGIN CREATE USER  [HYWD\AgentsAlly_App] FOR LOGIN [HYWD\AgentsAlly_App] WITH DEFAULT_SCHEMA = [dbo] END; 
IF NOT EXISTS (SELECT [name] FROM sys.database_principals WHERE [name] =  ''HYWD\Application Support Group'') BEGIN CREATE USER  [HYWD\Application Support Group] FOR LOGIN [HYWD\Application Support Group] WITH DEFAULT_SCHEMA = [dbo] END; 
IF NOT EXISTS (SELECT [name] FROM sys.database_principals WHERE [name] =  ''HYWD\bayleem'') BEGIN CREATE USER  [HYWD\bayleem] FOR LOGIN [HYWD\bayleek] WITH DEFAULT_SCHEMA = [dbo] END; 
IF NOT EXISTS (SELECT [name] FROM sys.database_principals WHERE [name] =  ''HYWD\brandonw'') BEGIN CREATE USER  [HYWD\brandonw] FOR LOGIN [HYWD\brandonw] WITH DEFAULT_SCHEMA = [dbo] END; 
IF NOT EXISTS (SELECT [name] FROM sys.database_principals WHERE [name] =  ''HYWD\dashboard_app'') BEGIN CREATE USER  [HYWD\dashboard_app] FOR LOGIN [HYWD\dashboard_app] WITH DEFAULT_SCHEMA = [dbo] END; 
IF NOT EXISTS (SELECT [name] FROM sys.database_principals WHERE [name] =  ''HYWD\djj'') BEGIN CREATE USER  [HYWD\djj] FOR LOGIN [HYWD\djj] WITH DEFAULT_SCHEMA = [dbo] END; 
IF NOT EXISTS (SELECT [name] FROM sys.database_principals WHERE [name] =  ''HYWD\eng.ray'') BEGIN CREATE USER  [HYWD\eng.ray] FOR LOGIN [HYWD\eng.ray] WITH DEFAULT_SCHEMA = [dbo] END; 
IF NOT EXISTS (SELECT [name] FROM sys.database_principals WHERE [name] =  ''HYWD\garyg'') BEGIN CREATE USER  [HYWD\garyg] FOR LOGIN [HYWD\garyg] WITH DEFAULT_SCHEMA = [dbo] END; 
IF NOT EXISTS (SELECT [name] FROM sys.database_principals WHERE [name] =  ''HYWD\henryp'') BEGIN CREATE USER  [HYWD\henryp] FOR LOGIN [HYWD\henryp] WITH DEFAULT_SCHEMA = [dbo] END; 
IF NOT EXISTS (SELECT [name] FROM sys.database_principals WHERE [name] =  ''HYWD\HYWD_DEVOPS_SQL'') BEGIN CREATE USER  [HYWD\HYWD_DEVOPS_SQL] FOR LOGIN [HYWD\HYWD_DEVOPS_SQL] WITH DEFAULT_SCHEMA = [dbo] END; 
IF NOT EXISTS (SELECT [name] FROM sys.database_principals WHERE [name] =  ''HYWD\HYWD_DEVOPS_SQLTEST'') BEGIN CREATE USER  [HYWD\HYWD_DEVOPS_SQLTEST] FOR LOGIN [HYWD\HYWD_DEVOPS_SQLTEST] WITH DEFAULT_SCHEMA = [HYWD\HYWD_DEVOPS_SQLTEST] END; 
IF NOT EXISTS (SELECT [name] FROM sys.database_principals WHERE [name] =  ''HYWD\HYWD_PHBSQL01_RW'') BEGIN CREATE USER  [HYWD\HYWD_PHBSQL01_RW] FOR LOGIN [HYWD\HYWD_PHBSQL01_RW] WITH DEFAULT_SCHEMA = [dbo] END; 
IF NOT EXISTS (SELECT [name] FROM sys.database_principals WHERE [name] =  ''HYWD\iarinam'') BEGIN CREATE USER  [HYWD\iarinam] FOR LOGIN [HYWD\iarinam] WITH DEFAULT_SCHEMA = [dbo] END; 
IF NOT EXISTS (SELECT [name] FROM sys.database_principals WHERE [name] =  ''HYWD\Jareds'') BEGIN CREATE USER  [HYWD\Jareds] FOR LOGIN [HYWD\Jareds] WITH DEFAULT_SCHEMA = [dbo] END; 
IF NOT EXISTS (SELECT [name] FROM sys.database_principals WHERE [name] =  ''HYWD\JeremyW'') BEGIN CREATE USER  [HYWD\JeremyW] FOR LOGIN [HYWD\JeremyW] WITH DEFAULT_SCHEMA = [dbo] END; 
IF NOT EXISTS (SELECT [name] FROM sys.database_principals WHERE [name] =  ''HYWD\leadAlerts_App'') BEGIN CREATE USER  [HYWD\leadAlerts_App] FOR LOGIN [HYWD\leadAlerts_App] WITH DEFAULT_SCHEMA = [dbo] END; 
IF NOT EXISTS (SELECT [name] FROM sys.database_principals WHERE [name] =  ''HYWD\michaelo'') BEGIN CREATE USER  [HYWD\michaelo] FOR LOGIN [HYWD\michaelo] WITH DEFAULT_SCHEMA = [dbo] END; 
IF NOT EXISTS (SELECT [name] FROM sys.database_principals WHERE [name] =  ''HYWD\Neilh'') BEGIN CREATE USER  [HYWD\Neilh] FOR LOGIN [HYWD\neilh] WITH DEFAULT_SCHEMA = [dbo] END; 
IF NOT EXISTS (SELECT [name] FROM sys.database_principals WHERE [name] =  ''HYWD\patrickf'') BEGIN CREATE USER  [HYWD\patrickf] FOR LOGIN [HYWD\patrickf] WITH DEFAULT_SCHEMA = [dbo] END; 
IF NOT EXISTS (SELECT [name] FROM sys.database_principals WHERE [name] =  ''HYWD\PROD_BU_SQLAccess_RWE'') BEGIN CREATE USER  [HYWD\PROD_BU_SQLAccess_RWE] FOR LOGIN [HYWD\PROD_BU_SQLAccess_RWE] WITH DEFAULT_SCHEMA = [dbo] END; 
IF NOT EXISTS (SELECT [name] FROM sys.database_principals WHERE [name] =  ''HYWD\russp'') BEGIN CREATE USER  [HYWD\russp] FOR LOGIN [HYWD\russp] WITH DEFAULT_SCHEMA = [dbo] END; 
IF NOT EXISTS (SELECT [name] FROM sys.database_principals WHERE [name] =  ''HYWD\seand'') BEGIN CREATE USER  [HYWD\seand] FOR LOGIN [HYWD\seand] WITH DEFAULT_SCHEMA = [dbo] END; 
IF NOT EXISTS (SELECT [name] FROM sys.database_principals WHERE [name] =  ''HYWD\SimsDBWorker'') BEGIN CREATE USER  [HYWD\SimsDBWorker] FOR LOGIN [HYWD\SimsDBWorker] WITH DEFAULT_SCHEMA = [dbo] END; 
IF NOT EXISTS (SELECT [name] FROM sys.database_principals WHERE [name] =  ''HYWD\simsSql_Service'') BEGIN CREATE USER  [HYWD\simsSql_Service] FOR LOGIN [HYWD\simsSql_Service] WITH DEFAULT_SCHEMA = [dbo] END; 
IF NOT EXISTS (SELECT [name] FROM sys.database_principals WHERE [name] =  ''HYWD\SQLAccessFSG'') BEGIN CREATE USER  [HYWD\SQLAccessFSG] FOR LOGIN [HYWD\SQLAccessFSG] WITH DEFAULT_SCHEMA = [dbo] END; 
IF NOT EXISTS (SELECT [name] FROM sys.database_principals WHERE [name] =  ''HYWD\TomCat_App'') BEGIN CREATE USER  [HYWD\TomCat_App] FOR LOGIN [HYWD\TomCat_App] WITH DEFAULT_SCHEMA = [dbo] END; 
IF NOT EXISTS (SELECT [name] FROM sys.database_principals WHERE [name] =  ''HYWD\VictorR'') BEGIN CREATE USER  [HYWD\VictorR] FOR LOGIN [HYWD\VictorR] WITH DEFAULT_SCHEMA = [dbo] END; 
IF NOT EXISTS (SELECT [name] FROM sys.database_principals WHERE [name] =  ''HYWD\zgridworker'') BEGIN CREATE USER  [HYWD\zgridworker] FOR LOGIN [HYWD\zGridWorker] WITH DEFAULT_SCHEMA = [dbo] END; 
IF NOT EXISTS (SELECT [name] FROM sys.database_principals WHERE [name] =  ''HYWD\zgridworker'') BEGIN CREATE USER  [HYWD\HYWD_PHB_Cluj_Devs] FOR LOGIN [HYWD\HYWD_PHB_Cluj_Devs] WITH DEFAULT_SCHEMA = [dbo] END; 

-- [-- DB ROLES --] --
EXEC sp_addrolemember @rolename = ''db_datareader'', @membername = ''DS_ETL''
EXEC sp_addrolemember @rolename = ''db_datareader'', @membername = ''HYWD\_MarketingAnalyticsS''
EXEC sp_addrolemember @rolename = ''db_datareader'', @membername = ''HYWD\_metrics''
EXEC sp_addrolemember @rolename = ''db_datareader'', @membername = ''HYWD\aaApi_App''
EXEC sp_addrolemember @rolename = ''db_datareader'', @membername = ''HYWD\Application Support Group''
EXEC sp_addrolemember @rolename = ''db_datareader'', @membername = ''HYWD\bayleem''
EXEC sp_addrolemember @rolename = ''db_datareader'', @membername = ''HYWD\brandonw''
EXEC sp_addrolemember @rolename = ''db_datareader'', @membername = ''HYWD\dashboard_app''
EXEC sp_addrolemember @rolename = ''db_datareader'', @membername = ''HYWD\garyg''
EXEC sp_addrolemember @rolename = ''db_datareader'', @membername = ''HYWD\henryp''
EXEC sp_addrolemember @rolename = ''db_datareader'', @membername = ''HYWD\HYWD_DEVOPS_SQL''
EXEC sp_addrolemember @rolename = ''db_datareader'', @membername = ''HYWD\HYWD_PHBSQL01_RW''
EXEC sp_addrolemember @rolename = ''db_datareader'', @membername = ''HYWD\JeremyW''
EXEC sp_addrolemember @rolename = ''db_datareader'', @membername = ''HYWD\michaelo''
EXEC sp_addrolemember @rolename = ''db_datareader'', @membername = ''HYWD\Neilh''
EXEC sp_addrolemember @rolename = ''db_datareader'', @membername = ''HYWD\patrickf''
EXEC sp_addrolemember @rolename = ''db_datareader'', @membername = ''HYWD\PROD_BU_SQLAccess_RWE''
EXEC sp_addrolemember @rolename = ''db_datareader'', @membername = ''HYWD\russp''
EXEC sp_addrolemember @rolename = ''db_datareader'', @membername = ''HYWD\VictorR''
EXEC sp_addrolemember @rolename = ''db_datareader'', @membername = ''johnd''
EXEC sp_addrolemember @rolename = ''db_datareader'', @membername = ''michaelo''
EXEC sp_addrolemember @rolename = ''db_datareader'', @membername = ''HYWD\HYWD_PHB_Cluj_Devs''
EXEC sp_addrolemember @rolename = ''db_datawriter'', @membername = ''HYWD\garyg''
EXEC sp_addrolemember @rolename = ''db_datawriter'', @membername = ''HYWD\HYWD_DEVOPS_SQL''
EXEC sp_addrolemember @rolename = ''db_datawriter'', @membername = ''HYWD\HYWD_PHBSQL01_RW''
EXEC sp_addrolemember @rolename = ''db_datawriter'', @membername = ''HYWD\michaelo''
EXEC sp_addrolemember @rolename = ''db_datawriter'', @membername = ''HYWD\Neilh''
EXEC sp_addrolemember @rolename = ''db_datawriter'', @membername = ''HYWD\patrickf''
EXEC sp_addrolemember @rolename = ''db_datawriter'', @membername = ''HYWD\PROD_BU_SQLAccess_RWE''
EXEC sp_addrolemember @rolename = ''db_datawriter'', @membername = ''HYWD\HYWD_PHB_Cluj_Devs''
EXEC sp_addrolemember @rolename = ''db_ddladmin'', @membername = ''HYWD\_SQL_Monitor''
EXEC sp_addrolemember @rolename = ''db_ddladmin'', @membername = ''HYWD\HYWD_DEVOPS_SQL''
EXEC sp_addrolemember @rolename = ''db_ddladmin'', @membername = ''HYWD\HYWD_PHB_Cluj_Devs''
EXEC sp_addrolemember @rolename = ''db_executor'', @membername = ''HYWD\PROD_BU_SQLAccess_RWE''
EXEC sp_addrolemember @rolename = ''db_executor'', @membername = ''HYWD\HYWD_PHB_Cluj_Devs''
EXEC sp_addrolemember @rolename = ''db_owner'', @membername = ''HYWD\_simsmobilesvc''
EXEC sp_addrolemember @rolename = ''db_owner'', @membername = ''HYWD\aaApi_App''
EXEC sp_addrolemember @rolename = ''db_owner'', @membername = ''HYWD\aaApiSQL''
EXEC sp_addrolemember @rolename = ''db_owner'', @membername = ''HYWD\AgentsAlly_App''
EXEC sp_addrolemember @rolename = ''db_owner'', @membername = ''HYWD\danan''
EXEC sp_addrolemember @rolename = ''db_owner'', @membername = ''HYWD\eng.ray''
EXEC sp_addrolemember @rolename = ''db_owner'', @membername = ''HYWD\henryp''
EXEC sp_addrolemember @rolename = ''db_owner'', @membername = ''HYWD\HYWD_DEVOPS_SQLTEST''
EXEC sp_addrolemember @rolename = ''db_owner'', @membername = ''HYWD\iarinam''
EXEC sp_addrolemember @rolename = ''db_owner'', @membername = ''HYWD\Jareds''
EXEC sp_addrolemember @rolename = ''db_owner'', @membername = ''HYWD\leadAlerts_App''
EXEC sp_addrolemember @rolename = ''db_owner'', @membername = ''HYWD\patrickf''
EXEC sp_addrolemember @rolename = ''db_owner'', @membername = ''HYWD\seand''
EXEC sp_addrolemember @rolename = ''db_owner'', @membername = ''HYWD\SimsDBWorker''
EXEC sp_addrolemember @rolename = ''db_owner'', @membername = ''HYWD\simsSql_Service''
EXEC sp_addrolemember @rolename = ''db_owner'', @membername = ''HYWD\SQLAccessFSG''
EXEC sp_addrolemember @rolename = ''db_owner'', @membername = ''HYWD\TomCat_App''
EXEC sp_addrolemember @rolename = ''db_owner'', @membername = ''HYWD\zgridworker''
 -- [--DB LEVEL PERMISSIONS --] --
GRANT CONNECT TO [DS_ETL]
GRANT CONNECT TO [HYWD\_MarketingAnalyticsS]
GRANT CONNECT TO [HYWD\_metrics]
GRANT CONNECT TO [HYWD\_simsmobilesvc]
GRANT CONNECT TO [HYWD\_SQL_Monitor]
GRANT CONNECT TO [HYWD\aaApi_App]
GRANT CONNECT TO [HYWD\aaApiSQL]
GRANT CONNECT TO [HYWD\AgentsAlly_App]
GRANT CONNECT TO [HYWD\Application Support Group]
GRANT CONNECT TO [HYWD\bayleem]
GRANT CONNECT TO [HYWD\brandonw]
GRANT CONNECT TO [HYWD\danan]
GRANT CONNECT TO [HYWD\dashboard_app]
GRANT CONNECT TO [HYWD\djj]
GRANT CONNECT TO [HYWD\eng.ray]
GRANT CONNECT TO [HYWD\garyg]
GRANT CONNECT TO [HYWD\henryp]
GRANT CONNECT TO [HYWD\HYWD_DEVOPS_SQL]
GRANT CONNECT TO [HYWD\HYWD_DEVOPS_SQLTEST]
GRANT CONNECT TO [HYWD\HYWD_PHBSQL01_RW]
GRANT CONNECT TO [HYWD\iarinam]
GRANT CONNECT TO [HYWD\Jareds]
GRANT CONNECT TO [HYWD\JeremyW]
GRANT CONNECT TO [HYWD\leadAlerts_App]
GRANT CONNECT TO [HYWD\michaelo]
GRANT CONNECT TO [HYWD\Neilh]
GRANT CONNECT TO [HYWD\patrickf]
GRANT CONNECT TO [HYWD\PROD_BU_SQLAccess_RWE]
GRANT CONNECT TO [HYWD\russp]
GRANT CONNECT TO [HYWD\seand]
GRANT CONNECT TO [HYWD\SimsDBWorker]
GRANT CONNECT TO [HYWD\simsSql_Service]
GRANT CONNECT TO [HYWD\HYWD_PHB_Cluj_Devs]', 
		@database_name=N'Customers', 
		@flags=0
IF (@@ERROR <> 0 OR @ReturnCode <> 0) GOTO QuitWithRollback
EXEC @ReturnCode = msdb.dbo.sp_update_job @job_id = @jobId, @start_step_id = 1
IF (@@ERROR <> 0 OR @ReturnCode <> 0) GOTO QuitWithRollback
EXEC @ReturnCode = msdb.dbo.sp_add_jobschedule @job_id=@jobId, @name=N'Weekly', 
		@enabled=1, 
		@freq_type=8, 
		@freq_interval=64, 
		@freq_subday_type=1, 
		@freq_subday_interval=0, 
		@freq_relative_interval=0, 
		@freq_recurrence_factor=1, 
		@active_start_date=20171013, 
		@active_end_date=99991231, 
		@active_start_time=10000, 
		@active_end_time=235959, 
		@schedule_uid=N'387a6c5b-2daa-45aa-b4c6-a265ce06c0c9'
IF (@@ERROR <> 0 OR @ReturnCode <> 0) GOTO QuitWithRollback
EXEC @ReturnCode = msdb.dbo.sp_add_jobserver @job_id = @jobId, @server_name = N'(local)'
IF (@@ERROR <> 0 OR @ReturnCode <> 0) GOTO QuitWithRollback
COMMIT TRANSACTION
GOTO EndSave
QuitWithRollback:
    IF (@@TRANCOUNT > 0) ROLLBACK TRANSACTION
EndSave:

GO


