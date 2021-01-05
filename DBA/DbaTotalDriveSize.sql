/******************************************************************
*
* 		SQL Server Disk Space Check
* 
* This script displays database and file size, compared to total
* and free disk space. It also displays the number of Kb that each
* file will grow by on the next extend.
*
* The script displays sizes in Mb and Kb, so there are sometimes
* small rounding errors in the result set.
*
* Required Permissions:
*	CREATE TABLE (in current db)
*	EXEC ON master.dbo.xp_fixeddrives
*	EXEC ON master.dbo.sp_databases
*	EXEC ON sp_executesql
*	EXEC ON sp_helpfile (in all db's)
*	EXEC ON master.dbo.sp_OACreate
*	EXEC ON master.dbo.sp_OAMethod
*	EXEC ON master.dbo.sp_OADestroy
*	SELECT ON master.dbo.sysaltfiles
*	SELECT ON master.dbo.sysdatabases
*	
******************************************************************/

BEGIN

	/*****************************************
	* Create temp tables for disk space info
	*****************************************/
	CREATE TABLE #space (dletter varchar(2), fspace int, tspace BIGINT)
	CREATE TABLE #dbsize (dbname varchar(50), dbsize int, remarks varchar(255))
	CREATE TABLE #fdata ([name] VARCHAR(255), [filename] VARCHAR(255), 
				[filegroup] VARCHAR(10), [size] VARCHAR(50),
				[maxsize] VARCHAR(50), growth VARCHAR(20), usage VARCHAR(20))
	CREATE TABLE #growth (dbname VARCHAR(50), fname VARCHAR(255), next_exp INT, gtype VARCHAR(2))

	/*****************************************
	* populate temp tables
	*****************************************/
	INSERT INTO #space (dletter, fspace) EXEC master.dbo.xp_fixeddrives
	INSERT INTO #dbsize EXEC master.dbo.sp_databases
	
	-- Create cursor for files
	DECLARE c_files CURSOR FOR
		SELECT RTRIM(af.fileid), RTRIM(af.[name]), RTRIM(af.[filename]), 
			RTRIM(af.[size]), RTRIM(db.[name])
		FROM master.dbo.sysaltfiles af, master.dbo.sysdatabases db
		WHERE af.dbid = db.dbid AND db.version <> 0
	DECLARE @tfileid INT, @tname VARCHAR(255), @tfilename VARCHAR(255)
	DECLARE @tsize INT, @tdbname VARCHAR(50)
	DECLARE @SQL NVARCHAR(255)
	DECLARE @growth VARCHAR(20), @next_exp INT, @gtype VARCHAR(2)

	-- Open cursor
	OPEN c_files
	FETCH NEXT FROM c_files
	INTO @tfileid, @tname, @tfilename, @tsize, @tdbname

	-- Populate #growth table with file growth details
	WHILE @@fetch_status = 0
	BEGIN
		TRUNCATE TABLE #fdata
		-- Get file data
		SET @SQL = 'INSERT INTO #fdata EXEC '
		SET @SQL = @SQL + @tdbname + '.dbo.sp_helpfile ''' + @tname + ''''
		EXEC sp_executesql @SQL
		SELECT @growth = growth FROM #fdata
		-- Determine if growth is % or Mbytes
		IF RIGHT(@growth,1) = '%'
		BEGIN
			SET @next_exp = CAST(LEFT(@growth, LEN(@growth) - 1) AS INT)
			SET @next_exp = CAST(ROUND(((CAST(@tsize AS FLOAT) * 8) / 100) * @next_exp,0) AS INT)
			SET @gtype = '%'
		END
		ELSE
		BEGIN
			SET @next_exp = CAST(LEFT(@growth, CHARINDEX(' ',@growth)) AS INT)
			SET @gtype = 'MB'
		END
		-- Create record for file in #growth table
		INSERT INTO #growth VALUES (@tdbname, @tname, @next_exp, @gtype)
		FETCH NEXT FROM c_files
		INTO @tfileid, @tname, @tfilename, @tsize, @tdbname
	END

	-- Close cursor
	CLOSE c_files
	DEALLOCATE c_files

	/*****************************************
	* Update temp table info with total disk sizes
	*****************************************/
	-- Create cursor for disk space table
	DECLARE c_disks CURSOR FOR
		SELECT dletter, fspace, tspace FROM #space
		FOR UPDATE
	DECLARE @dletter VARCHAR(2), @fspace INT, @tspace BIGINT

	-- Create FileSystemObject
	DECLARE @oFSO INT, @oDrive INT, @drsize VARCHAR(255), @ret INT
	EXEC @ret = master.dbo.sp_OACreate 'scripting.FileSystemObject', @oFSO OUT
	
	-- Open cursor and fetch first row
	OPEN c_disks
	FETCH NEXT FROM c_disks
	INTO @dletter, @fspace, @tspace

	-- Loop through all records in the cursor
	WHILE @@fetch_status = 0
	BEGIN
		-- Get disk size
		SET @dletter = @dletter + ':\'
		EXEC @ret = master.dbo.sp_OAMethod @oFSO, 'GetDrive', @oDrive OUT, @dletter
		EXEC @ret = master.dbo.sp_OAMethod @oDrive, 'TotalSize', @drsize OUT
		-- Update table
		UPDATE #space
		SET tspace = CAST(@drsize AS BIGINT)
		WHERE CURRENT OF c_disks
		-- Destory oDrive
		EXEC master.dbo.sp_OADestroy @oDrive
		-- Fetch next row
		FETCH NEXT FROM c_disks
		INTO @dletter, @fspace, @tspace
	END

	-- Close cursor
	CLOSE c_disks
	DEALLOCATE c_disks

	-- Destroy FSO
	EXEC master.dbo.sp_OADestroy @oFSO

	/*****************************************
	* Return disk space info
	*****************************************/
	SELECT db.[name] as [Database Name], 
		af.[name] as [File Name],
		CAST(ROUND(CAST(ds.dbsize AS FLOAT) / 1024,0) AS INT) as [Database Size (Mb)],  
		CAST(ROUND((CAST(af.[size] AS FLOAT) * 8) / 1024,0) AS INT) as [File Size (Mb)], 
		s.fspace as [Free Disk Space (Mb)], 
		CAST(ROUND((CAST(s.tspace AS FLOAT) / 1024) /1024,0) AS INT) as [Total Disk Space (Mb)],
		STR(g.next_exp) + ' KB' as [Next Extension],
		--CAST(ROUND(CAST(g.next_exp AS FLOAT) / 1024,0) AS INT) as [Next Expansion],
		af.[filename] as [File Path]
	FROM master.dbo.sysaltfiles af, #space s, #dbsize ds, 
		master.dbo.sysdatabases db, #growth g
	WHERE s.dletter = LEFT(af.[filename],1)
	AND af.dbid = db.dbid
	AND db.[name] = ds.dbname
	AND g.dbname = db.[name]
	AND g.fname = af.[name]
	ORDER BY db.[name], af.[name]

	/*****************************************
	* Drop temporary tables
	*****************************************/
	DROP TABLE #space
	DROP TABLE #dbsize
	DROP TABLE #fdata
	DROP TABLE #growth

END
