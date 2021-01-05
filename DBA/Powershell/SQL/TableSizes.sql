CREATE TABLE #temp(
	DBName		varchar(50),
	table_name	varchar(128),
	SchemaName varchar(50),
	nbr_of_rows	int,
	Total_space	int,
	Used_space	int,
	Unused_size	int
)
EXEC sp_msforeachdb @command1=
'IF ''?'' NOT IN(''master'', ''model'', ''msdb'', ''tempdb'') BEGIN USE ? 
insert into #temp(DBName, Table_name, SchemaName, nbr_of_rows, Total_space, Used_space, Unused_size) 
SELECT 
	''?'' AS DB,
	t.NAME AS TableName,
    s.Name AS SchemaName,
    p.rows AS RowCounts,
    SUM(a.total_pages) * 8 AS TotalSpaceKB, 
    SUM(a.used_pages) * 8 AS UsedSpaceKB, 
    (SUM(a.total_pages) - SUM(a.used_pages)) * 8 AS UnusedSpaceKB
FROM 
    sys.tables t
INNER JOIN      
    sys.indexes i ON t.OBJECT_ID = i.object_id
INNER JOIN 
    sys.partitions p ON i.object_id = p.OBJECT_ID AND i.index_id = p.index_id
INNER JOIN 
    sys.allocation_units a ON p.partition_id = a.container_id
LEFT OUTER JOIN 
    sys.schemas s ON t.schema_id = s.schema_id
WHERE 
    t.NAME NOT LIKE ''dt%'' 
    AND t.is_ms_shipped = 0
    AND i.OBJECT_ID > 255 
GROUP BY 
    t.Name, s.Name, p.Rows
ORDER BY 
    t.Name
END'

-- Get the data
SELECT getdate() as Dtm, @@servername as ServerName, *
FROM #temp
ORDER BY total_space DESC
-- Comment out the following line if you want to do further querying
DROP TABLE #temp