$Servers = invoke-sqlcmd -ServerInstance sqldba -Database DBA -Query "SELECT server FROM vservers"
 
 
    $Query = "CREATE TABLE #output( 
server_name varchar(128), 
dbname varchar(128), 
physical_name varchar(260), 
dt datetime, 
file_group_name varchar(128), 
size_mb int, 
free_mb int)  
 
exec sp_MSforeachdb @command1= 
'USE [?]; INSERT #output 
SELECT CAST(SERVERPROPERTY(''ServerName'') AS varchar(128)) AS server_name, 
''?'' AS dbname, 
f.filename AS physical_name, 
CAST(FLOOR(CAST(getdate() AS float)) AS datetime) AS dt, 
g.groupname, 
CAST (size*8.0/1024.0 AS int) AS ''size_mb'', 
CAST((size - FILEPROPERTY(f.name,''SpaceUsed''))*8.0/1024.0 AS int) AS ''free_mb'' 
FROM sysfiles f 
JOIN sysfilegroups g 
ON f.groupid = g.groupid' 
 
SELECT * FROM #output"
    $Servers | ForEach-Object{
 Invoke-Sqlcmd -Query $Query -ServerInstance $_.server;
 }