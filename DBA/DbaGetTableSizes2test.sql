TRUNCATE TABLE tTableSpace

DECLARE @srvname varchar(255),
@srvname_header varchar(255)

DECLARE srvnames_cursor CURSOR FOR SELECT srvname FROM master..sysservers 
WHERE srvname NOT IN ('KRONOS', 'USERACCESS', 'LAWSON')
OPEN srvnames_cursor
FETCH NEXT FROM srvnames_cursor INTO @srvname
WHILE @@FETCH_STATUS = 0
BEGIN

	CREATE TABLE #Databases (dbnames varchar(50))

	DECLARE @STMT1 varchar (200)
	SELECT @STMT1 = 'INSERT #Databases SELECT [name] FROM ' + @srvname +'.master.dbo.sysdatabases 
	WHERE [name] NOT IN (''tempdb'', ''pubs'', ''model'', ''msdb'', ''master'')'
	EXEC (@STMT1)

	DECLARE @dbname varchar(255),
	@dbname_header varchar(255)

	DECLARE dbnames_cursor CURSOR FOR SELECT * FROM #Databases
	OPEN dbnames_cursor
	FETCH NEXT FROM dbnames_cursor INTO @dbname
	
	WHILE @@FETCH_STATUS = 0
	BEGIN

		declare @sql varchar(400)
		create table #tables(tablename varchar(128))
	
		select @sql = 'insert #tables select name from ' + @srvname + '.' + @dbname + '.dbo.sysobjects where xtype = ''U'''
		exec (@sql)

		DECLARE @name varchar(255),
		@name_header varchar(255)

		DECLARE names_cursor CURSOR FOR SELECT * FROM #tables
		OPEN names_cursor
		FETCH NEXT FROM names_cursor INTO @name
	
		WHILE @@FETCH_STATUS = 0
		BEGIN
			
			create table #SpaceUsed (tablename varchar(128), rows varchar(11), reserved varchar(18), data varchar(18), index_size varchar(18), unused varchar(18))
			
			declare @sql2 varchar(400)
			select @sql2 = 'exec sp_executesql N''insert #SpaceUsed exec ' + @srvname + '.' + @dbname + '.dbo.sp_spaceused ' + @name + ''''
			exec (@sql2)

			DECLARE @STMT3 varchar (700)
			SELECT @STMT3 = 'INSERT INTO tTableSpace (DatabaseName, ServerName, TableName, TableRows, reserved_in_KB, data, index_size, unused) select ''' + @dbname + ''', ''' + @srvname + ''', tablename, rows, reserved, data, index_size, unused from #SpaceUsed WHERE rows <> ''0'''
			EXEC (@STMT3)
			
			drop table #SpaceUsed
			
		FETCH NEXT FROM names_cursor INTO @name
		END
	
		CLOSE names_cursor
		DEALLOCATE names_cursor

		drop table #tables

	FETCH NEXT FROM dbnames_cursor INTO @dbname
	END
	
	CLOSE dbnames_cursor
	DEALLOCATE dbnames_cursor

DROP TABLE #Databases

 FETCH NEXT FROM srvnames_cursor INTO @srvname
END
CLOSE srvnames_cursor
DEALLOCATE srvnames_cursor