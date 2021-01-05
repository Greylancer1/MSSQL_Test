IF OBJECT_ID('tJobReport') IS NOT NULL
DROP TABLE tJobReport
GO

CREATE TABLE tJobReport
(
lngID INTEGER IDENTITY(1,1)
,server VARCHAR(50)
,jobname VARCHAR(100)
,status VARCHAR(50)
,rundate VARCHAR(50)
,runtime VARCHAR(50)
,runduration VARCHAR(50)
)
GO

CREATE CLUSTERED INDEX tJobReport_clustered 
ON tJobReport(server,jobname,rundate,runtime)
GO

INSERT INTO tJobReport (server, jobname, status, rundate, runtime, runduration)
SELECT sj.originating_server, sj.name,

--What is it in English
CASE sh.run_status
	WHEN 0 THEN 'Failed'
	WHEN 1 THEN 'Succeeded'
	WHEN 2 THEN 'Retry'
	WHEN 3 THEN 'Canceled'
	ELSE 'Unknown'
END, 

--Convert Integer date to regular datetime
SUBSTRING(CAST(sh.run_date AS CHAR(8)),5,2) + '/' + 
RIGHT(CAST(sh.run_date AS CHAR(8)),2) + '/' + 
LEFT(CAST(sh.run_date AS CHAR(8)),4)

--Change run time into something you can recognize (hh:mm:ss)
, LEFT(RIGHT('000000' + CAST(run_time AS VARCHAR(10)),6),2) + ':' + 
 SUBSTRING(RIGHT('000000' + CAST(run_time AS VARCHAR(10)),6),3,2) + ':' + 
 RIGHT(RIGHT('000000' + CAST(run_time AS VARCHAR(10)),6),2)

--Change run duration into something you can recognize (hh:mm:ss)
, LEFT(RIGHT('000000' + CAST(run_duration AS VARCHAR(10)),6),2) + ':' + 
 SUBSTRING(RIGHT('000000' + CAST(run_duration AS VARCHAR(10)),6),3,2) + ':' + 
 RIGHT(RIGHT('000000' + CAST(run_duration AS VARCHAR(10)),6),2)
FROM      OPENDATASOURCE(
         'SQLOLEDB',
         'Data Source=MSSQL1;User ID=sa;Password=moap842'
         ).msdb.dbo.sysjobs sj

INNER JOIN OPENDATASOURCE(
         'SQLOLEDB',
         'Data Source=MSSQL1;User ID=sa;Password=moap842'
         ).msdb.dbo.sysjobhistory sh
ON sj.job_id = sh.job_id

--Join for new history rows
left JOIN DBA.dbo.tJobReport jr
ON sj.originating_server = jr.server
AND sj.name = jr.jobname
AND SUBSTRING(CAST(sh.run_date AS CHAR(8)),5,2) + '/' + 
RIGHT(CAST(sh.run_date AS CHAR(8)),2) + '/' + 
LEFT(CAST(sh.run_date AS CHAR(8)),4) = jr.rundate
AND LEFT(RIGHT('000000' + CAST(run_time AS VARCHAR(10)),6),2) + ':' + 
 SUBSTRING(RIGHT('000000' + CAST(run_time AS VARCHAR(10)),6),3,2) + ':' + 
 RIGHT(RIGHT('000000' + CAST(run_time AS VARCHAR(10)),6),2) = jr.runtime

--Only enabled jobs
WHERE sj.enabled = 1
--Only job outcome not each step outcome
AND sh.step_id = 0
--Only completed jobs
AND sh.run_status <> 4
--Only new data
AND jr.lngID IS NULL

--Latest date first
ORDER BY sh.run_date DESC


SELECT * FROM tJobReport
