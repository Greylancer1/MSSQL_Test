TRUNCATE TABLE tDbSpaceChk

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
WHERE [name] NOT IN (''tempdb'', ''pubs'', ''model'', ''msdb'')'
EXEC (@STMT1)

DECLARE @dbname varchar(255),
@dbname_header varchar(255)

DECLARE dbnames_cursor CURSOR FOR SELECT * FROM #Databases
OPEN dbnames_cursor
FETCH NEXT FROM dbnames_cursor INTO @dbname
WHILE @@FETCH_STATUS = 0
BEGIN

DECLARE @STMT varchar (2500)
SELECT @STMT = 
'INSERT INTO tDbSpaceChk (BackupStartDate, SpaceDate, SpaceTime, DbName, FilegroupName, LogicalFilename, PhysFilename, Filesize, GrowthPercentage, Server)
SELECT	backup_start_date,
	CONVERT(char, backup_start_date, 111) AS [Date], --yyyy/mm/dd format
	CONVERT(char, backup_start_date, 108) AS [Time],
	''' + @dbname + ''' AS [Database Name], [filegroup_name] AS [Filegroup Name], logical_name AS [Logical Filename], 
	physical_name AS [Physical Filename], CONVERT(numeric(9,2),file_size/1048576) AS [File Size (MB)],
	Growth AS [Growth Percentage (%)],
	''' + @srvname + '''
FROM
(
	SELECT	b.backup_start_date, a.backup_set_id, a.file_size, a.logical_name, a.[filegroup_name], a.physical_name,
		(
			SELECT	CONVERT(numeric(5,2),((a.file_size * 100.00)/i1.file_size)-100)
			FROM	' + @srvname + '.msdb.dbo.backupfile i1
			WHERE 	i1.backup_set_id = 
						(
							SELECT	MAX(i2.backup_set_id) 
							FROM	' + @srvname + '.msdb.dbo.backupfile i2 JOIN ' + @srvname + '.msdb.dbo.backupset i3
								ON i2.backup_set_id = i3.backup_set_id
							WHERE	i2.backup_set_id < a.backup_set_id AND 
								i2.file_type=''D'' AND
								i3.database_name = ''' + @dbname + ''' AND
								i2.logical_name = a.logical_name AND
								i2.logical_name = i1.logical_name AND
								i3.type = ''D'' 
						) AND
				i1.file_type = ''D'' 
		) AS Growth
	FROM	' + @srvname + '.msdb.dbo.backupfile a JOIN ' + @srvname + '.msdb.dbo.backupset b 
		ON a.backup_set_id = b.backup_set_id
	WHERE	b.database_name = ''' + @dbname + ''' AND
		a.file_type = ''D'' AND
		b.type = ''D'' AND
		b.backup_start_date > (getdate() - 90)
) as Derived
WHERE (Growth <> 0.0) OR (Growth IS NULL)
ORDER BY logical_name, [Date]'
 EXEC (@STMT)

FETCH NEXT FROM dbnames_cursor INTO @dbname
END
CLOSE dbnames_cursor
DEALLOCATE dbnames_cursor

DROP TABLE #Databases

 FETCH NEXT FROM srvnames_cursor INTO @srvname
END
CLOSE srvnames_cursor
DEALLOCATE srvnames_cursor