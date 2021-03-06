/******************************************************
Script: looks at the backup directory and restores the
    most recent backup (bak) file 
    You will have to modify the code
    to match your database names and paths.
    DO NOT USE IN PRODUCTION.  It kicks all users off!

Created By:
    Michael F. Berry
Create Date:
    1/15/2014
******************************************************/


--get the last backup file name and path

Declare @FileName varChar(255)
Declare @cmdText varChar(255)
Declare @BKFolder varchar(255)
DECLARE @cmd NVARCHAR(500) 

set @FileName = null
set @cmdText = null
set @BKFolder = '\\VHYDPM01.hywd.ipzo.net\SQLBackups\CHYSQL1CL$SimsSqlHA1\aaData_CA\FULL\'


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
--ALTER DATABASE DBName
--SET SINGLE_USER WITH ROLLBACK IMMEDIATE;


--execute the restore
SET @cmd = ('RESTORE DATABASE [aaData_CA] FROM  DISK = ''' + @filename + ''' WITH  REPLACE')
--EXEC @CMD

--Let people/processes back in!
--ALTER DATABASE DBName
--SET MULTI_USER WITH ROLLBACK IMMEDIATE;
PRINT @cmd
DROP TABLE #FileList
go 