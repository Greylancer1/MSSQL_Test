set-location C:\health\SQL_Server

$isodate=Get-Date -format s 
$isodate=$isodate -replace(":","")
$basepath=(Get-Location -PSProvider FileSystem).ProviderPath


$instancepath=$basepath + "\config\instances.txt"
$outputfile="\logs\sql_server_Jobs_" + $isodate + ".html"
$outputfilefull = $basepath + $outputfile

$dt = new-object "System.Data.DataTable"
foreach ($instance in get-content $instancepath)
{
$instance
$cn = new-object System.Data.SqlClient.SqlConnection "server=$instance;database=msdb;Integrated Security=sspi"
$cn.Open()
$sql = $cn.CreateCommand()
$sql.CommandText = "
USE msdb    
SELECT  
   [Server],
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
"
    $rdr = $sql.ExecuteReader()
    $dt.Load($rdr)
    $cn.Close()
 
}
    $dt | select * -ExcludeProperty RowError, RowState, HasErrors, Table, ItemArray | ConvertTo-Html -head $reportstyle -body "SQL Server Jobs" | Set-Content $outputfilefull  

