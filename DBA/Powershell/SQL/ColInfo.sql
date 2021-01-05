
CREATE TABLE #temp(
	Dtm			datetime,
	Instance	varchar(128),
	DBName		varchar(128),
	SchemaName	varchar(128),
	table_name	varchar(128),
	Column_Name	varchar(128),
	Data_Type	varchar(128),
	Max_Len		smallint,
	Is_Nullable	bit,
	Is_ANSI		bit
)
EXEC sp_msforeachdb @command1=
'IF ''?'' NOT IN(''master'', ''model'', ''msdb'', ''tempdb'') 
BEGIN USE [?]; 
Insert into #temp(Dtm, Instance, DBName, SchemaName, Table_name, Column_Name, Data_Type, Max_Len, Is_Nullable, Is_ANSI) 

SELECT Getdate() AS DTM, @@SERVERNAME AS Instance, DB_NAME() AS [Database], QUOTENAME(SCHEMA_NAME(sOBJ.schema_id)) AS SchemaName, QUOTENAME(sOBJ.name) AS [TableName], AC.[name] AS [column_name],   
        TY.[name] AS system_data_type, AC.[max_length],  
        AC.[is_nullable], AC.[is_ansi_padded]
--INTO ColMon  
FROM sys.[objects] AS sObj   
 INNER JOIN sys.[all_columns] AC ON sObj.[object_id] = AC.[object_id]  
 INNER JOIN sys.[types] TY ON AC.[system_type_id] = TY.[system_type_id] AND AC.[user_type_id] = TY.[user_type_id]   
WHERE sOBJ.type = ''U''
      AND sOBJ.is_ms_shipped = 0x0
      AND DB_NAME() NOT IN (''master'', ''msdb'', ''tempdb'', ''ReportServer'', ''ReportServerTempDB'') 
ORDER BY sObj.[name], AC.[column_id]
END'
-- Get the data
SELECT *
FROM #temp
-- Comment out the following line if you want to do further querying
DROP TABLE #temp