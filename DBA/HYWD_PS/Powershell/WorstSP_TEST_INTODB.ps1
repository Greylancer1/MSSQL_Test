. C:\DBA\Powershell\Functions\invoke-sqlcmd2
. C:\DBA\Powershell\Functions\write-data-table

Import-Module SqlPs -DisableNameChecking 
#$Servers=$basepath + "C:\health\SQL_Server\config\instances.txt"
$Servers = invoke-sqlcmd -ServerInstance PICDataASQL01\DSASQL01 -Database DBA -Query "SELECT name FROM servermon WHERE monitored IS NULL"

foreach ($Server in $Servers){
$Server.name
$dt = invoke-sqlcmd2 -ServerInstance $Server.name -InputFile C:\DBA\Powershell\SQL\WorstPerfSPs.sql -As ‘DataTable’
Write-DataTable -ServerInstance "PICDataASQL01\DSASQL01" -Database "DBA” -TableName "WorstSPMon” -Data $dt
}
invoke-sqlcmd2 -ServerInstance "PICDataASQL01\DSASQL01" -Database "DBA” -Query "SELECT * FROM WorstSPMon" | Out-GridView