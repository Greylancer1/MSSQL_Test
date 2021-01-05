. C:\DBA\Powershell\Functions\invoke-sqlcmd2
. C:\DBA\Powershell\Functions\write-data-table

Import-Module SqlPs -DisableNameChecking 

$Servers = invoke-sqlcmd -ServerInstance PICDataASQL01\DSASQL01 -Database DBA -Query "SELECT name FROM servermon"
invoke-sqlcmd -ServerInstance PICDataASQL01\DSASQL01 -Database DBA -Query "TRUNCATE TABLE DBCompatLvlMon"

foreach ($Server in $Servers){
$Server.name
$dt = invoke-sqlcmd2 -ServerInstance $Server.name -InputFile C:\DBA\Powershell\SQL\DBCompatLvls.sql  -As ‘DataTable’

Write-DataTable -ServerInstance "PICDataASQL01\DSASQL01" -Database "DBA” -TableName "DBCompatLvlMon” -Data $dt
}

invoke-sqlcmd2 -ServerInstance "PICDataASQL01\DSASQL01" -Database "DBA” -Query "SELECT * FROM InstanceInfoMon" | Out-GridView