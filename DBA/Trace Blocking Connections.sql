if exists (select * from dbo.sysobjects where id = object_id(N'[dbo].[BlockedHosts]') and xtype in (N'FN', N'IF', N'TF'))
drop function [dbo].[BlockedHosts]
GO
--List all hosts that are involved in a block
--Either blocking, or being blocked
CREATE FUNCTION BlockedHosts ()
RETURNS TABLE
AS
RETURN
	SELECT
		s.SPID,
		Hostname = RTrim(Convert(varchar(256), Hostname)),
		Blocking = IsNull(b.spid, 0),
		[Blocked By] = s.blocked,
		WaitTime,
		Program = program_name,
		nt_username,
		loginame
	FROM
		master.dbo.sysprocesses s
		LEFT JOIN (
			SELECT DISTINCT blocked, spid
			FROM master.dbo.sysprocesses
			WHERE
				blocked > 0
				AND waittime >= 1000 -- time in ms
		) b ON b.blocked = s.spid
	WHERE
		b.blocked > 0
		OR (
			s.blocked > 0
			AND s.waittime >= 1000
		)
GO


--select * from BlockedHosts()
GO

if not exists (select * from dbo.sysobjects where id = object_id(N'[dbo].[BlockingLog]') and OBJECTPROPERTY(id, N'IsUserTable') = 1)
	SELECT BlockDate = GetDate(), * INTO BlockingLog FROM BlockedHosts() WHERE 1 = 0
GO

if exists (select * from dbo.sysobjects where id = object_id(N'[dbo].[BlockedTraceStart]') and OBJECTPROPERTY(id, N'IsProcedure') = 1)
drop procedure [dbo].[BlockedTraceStart]
GO
--Start a trace for a definite time period of hosts that are involved in a block
CREATE PROCEDURE [dbo].[BlockedTraceStart]
	@FileName nvarchar(256) = NULL,
	@StopTime datetime = NULL,
	@MaxFileSize bigint = 5 -- in Mb
AS

SET NOCOUNT ON

DECLARE
	@Result int,
	@TraceID int,
	@TraceTime datetime

SET @TraceTime = GetDate()
PRINT 'Trace Time: ' + Convert(varchar(23), @TraceTime)

IF NOT EXISTS (SELECT * FROM BlockedHosts()) BEGIN
	PRINT 'No hosts are blocking on server ' + convert(varchar(256), SERVERPROPERTY('ServerName')) + ', database ' + db_name() 
	RETURN 0
END

IF @FileName IS NULL
	SET @FileName = 'C:\BlockedTrace ' + convert(varchar(256), SERVERPROPERTY('ServerName')) + '-' + db_name() + ' ' + Replace(Replace(Convert(varchar(23), @TraceTime, 121), ':', ''), ' ', '-')

IF @StopTime IS NULL SET @StopTime = GetDate() + '00:05' -- Run for five minutes

-- Capture the currently blocked hosts in a log
INSERT BlockingLog
SELECT GetDate(), * FROM BlockedHosts()

-- Create the trace (in stopped mode)
EXEC @Result = sp_trace_create @TraceID OUTPUT, 0, @FileName, @MaxFileSize, @StopTime
IF @Result <> 0 BEGIN
	PRINT
		CASE @Result
			WHEN 1 THEN 'sp_trace_create Error 1 - Unknown error.'
			WHEN 10 THEN 'sp_trace_create Error 10 - Invalid options. Options specified are incompatible.'
			WHEN 12 THEN 'sp_trace_create Error 12 - File not created.'
			WHEN 13 THEN 'sp_trace_create Error 13 - Out of memory. There is not enough memory to perform the specified action.'
			WHEN 14 THEN 'sp_trace_create Error 14 - Invalid stop time. Stop time specified is in the past.' 
			WHEN 15 THEN 'sp_trace_create Error 15 - Invalid parameters. User supplied incompatible parameters.'
			ELSE 'sp_trace_create Unlisted Error ' + Convert(varchar(11), @Result)
		END
	GOTO Error
END

PRINT 'Trace File: ' + @FileName
PRINT 'TraceID: ' + convert(varchar(11), @TraceID)

-- Set the events
DECLARE @on bit
SET @on = 1
EXEC sp_trace_setevent @TraceID, 10, 1, @on
EXEC sp_trace_setevent @TraceID, 10, 6, @on
EXEC sp_trace_setevent @TraceID, 10, 8, @on
EXEC sp_trace_setevent @TraceID, 10, 9, @on
EXEC sp_trace_setevent @TraceID, 10, 10, @on
EXEC sp_trace_setevent @TraceID, 10, 11, @on
EXEC sp_trace_setevent @TraceID, 10, 12, @on
EXEC sp_trace_setevent @TraceID, 10, 13, @on
EXEC sp_trace_setevent @TraceID, 10, 14, @on
EXEC sp_trace_setevent @TraceID, 10, 16, @on
EXEC sp_trace_setevent @TraceID, 10, 17, @on
EXEC sp_trace_setevent @TraceID, 10, 18, @on
EXEC sp_trace_setevent @TraceID, 12, 1, @on
EXEC sp_trace_setevent @TraceID, 12, 6, @on
EXEC sp_trace_setevent @TraceID, 12, 8, @on
EXEC sp_trace_setevent @TraceID, 12, 9, @on
EXEC sp_trace_setevent @TraceID, 12, 10, @on
EXEC sp_trace_setevent @TraceID, 12, 11, @on
EXEC sp_trace_setevent @TraceID, 12, 12, @on
EXEC sp_trace_setevent @TraceID, 12, 13, @on
EXEC sp_trace_setevent @TraceID, 12, 14, @on
EXEC sp_trace_setevent @TraceID, 12, 16, @on
EXEC sp_trace_setevent @TraceID, 12, 17, @on
EXEC sp_trace_setevent @TraceID, 12, 18, @on
EXEC sp_trace_setevent @TraceID, 37, 1, @on
EXEC sp_trace_setevent @TraceID, 37, 6, @on
EXEC sp_trace_setevent @TraceID, 37, 8, @on
EXEC sp_trace_setevent @TraceID, 37, 9, @on
EXEC sp_trace_setevent @TraceID, 37, 10, @on
EXEC sp_trace_setevent @TraceID, 37, 11, @on
EXEC sp_trace_setevent @TraceID, 37, 12, @on
EXEC sp_trace_setevent @TraceID, 37, 13, @on
EXEC sp_trace_setevent @TraceID, 37, 14, @on
EXEC sp_trace_setevent @TraceID, 37, 16, @on
EXEC sp_trace_setevent @TraceID, 37, 17, @on
EXEC sp_trace_setevent @TraceID, 37, 18, @on
EXEC sp_trace_setevent @TraceID, 41, 1, @on
EXEC sp_trace_setevent @TraceID, 41, 6, @on
EXEC sp_trace_setevent @TraceID, 41, 8, @on
EXEC sp_trace_setevent @TraceID, 41, 9, @on
EXEC sp_trace_setevent @TraceID, 41, 10, @on
EXEC sp_trace_setevent @TraceID, 41, 11, @on
EXEC sp_trace_setevent @TraceID, 41, 12, @on
EXEC sp_trace_setevent @TraceID, 41, 13, @on
EXEC sp_trace_setevent @TraceID, 41, 14, @on
EXEC sp_trace_setevent @TraceID, 41, 16, @on
EXEC sp_trace_setevent @TraceID, 41, 17, @on
EXEC sp_trace_setevent @TraceID, 41, 18, @on
EXEC sp_trace_setevent @TraceID, 43, 1, @on
EXEC sp_trace_setevent @TraceID, 43, 6, @on
EXEC sp_trace_setevent @TraceID, 43, 8, @on
EXEC sp_trace_setevent @TraceID, 43, 9, @on
EXEC sp_trace_setevent @TraceID, 43, 10, @on
EXEC sp_trace_setevent @TraceID, 43, 11, @on
EXEC sp_trace_setevent @TraceID, 43, 12, @on
EXEC sp_trace_setevent @TraceID, 43, 13, @on
EXEC sp_trace_setevent @TraceID, 43, 14, @on
EXEC sp_trace_setevent @TraceID, 43, 16, @on
EXEC sp_trace_setevent @TraceID, 43, 17, @on
EXEC sp_trace_setevent @TraceID, 43, 18, @on
EXEC sp_trace_setevent @TraceID, 45, 1, @on
EXEC sp_trace_setevent @TraceID, 45, 6, @on
EXEC sp_trace_setevent @TraceID, 45, 8, @on
EXEC sp_trace_setevent @TraceID, 45, 9, @on
EXEC sp_trace_setevent @TraceID, 45, 10, @on
EXEC sp_trace_setevent @TraceID, 45, 11, @on
EXEC sp_trace_setevent @TraceID, 45, 12, @on
EXEC sp_trace_setevent @TraceID, 45, 13, @on
EXEC sp_trace_setevent @TraceID, 45, 14, @on
EXEC sp_trace_setevent @TraceID, 45, 16, @on
EXEC sp_trace_setevent @TraceID, 45, 17, @on
EXEC sp_trace_setevent @TraceID, 45, 18, @on
EXEC sp_trace_setevent @TraceID, 100, 1, @on
EXEC sp_trace_setevent @TraceID, 100, 6, @on
EXEC sp_trace_setevent @TraceID, 100, 8, @on
EXEC sp_trace_setevent @TraceID, 100, 9, @on
EXEC sp_trace_setevent @TraceID, 100, 10, @on
EXEC sp_trace_setevent @TraceID, 100, 11, @on
EXEC sp_trace_setevent @TraceID, 100, 12, @on
EXEC sp_trace_setevent @TraceID, 100, 13, @on
EXEC sp_trace_setevent @TraceID, 100, 14, @on
EXEC sp_trace_setevent @TraceID, 100, 16, @on
EXEC sp_trace_setevent @TraceID, 100, 17, @on
EXEC sp_trace_setevent @TraceID, 100, 18, @on

-- Set the filters:
-- Trace only the hosts involved in blocking
DECLARE
	@HostName nvarchar(128),
	@SPIDs varchar(8000)

SET @HostName = ''
PRINT 'Trace Hosts:'
WHILE @HostName IS NOT NULL BEGIN
	IF @HostName <> '' BEGIN
		EXEC sp_trace_setfilter @TraceID, 8, 1, 6, @HostName
		SET @SPIDs = NULL
		SELECT @SPIDs = IsNull(@SPIDs + ', ', '') + Convert(varchar(11), SPID) FROM BlockedHosts() WHERE Hostname = @HostName
		PRINT '   ' + @HostName + ', SPID' + CASE WHEN @SPIDs LIKE '%,%' THEN 's' ELSE '' END + ' ' + @SPIDs
	END
	SET @HostName = (SELECT TOP 1 Hostname FROM BlockedHosts() WHERE Hostname > @HostName ORDER BY Hostname)
END

EXEC sp_trace_setfilter @TraceID, 10, 0, 7, N'SQL Profiler'
EXEC sp_trace_setfilter @TraceID, 10, 0, 7, N'SQLAgent%'

-- Start the trace
EXEC sp_trace_setstatus @TraceID, 1

RETURN 1

Error:
RETURN 2
GO

if exists (select * from dbo.sysobjects where id = object_id(N'[dbo].[TraceView]') and OBJECTPROPERTY(id, N'IsProcedure') = 1)
drop procedure [dbo].[TraceView]
GO
--Display any currently running traces
--Provides better information than the system function by itself
CREATE PROCEDURE TraceView
AS
SELECT
	TraceID = traceid,
	Property = Descr,
	Value = 
		CASE property
		WHEN 1 THEN
			SubString(
				CASE WHEN Convert(int, value) = 0 THEN '  ' ELSE '' END
				+ CASE WHEN Convert(int, value) & 1 = 1 THEN ', TRACE_PRODUCE_ROWSET' ELSE '' END
				+ CASE WHEN Convert(int, value) & 2 = 2 THEN ', TRACE_FILE_ROLLOVER' ELSE '' END
				+ CASE WHEN Convert(int, value) & 4 = 4 THEN ', SHUTDOWN_ON_ERROR' ELSE '' END
				+ CASE WHEN Convert(int, value) & 8 = 8 THEN ', TRACE_PRODUCE_BLACKBOX' ELSE '' END
				, 3, 4000
			)
		WHEN 3 THEN Convert(varchar(11), value) + ' MB'
		WHEN 4 THEN Convert(varchar(23), value, 121) + ' ('
			+ Convert(varchar(11), DateDiff(n, GetDate(), Convert(datetime, value))) + ' m '
			+ Convert(varchar(11), DateDiff(ss, GetDate(), Convert(datetime, value)) % 60) + ' s remaining)'
		WHEN 5 THEN
			CASE WHEN Convert(int, value) = 0 THEN 'Stopped' ELSE 'Running' END
		ELSE Value
		END
FROM
	::fn_trace_getinfo(0) I
	INNER JOIN (
		SELECT P = 1, Descr = 'Trace Options'
		UNION SELECT 2, 'FileName'
		UNION SELECT 3, 'MaxSize'
		UNION SELECT 4, 'StopTime'
		UNION SELECT 5, 'Current Trace Status'
	) V ON I.property = V.P
GO

--view a saved trace file in a rowset
--SELECT * FROM ::fn_trace_gettable('C:\Trace IT170106-c 2006-06-16-111017.440.trc', -1)

--view blocking log
--SELECT * FROM BlockingLog

if exists (select * from dbo.sysobjects where id = object_id(N'[dbo].[TraceKill]') and OBJECTPROPERTY(id, N'IsProcedure') = 1)
drop procedure [dbo].[TraceKill]
GO
CREATE PROCEDURE TraceKill @TraceID int
AS
DECLARE @Result int
EXEC @Result = sp_trace_setstatus @TraceID, 0 -- stop trace (Trace still open and defined on server)
IF @Result = 0 AND @@Error = 0 EXEC @Result = sp_trace_setstatus @TraceID, 2 -- close trace and delete server definition
IF @Result <> 0 BEGIN
	PRINT
		CASE @Result
			WHEN 1 THEN 'sp_trace_setstatus Error 1 - Unknown error.'
			WHEN 8 THEN 'sp_trace_setstatus Error 8 - The specified Status is not valid.'
			WHEN 9 THEN 'sp_trace_setstatus Error 9 - The specified Trace Handle is not valid.'
			WHEN 13 THEN 'sp_trace_setstatus Error 13 - Out of memory. Not enough memory to perform the specified action.'
			ELSE 'sp_trace_setstatus Unlisted Error ' + Convert(varchar(11), @Result)
		END
END
GO