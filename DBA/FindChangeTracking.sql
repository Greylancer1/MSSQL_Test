exec sp_MSforeachdb @command1= 
'SELECT ''?'' AS dbname, database_id, is_auto_cleanup_on, retention_period, retention_period_units, retention_period_units_desc, max_cleanup_version  
FROM sys.change_tracking_databases 
WHERE database_id=DB_ID(''?'')'


select sys.schemas.name as Schema_name, sys.tables.name as Table_name from sys.change_tracking_tables
join sys.tables on sys.tables.object_id = sys.change_tracking_tables.object_id
join sys.schemas on sys.schemas.schema_id = sys.tables.schema_id