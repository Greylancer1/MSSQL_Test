. H:\DBA\Powershell\Functions\invoke-sqlcmd2
. H:\DBA\Powershell\Functions\write-data-table

Import-Module SqlPs -DisableNameChecking 
#$Servers=$basepath + "C:\health\SQL_Server\config\instances.txt"
$Servers = invoke-sqlcmd -ServerInstance sqldba -Database DBA -Query "SELECT name FROM servermon WHERE monitored IS NULL AND IdxChk IS NULL"
invoke-sqlcmd -ServerInstance sqldba -Database DBA -Query "TRUNCATE TABLE IdxFragMon"

foreach ($Server in $Servers){
$Server.name
$dt = invoke-sqlcmd2 -ServerInstance $Server.name -InputFile H:\DBA\Powershell\SQL\IndexFrag.sql -As ‘DataTable’
Write-DataTable -ServerInstance "SQLDBA" -Database "DBA” -TableName "IdxFragMon” -Data $dt
}
invoke-sqlcmd2 -ServerInstance "SQLDBA" -Database "DBA” -Query "SELECT * FROM IdxFragMon" | Out-GridView