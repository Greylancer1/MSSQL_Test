--Checks 01 to see if it exists on 02 (must be run on 02)
--Logins

SELECT * FROM [PHYSQL01\SIMSSQL1].[master].[sys].[server_principals]
WHERE name NOT IN (SELECT name FROM [PHYSQL02\SIMSSQL1].[master].[sys].[server_principals])

--Agent Jobs

SELECT * FROM [PHYSQL01\SIMSSQL1].[msdb].[dbo].[sysjobs]
WHERE name NOT IN (SELECT name FROM [PHYSQL02\SIMSSQL1].[msdb].[dbo].[sysjobs])