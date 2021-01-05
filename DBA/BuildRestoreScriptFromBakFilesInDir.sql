-- To allow advanced options to be changed.  
EXEC sp_configure 'show advanced options', 1;  
GO  
-- To update the currently configured value for advanced options.  
RECONFIGURE;  
GO  
-- To enable the feature.  
EXEC sp_configure 'xp_cmdshell', 1;  
GO  
-- To update the currently configured value for this feature.  
RECONFIGURE;  
GO  

USE Master; 
GO  
SET NOCOUNT ON 

-- 1 - Variable declaration 
DECLARE @dbFileName sysname 
DECLARE @dbName sysname 
DECLARE @backupPath NVARCHAR(500) 
DECLARE @cmd NVARCHAR(500) 
DECLARE @fileList TABLE (backupFile NVARCHAR(255)) 
DECLARE @lastFullBackup NVARCHAR(500) 
DECLARE @lastDiffBackup NVARCHAR(500) 
DECLARE @backupFile NVARCHAR(500) 

-- 2 - Initialize variables 
SET @dbName = 'aaData_CA'
SET @dbFileName = 'CHYSQL1CL$SimsSqlHA1_aaData_CA_FULL_' 
SET @backupPath = '\\VHYDPM01.hywd.ipzo.net\SQLBackups\CHYSQL1CL$SimsSqlHA1\aaData_CA\FULL\' 

-- 3 - get list of files 
SET @cmd = 'DIR /b "' + @backupPath + '"'

INSERT INTO @fileList(backupFile) 
EXEC master.sys.xp_cmdshell @cmd 

-- 4 - Find latest full backup 
SELECT @lastFullBackup = MAX(backupFile)  
FROM @fileList  
WHERE backupFile LIKE '%.bak'  
   AND backupFile LIKE @dbFileName + '%' 

SET @cmd = 'RESTORE DATABASE [' + @dbName + '] FROM DISK = '''  
       + @backupPath + @lastFullBackup + ''' WITH NORECOVERY, REPLACE' 
PRINT @cmd 

-- 4 - Find latest diff backup 
--SELECT @lastDiffBackup = MAX(backupFile)  
--FROM @fileList  
--WHERE backupFile LIKE '%.DIF'  
--   AND backupFile LIKE @dbFileName + '%' 
--   AND backupFile > @lastFullBackup 

-- check to make sure there is a diff backup 
--IF @lastDiffBackup IS NOT NULL 
--BEGIN 
--   SET @cmd = 'RESTORE DATABASE [' + @dbName + '] FROM DISK = '''  
--       + @backupPath + @lastDiffBackup + ''' WITH NORECOVERY' 
--   PRINT @cmd 
--   SET @lastFullBackup = @lastDiffBackup 
--END 

-- 5 - check for log backups 
--DECLARE backupFiles CURSOR FOR  
--   SELECT backupFile  
--   FROM @fileList 
--   WHERE backupFile LIKE '%.TRN'  
--   AND backupFile LIKE @dbFileName + '%' 
--   AND backupFile > @lastFullBackup 

--OPEN backupFiles  

-- Loop through all the files for the database  
--FETCH NEXT FROM backupFiles INTO @backupFile  

--WHILE @@FETCH_STATUS = 0  
--BEGIN  
--   SET @cmd = 'RESTORE LOG [' + @dbName + '] FROM DISK = '''  
--       + @backupPath + @backupFile + ''' WITH NORECOVERY' 
--   PRINT @cmd 
--   FETCH NEXT FROM backupFiles INTO @backupFile  
--END 

--CLOSE backupFiles  
--DEALLOCATE backupFiles  

-- 6 - put database in a useable state 
SET @cmd = 'RESTORE DATABASE [' + @dbName + '] WITH RECOVERY' 
PRINT @cmd 

-- To disable the feature.  
EXEC sp_configure 'xp_cmdshell', 0;  
GO  
-- To update the currently configured value for this feature.  
RECONFIGURE;  
GO  

-- To disallow advanced options to be changed.  
EXEC sp_configure 'show advanced options', 0;  
GO  
-- To update the currently configured value for advanced options.  
RECONFIGURE;  
GO  