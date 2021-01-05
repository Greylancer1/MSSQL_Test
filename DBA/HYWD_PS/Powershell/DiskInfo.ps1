$Servers = invoke-sqlcmd -ServerInstance sqldba -Database DBA -Query "SELECT server FROM vservers"
 
    $Servers | ForEach-Object{
get-WmiObject win32_logicaldisk -Computername $_.server;
 }