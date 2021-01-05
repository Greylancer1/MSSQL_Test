DECLARE @srvname varchar(255)

DECLARE datanames_cursor CURSOR FOR SELECT srvname FROM master..sysservers 
WHERE srvname in ('MSSQL1', 'MSSQL2')
OPEN datanames_cursor
FETCH NEXT FROM datanames_cursor INTO @srvname
WHILE @@FETCH_STATUS = 0
BEGIN

CREATE TABLE #logspace (
   DBName varchar( 100),
   LogSize float,
   PrcntUsed float,
   status int
   )
INSERT INTO #logspace

SELECT * FROM
OPENQUERY(MSSQL1, 'EXEC (''DBCC sqlperf( logspace)'')')



drop table #logspace

FETCH NEXT FROM datanames_cursor INTO @srvname
END
CLOSE datanames_cursor
DEALLOCATE datanames_cursor