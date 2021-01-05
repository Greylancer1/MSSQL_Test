DECLARE @srvname varchar(255)

DECLARE datanames_cursor CURSOR FOR SELECT srvname FROM master..sysservers 
WHERE srvname in ('MSSQL1', 'MSSQL2')
OPEN datanames_cursor
FETCH NEXT FROM datanames_cursor INTO @srvname
WHILE @@FETCH_STATUS = 0
BEGIN
DECLARE @STMT1 varchar (100)
 SELECT @STMT1 =
'SELECT *
FROM ' + @srvname + '.master.dbo.sysdatabases
WHERE (name NOT IN (''tempdb'', ''pubs'', ''Northwind'', ''model''))'
EXEC (@STMT1)
DECLARE @STMT2 varchar (100)
 SELECT @STMT2 =
'UPDATE  + @srvname + '.master.dbo.sysdatabases
WHERE (name NOT IN (''tempdb'', ''pubs'', ''Northwind'', ''model''))'
EXEC (@STMT2)
FETCH NEXT FROM datanames_cursor INTO @srvname
END
CLOSE datanames_cursor
DEALLOCATE datanames_cursor