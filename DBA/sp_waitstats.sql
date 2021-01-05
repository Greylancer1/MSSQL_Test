-- ***************************************************************************
-- Copyright (C) 1991-2003 SQLDEV.NET
-- 
-- file: sp_waitstats.sql
-- descr.: sp_waitstats
-- author: Gert E.R. Drapers (GertD@SQLDev.Net)
--
-- @@bof_revsion_marker
-- revision history
-- yyyy/mm/dd by      description
-- ========== ======= ========================================================
-- 2005/04/13 gertd   v1.0.0.6 rtw
-- 2004/11/15 gertd   v1.0.0.5 bug fix drop proc if statement, 
--							   precission increased, 
--							   added request avg (thanks again Michel)
-- 2004/10/28 gertd   v1.0.0.4 bug fix inserting wrong total time for signal wait (thanks Michel)
-- 2004/10/14 gertd   v1.0.0.3 added sort order selection
-- 2004/10/14 gertd   v1.0.0.2 added total, resource and signal time
-- 2003/07/29 gertd   v1.0.0.1 fixes
-- 2003/07/06 gertd   v1.0.0.0 created
-- @@eof_revsion_marker
-- ***************************************************************************
use master
go

if ((object_id('sp_waitstats') is not null) and (objectproperty(object_id('sp_waitstats'), 'IsProcedure') = 1))
	drop proc [dbo].[sp_waitstats]
go

create proc [dbo].[sp_waitstats] @orderby nvarchar(10) = N'total'
as

set nocount on

if (lower(@orderby) not in ('total', 'resource', 'signal'))
begin
	raiserror('Error: incorrect @orderby value, use ''total'', ''resource'', ''signal''', 10, 1) with nowait
	return
end

declare	@requests	bigint,
		@totalwait 	numeric(20, 5),
		@totalres	numeric(20, 5),
		@totalsig	numeric(20, 5),
		@endtime 	datetime,
		@begintime 	datetime

create table [#waitstats]
(
	[wait type] 		varchar(80) not null, 
	[requests] 			bigint not null,
	[wait time] 		numeric(20, 5) not null,
	[signal wait time] 	numeric(20, 5) not null,
	[now] 				datetime not null default getdate()
)

insert into [#waitstats]([wait type], [requests], [wait time], [signal wait time])      
	exec ('dbcc sqlperf(waitstats) with tableresults, no_infomsgs')

select  @begintime = min([now]),
		@endtime   = max([now])
from 	[#waitstats] 
where 	[wait type] = 'Total'

--- subtract waitfor, sleep, and resource_queue from Total
select 	@requests  = sum([requests]),
		@totalwait = sum([wait time]),
		@totalres  = sum(([wait time] - [signal wait time])),
		@totalsig  = sum([signal wait time]) 
from 	[#waitstats] 
where 	[wait type] not in ('WAITFOR','SLEEP','RESOURCE_QUEUE', 'Total', '***total***') 
and 	[now] = @endtime

-- insert adjusted totals, rank by percentage descending
delete 	[#waitstats] 
where 	[wait type] = '***total***' 
and 	[now] = @endtime

insert into #waitstats values('***total***', @requests, @totalwait, @totalsig, @endtime)

if (@orderby = N'total')
begin

	select 	[requests],
			[wait type],
			[total wait time] 		= [wait time],
			[resource wait time] 	= [wait time] - [signal wait time],
			[signal wait time],
			[%total wait time]  	= case @totalwait when 0 then 0 else cast(100 * [wait time] / @totalwait as numeric(20, 5)) end,
			[%resource wait time] 	= case @totalres  when 0 then 0 else cast(100 * ([wait time] - [signal wait time]) / @totalres as numeric(20, 5)) end,
			[%signal wait time] 	= case @totalsig  when 0 then 0 else cast(100 * [signal wait time] / @totalsig as numeric(20, 5)) end,
			[avg total wait time]   = case [requests] when 0 then 0 else cast(100 * @totalwait / [requests] as numeric(20, 5)) end,
			[avg resource wait time]= case [requests] when 0 then 0 else cast(100 * @totalres  / [requests] as numeric(20, 5)) end,
			[avg signal wait time] 	= case [requests] when 0 then 0 else cast(100 * @totalsig  / [requests] as numeric(20, 5)) end
	from 	[#waitstats]
	where 	[wait type] not in ('WAITFOR','SLEEP','RESOURCE_QUEUE', 'Total')
	and 	[now] = @endtime
	order by [%total wait time] desc

end

if (@orderby = N'resource')
begin

	select 	[requests],
			[wait type],
			[total wait time] 		= [wait time],
			[resource wait time] 	= [wait time] - [signal wait time],
			[signal wait time],
			[%total wait time]  	= case @totalwait when 0 then 0 else cast(100 * [wait time] / @totalwait as numeric(20, 5)) end,
			[%resource wait time] 	= case @totalres  when 0 then 0 else cast(100 * ([wait time] - [signal wait time]) / @totalres as numeric(20, 5)) end,
			[%signal wait time] 	= case @totalsig  when 0 then 0 else cast(100 * [signal wait time] / @totalsig as numeric(20, 5)) end,
			[avg total wait time]   = case [requests] when 0 then 0 else cast(100 * @totalwait / [requests] as numeric(20, 5)) end,
			[avg resource wait time]= case [requests] when 0 then 0 else cast(100 * @totalres  / [requests] as numeric(20, 5)) end,
			[avg signal wait time] 	= case [requests] when 0 then 0 else cast(100 * @totalsig  / [requests] as numeric(20, 5)) end
	from 	[#waitstats]
	where 	[wait type] not in ('WAITFOR','SLEEP','RESOURCE_QUEUE', 'Total')
	and 	[now] = @endtime
	order by [%resource wait time] desc

end

if (@orderby = N'signal')
begin

	select 	[requests],
			[wait type],
			[total wait time] 		= [wait time],
			[resource wait time] 	= [wait time] - [signal wait time],
			[signal wait time],
			[%total wait time]  	= case @totalwait when 0 then 0 else cast(100 * [wait time] / @totalwait as numeric(20, 5)) end,
			[%resource wait time] 	= case @totalres  when 0 then 0 else cast(100 * ([wait time] - [signal wait time]) / @totalres as numeric(20, 5)) end,
			[%signal wait time] 	= case @totalsig  when 0 then 0 else cast(100 * [signal wait time] / @totalsig as numeric(20, 5)) end,
			[avg total wait time]   = case [requests] when 0 then 0 else cast(100 * @totalwait / [requests] as numeric(20, 5)) end,
			[avg resource wait time]= case [requests] when 0 then 0 else cast(100 * @totalres  / [requests] as numeric(20, 5)) end,
			[avg signal wait time] 	= case [requests] when 0 then 0 else cast(100 * @totalsig  / [requests] as numeric(20, 5)) end
	from 	[#waitstats]
	where 	[wait type] not in ('WAITFOR','SLEEP','RESOURCE_QUEUE', 'Total')
	and 	[now] = @endtime
	order by [%signal wait time] desc

end

drop table [#waitstats]
go

exec sp_waitstats
exec sp_waitstats @orderby = 'total'
exec sp_waitstats @orderby = 'resource'
exec sp_waitstats @orderby = 'signal'
go
