. C:\DBA\Powershell\Functions\invoke-sqlcmd2
. C:\DBA\Powershell\Functions\write-data-table

#Import-Module SqlPs -DisableNameChecking 

$Servers = invoke-sqlcmd2 -ServerInstance "VHYDPM01.hywd.ipzo.net\MSDPM2012" -Database DBA -Query "SELECT name FROM servermon WHERE Files IS NULL"
invoke-sqlcmd2 -ServerInstance "VHYDPM01.hywd.ipzo.net\MSDPM2012" -Database DBA -Query "TRUNCATE TABLE DataAndLogFilesMon"

foreach ($Server in $Servers){
$Server.name
$dt = invoke-sqlcmd2 -ServerInstance $Server.name -InputFile C:\DBA\Powershell\SQL\DataAndLogFiles.sql  -As ‘DataTable’

Write-DataTable -ServerInstance "VHYDPM01.hywd.ipzo.net\MSDPM2012" -Database "DBA” -TableName "DataAndLogFilesMon” -Data $dt
}

#invoke-sqlcmd2 -ServerInstance "PICDataASQL01\DSASQL01" -Database "DBA” -Query "SELECT * FROM InstanceInfoMon" | Out-GridView