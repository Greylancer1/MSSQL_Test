SET NOCOUNT ON

DECLARE @ObjectName sysname

DECLARE TableIndexList CURSOR FAST_FORWARD FOR
SELECT distinct co.objectname
FROM CHOMP_ShowContigOutput co
INNER JOIN sysobjects so
ON so.id=co.Objectid
WHERE OBJECTPROPERTY(CO.OBJECTID, 'IsUserTable') =1
AND co.objectname = 'SCMObsFSListValues'

OPEN TableIndexList

FETCH NEXT FROM TableIndexList
INTO @ObjectName

WHILE (@@fetch_status = 0)
BEGIN
	EXEC ('DBCC DBREINDEX(' + @ObjectName + ')')

	FETCH NEXT FROM TableIndexList
	INTO @ObjectName

END

CLOSE TableIndexList

DEALLOCATE TableIndexList