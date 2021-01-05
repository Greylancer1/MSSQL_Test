SET NOCOUNT ON

DECLARE @Result Table (
	[DBName] Varchar(100),
	[size] int,
	Log_Size float,
	Log_Space float
)
DECLARE @DBName Varchar(100)
DECLARE @SIZE int

declare @RECCNT varchar(500)
declare @DeviceName varchar(500)
declare @CMD Nvarchar(500)

DECLARE tmpcursor CURSOR FOR select DBName from @Result

INSERT INTO @Result (DBName)
Select [name] from sysdatabases where [status] <> 536

IF EXISTS (Select [name] from sysobjects where xtype = 'u' and [name] = '#temp_table')
	DROP TABLE #temp_table

create table #temp_table (
	Database_Name varchar(100),
	Log_Size float,
	Log_Space float,
	Status varchar(100)
)
insert into #temp_table
EXEC ('DBCC sqlperf(LOGSPACE) WITH NO_INFOMSGS')

declare @temp_table table (
	Database_Name varchar(100),
	Log_Size float,
	Log_Space float,
	Status varchar(100)
)
insert into @temp_table
select * from #temp_table

drop table #temp_table

OPEN tmpcursor

FETCH NEXT FROM tmpcursor INTO @DBName
WHILE (@@fetch_status <> -1)
BEGIN
	IF (@@fetch_status <> -2)
	BEGIN
		SET @CMD = N'use ' +  quotename(@DBName) + N' SELECT @SIZE=(SUM([size]) * 8) from sysfiles'-- where [name] = @RECCNT'
		exec sp_executesql @CMD,
                   N'@DeviceName varchar(100) out, @SIZE int out, @RECCNT varchar(100)', 
                   @DBName,
		   @SIZE out,
		   @RECCNT
		update @Result
		set [size] = LTRIM(RTRIM(@SIZE))
		where DBName = @DBName
		update @Result set Log_Size = (Select Log_Size from @temp_table where Database_Name = @DBName) where DBName = @DBName
		update @Result set Log_Space = (Select Log_Space from @temp_table where Database_Name = @DBName) where DBName = @DBName
	END
	FETCH NEXT FROM tmpcursor INTO @DBName
END
select DBName, CONVERT(char,CAST([size] as money),1) as 'size', CONVERT(char,CAST([Log_Size] as money),1), CONVERT(char,CAST([Log_Space] as money),1)  as 'Log Space Used (%)' from @Result
order by size DESC

CLOSE tmpcursor
DEALLOCATE tmpcursor

SET NOCOUNT OFF
GO

