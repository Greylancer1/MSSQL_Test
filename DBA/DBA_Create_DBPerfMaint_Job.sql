USE [msdb]
GO

/****** Object:  Job [DBA DB Maintenance]    Script Date: 9/15/2017 11:20:38 AM ******/
BEGIN TRANSACTION
DECLARE @ReturnCode INT
SELECT @ReturnCode = 0
/****** Object:  JobCategory [[Uncategorized (Local)]]    Script Date: 9/15/2017 11:20:38 AM ******/
IF NOT EXISTS (SELECT name FROM msdb.dbo.syscategories WHERE name=N'[Uncategorized (Local)]' AND category_class=1)
BEGIN
EXEC @ReturnCode = msdb.dbo.sp_add_category @class=N'JOB', @type=N'LOCAL', @name=N'[Uncategorized (Local)]'
IF (@@ERROR <> 0 OR @ReturnCode <> 0) GOTO QuitWithRollback

END

DECLARE @jobId BINARY(16)
EXEC @ReturnCode =  msdb.dbo.sp_add_job @job_name=N'DBA DB Maintenance', 
		@enabled=1, 
		@notify_level_eventlog=0, 
		@notify_level_email=0, 
		@notify_level_netsend=0, 
		@notify_level_page=0, 
		@delete_level=0, 
		@description=N'No description available.', 
		@category_name=N'[Uncategorized (Local)]', 
		@owner_login_name=N'HYWD\dba.keith', @job_id = @jobId OUTPUT
IF (@@ERROR <> 0 OR @ReturnCode <> 0) GOTO QuitWithRollback
/****** Object:  Step [Index Maintenance]    Script Date: 9/15/2017 11:20:38 AM ******/
EXEC @ReturnCode = msdb.dbo.sp_add_jobstep @job_id=@jobId, @step_name=N'Index Maintenance', 
		@step_id=1, 
		@cmdexec_success_code=0, 
		@on_success_action=3, 
		@on_success_step_id=0, 
		@on_fail_action=2, 
		@on_fail_step_id=0, 
		@retry_attempts=0, 
		@retry_interval=0, 
		@os_run_priority=0, @subsystem=N'TSQL', 
		@command=N'IF ([sys].[fn_hadr_is_primary_replica] (''DBA'')) = 1
Exec dbo.dba_indexDefrag_sp
	@executeSQL	= 1
	, @printCommands	= 1
	, @debugMode	= 1
	, @printFragmentation	= 1
	, @forceRescan	 = 1
	, @maxDopRestriction	 = 2
	--, @minPageCount	= 500
	--, @maxPageCount	= 100000
	, @minFragmentation	= 10
	, @rebuildThreshold	= 30
	, @defragDelay	= ''00:00:05''
	, @defragOrderColumn	= ''page_count''
	, @defragSortOrder	= ''DESC''
	, @excludeMaxPartition	= 1
	, @onlineRebuild	= 1
	, @sortInTempDB	= 1;', 
		@database_name=N'DBA', 
		@flags=0
IF (@@ERROR <> 0 OR @ReturnCode <> 0) GOTO QuitWithRollback
/****** Object:  Step [Recalculate Stats]    Script Date: 9/15/2017 11:20:38 AM ******/
EXEC @ReturnCode = msdb.dbo.sp_add_jobstep @job_id=@jobId, @step_name=N'Recalculate Stats', 
		@step_id=2, 
		@cmdexec_success_code=0, 
		@on_success_action=1, 
		@on_success_step_id=0, 
		@on_fail_action=2, 
		@on_fail_step_id=0, 
		@retry_attempts=0, 
		@retry_interval=0, 
		@os_run_priority=0, @subsystem=N'TSQL', 
		@command=N'IF ([sys].[fn_hadr_is_primary_replica] (''DBA'')) = 1
exec sp_MSforeachdb ''use [?]; if db_name() not in (''''master'''', ''''model'''', ''''tempdb'''', ''''msdb'''') exec sp_updatestats;'';
go', 
		@database_name=N'master', 
		@flags=0
IF (@@ERROR <> 0 OR @ReturnCode <> 0) GOTO QuitWithRollback
EXEC @ReturnCode = msdb.dbo.sp_update_job @job_id = @jobId, @start_step_id = 1
IF (@@ERROR <> 0 OR @ReturnCode <> 0) GOTO QuitWithRollback
EXEC @ReturnCode = msdb.dbo.sp_add_jobschedule @job_id=@jobId, @name=N'Nightly', 
		@enabled=1, 
		@freq_type=4, 
		@freq_interval=1, 
		@freq_subday_type=1, 
		@freq_subday_interval=0, 
		@freq_relative_interval=0, 
		@freq_recurrence_factor=0, 
		@active_start_date=20161011, 
		@active_end_date=99991231, 
		@active_start_time=210000, 
		@active_end_time=235959, 
		@schedule_uid=N'eafd5b58-aa19-4d46-aed7-360fd1ed8212'
IF (@@ERROR <> 0 OR @ReturnCode <> 0) GOTO QuitWithRollback
EXEC @ReturnCode = msdb.dbo.sp_add_jobserver @job_id = @jobId, @server_name = N'(local)'
IF (@@ERROR <> 0 OR @ReturnCode <> 0) GOTO QuitWithRollback
COMMIT TRANSACTION
GOTO EndSave
QuitWithRollback:
    IF (@@TRANCOUNT > 0) ROLLBACK TRANSACTION
EndSave:

GO


