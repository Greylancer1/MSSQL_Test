CREATE TABLE #TMP ([SRVRNAME] NVARCHAR(256) NULL, [DBNAME] NVARCHAR(256) NULL, [SCHEMANAME] NVARCHAR(256) NULL, [TABLENAME] NVARCHAR(256) NULL, [INDEXNAME] NVARCHAR(256) NULL, [INDEXTYPE] NVARCHAR(256) NULL)

EXEC sp_MSforeachdb 'USE [?] INSERT INTO #TMP SELECT @@Servername, ''[?]'', sc.name AS Schema_Name
, o.name AS Table_Name
, i.name AS Index_Name
, i.type_desc AS Index_Type
FROM sys.indexes i
INNER JOIN sys.objects o ON i.object_id = o.object_id
INNER JOIN sys.schemas sc ON o.schema_id = sc.schema_id
WHERE i.name IS NOT NULL
AND o.type = ''U''
AND ''[?]'' NOT IN (''master'', ''msdb'', ''tempdb'', ''ReportServer'', ''ReportServerTempDB'')
ORDER BY o.name, i.type'
SELECT * FROM #TMP
DROP TABLE #TMP