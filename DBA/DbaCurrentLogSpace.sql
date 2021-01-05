CREATE TABLE #logspace (
   DBName varchar( 100),
   LogSize float,
   PrcntUsed float,
   status int
   )
INSERT INTO #logspace
   EXEC ('DBCC sqlperf( logspace)')
/*
process the data
*/
select * from #logspace
/*
Cleanup - drop the temp table
*/
drop table #logspace