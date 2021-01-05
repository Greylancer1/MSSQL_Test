TRUNCATE TABLE tMyDbs

DECLARE @srvname varchar(500)

DECLARE datanames_cursor CURSOR FOR SELECT srvname FROM master..sysservers 
WHERE srvname IN ('MSSQL1')
OPEN datanames_cursor
FETCH NEXT FROM datanames_cursor INTO @srvname
WHILE @@FETCH_STATUS = 0
BEGIN

CREATE TABLE #DbInfo
(
dbname varchar ( 50), 
dbsize varchar ( 50), 
dbowner varchar ( 50), 
dbid varchar ( 50), 
crdate datetime, 
status varchar ( 2000),
compatlevel int
)

DECLARE @STMT1 varchar (500)
IF @srvname NOT LIKE '%EPF%' AND @srvname NOT LIKE 'MISYS%' AND @srvname <> 'PLUTUS' AND @srvname NOT LIKE 'HYDRA'
BEGIN
 SELECT @STMT1 =
'INSERT INTO #DbInfo EXEC ' + @srvname + '.master..sp_helpdb'
EXEC (@STMT1)
END

IF @srvname LIKE '%EPF%' OR @srvname LIKE 'MISYS%' OR @srvname = 'PLUTUS' OR @srvname LIKE 'HYDRA'
BEGIN
 SELECT @STMT1 =
'INSERT INTO #DbInfo (dbname, dbsize, dbowner, dbid, crdate, status) EXEC ' + @srvname + '.master..sp_helpdb'
EXEC (@STMT1)
END

DECLARE @STMT2 varchar (500)
 SELECT @STMT2 =
'INSERT INTO tMyDbs (dbname, dbsize, dbowner, dbid, crdate, status, server) SELECT dbname, dbsize, dbowner, dbid, crdate, status, ''' + @srvname + ''' FROM #DbInfo'
EXEC (@STMT2)

DROP TABLE #DbInfo

FETCH NEXT FROM datanames_cursor INTO @srvname
END
CLOSE datanames_cursor
DEALLOCATE datanames_cursor