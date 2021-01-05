---Get List of Last Full Backup or No Backup
;WITH LAST_FULL_BACKUP_LIST
AS
(
SELECT
SYSDBLIST.name AS Name,
MAX(BUSETS.backup_finish_date) AS Last_Backup_Finish_DateTime
FROM 
MASTER.sys.databases AS SYSDBLIST
LEFT OUTER JOIN
msdb.dbo.backupset AS BUSETS
ON
SYSDBLIST.name = BUSETS.database_name
WHERE
SYSDBLIST.name<>'TempDB'
AND
BUSETS.[type] ='D' OR BUSETS.[type] IS NULL
GROUP BY 
SYSDBLIST.name
)

,
---Get List of Last Differential Backup
LAST_DIFFERENTIAL_BACKUP_LIST
AS
(
SELECT
SYSDBLIST.name AS Name,
MAX(BUSETS.backup_finish_date) AS Last_Backup_Finish_DateTime
FROM 
MASTER.sys.databases AS SYSDBLIST
LEFT OUTER JOIN
msdb.dbo.backupset AS BUSETS
ON
SYSDBLIST.name = BUSETS.database_name
WHERE
SYSDBLIST.name<>'TempDB'
AND
BUSETS.[type] ='I' 
GROUP BY 
SYSDBLIST.name
)

,
---Get List of Last Log Backup

LOG_BACKUP_LIST
AS
(
SELECT
SYSDBLIST.name AS Name,
BUSETS.backup_finish_date AS Backup_Finish_DateTime,
ROUND(((BUSETS.backup_size/1024)/1024),2) AS Backup_Size_MB,
ROW_NUMBER() OVER(Partition by SYSDBLIST.name ORDER BY BUSETS.backup_finish_date DESC) AS RevOrderBuDate
FROM 
MASTER.sys.databases AS SYSDBLIST
LEFT OUTER JOIN
msdb.dbo.backupset AS BUSETS
ON
SYSDBLIST.name = BUSETS.database_name
WHERE
SYSDBLIST.name<>'TempDB'
AND
BUSETS.[type] ='L' 
)
,
LAST_LOG_BACKUP_LIST
AS
(SELECT
Name,
Backup_Finish_DateTime AS Last_Backup_Finish_DateTime,
Backup_Size_MB AS Log_Backup_Size_MB
FROM
LOG_BACKUP_LIST
WHERE
RevOrderBuDate=1
)



SELECT SERVERPROPERTY('Servername') AS ServerName,
SYSDBLIST.name AS Database_Name,
SYSDBLIST.Compatibility_level,
SYSDBLIST.Recovery_model,
SYSDBLIST.Recovery_model_desc,
BUSETS.database_creation_date AS Database_Create_Date,
CASE WHEN BUSETS.backup_set_id IS NULL THEN 'NO Backup' ELSE 'Backup Complete' END AS Backup_Completed,
BUSETS.backup_start_date AS Backup_Start_DateTime,
BUSETS.backup_finish_date AS Backup_Finish_DateTime,
DATEDIFF(MINUTE, BUSETS.backup_start_date, BUSETS.backup_finish_date) AS Duration_Min,
(DATEDIFF(DAY,BUSETS.backup_finish_date,GETDATE())) AS Days_Since_Last_Backup,

LASTDIFFBACKUP.Last_Backup_Finish_DateTime AS Last_Differential_Finish_DateTime,
(DATEDIFF(DAY,LASTDIFFBACKUP.Last_Backup_Finish_DateTime ,GETDATE())) AS Days_Since_Last_Differential_Backup,
LASTLOGBACKUP.Last_Backup_Finish_DateTime AS Last_Log_Finish_DateTime,
(DATEDIFF(DAY,LASTLOGBACKUP.Last_Backup_Finish_DateTime,GETDATE()))AS Days_Since_Last_Log_Backup,
LASTLOGBACKUP.Log_Backup_Size_MB AS LOG_Backup_Size_MB,
CASE 
WHEN BUSETS.[type] = 'D' THEN 'Full Backup' 
WHEN BUSETS.[type] = 'I' THEN 'Differential Database' 
WHEN BUSETS.[type] = 'L' THEN 'Log' 
WHEN BUSETS.[type] = 'F' THEN 'File/Filegroup'
WHEN BUSETS.[type] = 'G' THEN 'Differential File'
WHEN BUSETS.[type] = 'P' THEN 'Partial'  
WHEN BUSETS.[type] = 'Q'THEN 'Differential partial' 
END AS Backup_Type,
ROUND(((BUSETS.backup_size/1024)/1024),2) AS Backup_Size_MB,
ROUND(((BUSETS.compressed_backup_size/1024)/1024),2) AS Backup_Size_Compressed_MB,
BUMEDFAM.Device_type,
BUMEDFAM.Physical_device_name,
BUMEDFAM.Logical_device_name
FROM 
MASTER.sys.databases AS SYSDBLIST
LEFT OUTER JOIN
msdb.dbo.backupset AS BUSETS
ON
SYSDBLIST.name = BUSETS.database_name
LEFT OUTER JOIN
msdb.dbo.backupmediafamily  AS BUMEDFAM
ON
BUSETS.media_set_id = BUMEDFAM.media_set_id

INNER JOIN
LAST_FULL_BACKUP_LIST AS LASTBACKUP
ON
SYSDBLIST.Name=LASTBACKUP.Name
AND
ISNULL(BUSETS.backup_finish_date,'01/01/1900') = ISNULL(LASTBACKUP. Last_Backup_Finish_DateTime,'01/01/1900')

LEFT OUTER JOIN
LAST_DIFFERENTIAL_BACKUP_LIST AS LASTDIFFBACKUP
ON
SYSDBLIST.Name=LASTDIFFBACKUP.Name

LEFT OUTER JOIN
LAST_LOG_BACKUP_LIST AS LASTLOGBACKUP
ON
SYSDBLIST.Name=LASTLOGBACKUP.Name
WHERE
SYSDBLIST.name<>'TempDB'