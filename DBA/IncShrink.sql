declare @from int                             
declare @leap int                             
declare @to int                             
declare @datafile varchar(128)
declare @cmd varchar (512)
/*settings*/                                                      
set @from = 300000                 /*Current size in MB*/
set @to = 250000                   /*Goal size in MB*/ 
set @datafile = 'MyDatabase_Data'  /*Datafile name*/
set @leap = 1000                   /*Size of leaps in MB*/
print '--- SATS SHRINK SCRIPT START ---'
while ((@from - @leap) > @to)                             
begin
set @from = @from - @leap
set @cmd = 'DBCC SHRINKFILE (' + @datafile +', ' + cast(@from as varchar(20)) + ')'
print @cmd
exec(@cmd)
print '==>    SATS SHRINK SCRIPT - '+ cast ((@from-@to) as  varchar (20)) + 'MB LEFT'                             end
set @cmd =  'DBCC SHRINKFILE (' + @datafile +', ' + cast(@to as varchar(20)) + ')'
print @cmd
exec(@cmd)
print '--- SATS SHRINK SCRIPT COMPLETE ---'
GO