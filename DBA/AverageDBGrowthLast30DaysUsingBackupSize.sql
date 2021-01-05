SELECT DISTINCT
	A.[database_name]
,	AVG( A.[Backup Size (MB)] - A.[Previous Backup Size (MB)] ) OVER ( PARTITION BY A.[database_name] ) AS [Avg Size Diff From Previous (MB)]
,	MAX( A.[Backup Size (MB)] - A.[Previous Backup Size (MB)] ) OVER ( PARTITION BY A.[database_name] ) AS [Max Size Diff From Previous (MB)]
,	MIN( A.[Backup Size (MB)] - A.[Previous Backup Size (MB)] ) OVER ( PARTITION BY A.[database_name] ) AS [Min Size Diff From Previous (MB)]
,	A.[Sample Size]
FROM 
(
	SELECT
		s.[database_name]
	--,	s.[backup_start_date]
	,	COUNT(*) OVER ( PARTITION BY s.[database_name] ) AS [Sample Size]
	,	CAST ( ( s.[backup_size] / 1024 / 1024 ) AS INT ) AS [Backup Size (MB)]
	,	CAST ( ( LAG(s.[backup_size] ) 
			OVER ( PARTITION BY s.[database_name] ORDER BY s.[backup_start_date] ) / 1024 / 1024 ) AS INT ) AS [Previous Backup Size (MB)]
	FROM 
		[msdb]..[backupset] s
	WHERE
		s.[type] = 'D' --full backup
		AND s.[backup_start_date] >= DATEADD(MONTH, -1, getdate()) --Last Month
	--ORDER BY
	--	s.[database_name]
	--,	s.[backup_start_date]
) AS A
ORDER BY
	[Avg Size Diff From Previous (MB)] DESC;
GO