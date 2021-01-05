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