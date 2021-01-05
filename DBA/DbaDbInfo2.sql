Create table #mydbs (dbname char( 50), size char( 50), dbowner char( 50), 
dbid int, crdate datetime, status varchar( 255), CompatLevel int)

	Insert #mydbs  Exec sp_helpdb

	Select * from #mydbs
	/*
	*/
	Drop table #mydbs