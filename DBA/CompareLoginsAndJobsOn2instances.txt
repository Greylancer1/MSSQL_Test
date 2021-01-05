--Logins
SELECT @@SERVERNAME AS Instance,* FROM [master].[sys].[server_principals]
WHERE name NOT IN (SELECT name FROM [VHYGWASQL01.hywd.ipzo.net\GWASQL1].[master].[sys].[server_principals])

--Agent Jobs
SELECT @@SERVERNAME AS Instance, * FROM [msdb].[dbo].[sysjobs]
WHERE name NOT IN (SELECT name FROM [VHYGWASQL01.hywd.ipzo.net\GWASQL1].[msdb].[dbo].[sysjobs])