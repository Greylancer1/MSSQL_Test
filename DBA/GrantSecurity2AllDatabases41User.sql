exec sp_MSforeachdb @command1= 'USE [?];
CREATE ROLE db_executor
GRANT EXECUTE TO db_executor
CREATE USER [IPZHOST\AFS_SQLAccess_RWE] FOR LOGIN [IPZHOST\AFS_SQLAccess_RWE];
EXEC sys.sp_addrolemember ''db_datareader'',''IPZHOST\AFS_SQLAccess_RWE'';
EXEC sys.sp_addrolemember ''db_datawriter'', ''IPZHOST\AFS_SQLAccess_RWE''; 
EXEC sys.sp_addrolemember ''db_executor'', ''IPZHOST\AFS_SQLAccess_RWE'';'