SELECT @@servername, name,  
    DATABASEPROPERTYEX(name, 'Recovery') AS RecoveryMode, 
    DATABASEPROPERTYEX(name, 'Status') AS [Status],
	DATABASEPROPERTYEX(name, 'IsAutoClose') AS [AutoClose],
	DATABASEPROPERTYEX(name, 'IsAutoCreateStatistics') AS [AutoStats],
	DATABASEPROPERTYEX(name, 'IsAutoShrink') AS [AutoShrink],
	DATABASEPROPERTYEX(name, 'IsFullTextEnabled') AS [FullText]
FROM   master.dbo.sysdatabases 