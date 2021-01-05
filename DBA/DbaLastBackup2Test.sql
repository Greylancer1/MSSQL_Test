SELECT * FROM master..sysdatabases
SELECT * FROM msdb..backupset

CREATE TABLE #BackupInfo
(
DbName varchar ( 50),
StartDate datetime,
FinishDate datetime,
Type varchar ( 10), 
BackupSize int,
RunBy varchar ( 50)
)

INSERT INTO #BackupInfo SELECT database_name, backup_start_date, backup_finish_date, type, backup_size, [user_name] FROM MSSQL1.msdb.dbo.backupset

SELECT * FROM #BackupInfo

DROP TABLE #BackupInfo