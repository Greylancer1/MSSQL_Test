SELECT name, index_id, type, type_desc, is_disabled FROM sys.indexes WHERE object_id = Object_id('TableName') 

SELECT COUNT(*) AS Cnt
FROM sys.indexes
WHERE is_disabled = 1