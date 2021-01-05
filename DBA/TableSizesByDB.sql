USE DBNAme
SELECT so.name, 
8 * Sum(CASE WHEN si.indid IN (0, 1) THEN si.reserved END) AS data_kb, 
Coalesce(8 * Sum(CASE WHEN si.indid NOT IN (0, 1, 255) THEN si.reserved END), 0) AS index_kb, 
Coalesce(8 * Sum(CASE WHEN si.indid IN (255) THEN si.reserved END), 0) AS blob_kb 
FROM dbo.sysobjects AS so JOIN dbo.sysindexes AS si ON (si.id = so.id) 
WHERE 'U' = so.type GROUP BY so.name  ORDER BY data_kb DESC