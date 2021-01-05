declare @thisTrace int = 2
exec dba.dbo.CreateCustom @name = 'aaDataCA'                       -- Name of the trace and trace filename
exec dba.dbo.AddEvent @traceid = @thisTrace, @eventid = 41 -- SQL:StmtCompleted
exec dba.dbo.AddEvent @traceid = @thisTrace, @eventid = 12 -- SQL:BatchCompleted
exec dba.dbo.AddEvent @traceid = @thisTrace, @eventid = 13 -- SQL:BatchStarting
exec dba.dbo.AddEvent @traceid = @thisTrace, @eventid = 42 -- SP:StoredProcedureStarting
exec dba.dbo.AddEvent @traceid = @thisTrace, @eventid = 43 -- SP:StoredProcedureCompleted
exec dba.dbo.AddEvent @traceid = @thisTrace, @eventid = 45 -- SP:StmtCompleted
exec dba.dbo.AddEvent @traceid = @thisTrace, @eventid = 27 -- Lock:Timeout
exec dba.dbo.filterDatabase @thisTrace,'aaData_CA'           -- fileter by database name 
--exec dba.dbo.IncludeServer 2,'VHYSERVICE16'
--exec dba.dbo.filterTable 2,'Contacts'
--exec dba.dbo.filterText 2,'NOT LIKE','INSERT'
--exec dba.dbo.filterColumn 2, 13, '>', '10'            
--exec dba.dbo.excludeServer 2,'VHYSERVICE12'
exec dba.dbo.control @thisTrace, 'start'



exec dba.dbo.control 2, 'stop'
exec dba.dbo.control 2, 'delete'




USE [ipzTech]
GO

/****** Object:  StoredProcedure [trace].[IncludeServer]    Script Date: 2/24/2017 8:42:59 AM ******/
SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO


-- =============================================
-- Author:		<Author,,Name>
-- Create date: <Create Date,,>
-- Description:	<Description,,>
-- =============================================
CREATE PROCEDURE [trace].[IncludeServer]
	@TraceID int,
	@serverName nvarchar(256)
AS
BEGIN
	-- SET NOCOUNT ON added to prevent extra result sets from
	-- interfering with SELECT statements.
	SET NOCOUNT ON;
		
	exec sp_trace_setfilter 
		@TraceID
		,@columnid = 8 -- host name
		,@logical_operator = 0		-- 0 = AND, 1 = OR
		,@comparison_operator = 0	-- 0 is =, 1 is <>, 2 is >, 3 is <, 4 is >=, 5 is <=, 6 is LIKE, 7 is NOT LIKE
		,@value = @serverName
END


GO

USE [ipzTech]
GO

/****** Object:  StoredProcedure [trace].[FilterText]    Script Date: 2/24/2017 8:42:56 AM ******/
SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO

-- =============================================
-- Author:		<Author,,Name>
-- Create date: <Create Date,,>
-- Description:	<Description,,>
-- =============================================
CREATE PROCEDURE [trace].[FilterText]
	@TraceID int,
	@op varchar(50),
	@operand nvarchar(256)
AS
BEGIN
	-- SET NOCOUNT ON added to prevent extra result sets from
	-- interfering with SELECT statements.
	SET NOCOUNT ON;

	DECLARE @operator int

	set @operator = CASE @op
		WHEN '=' THEN 0
		WHEN '<>' THEN 1
		WHEN '>' THEN 2
		WHEN '<' THEN 3
		WHEN '>=' THEN 4
		WHEN '<=' THEN 5
		WHEN 'LIKE' THEN 6
		WHEN 'NOT LIKE' THEN 7
	END 

	if ( @operator = 6 OR @operator = 7 )
		SET @operand = N'%' + @operand + N'%'

	exec sp_trace_setfilter 
		@TraceID
		,@columnid = 1
		,@logical_operator = 0		-- 0 = AND, 1 = OR
		,@comparison_operator = @operator	-- 0 is =, 1 is <>, 2 is >, 3 is <, 4 is >=, 5 is <=, 6 is LIKE, 7 is NOT LIKE
		,@value = @operand
END

GO


USE [ipzTech]
GO

/****** Object:  StoredProcedure [trace].[FilterTable]    Script Date: 2/24/2017 8:42:52 AM ******/
SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO

-- =============================================
-- Author:		<Author,,Name>
-- Create date: <Create Date,,>
-- Description:	<Description,,>
-- =============================================
CREATE PROCEDURE [trace].[FilterTable]
	@TraceID int,
	@tableName nvarchar(256)
AS
BEGIN
	-- SET NOCOUNT ON added to prevent extra result sets from
	-- interfering with SELECT statements.
	SET NOCOUNT ON;

	SET @tableName = N'%' + @tableName + N'%'
	
	exec sp_trace_setfilter 
		@TraceID
		,@columnid = 1
		,@logical_operator = 0		-- 0 = AND, 1 = OR
		,@comparison_operator = 6	-- 0 is =, 1 is <>, 2 is >, 3 is <, 4 is >=, 5 is <=, 6 is LIKE, 7 is NOT LIKE
		,@value = @tableName
END

GO


USE [ipzTech]
GO

/****** Object:  StoredProcedure [trace].[FilterDatabase]    Script Date: 2/24/2017 8:42:49 AM ******/
SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO

-- =============================================
-- Author:		<Author,,Name>
-- Create date: <Create Date,,>
-- Description:	<Description,,>
-- =============================================
CREATE PROCEDURE [trace].[FilterDatabase]
	@TraceID int,
	@dbName nvarchar(256)
AS
BEGIN
	-- SET NOCOUNT ON added to prevent extra result sets from
	-- interfering with SELECT statements.
	SET NOCOUNT ON;
	
	exec sp_trace_setfilter 
		@TraceID
		,@columnid = 35
		,@logical_operator = 0		-- 0 = AND, 1 = OR
		,@comparison_operator = 0	-- 0 is =, 1 is <>, 2 is >, 3 is <, 4 is >=, 5 is <=, 6 is LIKE, 7 is NOT LIKE
		,@value = @dbName
END

GO


USE [ipzTech]
GO

/****** Object:  StoredProcedure [trace].[FilterColumn]    Script Date: 2/24/2017 8:42:45 AM ******/
SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO

-- =============================================
-- Author:		<Author,,Name>
-- Create date: <Create Date,,>
-- Description:	<Description,,>
-- =============================================
CREATE PROCEDURE [trace].[FilterColumn]
	@TraceID int,
	@columnNumber int,
	@op varchar(50),
	@operand nvarchar(256)
AS
BEGIN
	-- SET NOCOUNT ON added to prevent extra result sets from
	-- interfering with SELECT statements.
	SET NOCOUNT ON;

	DECLARE @operator int

	set @operator = CASE @op
		WHEN '=' THEN 0
		WHEN '<>' THEN 1
		WHEN '>' THEN 2
		WHEN '<' THEN 3
		WHEN '>=' THEN 4
		WHEN '<=' THEN 5
		WHEN 'LIKE' THEN 6
		WHEN 'NOT LIKE' THEN 7
	END 

	if ( @operator = 6 OR @operator = 7 )
		SET @operand = N'%' + @operand + N'%'
		
	if ( EXISTS( SELECT 1 FROM sys.trace_columns WHERE trace_column_id = @columnNumber and type_name like '%int') )
	BEGIN
		DECLARE @intOperand as bigint = @operand

		exec sp_trace_setfilter 
			@TraceID
			,@columnid = @columnNumber
			,@logical_operator = 0		-- 0 = AND, 1 = OR
			,@comparison_operator = @operator	-- 0 is =, 1 is <>, 2 is >, 3 is <, 4 is >=, 5 is <=, 6 is LIKE, 7 is NOT LIKE
			,@value = @intOperand
	END
	ELSE
	BEGIN		
		exec sp_trace_setfilter 
			@TraceID
			,@columnid = @columnNumber
			,@logical_operator = 0		-- 0 = AND, 1 = OR
			,@comparison_operator = @operator	-- 0 is =, 1 is <>, 2 is >, 3 is <, 4 is >=, 5 is <=, 6 is LIKE, 7 is NOT LIKE
			,@value = @operand
	END
END

GO


USE [ipzTech]
GO

/****** Object:  StoredProcedure [trace].[ExcludeServer]    Script Date: 2/24/2017 8:42:41 AM ******/
SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO

-- =============================================
-- Author:		<Author,,Name>
-- Create date: <Create Date,,>
-- Description:	<Description,,>
-- =============================================
CREATE PROCEDURE [trace].[ExcludeServer]
	@TraceID int,
	@serverName nvarchar(256)
AS
BEGIN
	-- SET NOCOUNT ON added to prevent extra result sets from
	-- interfering with SELECT statements.
	SET NOCOUNT ON;
		
	exec sp_trace_setfilter 
		@TraceID
		,@columnid = 8 -- host name
		,@logical_operator = 0		-- 0 = AND, 1 = OR
		,@comparison_operator = 1	-- 0 is =, 1 is <>, 2 is >, 3 is <, 4 is >=, 5 is <=, 6 is LIKE, 7 is NOT LIKE
		,@value = @serverName
END

GO


USE [ipzTech]
GO

/****** Object:  StoredProcedure [trace].[CreateCustom]    Script Date: 2/24/2017 8:42:38 AM ******/
SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO

-- =============================================
-- Author:		<Author,,Name>
-- Create date: <Create Date,,>
-- Description:	<Description,,>
-- =============================================
CREATE PROCEDURE [trace].[CreateCustom]
	@name as nvarchar(256)
AS
BEGIN
	-- SET NOCOUNT ON added to prevent extra result sets from
	-- interfering with SELECT statements.
	SET NOCOUNT ON;

	declare @TraceID int
	declare @filesize as bigint = 200

	set @name = 'T:\Trace\' + @name

	exec  master..sp_trace_create 
		@TraceID output, 
		@options = 2, 
		@tracefile = @name, 
		@maxfilesize = @filesize, 
		@stoptime = null,
		@filecount = 50				-- @filecount

	SELECT @TraceID as TraceID

END

GO


USE [ipzTech]
GO

/****** Object:  StoredProcedure [trace].[Control]    Script Date: 2/24/2017 8:42:34 AM ******/
SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO

-- =============================================
-- Author:		<Author,,Name>
-- Create date: <Create Date,,>
-- Description:	<Description,,>
-- =============================================
CREATE PROCEDURE [trace].[Control]
	@TraceID int,
	@action varchar(10)
AS
BEGIN
	-- SET NOCOUNT ON added to prevent extra result sets from
	-- interfering with SELECT statements.
	SET NOCOUNT ON;
	if ( @action = 'start' )
		exec sp_trace_setstatus  @traceid =  @TraceID,  @status =  1	

	if ( @action = 'stop' )
		exec sp_trace_setstatus  @traceid =  @TraceID,  @status =  0

	if ( @action = 'delete' )
		exec sp_trace_setstatus  @traceid =  @TraceID,  @status =  2	

END

GO


USE [ipzTech]
GO

/****** Object:  StoredProcedure [trace].[AddEvent]    Script Date: 2/24/2017 8:42:30 AM ******/
SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO

-- =============================================
-- Author:		<Author,,Name>
-- Create date: <Create Date,,>
-- Description:	<Description,,>
-- =============================================
CREATE PROCEDURE [trace].[AddEvent]
	@TraceID int,
	@eventid int
AS
BEGIN
	-- SET NOCOUNT ON added to prevent extra result sets from
	-- interfering with SELECT statements.
	SET NOCOUNT ON;

Declare @onBit bit = 1

exec sp_trace_setevent
	@TraceID
	, @eventid
	, @columnid =  35	-- database name
	, @on = @onBit

exec sp_trace_setevent
	@TraceID
	, @eventid
	, @columnid =  8	-- hostname
	, @on = @onBit

exec sp_trace_setevent
	@TraceID
	, @eventid
	, @columnid =  14	-- start time
	, @on = @onBit

exec sp_trace_setevent
	@TraceID
	, @eventid
	, @columnid =  13	-- duration
	, @on = @onBit

exec sp_trace_setevent
	@TraceID
	, @eventid
	, @columnid =  1	-- textdata
	, @on = @onBit

exec sp_trace_setevent
	@TraceID
	, @eventid
	, @columnid =  10	-- Appplication Name
	, @on = @onBit

exec sp_trace_setevent
	@TraceID
	, @eventid
	, @columnid =  18	-- CPU
	, @on = @onBit

exec sp_trace_setevent
	@TraceID
	, @eventid
	, @columnid =  34	-- Object Name
	, @on = @onBit

exec sp_trace_setevent
	@TraceID
	, @eventid
	, @columnid =  63	-- SQL Handle
	, @on = @onBit
END

GO


