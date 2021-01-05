SELECT DISTINCT @@SERVERNAME AS Instance,
dovs.logical_volume_name AS LogicalName,
dovs.volume_mount_point AS Drive,
CONVERT(INT,dovs.available_bytes/1048576.0) AS FreeSpaceInMB,
REPLACE(REPLACE(RTRIM(REPLACE(ROUND((CONVERT(decimal,dovs.available_bytes/1048576.0)/1024),1), '0' ,' ')), ' ','0') + ' ', '. ', '') AS FreeSpaceInGB
FROM sys.master_files mf
CROSS APPLY sys.dm_os_volume_stats(mf.database_id, mf.FILE_ID) dovs
ORDER BY FreeSpaceInMB ASC