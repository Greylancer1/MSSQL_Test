-- Script generated on 11/15/2005 1:16 PM
-- By: CHOMP\KD9173
-- Server: (local)

BEGIN TRANSACTION            
  DECLARE @JobID BINARY(16)  
  DECLARE @ReturnCode INT    
  SELECT @ReturnCode = 0     
IF (SELECT COUNT(*) FROM msdb.dbo.syscategories WHERE name = N'[Uncategorized (Local)]') < 1 
  EXECUTE msdb.dbo.sp_add_category @name = N'[Uncategorized (Local)]'

  -- Delete the job with the same name (if it exists)
  SELECT @JobID = job_id     
  FROM   msdb.dbo.sysjobs    
  WHERE (name = N'CHOMP Db Size Data Collection')       
  IF (@JobID IS NOT NULL)    
  BEGIN  
  -- Check if the job is a multi-server job  
  IF (EXISTS (SELECT  * 
              FROM    msdb.dbo.sysjobservers 
              WHERE   (job_id = @JobID) AND (server_id <> 0))) 
  BEGIN 
    -- There is, so abort the script 
    RAISERROR (N'Unable to import job ''CHOMP Db Size Data Collection'' since there is already a multi-server job with this name.', 16, 1) 
    GOTO QuitWithRollback  
  END 
  ELSE 
    -- Delete the [local] job 
    EXECUTE msdb.dbo.sp_delete_job @job_name = N'CHOMP Db Size Data Collection' 
    SELECT @JobID = NULL
  END 

BEGIN 

  -- Add the job
  EXECUTE @ReturnCode = msdb.dbo.sp_add_job @job_id = @JobID OUTPUT , @job_name = N'CHOMP Db Size Data Collection', @owner_login_name = N'sa', @description = N'No description available.', @category_name = N'[Uncategorized (Local)]', @enabled = 1, @notify_level_email = 0, @notify_level_page = 0, @notify_level_netsend = 0, @notify_level_eventlog = 2, @delete_level= 0
  IF (@@ERROR <> 0 OR @ReturnCode <> 0) GOTO QuitWithRollback 

  -- Add the job steps
  EXECUTE @ReturnCode = msdb.dbo.sp_add_jobstep @job_id = @JobID, @step_id = 1, @step_name = N'Db Size Data', @command = N'TRUNCATE TABLE chomp_tables.dbo.CHOMP_SizeData

-- Create the temp table for further querying
CREATE TABLE #temp(
	DbName		varchar(25),
	rec_id		int IDENTITY (1, 1),
	table_name	varchar(128),
	nbr_of_rows	int,
	data_space	decimal(15,2),
	index_space	decimal(15,2),
	total_size	decimal(15,2),
	percent_of_db	decimal(15,12),
	db_size		decimal(15,2))

CREATE TABLE #Databases (dbnames varchar(50))

DECLARE @STMT1 varchar (400)
SELECT @STMT1 = ''INSERT #Databases SELECT [name] FROM master.dbo.sysdatabases WHERE [name] NOT IN (''''tempdb'''', ''''pubs'''', ''''model'''', ''''msdb'''', ''''master'''', ''''chomp_tables'''')''
EXEC (@STMT1)

DECLARE @dbname varchar(255),
@dbname_header varchar(255)

DECLARE dbnames_cursor CURSOR FOR SELECT * FROM #Databases
OPEN dbnames_cursor
FETCH NEXT FROM dbnames_cursor INTO @dbname
	
WHILE @@FETCH_STATUS = 0
BEGIN

	declare @sql varchar(400)
	
	-- Get all tables, names, and sizes
	select @sql = ''EXEC '' + @dbname + ''.dbo.sp_msforeachtable @command1="insert into #temp(nbr_of_rows, data_space, index_space) exec '' + @dbname + ''.dbo.sp_mstablespace ''''?''''", @command2="update #temp set table_name = ''''?'''' where rec_id = (select max(rec_id) from #temp)"''
	exec (@sql)

	-- Set the total_size and total database size fields
	declare @sql2 varchar(400)
	select @sql2 = ''UPDATE #temp SET total_size = (data_space + index_space), db_size = (SELECT SUM(data_space + index_space) FROM #temp)''
	exec (@sql2)

	-- Set the percent of the total database size
	DECLARE @STMT3 varchar (1000)
	SELECT @STMT3 = ''UPDATE #temp SET percent_of_db = (total_size/db_size) * 100''
	EXEC (@STMT3)

	-- Set the database name
	DECLARE @STMT4 varchar (1000)
	SELECT @STMT4 = ''UPDATE #temp SET DbName = '''''' + @dbname + ''''''''
	EXEC (@STMT4)

	-- Set the database name
	DECLARE @STMT5 varchar (1000)
	SELECT @STMT5 = ''INSERT INTO chomp_tables.dbo.CHOMP_SizeData (DbName, rec_id, table_name, nbr_of_rows, data_space, index_space, total_size, percent_of_db, db_size) SELECT * FROM #temp''
	EXEC (@STMT5)

FETCH NEXT FROM dbnames_cursor INTO @dbname
END
	
CLOSE dbnames_cursor
DEALLOCATE dbnames_cursor

DROP TABLE #Databases

-- Get the data
SELECT *
FROM #temp
ORDER BY total_size DESC

-- Comment out the following line if you want to do further querying
DROP TABLE #temp', @database_name = N'master', @server = N'', @database_user_name = N'', @subsystem = N'TSQL', @cmdexec_success_code = 0, @flags = 0, @retry_attempts = 0, @retry_interval = 1, @output_file_name = N'', @on_success_step_id = 0, @on_success_action = 1, @on_fail_step_id = 0, @on_fail_action = 2
  IF (@@ERROR <> 0 OR @ReturnCode <> 0) GOTO QuitWithRollback 
  EXECUTE @ReturnCode = msdb.dbo.sp_update_job @job_id = @JobID, @start_step_id = 1 

  IF (@@ERROR <> 0 OR @ReturnCode <> 0) GOTO QuitWithRollback 

  -- Add the job schedules
  EXECUTE @ReturnCode = msdb.dbo.sp_add_jobschedule @job_id = @JobID, @name = N'Db Size Data Sched', @enabled = 1, @freq_type = 4, @active_start_date = 20051115, @active_start_time = 50000, @freq_interval = 1, @freq_subday_type = 1, @freq_subday_interval = 0, @freq_relative_interval = 0, @freq_recurrence_factor = 0, @active_end_date = 99991231, @active_end_time = 235959
  IF (@@ERROR <> 0 OR @ReturnCode <> 0) GOTO QuitWithRollback 

  -- Add the Target Servers
  EXECUTE @ReturnCode = msdb.dbo.sp_add_jobserver @job_id = @JobID, @server_name = N'(local)' 
  IF (@@ERROR <> 0 OR @ReturnCode <> 0) GOTO QuitWithRollback 

END
COMMIT TRANSACTION          
GOTO   EndSave              
QuitWithRollback:
  IF (@@TRANCOUNT > 0) ROLLBACK TRANSACTION 
EndSave: 


