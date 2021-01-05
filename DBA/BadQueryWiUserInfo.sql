select
    r.session_id,
    s.login_name,
    c.client_net_address,
    s.host_name,
    s.program_name,
    st.text
from sys.dm_exec_requests r
inner join sys.dm_exec_sessions s
on r.session_id = s.session_id
left join sys.dm_exec_connections c
on r.session_id = c.session_id
outer apply sys.dm_exec_sql_text(r.sql_handle) st
--where st.text like '%your query string to search for%';
WHERE st.text IS NOT NULL