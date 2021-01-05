select CAST(
			REPLACE(
				REPLACE(XEventData.XEvent.value('(data/value)[1]', 'varchar(max)'), 
				'<victim-list>', '<deadlock><victim-list>'),
			'<process-list>','</victim-list><process-list>')
		as xml) as DeadlockGraph
FROM
(select CAST(target_data as xml) as TargetData
from sys.dm_xe_session_targets st
join sys.dm_xe_sessions s on s.address = st.event_session_address
where name = 'system_health') AS Data
CROSS APPLY TargetData.nodes ('//RingBufferTarget/event') AS XEventData (XEvent)
where XEventData.XEvent.value('@name', 'varchar(4000)') = 'xml_deadlock_report'


select cast(XEventData.XEvent.value('(data/value)[1]', 'varchar(max)') as xml) as DeadlockGraph
FROM
(select CAST(target_data as xml) as TargetData
from sys.dm_xe_session_targets st
join sys.dm_xe_sessions s on s.address = st.event_session_address
where name = 'system_health') AS Data
CROSS APPLY TargetData.nodes ('//RingBufferTarget/event') AS XEventData (XEvent)
where XEventData.XEvent.value('@name', 'varchar(4000)') = 'xml_deadlock_report'


select XEventData.XEvent.value('(data/value)[1]', 'varchar(max)') as DeadlockGraph
FROM
(select CAST(target_data as xml) as TargetData
from sys.dm_xe_session_targets st
join sys.dm_xe_sessions s on s.address = st.event_session_address
where name = 'system_health') AS Data
CROSS APPLY TargetData.nodes ('//RingBufferTarget/event') AS XEventData (XEvent)
where XEventData.XEvent.value('@name', 'varchar(4000)') = 'xml_deadlock_report'


