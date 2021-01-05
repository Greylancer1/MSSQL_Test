/*capture diferences in CPU utilization
per process. Show which process are using
the most CPU*/

DROP TABLE cpu_usage
GO
SELECT cpu, spid 
INTO cpu_usage
FROM sysprocesses
SELECT difference = p.cpu-u.cpu,
p.cpu,
p.program_name,
p.loginame,
p.spid,
p.hostname,
p.last_batch
FROM sysprocesses p
INNER JOIN cpu_usage u
ON p.spid = u.spid
ORDER BY 1 DESC