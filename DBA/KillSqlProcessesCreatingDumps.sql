DECLARE  tempcursor
CURSOR
READ_ONLY
FOR 
      select spid From master..sysprocesses
      where dbid = (select database_id from sys.databases where name = 'msdb')

DECLARE @name int
OPEN tempcursor

FETCH NEXT FROM tempcursor INTO @name
WHILE (@@fetch_status <> -1)
BEGIN
      exec('kill ' + @name)

      FETCH NEXT FROM tempcursor INTO @name
END

CLOSE tempcursor
DEALLOCATE tempcursor