USE master
GO
DECLARE @LoginName varchar(256)
SET @LoginName ='HYWD\HYWD_DEVOPS_SQLTEST'

SELECT 'USE [' + Name + ']'
+ 'EXEC sp_addrolemember ''db_owner'', '''+ @LoginName + ''''
AS ScriptToExecute

FROM sys.databases 
WHERE name NOT IN ('Master','tempdb','model','msdb','dba') -- Avoid System Databases
AND (state_desc ='ONLINE') -- Avoid Offline Databases
AND (source_database_id Is Null) -- Avoid Database Snapshot
ORDER BY Name