To strip out "somestring" from "SomeColumn" in "SomeTable" in the SELECT query:

SELECT REPLACE([SomeColumn],'somestring','') AS [SomeColumn]  FROM [SomeTable]
To update the table and strip out "somestring" from "SomeColumn" in "SomeTable"

UPDATE [SomeTable] SET [SomeColumn] = REPLACE([SomeColumn], 'somestring', '')