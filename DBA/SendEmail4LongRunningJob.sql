DECLARE @MaxMinutes int
SET @MaxMinutes = 2
		IF 
        EXISTS(
		SELECT p.spid FROM master..sysprocesses p
        JOIN msdb..sysjobs j ON dbo.udf_sysjobs_getprocessid(j.job_id) = substring(p.program_name,32,8)
        WHERE 
		j.name = 'ProspectPushChanges1' 
		AND 
		isnull(DATEDIFF(mi, p.last_batch, getdate()), 0) > @MaxMinutes
		)
		BEGIN
		EXEC msdb.dbo.sp_send_dbmail
             @profile_name = 'FIG Alert',
             @recipients = 'Operations Engineering',
			 @Body = '"ProspectPushChanges1" SQL job has run longer than 2 minutes.',
             @query = 'USE DBA
						DECLARE @MaxMinutes int
                        SET @MaxMinutes = 2
                        SELECT p.spid, isnull(DATEDIFF(mi, p.last_batch, getdate()), 0) [MinutesRunning]
						 FROM master..sysprocesses p
                        JOIN msdb..sysjobs j ON dbo.udf_sysjobs_getprocessid(j.job_id) = substring(p.program_name,32,8)
                        WHERE 
						j.name = ''ProspectPushChanges1'' 
						AND 
						isnull(DATEDIFF(mi, p.last_batch, getdate()), 0) > @MaxMinutes' ,
             @subject = '"ProspectPushChanges1" SQL job on HYWD Prod has run longer than 2 minutes.',
             @attach_query_result_as_file = 1
		END