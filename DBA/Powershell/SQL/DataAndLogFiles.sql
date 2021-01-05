CREATE TABLE #output( 
server_name varchar(128), 
dbname varchar(128), 
physical_name varchar(260), 
dt datetime, 
size_mb int, 
free_mb int)  
 
exec sp_MSforeachdb @command1= 
'USE [?]; INSERT #output 
SELECT CAST(SERVERPROPERTY(''ServerName'') AS varchar(128)) AS server_name, 
''?'' AS dbname, 
f.filename AS physical_name, 
CAST(FLOOR(CAST(getdate() AS float)) AS datetime) AS dt, 
CAST (size*8.0/1024.0 AS int) AS ''size_mb'', 
CAST((size - FILEPROPERTY(f.name,''SpaceUsed''))*8.0/1024.0 AS int) AS ''free_mb'' 
FROM sysfiles f'
 
SELECT * FROM #output
DROP TABLE #output