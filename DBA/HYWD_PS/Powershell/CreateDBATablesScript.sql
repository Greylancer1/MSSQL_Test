SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
SET ANSI_PADDING ON
GO
CREATE TABLE [dbo].[FilesMon](
	[ServerName] [varchar](50) NULL,
	[dbname] [varchar](100) NULL,
	[Physical_Name] [varchar](300) NULL,
	[Dt] [date] NULL,
	[File_Group_Name] [varchar](50) NULL,
	[Size_MB] [int] NULL,
	[Free_MB] [int] NULL,
	[Dtm] [datetime] NULL
) ON [PRIMARY]

SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
SET ANSI_PADDING ON
GO
CREATE TABLE [dbo].[IndexListMon](
	[ServerName] [varchar](50) NULL,
	[DBName] [varchar](50) NULL,
	[SchemaName] [varchar](50) NULL,
	[TableName] [varchar](100) NULL,
	[IndexName] [varchar](150) NULL,
	[IndexType] [varchar](50) NULL
) ON [PRIMARY]

SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
SET ANSI_PADDING ON
GO
CREATE TABLE [dbo].[DBConfigMon](
	[ServerName] [varchar](50) NULL,
	[DBName] [varchar](50) NULL,
	[RecoveryMode] [varchar](50) NULL,
	[Status] [varchar](50) NULL,
	[AutoClose] [bit] NULL,
	[AutoStats] [bit] NULL,
	[AutoShrink] [bit] NULL,
	[FullText] [bit] NULL
) ON [PRIMARY]

SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
SET ANSI_PADDING ON
GO
CREATE TABLE [dbo].[DBCompatLvlMon](
	[ServerName] [varchar](50) NULL,
	[DBName] [varchar](50) NULL,
	[CompatLvl] [int] NULL
) ON [PRIMARY]

GO
SET ANSI_PADDING OFF
GO
/****** Object:  Table [dbo].[DataAndLogFilesMon]    Script Date: 4/26/2016 11:40:47 AM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
SET ANSI_PADDING ON
GO
CREATE TABLE [dbo].[DataAndLogFilesMon](
	[ServerName] [varchar](50) NULL,
	[dbname] [varchar](100) NULL,
	[Physical_Name] [varchar](300) NULL,
	[Dt] [date] NULL,
	[Size_MB] [int] NULL,
	[Free_MB] [int] NULL,
	[Dtm] [datetime] NULL
) ON [PRIMARY]


SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
SET ANSI_PADDING ON
GO
CREATE TABLE [dbo].[ConfigMon](
	[ServerName] [varchar](50) NULL,
	[Version] [varchar](50) NULL,
	[Name] [varchar](50) NULL,
	[Value] [varchar](50) NULL,
	[Minimum] [int] NULL,
	[Maximum] [int] NULL,
	[ValueInUse] [int] NULL,
	[Description] [varchar](250) NULL,
	[Dynamic] [varchar](50) NULL,
	[Advanced] [varchar](50) NULL
) ON [PRIMARY]

SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[InstanceInfoMon](
	[ServerName] [nvarchar](50) NULL,
	[ProductVersion] [nvarchar](50) NULL,
	[ProductLevel] [nvarchar](50) NULL,
	[Edition] [nvarchar](50) NULL,
	[EngineEdition] [nvarchar](50) NULL
) ON [PRIMARY]

SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
SET ANSI_PADDING ON
GO
CREATE TABLE [dbo].[InstPerfMon](
	[ServerName] [varchar](50) NULL,
	[BufferCacheHitRatio] [int] NULL,
	[PageReadsSec] [int] NULL,
	[PageWritesSec] [int] NULL,
	[UserConns] [int] NULL,
	[PLE] [int] NULL,
	[CheckpointPagesSec] [int] NULL,
	[LazyWritesSec] [int] NULL,
	[FreeSpaceInTempDB] [int] NULL,
	[BatchRequestsSec] [int] NULL,
	[SQLCompsSec] [int] NULL,
	[SQLRecompsSec] [int] NULL,
	[TargetServerMemory_KB] [int] NULL,
	[TotServerMemory_KB] [int] NULL,
	[MeasurementTime] [datetime] NULL,
	[AvgTaskCount] [int] NULL,
	[AvgRunnableTaskCount] [int] NULL,
	[AvgPendingDiskIOCount] [int] NULL,
	[PercentSignalWait] [int] NULL,
	[PageLookupsSec] [int] NULL,
	[TransSec] [int] NULL,
	[MemoryGrantsPending] [int] NULL
) ON [PRIMARY]

SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
SET ANSI_PADDING ON
GO
CREATE TABLE [dbo].[JobMon](
	[ServerName] [varchar](50) NULL,
	[JobName] [varchar](300) NULL,
	[RunStatus] [varchar](50) NULL,
	[RunDt] [datetime] NULL
) ON [PRIMARY]

SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
SET ANSI_PADDING ON
GO
CREATE TABLE [dbo].[LogMon](
	[ServerName] [varchar](50) NULL,
	[LogDt] [datetime] NULL,
	[Entry] [varchar](500) NULL
) ON [PRIMARY]


SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
SET ANSI_PADDING ON
GO
CREATE TABLE [dbo].[LogSizeMon](
	[ServerName] [varchar](50) NULL,
	[DBName] [varchar](50) NULL,
	[Dtm] [datetime] NULL,
	[TotalSize] [float] NULL,
	[LogSize] [float] NULL,
	[LogPercentUsed] [float] NULL
) ON [PRIMARY]


SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
SET ANSI_PADDING ON
GO
CREATE TABLE [dbo].[ServerMon](
	[name] [nvarchar](50) NULL,
	[monitored] [nvarchar](50) NULL,
	[IdxChk] [varchar](50) NULL,
	[Perf] [varchar](50) NULL
) ON [PRIMARY]


SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
SET ANSI_PADDING ON
GO
CREATE TABLE [dbo].[SrvrDbTblColMon](
	[ServerNm] [varchar](150) NULL,
	[DbNm] [varchar](150) NULL,
	[TblNm] [varchar](150) NULL,
	[ColNm] [varchar](150) NULL
) ON [PRIMARY]


SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
SET ANSI_PADDING ON
GO
CREATE TABLE [dbo].[SrvrPerfMon](
	[ServerName] [varchar](50) NULL,
	[MemoryUsage] [float] NULL,
	[CPUUsage] [float] NULL,
	[Dt] [datetime] NULL
) ON [PRIMARY]


SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
SET ANSI_PADDING ON
GO
CREATE TABLE [dbo].[TableMon](
	[ServerName] [varchar](100) NOT NULL,
	[DBName] [varchar](100) NULL,
	[TableName] [varchar](100) NULL
) ON [PRIMARY]


SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
SET ANSI_PADDING ON
GO
CREATE TABLE [dbo].[TableRowCountMon](
	[servername] [varchar](100) NULL,
	[dbname] [varchar](100) NULL,
	[tablename] [varchar](150) NULL,
	[dt] [datetime] NULL,
	[rows] [int] NULL
) ON [PRIMARY]