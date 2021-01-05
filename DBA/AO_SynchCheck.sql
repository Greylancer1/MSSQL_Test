SELECT @@SERVERNAME AS Instance, a.* FROM [master].[sys].[server_principals] a
WHERE a.name NOT IN (SELECT b.name FROM [vhytestasql01\simsregsql1].[master].[sys].[server_principals] b)
SELECT @@SERVERNAME AS Instance, a.* FROM [msdb].[dbo].[sysjobs] a
WHERE a.name NOT IN (SELECT b.name FROM [vhytestasql01\simsregsql1].[msdb].[dbo].[sysjobs] b) AND a.name NOT LIKE 'DBA%' AND a.name NOT LIKE 'Test%'

SELECT @@SERVERNAME AS Instance, a.* FROM [master].[sys].[server_principals] a
WHERE a.name NOT IN (SELECT b.name FROM [PHYSQL02\SIMSSQL1].[master].[sys].[server_principals] b)
SELECT @@SERVERNAME AS Instance, a.* FROM [msdb].[dbo].[sysjobs] a
WHERE a.name NOT IN (SELECT b.name FROM [PHYSQL02\SIMSSQL1].[msdb].[dbo].[sysjobs] b) AND a.name NOT LIKE 'DBA%' AND a.name NOT LIKE 'Test%'

DECLARE @vsql AS VARCHAR(MAX)
DECLARE @body varchar (5000)
DECLARE @subject varchar (5000)
SET @body = 'Sample Email ' + CONVERT( VARCHAR( 20 ), GETDATE(), 113 ) + ' '
SET @subject = 'SIMS Prod AO Synch Check PHYSQL01 ' + CONVERT( VARCHAR( 20 ), GETDATE(), 113 )
SELECT @vsql = 'SELECT @@SERVERNAME AS Instance, a.* FROM [master].[sys].[server_principals] a
WHERE a.name NOT IN (SELECT b.name FROM [PHYSQL02\SIMSSQL1].[master].[sys].[server_principals] b)
SELECT @@SERVERNAME AS Instance, a.* FROM [msdb].[dbo].[sysjobs] a
WHERE a.name NOT IN (SELECT b.name FROM [PHYSQL02\SIMSSQL1].[msdb].[dbo].[sysjobs] b) AND a.name NOT LIKE ''DBA%'' AND a.name NOT LIKE ''Test%'''
	EXEC msdb.dbo.sp_send_dbmail
	@profile_name = 'FIG Alert',
	@recipients =  'keithd@imprezzio.com',
	@body = @body,
	@subject = @Subject, 
	@query = @vsql, 
	@attach_query_result_as_file = 1,
	@query_attachment_filename = 'PHYSQL01_AO_SynchCheck.txt'