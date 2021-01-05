--Logins
SELECT @@SERVERNAME AS Instance,* FROM [master].[sys].[server_principals]
WHERE name NOT IN (SELECT name FROM [VHYGWBSQL02.hywd.ipzo.net\GWBSQL1].[master].[sys].[server_principals])

--Agent Jobs
SELECT @@SERVERNAME AS Instance, * FROM [msdb].[dbo].[sysjobs]
WHERE name NOT IN (SELECT name FROM [VHYGWBSQL02.hywd.ipzo.net\GWBSQL1].[msdb].[dbo].[sysjobs])
ORDER BY name