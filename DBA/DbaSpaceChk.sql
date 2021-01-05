if object_Id('dbaSpaceDist') Is Not Null
 drop table dbaSpaceDist
go

CREATE TABLE dbaSpaceDist
 (	LNm 	char( 40),
	Tot	numeric( 10, 4),
	Used	numeric( 10, 4),
	Prcnt	numeric( 10, 4),
	DB		char( 40),
	Typ   char( 5),
	EntryDt datetime
 )
GO
grant select, insert, update, delete on dbaSpaceDist to WebUser
go

if object_id( 'dbaSpaceDist') Is Null
 select ' dbaSpaceDist Not Created'
else
 select ' dbaSpaceDist Created'
go

if object_Id( 'dbspCalcdbaSpaceDist') Is Not Null
 drop procedure dbspCalcdbaSpaceDist
go

CREATE procedure dbspCalcdbaSpaceDist
	@days int = -90
as
/*
*************************************************************
Name: dbspCalcdbaSpaceDist
Description:
   Gather the data and log space for all databases on the system
and insert the information into DBASpaceDist. The following databases
are not added to DBASpaceDist:
	pubs
	Northwind
	model
	tempdb

Usage:exec dbspCalcdbaSpaceDist -90

Author: Steve Jones

Input Params:
-------------
@days 	int. Number of days to keep in DBASpaceDist. defaults to 
			-90 days (1 quarter).
	
Output Params:
--------------

Return:

Results:
---------

Locals:
--------
@err		Holds error value

Modifications:
--------------

*************************************************************
*/
set nocount on
declare @err int

select @err = 0

/*
Create the temp tables to hold the results of DBCC
commands until the information is entered into
DBASpaceDist.
*/
CREATE TABLE #logspace (
   DBName varchar( 100),
   LogSize float,
   PrcntUsed float,
   status int
   )

CREATE TABLE #dataspace
 (	FileID 	int,
	FileGrp 	int,
	TotExt	int,
	UsdExt 	int,
   LFileNm	varchar( 100),
   PFileNm	varchar( 100)
   )

/*
Get the log space
*/
INSERT INTO #logspace
   EXEC ('dbcc sqlperf( logspace)')

insert dbaSpaceDist
 select 	dbname, 
			logsize, 
			(logsize * (PrcntUsed/100)), 
			(1 - ( PrcntUsed/ 100))*100, 
			dbname,
			'Log',
			getdate()
  from #logspace
  where dbname not in 
	(	'model',
		'tempdb',
		'pubs',
		'Northwind'
	)

/*
Get the data space
Use a cursor to loop through the results from DBCC
since you have to run this command from each database
with a USE command.
*/
declare @db char( 40), @cmd char( 500)
declare dbname cursor
 for select DBName from #logspace

open dbname
fetch next from dbname into @db
while @@fetch_status = 0
 begin
  select @cmd = 'use ' + rtrim( @db) + ' dbcc showfilestats'
  insert #dataspace
   exec( @cmd)
  if @db not in 
		(	'model',
			'tempdb',
			'pubs',
			'Northwind'
		)
  insert dbaSpaceDist
  select substring( lFileNM, 1, 20),
			((cast( TotExt as numeric( 10, 4))* 32) / 512),
			((cast( UsdExt as numeric( 10, 4))* 32) / 512),
			((cast( TotExt - UsdExt as numeric( 10, 4))* 32) / 512),
			@db,
			'Data',
			getdate()
   from #dataspace
  fetch next from dbname into @db
  delete #dataspace
 end
deallocate dbname

/*
Drop the temporary tables
*/
drop table #logspace
drop table #dataspace

/*
Remove old information from the DBASpaceDist table.
*/
delete DBASpaceDist
 where entrydt < dateadd( day, @days, getdate())

return @err
GO
grant execute on dbspCalcdbaSpaceDist to WebUser
go
if object_id( 'dbspCalcdbaSpaceDist') Is Null
 select 'dbspCalcdbaSpaceDist Not Created'
else
 select 'dbspCalcdbaSpaceDist Created'
go

