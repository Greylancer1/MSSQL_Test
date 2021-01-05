$Servers = invoke-sqlcmd -ServerInstance sqldba -Database DBA -Query "SELECT name FROM servermon"

    $Servers | ForEach-Object{
wscript.echo $_.servername
 }