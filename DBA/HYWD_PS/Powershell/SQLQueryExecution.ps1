Import-Module SqlPs -DisableNameChecking 

$Servers = invoke-sqlcmd -ServerInstance sqldba -Database DBA -Query "SELECT name FROM ServerMon"
 
 
    $Query = "SELECT SERVERPROPERTY('ServerName') AS ServerName
                ,SERVERPROPERTY('ProductVersion') AS ProductVersion
                ,SERVERPROPERTY('ProductLevel') AS ProductLevel
                ,SERVERPROPERTY('Edition') AS Edition
                ,SERVERPROPERTY('EngineEdition') AS EngineEdition;"
    $Servers | ForEach-Object{
 Invoke-Sqlcmd -Query $Query -ServerInstance $_.server;
 }