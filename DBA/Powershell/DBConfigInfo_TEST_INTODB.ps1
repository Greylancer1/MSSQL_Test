﻿. H:\DBA\Powershell\Functions\invoke-sqlcmd2
. H:\DBA\Powershell\Functions\write-data-table

Import-Module SqlPs -DisableNameChecking 

$Servers = invoke-sqlcmd -ServerInstance sqldba -Database DBA -Query "SELECT name FROM servermon"
invoke-sqlcmd -ServerInstance sqldba -Database DBA -Query "TRUNCATE TABLE DBConfigMon"

foreach ($Server in $Servers){
$Server.name
$dt = invoke-sqlcmd2 -ServerInstance $Server.name -InputFile H:\DBA\Powershell\SQL\DBConfigInfo.sql  -As ‘DataTable’

Write-DataTable -ServerInstance "SQLDBA" -Database "DBA” -TableName "DBConfigMon” -Data $dt
}

#invoke-sqlcmd2 -ServerInstance "SQLDBA" -Database "DBA” -Query "SELECT * FROM InstanceInfoMon" | Out-GridView