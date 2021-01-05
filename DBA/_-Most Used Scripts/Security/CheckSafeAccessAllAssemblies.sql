USE tempdb
GO
CREATE TABLE #assemblies
([db_name] SYSNAME,
[object_name] VARCHAR(255),
[type] VARCHAR(20),
[Schema] VARCHAR(255),
name VARCHAR(255),
permission_set_desc VARCHAR(50),
assembly_class VARCHAR(255),
assembly_method VARCHAR(255));

INSERT INTO #assemblies
EXEC sp_msforeachdb '
USE ?
SELECT      DB_NAME() AS [db_name],so.name AS [object_name], so.[type], SCHEMA_NAME(so.schema_id) AS [Schema],
            asmbly.name, asmbly.permission_set_desc, am.assembly_class, 
            am.assembly_method
FROM        sys.assembly_modules am
INNER JOIN  sys.assemblies asmbly
        ON  asmbly.assembly_id = am.assembly_id
INNER JOIN  sys.objects so
        ON  so.object_id = am.object_id
WHERE asmbly.name NOT LIKE ''Microsoft%'' AND asmbly.permission_set_desc IN (''SAFE_ACCESS'',''EXTERNAL_ACCESS'')';

SELECT * FROM #assemblies;

DROP TABLE #assemblies;