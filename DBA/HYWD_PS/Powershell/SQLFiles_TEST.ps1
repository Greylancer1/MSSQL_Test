set-location C:\health\SQL_Server

$isodate=Get-Date -format s 
$isodate=$isodate -replace(":","")
$basepath=(Get-Location -PSProvider FileSystem).ProviderPath


$instancepath=$basepath + "\config\instances.txt"
$outputfile="\logs\sql_server_Files_" + $isodate + ".html"
$outputfilefull = $basepath + $outputfile

$dt = new-object "System.Data.DataTable"
foreach ($instance in get-content $instancepath)
{
$instance
$cn = new-object System.Data.SqlClient.SqlConnection "server=$instance;database=msdb;Integrated Security=sspi"
$cn.Open()
$sql = $cn.CreateCommand()
$sql.CommandText = "
CREATE TABLE #output( 
server_name varchar(128), 
dbname varchar(128), 
physical_name varchar(260), 
dt datetime, 
file_group_name varchar(128), 
size_mb int, 
free_mb int)  
 
exec sp_MSforeachdb @command1= 
'USE [?]; INSERT #output 
SELECT CAST(SERVERPROPERTY(''ServerName'') AS varchar(128)) AS server_name, 
''?'' AS dbname, 
f.filename AS physical_name, 
CAST(FLOOR(CAST(getdate() AS float)) AS datetime) AS dt, 
g.groupname, 
CAST (size*8.0/1024.0 AS int) AS ''size_mb'', 
CAST((size - FILEPROPERTY(f.name,''SpaceUsed''))*8.0/1024.0 AS int) AS ''free_mb'' 
FROM sysfiles f 
JOIN sysfilegroups g 
ON f.groupid = g.groupid' 
 
SELECT * FROM #output
"
    $rdr = $sql.ExecuteReader()
    $dt.Load($rdr)
    $cn.Close()
 
}
    $dt | select * -ExcludeProperty RowError, RowState, HasErrors, Table, ItemArray | ConvertTo-Html -head $reportstyle -body "SQL Server Files" | Set-Content $outputfilefull  

