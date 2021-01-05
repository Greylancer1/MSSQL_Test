
/***************** Kick off all USERs, not services **************************************/
use master 
go
declare @spid nvarchar(5) --smallint
declare @sqlstring nvarchar(100)

DECLARE spid_cursor CURSOR
FOR 
SELECT  spid 
FROM sysprocesses 
WHERE dbid IN (5,6,7,8,9) --SXAProd    -- select * from master.sys.databases
AND hostname not like 'sxa%'

OPEN spid_cursor

FETCH NEXT FROM spid_cursor
INTO @spid 

WHILE @@FETCH_STATUS = 0

BEGIN	

	Set @SqlString = N'Kill ' + @spid   
	EXEC sp_executesql @sqlstring
		
	FETCH NEXT FROM spid_cursor
	INTO @spid 
END
CLOSE spid_cursor
DEALLOCATE spid_cursor