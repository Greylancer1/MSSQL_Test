DECLARE @srvname varchar(255)

DECLARE datanames_cursor CURSOR FOR SELECT srvname FROM master..sysservers 
WHERE srvname in ('MSSQL1', 'MSSQL2')
OPEN datanames_cursor
FETCH NEXT FROM datanames_cursor INTO @srvname
WHILE @@FETCH_STATUS = 0
BEGIN
DECLARE @STMT1 varchar (100)
 SELECT @STMT1 =
'INSERT INTO tMyDbs (''dbname'', ''size'', ''dbowner'', ''dbid'', ''crdate'', ''status'', ''CompatLevel'') EXEC ' + @srvname + '.master..sp_helpdb'
EXEC (@STMT1)
DECLARE @STMT2 varchar (100)
 SELECT @STMT2 =
'UPDATE tMyDbs SET Server= ' + @srvname + ' WHERE RowNum = (SELECT MAX(RowNum) FROM tMyDbs)'
EXEC (@STMT2)
FETCH NEXT FROM datanames_cursor INTO @srvname
END
CLOSE datanames_cursor
DEALLOCATE datanames_cursor
