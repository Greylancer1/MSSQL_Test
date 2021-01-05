--Set new Limit size of job history
EXEC msdb.dbo.sp_set_sqlagent_properties @jobhistory_max_rows=-1,@jobhistory_max_rows_per_job=-1

--delete jobhistory older than 7 days and schedule following as a job or use gui
DECLARE @oldest_date DATETIME
SET @oldest_date = DATEADD(DAY,-7,GETDATE())
PRINT @oldest_date
EXEC msdb..sp_purge_jobhistory NULL,NULL,@oldest_date

--For a specific job (the ones that run every few seconds)
USE msdb ;  
GO  
DECLARE @oldest_date DATETIME
SET @oldest_date = DATEADD(DAY,-1,GETDATE())  
EXEC dbo.sp_purge_jobhistory  
    @job_name = N'NightlyBackups',NULL,@oldest_date ;  
GO  



DECLARE @date DATETIME
SET @date = DATEADD(DAY,-7,GETDATE())
EXEC msdb..sp_purge_jobhistory @oldest_date=@date


DECLARE @date DATETIME
SET @date = DATEADD(DAY,-1,GETDATE())  
EXEC dbo.sp_purge_jobhistory  
    @job_name = N'Lead Data Append'
	,@oldest_date=@date