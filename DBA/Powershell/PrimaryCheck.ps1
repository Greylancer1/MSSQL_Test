. C:\DBA\Powershell\Functions\invoke-sqlcmd2
. C:\DBA\Powershell\Functions\write-data-table

#Import-Module SqlPs -DisableNameChecking 
#$Servers=$basepath + "C:\health\SQL_Server\config\instances.txt"
$Servers = invoke-sqlcmd2 -ServerInstance "vtzdpm01.tzg.ipzo.net\MSDPM2012" -Database DBA -Query "SELECT name FROM servermon WHERE monitored is null"
invoke-sqlcmd2 -ServerInstance "vtzdpm01.tzg.ipzo.net\MSDPM2012" -Database DBA -Query "TRUNCATE TABLE IsPrimaryMon"

foreach ($Server in $Servers){
$Server.name
$dt = invoke-sqlcmd2 -ServerInstance $Server.name -InputFile C:\DBA\Powershell\SQL\PrimaryCheck.sql -As ‘DataTable’
Write-DataTable -ServerInstance "vtzdpm01.tzg.ipzo.net\MSDPM2012" -Database "DBA” -TableName "IsPrimaryMon” -Data $dt
}
#invoke-sqlcmd2 -ServerInstance "vtzdpm01.tzg.ipzo.net\MSDPM2012" -Database "DBA” -Query "SELECT * FROM IsPrimaryMon" | Out-GridView