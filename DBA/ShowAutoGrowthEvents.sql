select
    te.name as event_name,
    tr.DatabaseName,
    tr.FileName,
    tr.IntegerData,
    tr.IntegerData2,
    tr.LoginName,
    tr.StartTime,
    tr.EndTime
--select * 
from 
sys.fn_trace_gettable(convert(nvarchar(255),(select value from sys.fn_trace_getinfo(0) where property=2)), 0) tr
inner join sys.trace_events te on tr.EventClass = te.trace_event_id
where 
tr.EventClass in (93, 95) --can't identify any other EventClass to add here
order by 
EndTime desc;