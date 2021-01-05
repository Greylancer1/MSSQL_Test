Import-Module SqlPs -DisableNameChecking 

$dt = invoke-sqlcmd2 -ServerInstance "SCOMOPSDB1P" -Database "OperationsManager” -InputFile C:\health\SQL_Server\SQL\ServerList.sql  -As ‘DataTable’

Write-DataTable -ServerInstance "SQLDBA" -Database "DBA” -TableName "ServerMon” -Data $dt

invoke-sqlcmd2 -ServerInstance "SQLDBA" -Database "DBA” -Query "SELECT * FROM ServerMon" | Out-GridView