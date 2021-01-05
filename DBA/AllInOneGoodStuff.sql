CREATE TABLE #TempTable 
	(
	DatabaseName 			VARCHAR(128)
	,DBid				INT
	,DBSize				VARCHAR(128)
	,Recovery 			VARCHAR(128)
	,Owner				VARCHAR(128)
	,Status 			VARCHAR(128)
	,Updateability 			VARCHAR(128)
	,UserAccess 			VARCHAR(128)
	,CompatibilityLevel		VARCHAR(30)
	,LastFullBackup			DATETIME
	,LastDiffBackup			DATETIME
	,LastLogBackup			DATETIME
	,MaintenancePlan		VARCHAR(128)
	,Name1				VARCHAR(128)
	,FileName1			VARCHAR(128)
	,FileGroup1			VARCHAR(128)
	,Size1				VARCHAR(128)
	,MaxSize1			VARCHAR(128)
	,Growth1			VARCHAR(128)
	,Usage1				VARCHAR(30)
	,Name2				VARCHAR(128)
	,FileName2			VARCHAR(128)
	,FileGroup2			VARCHAR(128)
	,Size2				VARCHAR(128)
	,MaxSize2			VARCHAR(128)
	,Growth2			VARCHAR(128)
	,Usage2				VARCHAR(30)
	,CreationDate			DATETIME
	,SQLSortOrder 			INT
	,Collation 			VARCHAR(128)
	,Version 			VARCHAR(128)
	,IsAnsiNullDefault 		BIT
	,IsAnsiNullsEnabled 		BIT
	,IsAnsiPaddingEnabled 		BIT
	,IsAnsiWarningsEnabled 		BIT
	,IsArithmeticAbortEnabled 	BIT
	,IsAutoClose 			BIT
	,IsAutoCreateStatistics 	BIT
	,IsAutoShrink 			BIT
	,IsAutoUpdateStatistics 	BIT
	,IsCloseCursorsOnCommitEnabled 	BIT
	,IsFulltextEnabled 		BIT
	,IsInStandBy 			BIT
	,IsLocalCursorsDefault 		BIT
	,IsMergePublished 		BIT
	,IsNullConcat 			BIT
	,IsNumericRoundAbortEnabled 	BIT
	,IsPublished 			BIT
	,IsQuotedIdentifiersEnabled 	BIT
	,IsRecursiveTriggersEnabled 	BIT
	,IsSubscribed 			BIT
	,IsTornPageDetectionEnabled 	BIT
	)

DECLARE @databasename VARCHAR(128)
DECLARE @owner VARCHAR(128)
DECLARE @DBid	INT
DECLARE @cmptlevel VARCHAR(30)
DECLARE	@crdate DATETIME
DECLARE @low NVARCHAR(11)
DECLARE @sql VARCHAR(1000)
SELECT @low = convert(varchar(11),low) from master.dbo.spt_values where type = N'E' and number = 1
DECLARE dbname CURSOR FOR SELECT name,dbid,cmptlevel,crdate,suser_sname(sid) FROM master..sysdatabases
OPEN dbname
FETCH NEXT FROM dbname
INTO @databasename,@DBid,@cmptlevel,@crdate,@owner
WHILE @@FETCH_STATUS = 0
BEGIN
	INSERT INTO #TempTable SELECT @databasename 
	, @dbid
	, 'DBSize'
	, CAST( databasePROPERTYEX( @databasename , 'Recovery') 			AS VARCHAR(128))
	, @owner
	, CAST( databasePROPERTYEX( @databasename , 'Status') 				AS VARCHAR(128))
	, CAST( databasePROPERTYEX( @databasename , 'Updateability') 			AS VARCHAR(128))
	, CAST( databasePROPERTYEX( @databasename , 'UserAccess') 			AS VARCHAR(128))
	, @cmptlevel
	, GETDATE()
	, GETDATE()
	, GETDATE()
	, 'MaintenancePlan'
	, 'name1'
	, 'filename1'
	, 'filegroup1'
	, 'size1'
	, 'maxsize1'
	, 'growth1'
	, 'usage1'
	, 'name2'
	, 'filename2'
	, 'filegroup2'
	, 'size2'
	, 'maxsize2'
	, 'growth2'
	, 'usage2'
	, @crdate	
	, CAST( databasePROPERTYEX( @databasename , 'SQLSortOrder') 			AS INT)
	, CAST( databasePROPERTYEX( @databasename , 'Collation') 			AS VARCHAR(128))
	, CAST( databasePROPERTYEX( @databasename , 'Version') 				AS VARCHAR(128))
	, CAST( databasePROPERTYEX( @databasename , 'IsAnsiNullDefault') 		AS BIT)
	, CAST( databasePROPERTYEX( @databasename , 'IsAnsiNullsEnabled') 		AS BIT)
	, CAST( databasePROPERTYEX( @databasename , 'IsAnsiPaddingEnabled') 		AS BIT)
	, CAST( databasePROPERTYEX( @databasename , 'IsAnsiWarningsEnabled') 		AS BIT)
	, CAST( databasePROPERTYEX( @databasename , 'IsArithmeticAbortEnabled') 	AS BIT)
	, CAST( databasePROPERTYEX( @databasename , 'IsAutoClose') 			AS BIT)
	, CAST( databasePROPERTYEX( @databasename , 'IsAutoCreateStatistics') 		AS BIT)
	, CAST( databasePROPERTYEX( @databasename , 'IsAutoShrink') 			AS BIT)
	, CAST( databasePROPERTYEX( @databasename , 'IsAutoUpdateStatistics') 		AS BIT)
	, CAST( databasePROPERTYEX( @databasename , 'IsCloseCursorsOnCommitEnabled') 	AS BIT)
	, CAST( databasePROPERTYEX( @databasename , 'IsFulltextEnabled') 		AS BIT)
	, CAST( databasePROPERTYEX( @databasename , 'IsInStandBy') 			AS BIT)
	, CAST( databasePROPERTYEX( @databasename , 'IsLocalCursorsDefault') 		AS BIT)
	, CAST( databasePROPERTYEX( @databasename , 'IsMergePublished') 		AS BIT)
	, CAST( databasePROPERTYEX( @databasename , 'IsNullConcat') 			AS BIT)
	, CAST( databasePROPERTYEX( @databasename , 'IsNumericRoundAbortEnabled') 	AS BIT)
	, CAST( databasePROPERTYEX( @databasename , 'IsPublished') 			AS BIT)
	, CAST( databasePROPERTYEX( @databasename , 'IsQuotedIdentifiersEnabled') 	AS BIT)
	, CAST( databasePROPERTYEX( @databasename , 'IsRecursiveTriggersEnabled') 	AS BIT)
	, CAST( databasePROPERTYEX( @databasename , 'IsSubscribed') 			AS BIT)
	, CAST( databasePROPERTYEX( @databasename , 'IsTornPageDetectionEnabled') 	AS BIT)

	SELECT @sql= 'UPDATE #TempTable set DBSize = (select str(convert(dec(15),sum(size))* ' + @low + 
			'/ 1048576,10,2)+ N'' MB'' from ' + quotename(@databasename, N'[') + 
			N'.dbo.sysfiles) WHERE dbid=' + cast(@dbid as VARCHAR(30))
	EXEC (@sql)

	SELECT @sql= 'UPDATE #TempTable set name1 = (select name from ' + quotename(@databasename, N'[') + 
			N'.dbo.sysfiles WHERE fileid=1) WHERE dbid=' + cast(@dbid as VARCHAR(30))
	EXEC (@sql)
	SELECT @sql= 'UPDATE #TempTable set name2 = (select name from ' + quotename(@databasename, N'[') + 
			N'.dbo.sysfiles WHERE fileid=2) WHERE dbid=' + cast(@dbid as VARCHAR(30))
	EXEC (@sql)

	SELECT @sql= 'UPDATE #TempTable set filename1 = (select filename from ' + quotename(@databasename, N'[') + 
			N'.dbo.sysfiles WHERE fileid=1) WHERE dbid=' + cast(@dbid as VARCHAR(30))
	EXEC (@sql)
	SELECT @sql= 'UPDATE #TempTable set filename2 = (select filename from ' + quotename(@databasename, N'[') + 
			N'.dbo.sysfiles WHERE fileid=2) WHERE dbid=' + cast(@dbid as VARCHAR(30))
	EXEC (@sql)

	SELECT @sql= 'UPDATE #TempTable set filegroup1 = (select filegroup_name(groupid) from ' + quotename(@databasename, N'[') + 
			N'.dbo.sysfiles WHERE fileid=1) WHERE dbid=' + cast(@dbid as VARCHAR(30))
	EXEC (@sql)
	SELECT @sql= 'UPDATE #TempTable set filegroup2 = (select filegroup_name(groupid) from ' + quotename(@databasename, N'[') + 
			N'.dbo.sysfiles WHERE fileid=2) WHERE dbid=' + cast(@dbid as VARCHAR(30))
	EXEC (@sql)

	SELECT @sql= 'UPDATE #TempTable set size1 = (select convert(nvarchar(15), size * 8) + N'' KB'' from ' + quotename(@databasename, N'[') + 
			N'.dbo.sysfiles WHERE fileid=1) WHERE dbid=' + cast(@dbid as VARCHAR(30))
	EXEC (@sql)
	SELECT @sql= 'UPDATE #TempTable set size2 = (select convert(nvarchar(15), size * 8) + N'' KB'' from ' + quotename(@databasename, N'[') + 
			N'.dbo.sysfiles WHERE fileid=2) WHERE dbid=' + cast(@dbid as VARCHAR(30))
	EXEC (@sql)

	SELECT @sql= 'UPDATE #TempTable set maxsize1 = (select (case maxsize when -1 then N''Unlimited'' else
			convert(nvarchar(15), maxsize * 8) + N'' KB'' end) from ' + quotename(@databasename, N'[') + 
			N'.dbo.sysfiles WHERE fileid=1) WHERE dbid=' + cast(@dbid as VARCHAR(30))
	EXEC (@sql)
	SELECT @sql= 'UPDATE #TempTable set maxsize2 = (select (case maxsize when -1 then N''Unlimited'' else
			convert(nvarchar(15), maxsize * 8) + N'' KB'' end) from ' + quotename(@databasename, N'[') + 
			N'.dbo.sysfiles WHERE fileid=2) WHERE dbid=' + cast(@dbid as VARCHAR(30))
	EXEC (@sql)

	SELECT @sql= 'UPDATE #TempTable set growth1 = (select (case status & 0x100000 when 0x100000 then
		convert(nvarchar(3), growth) + N''%'' else
		convert(nvarchar(15), growth * 8) + N'' KB'' end) from ' + quotename(@databasename, N'[') + 
			N'.dbo.sysfiles WHERE fileid=1) WHERE dbid=' + cast(@dbid as VARCHAR(30))
	EXEC (@sql)
	SELECT @sql= 'UPDATE #TempTable set growth2 = (select (case status & 0x100000 when 0x100000 then
		convert(nvarchar(3), growth) + N''%'' else
		convert(nvarchar(15), growth * 8) + N'' KB'' end) from ' + quotename(@databasename, N'[') + 
			N'.dbo.sysfiles WHERE fileid=2) WHERE dbid=' + cast(@dbid as VARCHAR(30))
	EXEC (@sql)

	SELECT @sql= 'UPDATE #TempTable set usage1 = (select (case status & 0x40 when 0x40 then ''log only'' else ''data only'' end) from ' + 
			quotename(@databasename, N'[') + N'.dbo.sysfiles WHERE fileid=1) WHERE dbid=' + 
			cast(@dbid as VARCHAR(30))
	EXEC (@sql)
	SELECT @sql= 'UPDATE #TempTable set usage2 = (select (case status & 0x40 when 0x40 then ''log only'' else ''data only'' end) from ' + 
			quotename(@databasename, N'[') + N'.dbo.sysfiles WHERE fileid=2) WHERE dbid=' + 
			cast(@dbid as VARCHAR(30))
	EXEC (@sql)

	SELECT @sql= 'UPDATE #TempTable set lastfullbackup = (select TOP 1 backup_finish_date from msdb..backupset where type = ''D'' and database_name =''' + 
		@databasename + ''' order by backup_finish_date desc) WHERE dbid=' + cast(@dbid as VARCHAR(30))
	EXEC (@sql)

	SELECT @sql= 'UPDATE #TempTable set lastdiffbackup = (select TOP 1 backup_finish_date from msdb..backupset where type = ''I'' and database_name =''' + 
		@databasename + ''' order by backup_finish_date desc) WHERE dbid=' + cast(@dbid as VARCHAR(30))
	EXEC (@sql)

	SELECT @sql= 'UPDATE #TempTable set lastlogbackup = (select TOP 1 backup_finish_date from msdb..backupset where type = ''L'' and database_name =''' + 
		@databasename + ''' order by backup_finish_date desc) WHERE dbid=' + cast(@dbid as VARCHAR(30))
	EXEC (@sql)

	IF @databasename NOT IN ('master','msdb','model')
		BEGIN
			SELECT @sql= 'UPDATE #TempTable set maintenanceplan = (select p.plan_name from msdb..sysdbmaintplans p, msdb..sysdbmaintplan_databases d where (d.database_name = ''All Databases'' or d.database_name = ''All User Databases'' or d.database_name = ''' + @databasename + ''') and (p.plan_id = d.plan_id)) WHERE dbid=' + cast(@dbid as VARCHAR(30))
			EXEC (@sql)
		END
	ELSE
	BEGIN
			SELECT @sql= 'UPDATE #TempTable set maintenanceplan = (select p.plan_name from msdb..sysdbmaintplans p, msdb..sysdbmaintplan_databases d where (d.database_name = ''All Databases'' or d.database_name = ''All System Databases'' or d.database_name = ''' + @databasename + ''') and (p.plan_id = d.plan_id)) WHERE dbid=' + cast(@dbid as VARCHAR(30))
			EXEC (@sql)
	END
	FETCH NEXT FROM dbname
	INTO @databasename,@dbid,@cmptlevel,@crdate,@owner
END
SELECT * FROM #TempTable ORDER BY DatabaseName
DROP TABLE #TempTable
CLOSE dbname
DEALLOCATE dbname
