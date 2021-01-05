SELECT SPID, lastwaittype, dbid, uid, cpu, physical_io, memusage, status, loginame, program_name
FROM master..sysprocesses
ORDER BY cpu desc
