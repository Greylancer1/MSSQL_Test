. C:\DBA\Powershell\Functions\invoke-sqlcmd2
. C:\DBA\Powershell\Functions\write-data-table

Import-Module SqlPs -DisableNameChecking 

$Servers = invoke-sqlcmd2 -ServerInstance PICDataASQL01\DSASQL01 -Database DBA -Query "SELECT name FROM servermon"
invoke-sqlcmd2 -ServerInstance PICDataASQL01\DSASQL01 -Database DBA -Query "TRUNCATE TABLE DBConfigMon"

foreach ($Server in $Servers){
$Server.name
$dt = invoke-sqlcmd2 -ServerInstance $Server.name -InputFile C:\DBA\Powershell\SQL\DBConfigInfo.sql  -As ‘DataTable’

Write-DataTable -ServerInstance "PICDataASQL01\DSASQL01" -Database "DBA” -TableName "DBConfigMon” -Data $dt
}

#invoke-sqlcmd2 -ServerInstance "PICDataASQL01\DSASQL01\DSASQL01" -Database "DBA” -Query "SELECT * FROM InstanceInfoMon" | Out-GridView