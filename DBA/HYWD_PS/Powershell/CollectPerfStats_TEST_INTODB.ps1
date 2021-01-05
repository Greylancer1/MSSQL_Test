#Instantiate our external function scripts
. C:\DBA\Powershell\Functions\invoke-sqlcmd2
. C:\DBA\Powershell\Functions\write-data-table

#Import-Module SqlPs -DisableNameChecking 

#Build our instance list
$Servers = invoke-sqlcmd2 -ServerInstance "VHYDPM01.hywd.ipzo.net\MSDPM2012" -Database DBA -Query "SELECT name FROM servermon"
invoke-sqlcmd2 -ServerInstance "VHYDPM01.hywd.ipzo.net\MSDPM2012" -Database DBA -Query "TRUNCATE TABLE InstPerfMon"
invoke-sqlcmd2 -ServerInstance "VHYDPM01.hywd.ipzo.net\MSDPM2012" -Database DBA -Query "TRUNCATE TABLE SrvrPerfMon"

#Run our script(s) against each instance
foreach ($Server in $Servers){
$Server.name
$dt = invoke-sqlcmd2 -ServerInstance $Server.name -InputFile C:\DBA\Powershell\SQL\InstancePerfStats.sql -As ‘DataTable’
Write-DataTable -ServerInstance "VHYDPM01.hywd.ipzo.net\MSDPM2012" -Database "DBA” -TableName "InstPerfMon” -Data $dt
$dt = invoke-sqlcmd2 -ServerInstance $Server.name -InputFile C:\DBA\Powershell\SQL\ServerStats.sql -As ‘DataTable’
Write-DataTable -ServerInstance "VHYDPM01.hywd.ipzo.net\MSDPM2012" -Database "DBA” -TableName "SrvrPerfMon” -Data $dt
}

#invoke-sqlcmd2 -ServerInstance "PICDataASQL01\DSASQL01" -Database "DBA” -Query "SELECT * FROM InstPerfMon" | Out-GridView
#invoke-sqlcmd2 -ServerInstance "PICDataASQL01\DSASQL01" -Database "DBA” -Query "SELECT * FROM SrvrPerfMon" | Out-GridView