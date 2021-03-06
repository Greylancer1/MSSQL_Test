﻿. C:\DBA\Powershell\Functions\invoke-sqlcmd2
. C:\DBA\Powershell\Functions\write-data-table

#Import-Module SqlPs -DisableNameChecking 

$Servers = invoke-sqlcmd2 -ServerInstance "VITSCSMDB02.it.ipzo.net\SCSMSQL" -Database DBA -Query "SELECT name FROM servermon WHERE monitored IS NULL"
invoke-sqlcmd2 -ServerInstance "VITSCSMDB02.it.ipzo.net\SCSMSQL" -Database DBA -Query "TRUNCATE TABLE DriveFreeSpaceMon"

foreach ($Server in $Servers){
$Server.name
$dt = invoke-sqlcmd2 -ServerInstance $Server.name -InputFile C:\DBA\Powershell\SQL\DriveFreeSpace.sql  -As ‘DataTable’

Write-DataTable -ServerInstance "VITSCSMDB02.it.ipzo.net\SCSMSQL" -Database "DBA” -TableName "DriveFreeSpaceMon” -Data $dt
}

#invoke-sqlcmd2 -ServerInstance "PICDataASQL01\DSASQL01" -Database "DBA” -Query "SELECT * FROM InstanceInfoMon" | Out-GridView