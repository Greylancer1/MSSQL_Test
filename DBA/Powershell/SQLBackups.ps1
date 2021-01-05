$Servers = invoke-sqlcmd -ServerInstance sqldba -Database DBA -Query "SELECT server FROM vservers"

$Servers | ForEach-Object{  
    $SQLServer = New-Object ('Microsoft.SqlServer.Management.Smo.Server') $_.server  
    Foreach($Database in $SQLServer.Databases) 
    {
$_.server
$Database.Name
$Database.RecoveryModel
$Database.LastBackupDate
$Database.LastDifferentialBackupDate
$Database.LastLogBackupDate
    } 
} 