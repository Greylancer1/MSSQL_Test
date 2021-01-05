SELECT 
	percent_complete, 
	start_time, 
	status, 
	command, 
	CASE WHEN ((estimated_completion_time/1000)/3600) < 10 THEN '0' +
CONVERT(VARCHAR(10),(estimated_completion_time/1000)/3600)
ELSE CONVERT(VARCHAR(10),(estimated_completion_time/1000)/3600)
END + ':' + 
CASE WHEN ((estimated_completion_time/1000)%3600/60) < 10 THEN '0' +
CONVERT(VARCHAR(10),(estimated_completion_time/1000)%3600/60) 
ELSE CONVERT(VARCHAR(10),(estimated_completion_time/1000)%3600/60)
END  + ':' + 
CASE WHEN ((estimated_completion_time/1000)%60) < 10 THEN '0' +
CONVERT(VARCHAR(10),(estimated_completion_time/1000)%60)
ELSE CONVERT(VARCHAR(10),(estimated_completion_time/1000)%60)
END
AS [Time Remaining], 
	cpu_time, 
	total_elapsed_time
FROM 
	sys.dm_exec_requests
WHERE
	command = 'DbccFilesCompact'