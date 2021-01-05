TRUNCATE TABLE tDbMessages

DECLARE @srvname varchar(255)

DECLARE datanames_cursor CURSOR FOR SELECT srvname FROM master..sysservers 
WHERE srvname NOT IN ('KRONOS', 'USERACCESS', 'LAWSON')
OPEN datanames_cursor
FETCH NEXT FROM datanames_cursor INTO @srvname
WHILE @@FETCH_STATUS = 0
BEGIN

CREATE TABLE #Errors (vchMessage varchar(2000), ID int)

DECLARE @STMT1 varchar (200)
SELECT @STMT1 = 
'INSERT #Errors EXEC ' + @srvname + '.master..xp_readerrorlog'
EXEC (@STMT1)

DECLARE @STMT2 varchar (500)
SELECT @STMT2 = 
'INSERT INTO tDbMessages (Message, EventDate, Server) SELECT vchMessage, 
CASE
WHEN ISNUMERIC(SUBSTRING(vchMessage,1,4)) = 1 THEN SUBSTRING(vchMessage,1,22)
ELSE NULL
END, ''' + @srvname + ''' FROM #Errors' 
EXEC (@STMT2)

DROP TABLE #Errors

FETCH NEXT FROM datanames_cursor INTO @srvname
END
CLOSE datanames_cursor
DEALLOCATE datanames_cursor