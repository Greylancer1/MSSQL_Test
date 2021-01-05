USE < DBName > --Replace this with the actual DBName
GO

DECLARE @ColumnName AS VARCHAR(50) = 'CreatedOn' --The name of the column on which you need to put the criteria
DECLARE @Criteria AS VARCHAR(50) = 'CONVERT(DATE,' + @ColumnName + ') >= ''20130225''' -- The Actual criteria/WHERE Clause of the query

--The below will list the TSQL Statements which could be copied & executed in a separate query window.
SELECT 'IF EXISTS(SELECT 1 FROM ' + T.NAME + ' WHERE ' + @Criteria + ') ' + 'SELECT ''' + T.NAME + ''' TableName, * FROM ' + T.NAME + ' WHERE ' + @Criteria
FROM sys.columns C
INNER JOIN sys.tables T
 ON T.object_id = C.object_id
WHERE C.NAME = @ColumnName