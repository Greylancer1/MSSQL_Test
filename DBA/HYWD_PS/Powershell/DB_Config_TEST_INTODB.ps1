. C:\DBA\Powershell\Functions\invoke-sqlcmd2
. C:\DBA\Powershell\Functions\write-data-table

#Import-Module SqlPs -DisableNameChecking 
#$Servers=$basepath + "C:\health\SQL_Server\config\instances.txt"
$Servers = invoke-sqlcmd2 -ServerInstance "VHYDPM01.hywd.ipzo.net\MSDPM2012" -Database "DBA" -Query "SELECT name FROM servermon WHERE monitored IS NULL"
invoke-sqlcmd2 -ServerInstance "VHYDPM01.hywd.ipzo.net\MSDPM2012" -Database "DBA" -Query "TRUNCATE TABLE ConfigMon"

foreach ($Server in $Servers){
$Server.name
$dt = invoke-sqlcmd2 -ServerInstance $Server.name -InputFile C:\DBA\Powershell\SQL\Config.sql -As ‘DataTable’
Write-DataTable -ServerInstance "VHYDPM01.hywd.ipzo.net\MSDPM2012" -Database "DBA” -TableName "ConfigMon” -Data $dt
}
invoke-sqlcmd2 -ServerInstance "VHYDPM01.hywd.ipzo.net\MSDPM2012" -Database "DBA” -Query "SELECT * FROM ConfigMon" | Out-GridView