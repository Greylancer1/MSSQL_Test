Import-Module SqlPs -DisableNameChecking 

$Servers = invoke-sqlcmd -ServerInstance sqldba -Database DBA -Query "SELECT server FROM vservers"
 
 
    $Query = "USE msdb  
GO  
SELECT  
   j.[name] AS [JobName],  
   run_status = CASE h.run_status  
   WHEN 0 THEN 'Failed' 
   WHEN 1 THEN 'Succeeded' 
   WHEN 2 THEN 'Retry' 
   WHEN 3 THEN 'Canceled' 
   WHEN 4 THEN 'In progress' 
   END, 
   h.run_date AS LastRunDate,   
   h.run_time AS LastRunTime 
FROM sysjobhistory h  
   INNER JOIN sysjobs j ON h.job_id = j.job_id  
       WHERE h.run_status = 0 
       AND j.enabled = 1   
       AND h.instance_id IN  
       (SELECT MAX(h.instance_id)  
           FROM sysjobhistory h GROUP BY (h.job_id))
GO "
    $Servers | ForEach-Object{
 $_.server
 Invoke-Sqlcmd -Query $Query -ServerInstance $_.server;
 }