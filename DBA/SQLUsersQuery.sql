DECLARE @srvname varchar(500),
@srvname_header varchar(500)

DECLARE srvnames_cursor CURSOR FOR SELECT server FROM DBA..vServers 
WHERE server = 'IT170105'
OPEN srvnames_cursor
FETCH NEXT FROM srvnames_cursor INTO @srvname
WHILE @@FETCH_STATUS = 0
BEGIN

CREATE TABLE #Databases (dbnames varchar(50))

DECLARE @STMT1 varchar (200)
SELECT @STMT1 = 'INSERT #Databases SELECT [name] FROM [' + @srvname +'].master.dbo.sysdatabases 
WHERE [name] NOT IN (''tempdb'', ''pubs'', ''model'', ''msdb'')'
EXEC (@STMT1)

DECLARE @dbname varchar(255),
@dbname_header varchar(255)

DECLARE dbnames_cursor CURSOR FOR SELECT * FROM #Databases
OPEN dbnames_cursor
FETCH NEXT FROM dbnames_cursor INTO @dbname
WHILE @@FETCH_STATUS = 0
BEGIN

DECLARE @STMT varchar (2000)
SELECT @STMT = 
'SET NOCOUNT ON 

IF EXISTS (SELECT * FROM [' + @srvname + '].tempdb.dbo.sysobjects WHERE name = ''##Users'' AND type in (N''U'')) DROP TABLE ##Users; 
IF EXISTS (SELECT * FROM [' + @srvname + '].tempdb.dbo.sysobjects WHERE name = ''##DBUsers'' AND type in (N''U'')) DROP TABLE ##DBUsers; 

DECLARE @DBName VARCHAR(32); 
DECLARE @SQLCmd VARCHAR(1024); 

CREATE TABLE ##Users ( 
[sid] varbinary(85) NULL, 
[Login Name] varchar(255) NULL, 
[Default Database] varchar(18) NULL, 
[Login Type] varchar(9), 
[AD Login Type] varchar(8), 
[sysadmin] varchar(3), 
[securityadmin] varchar(3), 
[serveradmin] varchar(3), 
[setupadmin] varchar(3), 
[processadmin] varchar(3), 
[diskadmin] varchar(3), 
[dbcreator] varchar(3), 
[bulkadmin] varchar(3))

INSERT INTO ##Users SELECT sid, loginname AS [Login Name], dbname AS [Default Database],
 CASE isntname WHEN 1 THEN ''AD Login'' ELSE ''SQL Login'' END AS [Login Type],
 CASE WHEN isntgroup = 1 THEN ''AD Group'' WHEN isntuser = 1 THEN ''AD User'' ELSE ''?'' END AS [AD Login Type],
 CASE [sysadmin] WHEN 1 THEN ''Yes'' ELSE ''No'' END AS [sysadmin],
 CASE [securityadmin] WHEN 1 THEN ''Yes'' ELSE ''No'' END AS [securityadmin],
 CASE [serveradmin] WHEN 1 THEN ''Yes'' ELSE ''No'' END AS [serveradmin],
 CASE [setupadmin] WHEN 1 THEN ''Yes'' ELSE ''No'' END AS [setupadmin],
 CASE [processadmin] WHEN 1 THEN ''Yes'' ELSE ''No'' END AS [processadmin],
 CASE [diskadmin] WHEN 1 THEN ''Yes'' ELSE ''No'' END AS [diskadmin],
 CASE [dbcreator] WHEN 1 THEN ''Yes'' ELSE ''No'' END AS [dbcreator],
 CASE [bulkadmin] WHEN 1 THEN ''Yes'' ELSE ''No'' END AS [bulkadmin]
 FROM [' + @srvname + '].master.dbo.syslogins;

SELECT [Login Name],
 [Default Database], 
 [Login Type],
 [AD Login Type],
 [sysadmin],
 [securityadmin],
 [serveradmin],
 [setupadmin],
 [processadmin],
 [diskadmin],
 [dbcreator],
 [bulkadmin]
FROM ##Users
ORDER BY [Login Type], [AD Login Type], [Login Name]

CREATE TABLE ##DBUsers (
 [Database User ID] varchar(255) NULL,
 [Server Login] varchar(255) NULL,
 [Database Role] varchar(255) NULL,
 [Database] varchar(255) NULL);

 SELECT @SQLCmd = ''INSERT ##DBUsers '' +
 '' SELECT su.[name] AS [Database User ID], '' +
 '' COALESCE (u.[Login Name], ''** Orphaned **'') AS [Server Login], '' +
 '' COALESCE (sug.name, ''Public'') AS [Database Role], '' + 
 '' [''' + @DBName + '''] AS [Database]'' +
 '' FROM [''' + @DBName + '''].[dbo].[sysusers] su'' +
 '' LEFT OUTER JOIN ##Users u'' +
 '' ON su.sid = u.sid'' +
 '' LEFT OUTER JOIN ([''' + @srvname + '''].[''' + @DBName + '''].[dbo].[sysmembers] sm '' +
 '' INNER JOIN [''' + @srvname + '''].[''' + @DBName + '''].[dbo].[sysusers] sug '' +
 '' ON sm.groupuid = sug.uid)'' +
 '' ON su.uid = sm.memberuid '' +
 '' WHERE su.hasdbaccess = 1'' +
 '' AND su.[name] != ''dbo'' ''
 EXEC (@SQLCmd)

 FETCH NEXT 
 FROM csrDB
 INTO @DBName

 END

SELECT * 
 FROM ##DBUsers
 ORDER BY [Database User ID],[Database];

IF EXISTS (SELECT * FROM [' + @srvname + '].tempdb.dbo.sysobjects WHERE name = ''##Users''AND type in (N''U''))
 DROP TABLE ##Users;

IF EXISTS (SELECT * FROM [' + @srvname + '].tempdb.dbo.sysobjects WHERE name = ''##DBUsers'' AND type in (N''U''))
 DROP TABLE ##DBUsers;
-- ***************************************************************************
GO'

EXEC (@STMT)
FETCH NEXT FROM dbnames_cursor INTO @dbname
END
CLOSE dbnames_cursor
DEALLOCATE dbnames_cursor

DROP TABLE #Databases

 FETCH NEXT FROM srvnames_cursor INTO @srvname
END
CLOSE srvnames_cursor
DEALLOCATE srvnames_cursor