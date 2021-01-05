TRUNCATE TABLE chomp_tables.dbo.CHOMP_SizeData

-- Create the temp table for further querying
CREATE TABLE #temp(
	DbName		varchar(25),
	rec_id		int IDENTITY (1, 1),
	table_name	varchar(128),
	nbr_of_rows	int,
	data_space	decimal(15,2),
	index_space	decimal(15,2),
	total_size	decimal(15,2),
	percent_of_db	decimal(15,12),
	db_size		decimal(15,2))

CREATE TABLE #Databases (dbnames varchar(50))

DECLARE @STMT1 varchar (400)
SELECT @STMT1 = 'INSERT #Databases SELECT [name] FROM master.dbo.sysdatabases WHERE [name] NOT IN (''tempdb'', ''pubs'', ''model'', ''msdb'', ''master'')'
EXEC (@STMT1)

DECLARE @dbname varchar(255),
@dbname_header varchar(255)

DECLARE dbnames_cursor CURSOR FOR SELECT * FROM #Databases
OPEN dbnames_cursor
FETCH NEXT FROM dbnames_cursor INTO @dbname
	
WHILE @@FETCH_STATUS = 0
BEGIN

	declare @sql varchar(400)
	
	-- Get all tables, names, and sizes
	select @sql = 'EXEC ' + @dbname + '.dbo.sp_msforeachtable @command1="insert into #temp(nbr_of_rows, data_space, index_space) exec ' + @dbname + '.dbo.sp_mstablespace ''?''", @command2="update #temp set table_name = ''?'' where rec_id = (select max(rec_id) from #temp)"'
	exec (@sql)

	-- Set the total_size and total database size fields
	declare @sql2 varchar(400)
	select @sql2 = 'UPDATE #temp SET total_size = (data_space + index_space), db_size = (SELECT SUM(data_space + index_space) FROM #temp)'
	exec (@sql2)

	-- Set the percent of the total database size
	DECLARE @STMT3 varchar (1000)
	SELECT @STMT3 = 'UPDATE #temp SET percent_of_db = (total_size/db_size) * 100'
	EXEC (@STMT3)

	-- Set the database name
	DECLARE @STMT4 varchar (1000)
	SELECT @STMT4 = 'UPDATE #temp SET DbName = ''' + @dbname + ''''
	EXEC (@STMT4)

	-- Set the database name
	DECLARE @STMT5 varchar (1000)
	SELECT @STMT5 = 'INSERT INTO chomp_tables.dbo.CHOMP_SizeData (DbName, rec_id, table_name, nbr_of_rows, data_space, index_space, total_size, percent_of_db, db_size) SELECT * FROM #temp'
	EXEC (@STMT5)

FETCH NEXT FROM dbnames_cursor INTO @dbname
END
	
CLOSE dbnames_cursor
DEALLOCATE dbnames_cursor

DROP TABLE #Databases

-- Get the data
SELECT *
FROM #temp
ORDER BY total_size DESC

-- Comment out the following line if you want to do further querying
DROP TABLE #temp