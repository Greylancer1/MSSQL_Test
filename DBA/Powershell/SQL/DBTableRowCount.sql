CREATE TABLE #temp(
	Dtm			datetime,
	Instance	varchar(128),
	DBName		varchar(128),
	SchemaName	varchar(128),
	table_name	varchar(128),
	nbr_of_rows	bigint
)
EXEC sp_msforeachdb @command1=
'IF ''?'' NOT IN(''master'', ''model'', ''msdb'', ''tempdb'') 
BEGIN USE [?]; 
Insert into #temp(Dtm, Instance, DBName, SchemaName, Table_name, nbr_of_rows) 
SELECT
      getdate() AS Dtm, @@SERVERNAME AS Instance, DB_NAME() AS [Database], QUOTENAME(SCHEMA_NAME(sOBJ.schema_id)) AS SchemaName, QUOTENAME(sOBJ.name) AS [TableName]
      , SUM(sdmvPTNS.row_count) AS [RowCount]
--INTO DBRowCountMon
FROM
      sys.objects AS sOBJ
      INNER JOIN sys.dm_db_partition_stats AS sdmvPTNS
            ON sOBJ.object_id = sdmvPTNS.object_id
WHERE 
      sOBJ.type = ''U''
      AND sOBJ.is_ms_shipped = 0x0
      AND sdmvPTNS.index_id < 2
      AND DB_NAME() NOT IN (''master'', ''msdb'', ''tempdb'', ''ReportServer'', ''ReportServerTempDB'')
GROUP BY
      sOBJ.schema_id
      , sOBJ.name
ORDER BY [RowCount] DESC
END'
-- Get the data
SELECT *
FROM #temp
-- Comment out the following line if you want to do further querying
DROP TABLE #temp