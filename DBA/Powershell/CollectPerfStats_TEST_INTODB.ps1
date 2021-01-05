#Instantiate our external function scripts
. H:\DBA\Powershell\Functions\invoke-sqlcmd2
. H:\DBA\Powershell\Functions\write-data-table

Import-Module SqlPs -DisableNameChecking 

#Build our instance list
$Servers = invoke-sqlcmd -ServerInstance sqldba -Database DBA -Query "SELECT name FROM servermon WHERE monitored IS NULL AND Perf IS NULL"

#Run our script(s) against each instance
foreach ($Server in $Servers){
$Server.name
$dt = invoke-sqlcmd2 -ServerInstance $Server.name -InputFile H:\DBA\Powershell\SQL\InstancePerfStats.sql -As ‘DataTable’
Write-DataTable -ServerInstance "SQLDBA" -Database "DBA” -TableName "InstPerfMon” -Data $dt
$dt = invoke-sqlcmd2 -ServerInstance $Server.name -InputFile H:\DBA\Powershell\SQL\ServerStats.sql -As ‘DataTable’
Write-DataTable -ServerInstance "SQLDBA" -Database "DBA” -TableName "SrvrPerfMon” -Data $dt
}

#invoke-sqlcmd2 -ServerInstance "SQLDBA" -Database "DBA” -Query "SELECT * FROM InstPerfMon" | Out-GridView
#invoke-sqlcmd2 -ServerInstance "SQLDBA" -Database "DBA” -Query "SELECT * FROM SrvrPerfMon" | Out-GridView