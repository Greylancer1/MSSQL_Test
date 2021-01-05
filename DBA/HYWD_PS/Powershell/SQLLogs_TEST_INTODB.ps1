. C:\DBA\Powershell\Functions\invoke-sqlcmd2
. C:\DBA\Powershell\Functions\write-data-table

Import-Module SqlPs -DisableNameChecking 
#$Servers=$basepath + "C:\health\SQL_Server\config\instances.txt"
$Servers = invoke-sqlcmd -ServerInstance PICDataASQL01\DSASQL01 -Database DBA -Query "SELECT name FROM servermon WHERE monitored IS NULL"
invoke-sqlcmd -ServerInstance PICDataASQL01\DSASQL01 -Database DBA -Query "TRUNCATE TABLE LogMon"

foreach ($Server in $Servers){
$Server.name
$dt = invoke-sqlcmd2 -ServerInstance $Server.name -InputFile C:\DBA\Powershell\SQL\ErrorLogs.sql -As ‘DataTable’
Write-DataTable -ServerInstance "PICDataASQL01\DSASQL01" -Database "DBA” -TableName "LogMon” -Data $dt
}
#invoke-sqlcmd2 -ServerInstance "PICDataASQL01\DSASQL01" -Database "DBA” -Query "SELECT * FROM LogMon" | Out-GridView