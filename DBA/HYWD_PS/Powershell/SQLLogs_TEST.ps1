set-location C:\health\SQL_Server

$isodate=Get-Date -format s 
$isodate=$isodate -replace(":","")
$basepath=(Get-Location -PSProvider FileSystem).ProviderPath


$instancepath=$basepath + "\config\instances.txt"
$outputfile="\logs\sql_server_Logs_" + $isodate + ".html"
$outputfilefull = $basepath + $outputfile

$dt = new-object "System.Data.DataTable"
foreach ($instance in get-content $instancepath)
{
$instance
$cn = new-object System.Data.SqlClient.SqlConnection "server=$instance;database=msdb;Integrated Security=sspi"
$cn.Open()
$sql = $cn.CreateCommand()
$sql.CommandText = "
DECLARE @sqlStatement1 VARCHAR(200)
SET @sqlStatement1 = 'master.dbo.xp_readerrorlog'
        CREATE TABLE #Errors (LogDate DATETIME,ProcessInfo NVARCHAR(50),vchMessage varchar(2000))
INSERT #Errors EXEC @sqlStatement1
SELECT @@servername as ServerName, LogDate, RTRIM(LTRIM(vchMessage)) FROM #Errors WHERE 
([vchMessage] like '%error%'
   or  [vchMessage] like '%fail%'
   or  [vchMessage] like '%Warning%'
   or  [vchMessage] like '%The SQL Server cannot obtain a LOCK resource at this time%'
   or  [vchMessage] like '%Autogrow of file%in database%cancelled or timed out after%'
   or  [vchMessage] like '%Consider using ALTER DATABASE to set smaller FILEGROWTH%'
   or  [vchMessage] like '% is full%'
   or  [vchMessage] like '% blocking processes%'
   or  [vchMessage] like '%SQL Server has encountered%IO requests taking longer%to complete%'
)
and [vchMessage] not like '%\ERRORLOG%'
and [vchMessage] not like '%Attempting to cycle errorlog%'
and [vchMessage] not like '%Errorlog has been reinitialized.%' 
and [vchMessage] not like '%found 0 errors and repaired 0 errors.%'
and [vchMessage] not like '%without errors%'
and [vchMessage] not like '%This is an informational message%'
and [vchMessage] not like '%WARNING:%Failed to reserve contiguous memory%'
and [vchMessage] not like '%The error log has been reinitialized%'
and [vchMessage] not like '%Setting database option ANSI_WARNINGS%'
and [vchMessage] not like '%Error: 15457, Severity: 0, State: 1%'
and [vchMessage] <>  'Error: 18456, Severity: 14, State: 16.'
AND Logdate > GETDATE() - 2
  
DROP TABLE #Errors
"
    $rdr = $sql.ExecuteReader()
    $dt.Load($rdr)
    $cn.Close()
 
}
    $dt | select * -ExcludeProperty RowError, RowState, HasErrors, Table, ItemArray | ConvertTo-Html -head $reportstyle -body "SQL Server Error Logs - Last 2 days" | Set-Content $outputfilefull  

