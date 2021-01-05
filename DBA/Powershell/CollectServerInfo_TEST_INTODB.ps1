#Instantiate our external function scripts
. C:\DBA\Powershell\Functions\invoke-sqlcmd2
. C:\DBA\Powershell\Functions\write-data-table

#Import-Module SqlPs -DisableNameChecking 

#Build our instance list
$Servers = invoke-sqlcmd2 -ServerInstance "VITSCSMDB02.it.ipzo.net\SCSMSQL" -Database DBA -Query "SELECT name FROM servermon where monitored is null"

#Run our script(s) against each instance
foreach ($Server in $Servers){
$Server.name
$dt = invoke-sqlcmd2 -ServerInstance $Server.name -InputFile C:\DBA\Powershell\SQL\ServerInfo.sql -As ‘DataTable’
Write-DataTable -ServerInstance "VITSCSMDB02.it.ipzo.net\SCSMSQL" -Database "DBA” -TableName "ServerInfoMon” -Data $dt
}

#invoke-sqlcmd2 -ServerInstance "PICDataASQL01\DSASQL01" -Database "DBA” -Query "SELECT * FROM InstPerfMon" | Out-GridView
#invoke-sqlcmd2 -ServerInstance "PICDataASQL01\DSASQL01" -Database "DBA” -Query "SELECT * FROM SrvrPerfMon" | Out-GridView