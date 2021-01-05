Declare @FileName varChar(255)
Declare @cmdText varChar(255)
Declare @BKFolder varchar(255)
DECLARE @cmd NVARCHAR(500) 

set @FileName = null
set @cmdText = null
set @BKFolder = '\\VHYDPM01.hywd.ipzo.net\SQLBackups\CHYSQL1CL$SimsSqlHA3\Customers\FULL\'


create table #FileList (
FileName varchar(255),
DepthFlag int,
FileFlag int
)


--get all the files and folders in the backup folder and put them in temporary table
insert into #FileList exec xp_dirtree @BKFolder,0,1
--select * from #filelist

--get the latest backup file name
select top 1 @FileName = @BKFolder + FileName from #FileList where Filename like '%.bak' order by filename desc
--select @filename


--kick off current users/processes
ALTER DATABASE Test
SET SINGLE_USER WITH ROLLBACK IMMEDIATE;


--execute the restore
EXEC ('RESTORE DATABASE [Customers] FROM  DISK = ''' + @filename + ''' WITH REPLACE')
--SET @cmd = ('RESTORE DATABASE [Test] FROM  DISK = ''' + @filename + ''' WITH REPLACE')
--EXEC @CMD

--Let people/processes back in!
ALTER DATABASE Test
SET MULTI_USER WITH ROLLBACK IMMEDIATE;
--PRINT @cmd
DROP TABLE #FileList
go 