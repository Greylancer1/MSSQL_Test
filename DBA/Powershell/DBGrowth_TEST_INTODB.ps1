. C:\DBA\Powershell\Functions\invoke-sqlcmd2
. C:\DBA\Powershell\Functions\write-data-table

#Import-Module SqlPs -DisableNameChecking 

$Servers = invoke-sqlcmd2 -ServerInstance "VITSCSMDB02.it.ipzo.net\SCSMSQL" -Database "DBA" -Query "SELECT name FROM servermon WHERE monitored IS NULL"
#invoke-sqlcmd2 -ServerInstance "VITSCSMDB02.it.ipzo.net\SCSMSQL" -Database DBA -Query "TRUNCATE TABLE DBGrowthMon"

foreach ($Server in $Servers){
$Server.name
$dt = invoke-sqlcmd2 -ServerInstance $Server.name -InputFile C:\DBA\Powershell\SQL\DBGrowth.sql  -As ‘DataTable’
#$dt = invoke-sqlcmd2 -ServerInstance "VITSCSMDB02.it.ipzo.net\SCSMSQL" -InputFile C:\DBA\Powershell\SQL\InstanceInfo.sql  -As ‘DataTable’
Write-DataTable -ServerInstance "VITSCSMDB02.it.ipzo.net\SCSMSQL" -Database "DBA” -TableName "DBGrowthMon” -Data $dt
}

#invoke-sqlcmd2 -ServerInstance "SQLDBA" -Database "DBA” -Query "SELECT * FROM DBGrowthMon" | Out-GridView