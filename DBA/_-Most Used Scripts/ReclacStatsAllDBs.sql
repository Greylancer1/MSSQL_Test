exec sp_MSforeachdb 'use [?]; if db_name() not in (''master'', ''model'', ''tempdb'', ''msdb'') exec sp_updatestats;';
go