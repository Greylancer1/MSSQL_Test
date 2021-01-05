--TRUNCATE TABLE tDbSpaceChk

DECLARE @srvname varchar(255),
@srvname_header varchar(255)

DECLARE srvnames_cursor CURSOR FOR SELECT srvname FROM master..sysservers 
WHERE srvname IN ('IT170105')
OPEN srvnames_cursor
FETCH NEXT FROM srvnames_cursor INTO @srvname
WHILE @@FETCH_STATUS = 0
BEGIN

CREATE TABLE #Databases (dbnames varchar(25))

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

CREATE TABLE #Tables (Tablenames varchar(50))

DECLARE @STMT2 varchar (300)
SELECT @STMT2 = 'INSERT #Tables SELECT [name] FROM ' + @srvname + '.' + @dbname + '.dbo.sysobjects WHERE xtype=''u'''
EXEC (@STMT2)

--create variable to use within cursor to pull system data
DECLARE @tablename varchar (55)

DECLARE tablename_cursor CURSOR FOR SELECT * FROM #Tables
OPEN tablename_cursor
FETCH NEXT FROM tablename_cursor
INTO @tablename 

CREATE TABLE #TableSpace (TableName varchar(50), TableRows varchar(50), reserved_in_KB varchar(50), data varchar(50), index_size varchar(50), unused varchar(50))

WHILE @@FETCH_STATUS =0
BEGIN
	INSERT INTO #Tablespace EXEC sp_spaceused @objname=@tablename
	--insert data into table from system sp used to get table data
	FETCH NEXT FROM tablename_cursor
	INTO @tablename
END

CLOSE tablename_cursor
DEALLOCATE tablename_cursor

INSERT INTO tTableSpace (DatabaseName, ServerName, TableName, TableRows, reserved_in_KB, data, index_size, unused) SELECT @dbname, @srvname, TableName, TableRows, reserved_in_KB, data, index_size, unused FROM #TableSpace

DROP TABLE #TableSpace
DROP TABLE #Tables

/*********************************************************************
NAME:	CRussell
DATE:	7/3/02
DESC:	To get the space used for each file in the database

Name:	CRussell	
Date:	10/26/2004
Desc:	Moved to SXAProd
**********************************************************************/

FETCH NEXT FROM dbnames_cursor INTO @dbname
END
CLOSE dbnames_cursor
DEALLOCATE dbnames_cursor

DROP TABLE #Databases

 FETCH NEXT FROM srvnames_cursor INTO @srvname
END
CLOSE srvnames_cursor
DEALLOCATE srvnames_cursor

--change reserved column to numeric and convert data
--truncate the  alpha chars
UPDATE tTableSpace
SET reserved_in_KB = (select replace(reserved_in_KB, ' KB', ''))
--set the column datatype to numeric
alter table tTablespace
alter column reserved_in_KB int