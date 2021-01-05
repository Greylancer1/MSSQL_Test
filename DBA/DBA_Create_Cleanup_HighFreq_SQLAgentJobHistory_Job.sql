USE [msdb]
GO

/****** Object:  Job [DBA Purge High Frequency jobs history]    Script Date: 9/15/2017 11:18:39 AM ******/
BEGIN TRANSACTION
DECLARE @ReturnCode INT
SELECT @ReturnCode = 0
/****** Object:  JobCategory [[Uncategorized (Local)]]    Script Date: 9/15/2017 11:18:39 AM ******/
IF NOT EXISTS (SELECT name FROM msdb.dbo.syscategories WHERE name=N'[Uncategorized (Local)]' AND category_class=1)
BEGIN
EXEC @ReturnCode = msdb.dbo.sp_add_category @class=N'JOB', @type=N'LOCAL', @name=N'[Uncategorized (Local)]'
IF (@@ERROR <> 0 OR @ReturnCode <> 0) GOTO QuitWithRollback

END

DECLARE @jobId BINARY(16)
EXEC @ReturnCode =  msdb.dbo.sp_add_job @job_name=N'DBA Purge High Frequency jobs history', 
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
/****** Object:  Step [Monitor SQL Stuff - Every 5 minutes]    Script Date: 9/15/2017 11:18:39 AM ******/
EXEC @ReturnCode = msdb.dbo.sp_add_jobstep @job_id=@jobId, @step_name=N'Monitor SQL Stuff - Every 5 minutes', 
		@step_id=1, 
		@cmdexec_success_code=0, 
		@on_success_action=3, 
		@on_success_step_id=0, 
		@on_fail_action=3, 
		@on_fail_step_id=0, 
		@retry_attempts=0, 
		@retry_interval=0, 
		@os_run_priority=0, @subsystem=N'TSQL', 
		@command=N'EXEC dbo.sp_purge_jobhistory  
    @job_name = N''Monitor SQL Stuff - Every 5 minutes''', 
		@database_name=N'msdb', 
		@flags=0
IF (@@ERROR <> 0 OR @ReturnCode <> 0) GOTO QuitWithRollback
/****** Object:  Step [MonitorContactsPostForSaveErrors]    Script Date: 9/15/2017 11:18:39 AM ******/
EXEC @ReturnCode = msdb.dbo.sp_add_jobstep @job_id=@jobId, @step_name=N'MonitorContactsPostForSaveErrors', 
		@step_id=2, 
		@cmdexec_success_code=0, 
		@on_success_action=3, 
		@on_success_step_id=0, 
		@on_fail_action=3, 
		@on_fail_step_id=0, 
		@retry_attempts=0, 
		@retry_interval=0, 
		@os_run_priority=0, @subsystem=N'TSQL', 
		@command=N'EXEC dbo.sp_purge_jobhistory  
    @job_name = N''MonitorContactsPostForSaveErrors''', 
		@database_name=N'msdb', 
		@flags=0
IF (@@ERROR <> 0 OR @ReturnCode <> 0) GOTO QuitWithRollback
/****** Object:  Step [Monitor Processing Queues]    Script Date: 9/15/2017 11:18:39 AM ******/
EXEC @ReturnCode = msdb.dbo.sp_add_jobstep @job_id=@jobId, @step_name=N'Monitor Processing Queues', 
		@step_id=3, 
		@cmdexec_success_code=0, 
		@on_success_action=3, 
		@on_success_step_id=0, 
		@on_fail_action=3, 
		@on_fail_step_id=0, 
		@retry_attempts=0, 
		@retry_interval=0, 
		@os_run_priority=0, @subsystem=N'TSQL', 
		@command=N'EXEC dbo.sp_purge_jobhistory  
    @job_name = N''Monitor Processing Queues''', 
		@database_name=N'msdb', 
		@flags=0
IF (@@ERROR <> 0 OR @ReturnCode <> 0) GOTO QuitWithRollback
/****** Object:  Step [Lead Data Append]    Script Date: 9/15/2017 11:18:39 AM ******/
EXEC @ReturnCode = msdb.dbo.sp_add_jobstep @job_id=@jobId, @step_name=N'Lead Data Append', 
		@step_id=4, 
		@cmdexec_success_code=0, 
		@on_success_action=3, 
		@on_success_step_id=0, 
		@on_fail_action=3, 
		@on_fail_step_id=0, 
		@retry_attempts=0, 
		@retry_interval=0, 
		@os_run_priority=0, @subsystem=N'TSQL', 
		@command=N'EXEC dbo.sp_purge_jobhistory  
    @job_name = N''Lead Data Append''', 
		@database_name=N'msdb', 
		@flags=0
IF (@@ERROR <> 0 OR @ReturnCode <> 0) GOTO QuitWithRollback
/****** Object:  Step [PossibleNow_Scrub]    Script Date: 9/15/2017 11:18:39 AM ******/
EXEC @ReturnCode = msdb.dbo.sp_add_jobstep @job_id=@jobId, @step_name=N'PossibleNow_Scrub', 
		@step_id=5, 
		@cmdexec_success_code=0, 
		@on_success_action=3, 
		@on_success_step_id=0, 
		@on_fail_action=3, 
		@on_fail_step_id=0, 
		@retry_attempts=0, 
		@retry_interval=0, 
		@os_run_priority=0, @subsystem=N'TSQL', 
		@command=N'EXEC dbo.sp_purge_jobhistory  
    @job_name = N''PossibleNow_Scrub''', 
		@database_name=N'msdb', 
		@flags=0
IF (@@ERROR <> 0 OR @ReturnCode <> 0) GOTO QuitWithRollback
/****** Object:  Step [SubContacts DNC with Change Tracking]    Script Date: 9/15/2017 11:18:39 AM ******/
EXEC @ReturnCode = msdb.dbo.sp_add_jobstep @job_id=@jobId, @step_name=N'SubContacts DNC with Change Tracking', 
		@step_id=6, 
		@cmdexec_success_code=0, 
		@on_success_action=3, 
		@on_success_step_id=0, 
		@on_fail_action=3, 
		@on_fail_step_id=0, 
		@retry_attempts=0, 
		@retry_interval=0, 
		@os_run_priority=0, @subsystem=N'TSQL', 
		@command=N'EXEC dbo.sp_purge_jobhistory  
    @job_name = N''SubContacts DNC with Change Tracking''', 
		@database_name=N'msdb', 
		@flags=0
IF (@@ERROR <> 0 OR @ReturnCode <> 0) GOTO QuitWithRollback
/****** Object:  Step [ProspectPush]    Script Date: 9/15/2017 11:18:39 AM ******/
EXEC @ReturnCode = msdb.dbo.sp_add_jobstep @job_id=@jobId, @step_name=N'ProspectPush', 
		@step_id=7, 
		@cmdexec_success_code=0, 
		@on_success_action=3, 
		@on_success_step_id=0, 
		@on_fail_action=3, 
		@on_fail_step_id=0, 
		@retry_attempts=0, 
		@retry_interval=0, 
		@os_run_priority=0, @subsystem=N'TSQL', 
		@command=N'EXEC dbo.sp_purge_jobhistory  
    @job_name = N''ProspectPush''', 
		@database_name=N'msdb', 
		@flags=0
IF (@@ERROR <> 0 OR @ReturnCode <> 0) GOTO QuitWithRollback
/****** Object:  Step [LeadPush]    Script Date: 9/15/2017 11:18:39 AM ******/
EXEC @ReturnCode = msdb.dbo.sp_add_jobstep @job_id=@jobId, @step_name=N'LeadPush', 
		@step_id=8, 
		@cmdexec_success_code=0, 
		@on_success_action=3, 
		@on_success_step_id=0, 
		@on_fail_action=3, 
		@on_fail_step_id=0, 
		@retry_attempts=0, 
		@retry_interval=0, 
		@os_run_priority=0, @subsystem=N'TSQL', 
		@command=N'EXEC dbo.sp_purge_jobhistory  
    @job_name = N''LeadPush''', 
		@database_name=N'msdb', 
		@flags=0
IF (@@ERROR <> 0 OR @ReturnCode <> 0) GOTO QuitWithRollback
/****** Object:  Step [Leads DNC with Change Tracking]    Script Date: 9/15/2017 11:18:39 AM ******/
EXEC @ReturnCode = msdb.dbo.sp_add_jobstep @job_id=@jobId, @step_name=N'Leads DNC with Change Tracking', 
		@step_id=9, 
		@cmdexec_success_code=0, 
		@on_success_action=3, 
		@on_success_step_id=0, 
		@on_fail_action=3, 
		@on_fail_step_id=0, 
		@retry_attempts=0, 
		@retry_interval=0, 
		@os_run_priority=0, @subsystem=N'TSQL', 
		@command=N'EXEC dbo.sp_purge_jobhistory  
    @job_name = N''Leads DNC with Change Tracking''', 
		@database_name=N'msdb', 
		@flags=0
IF (@@ERROR <> 0 OR @ReturnCode <> 0) GOTO QuitWithRollback
/****** Object:  Step [Every7]    Script Date: 9/15/2017 11:18:39 AM ******/
EXEC @ReturnCode = msdb.dbo.sp_add_jobstep @job_id=@jobId, @step_name=N'Every7', 
		@step_id=10, 
		@cmdexec_success_code=0, 
		@on_success_action=3, 
		@on_success_step_id=0, 
		@on_fail_action=3, 
		@on_fail_step_id=0, 
		@retry_attempts=0, 
		@retry_interval=0, 
		@os_run_priority=0, @subsystem=N'TSQL', 
		@command=N'EXEC dbo.sp_purge_jobhistory  
    @job_name = N''Every7''', 
		@database_name=N'msdb', 
		@flags=0
IF (@@ERROR <> 0 OR @ReturnCode <> 0) GOTO QuitWithRollback
/****** Object:  Step [Prospect Data Append Polling]    Script Date: 9/15/2017 11:18:39 AM ******/
EXEC @ReturnCode = msdb.dbo.sp_add_jobstep @job_id=@jobId, @step_name=N'Prospect Data Append Polling', 
		@step_id=11, 
		@cmdexec_success_code=0, 
		@on_success_action=3, 
		@on_success_step_id=0, 
		@on_fail_action=3, 
		@on_fail_step_id=0, 
		@retry_attempts=0, 
		@retry_interval=0, 
		@os_run_priority=0, @subsystem=N'TSQL', 
		@command=N'EXEC dbo.sp_purge_jobhistory  
    @job_name = N''Prospect Data Append Polling''', 
		@database_name=N'msdb', 
		@flags=0
IF (@@ERROR <> 0 OR @ReturnCode <> 0) GOTO QuitWithRollback
/****** Object:  Step [Contacts DNC with Change Tracking]    Script Date: 9/15/2017 11:18:39 AM ******/
EXEC @ReturnCode = msdb.dbo.sp_add_jobstep @job_id=@jobId, @step_name=N'Contacts DNC with Change Tracking', 
		@step_id=12, 
		@cmdexec_success_code=0, 
		@on_success_action=1, 
		@on_success_step_id=0, 
		@on_fail_action=2, 
		@on_fail_step_id=0, 
		@retry_attempts=0, 
		@retry_interval=0, 
		@os_run_priority=0, @subsystem=N'TSQL', 
		@command=N'EXEC dbo.sp_purge_jobhistory  
    @job_name = N''Contacts DNC with Change Tracking''', 
		@database_name=N'msdb', 
		@flags=0
IF (@@ERROR <> 0 OR @ReturnCode <> 0) GOTO QuitWithRollback
EXEC @ReturnCode = msdb.dbo.sp_update_job @job_id = @jobId, @start_step_id = 1
IF (@@ERROR <> 0 OR @ReturnCode <> 0) GOTO QuitWithRollback
EXEC @ReturnCode = msdb.dbo.sp_add_jobschedule @job_id=@jobId, @name=N'Every 2 Hours', 
		@enabled=1, 
		@freq_type=4, 
		@freq_interval=1, 
		@freq_subday_type=8, 
		@freq_subday_interval=2, 
		@freq_relative_interval=0, 
		@freq_recurrence_factor=0, 
		@active_start_date=20161004, 
		@active_end_date=99991231, 
		@active_start_time=0, 
		@active_end_time=235959, 
		@schedule_uid=N'c9fbb975-e798-4e9e-87b0-3a31f9766689'
IF (@@ERROR <> 0 OR @ReturnCode <> 0) GOTO QuitWithRollback
EXEC @ReturnCode = msdb.dbo.sp_add_jobserver @job_id = @jobId, @server_name = N'(local)'
IF (@@ERROR <> 0 OR @ReturnCode <> 0) GOTO QuitWithRollback
COMMIT TRANSACTION
GOTO EndSave
QuitWithRollback:
    IF (@@TRANCOUNT > 0) ROLLBACK TRANSACTION
EndSave:

GO


