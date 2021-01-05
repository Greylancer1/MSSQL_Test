set-location C:\health\SQL_Server

$isodate=Get-Date -format s 
$isodate=$isodate -replace(":","")
$basepath=(Get-Location -PSProvider FileSystem).ProviderPath


$instancepath=$basepath + "\config\instances.txt"
$outputfile="\logs\sql_server_db_configuration_" + $isodate + ".html"
$outputfilefull = $basepath + $outputfile



#$emailFrom = "DailyCheck@chomp.org"
#$emailTo = "keith.duggins@chomp.org"
#$subject = "SQL Server DB config"
#$body = "SQL Server DB config"
#$smtpServer = "EXCHANGE"
#$filePath = ""


#invoke stylesheet
#. .\modules\stylesheet.ps1

#intro smtp function 
#. .\modules\smtp.ps1


$dt = new-object "System.Data.DataTable"
foreach ($instance in get-content $instancepath)
{
$instance
$cn = new-object System.Data.SqlClient.SqlConnection "server=$instance;database=msdb;Integrated Security=sspi"
$cn.Open()
$sql = $cn.CreateCommand()
$sql.CommandText = "SELECT @@servername as ServerName,SERVERPROPERTY('ProductVersion') AS Version, name, value, minimum, maximum, value_in_use as [Value in use], 
        description, is_dynamic AS [Dynamic?], is_advanced AS [Advanced?]
FROM    sys.configurations ORDER BY name
"
    $rdr = $sql.ExecuteReader()
    $dt.Load($rdr)
    $cn.Close()
 
}

$dt | select * -ExcludeProperty RowError, RowState, HasErrors, Table, ItemArray | ConvertTo-Html -head $reportstyle -body "SQL Server Daily Health Check" | Set-Content $outputfilefull  

#$filepath = $outputfilefull  
#Call smtp Function 
#sendEmail $emailFrom $emailTo $subject $body $smtpServer $filePath

