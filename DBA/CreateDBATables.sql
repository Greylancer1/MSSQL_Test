/****** Object:  Database DBA    Script Date: 7/14/2006 11:25:39 AM ******/
IF EXISTS (SELECT name FROM master.dbo.sysdatabases WHERE name = N'DBA')
	DROP DATABASE [DBA]
GO

CREATE DATABASE [DBA]  ON (NAME = N'DBA_Data', FILENAME = N'C:\MSSQL2K\Data\DBA.mdf' , SIZE = 195, FILEGROWTH = 10%) LOG ON (NAME = N'DBA_Log', FILENAME = N'C:\MSSQL2K\Logs\DBA_log.ldf' , SIZE = 894, MAXSIZE = 10000, FILEGROWTH = 10%)
 COLLATE SQL_Latin1_General_CP1_CI_AS
GO

exec sp_dboption N'DBA', N'autoclose', N'false'
GO

exec sp_dboption N'DBA', N'bulkcopy', N'false'
GO

exec sp_dboption N'DBA', N'trunc. log', N'false'
GO

exec sp_dboption N'DBA', N'torn page detection', N'true'
GO

exec sp_dboption N'DBA', N'read only', N'false'
GO

exec sp_dboption N'DBA', N'dbo use', N'false'
GO

exec sp_dboption N'DBA', N'single', N'false'
GO

exec sp_dboption N'DBA', N'autoshrink', N'false'
GO

exec sp_dboption N'DBA', N'ANSI null default', N'false'
GO

exec sp_dboption N'DBA', N'recursive triggers', N'false'
GO

exec sp_dboption N'DBA', N'ANSI nulls', N'false'
GO

exec sp_dboption N'DBA', N'concat null yields null', N'false'
GO

exec sp_dboption N'DBA', N'cursor close on commit', N'false'
GO

exec sp_dboption N'DBA', N'default to local cursor', N'false'
GO

exec sp_dboption N'DBA', N'quoted identifier', N'false'
GO

exec sp_dboption N'DBA', N'ANSI warnings', N'false'
GO

exec sp_dboption N'DBA', N'auto create statistics', N'true'
GO

exec sp_dboption N'DBA', N'auto update statistics', N'true'
GO

if( (@@microsoftversion / power(2, 24) = 8) and (@@microsoftversion & 0xffff >= 724) )
	exec sp_dboption N'DBA', N'db chaining', N'false'
GO

use [DBA]
GO

if exists (select * from dbo.sysobjects where id = object_id(N'[dbo].[fk_01]') and OBJECTPROPERTY(id, N'IsForeignKey') = 1)
ALTER TABLE [dbo].[ServerDriveCapacity] DROP CONSTRAINT fk_01
GO

/****** Object:  Table [dbo].[ServerDriveCapacity]    Script Date: 7/14/2006 11:25:40 AM ******/
if exists (select * from dbo.sysobjects where id = object_id(N'[dbo].[ServerDriveCapacity]') and OBJECTPROPERTY(id, N'IsUserTable') = 1)
drop table [dbo].[ServerDriveCapacity]
GO

/****** Object:  Table [dbo].[Server]    Script Date: 7/14/2006 11:25:40 AM ******/
if exists (select * from dbo.sysobjects where id = object_id(N'[dbo].[Server]') and OBJECTPROPERTY(id, N'IsUserTable') = 1)
drop table [dbo].[Server]
GO

/****** Object:  Table [dbo].[ServerErrorLog]    Script Date: 7/14/2006 11:25:40 AM ******/
if exists (select * from dbo.sysobjects where id = object_id(N'[dbo].[ServerErrorLog]') and OBJECTPROPERTY(id, N'IsUserTable') = 1)
drop table [dbo].[ServerErrorLog]
GO

/****** Object:  Table [dbo].[ServerFreeSpaceHistory]    Script Date: 7/14/2006 11:25:40 AM ******/
if exists (select * from dbo.sysobjects where id = object_id(N'[dbo].[ServerFreeSpaceHistory]') and OBJECTPROPERTY(id, N'IsUserTable') = 1)
drop table [dbo].[ServerFreeSpaceHistory]
GO

/****** Object:  Table [dbo].[ServerHistory]    Script Date: 7/14/2006 11:25:40 AM ******/
if exists (select * from dbo.sysobjects where id = object_id(N'[dbo].[ServerHistory]') and OBJECTPROPERTY(id, N'IsUserTable') = 1)
drop table [dbo].[ServerHistory]
GO

/****** Object:  Table [dbo].[ServerInfo]    Script Date: 7/14/2006 11:25:40 AM ******/
if exists (select * from dbo.sysobjects where id = object_id(N'[dbo].[ServerInfo]') and OBJECTPROPERTY(id, N'IsUserTable') = 1)
drop table [dbo].[ServerInfo]
GO

/****** Object:  Table [dbo].[tAdminChk]    Script Date: 7/14/2006 11:25:40 AM ******/
if exists (select * from dbo.sysobjects where id = object_id(N'[dbo].[tAdminChk]') and OBJECTPROPERTY(id, N'IsUserTable') = 1)
drop table [dbo].[tAdminChk]
GO

/****** Object:  Table [dbo].[tBackupChk]    Script Date: 7/14/2006 11:25:40 AM ******/
if exists (select * from dbo.sysobjects where id = object_id(N'[dbo].[tBackupChk]') and OBJECTPROPERTY(id, N'IsUserTable') = 1)
drop table [dbo].[tBackupChk]
GO

/****** Object:  Table [dbo].[tBackupInfo]    Script Date: 7/14/2006 11:25:40 AM ******/
if exists (select * from dbo.sysobjects where id = object_id(N'[dbo].[tBackupInfo]') and OBJECTPROPERTY(id, N'IsUserTable') = 1)
drop table [dbo].[tBackupInfo]
GO

/****** Object:  Table [dbo].[tDbMessages]    Script Date: 7/14/2006 11:25:40 AM ******/
if exists (select * from dbo.sysobjects where id = object_id(N'[dbo].[tDbMessages]') and OBJECTPROPERTY(id, N'IsUserTable') = 1)
drop table [dbo].[tDbMessages]
GO

/****** Object:  Table [dbo].[tDbSizeHist]    Script Date: 7/14/2006 11:25:40 AM ******/
if exists (select * from dbo.sysobjects where id = object_id(N'[dbo].[tDbSizeHist]') and OBJECTPROPERTY(id, N'IsUserTable') = 1)
drop table [dbo].[tDbSizeHist]
GO

/****** Object:  Table [dbo].[tDbSpaceChk]    Script Date: 7/14/2006 11:25:40 AM ******/
if exists (select * from dbo.sysobjects where id = object_id(N'[dbo].[tDbSpaceChk]') and OBJECTPROPERTY(id, N'IsUserTable') = 1)
drop table [dbo].[tDbSpaceChk]
GO

/****** Object:  Table [dbo].[tDbaSec]    Script Date: 7/14/2006 11:25:40 AM ******/
if exists (select * from dbo.sysobjects where id = object_id(N'[dbo].[tDbaSec]') and OBJECTPROPERTY(id, N'IsUserTable') = 1)
drop table [dbo].[tDbaSec]
GO

/****** Object:  Table [dbo].[tDocs]    Script Date: 7/14/2006 11:25:40 AM ******/
if exists (select * from dbo.sysobjects where id = object_id(N'[dbo].[tDocs]') and OBJECTPROPERTY(id, N'IsUserTable') = 1)
drop table [dbo].[tDocs]
GO

/****** Object:  Table [dbo].[tDriveInfo]    Script Date: 7/14/2006 11:25:40 AM ******/
if exists (select * from dbo.sysobjects where id = object_id(N'[dbo].[tDriveInfo]') and OBJECTPROPERTY(id, N'IsUserTable') = 1)
drop table [dbo].[tDriveInfo]
GO

/****** Object:  Table [dbo].[tDriveSpaceChk]    Script Date: 7/14/2006 11:25:40 AM ******/
if exists (select * from dbo.sysobjects where id = object_id(N'[dbo].[tDriveSpaceChk]') and OBJECTPROPERTY(id, N'IsUserTable') = 1)
drop table [dbo].[tDriveSpaceChk]
GO

/****** Object:  Table [dbo].[tJobList]    Script Date: 7/14/2006 11:25:40 AM ******/
if exists (select * from dbo.sysobjects where id = object_id(N'[dbo].[tJobList]') and OBJECTPROPERTY(id, N'IsUserTable') = 1)
drop table [dbo].[tJobList]
GO

/****** Object:  Table [dbo].[tJobReport]    Script Date: 7/14/2006 11:25:40 AM ******/
if exists (select * from dbo.sysobjects where id = object_id(N'[dbo].[tJobReport]') and OBJECTPROPERTY(id, N'IsUserTable') = 1)
drop table [dbo].[tJobReport]
GO

/****** Object:  Table [dbo].[tLoginChk]    Script Date: 7/14/2006 11:25:40 AM ******/
if exists (select * from dbo.sysobjects where id = object_id(N'[dbo].[tLoginChk]') and OBJECTPROPERTY(id, N'IsUserTable') = 1)
drop table [dbo].[tLoginChk]
GO

/****** Object:  Table [dbo].[tMyDbs]    Script Date: 7/14/2006 11:25:40 AM ******/
if exists (select * from dbo.sysobjects where id = object_id(N'[dbo].[tMyDbs]') and OBJECTPROPERTY(id, N'IsUserTable') = 1)
drop table [dbo].[tMyDbs]
GO

/****** Object:  Table [dbo].[tTableSpace]    Script Date: 7/14/2006 11:25:40 AM ******/
if exists (select * from dbo.sysobjects where id = object_id(N'[dbo].[tTableSpace]') and OBJECTPROPERTY(id, N'IsUserTable') = 1)
drop table [dbo].[tTableSpace]
GO

/****** Object:  User ITAppMgr    Script Date: 7/14/2006 11:25:39 AM ******/
if not exists (select * from dbo.sysusers where name = N'ITAppMgr' and uid < 16382)
	EXEC sp_grantdbaccess N'ITAppMgr', N'ITAppMgr'
GO

/****** Object:  User ITAppMgr    Script Date: 7/14/2006 11:25:39 AM ******/
exec sp_addrolemember N'db_owner', N'ITAppMgr'
GO

/****** Object:  Table [dbo].[Server]    Script Date: 7/14/2006 11:25:42 AM ******/
CREATE TABLE [dbo].[Server] (
	[ServerID] [int] IDENTITY (1, 1) NOT NULL ,
	[Servername] [sysname] NOT NULL 
) ON [PRIMARY]
GO

/****** Object:  Table [dbo].[ServerErrorLog]    Script Date: 7/14/2006 11:25:42 AM ******/
CREATE TABLE [dbo].[ServerErrorLog] (
	[ErrorLogText] [varchar] (256) COLLATE SQL_Latin1_General_CP1_CI_AS NULL ,
	[ContinuationRow] [bit] NULL ,
	[Servername] [sysname] NULL ,
	[InsertDate] [datetime] NOT NULL 
) ON [PRIMARY]
GO

/****** Object:  Table [dbo].[ServerFreeSpaceHistory]    Script Date: 7/14/2006 11:25:42 AM ******/
CREATE TABLE [dbo].[ServerFreeSpaceHistory] (
	[ServerID] [int] NULL ,
	[Drive] [char] (1) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL ,
	[FreeSpace] [int] NOT NULL ,
	[CheckDate] [datetime] NOT NULL 
) ON [PRIMARY]
GO

/****** Object:  Table [dbo].[ServerHistory]    Script Date: 7/14/2006 11:25:42 AM ******/
CREATE TABLE [dbo].[ServerHistory] (
	[SHID] [int] IDENTITY (1, 1) NOT NULL ,
	[ErrorLogText] [varchar] (256) COLLATE SQL_Latin1_General_CP1_CI_AS NULL ,
	[Servername] [sysname] NULL ,
	[EventDate] [datetime] NOT NULL ,
	[InsertDate] [datetime] NOT NULL 
) ON [PRIMARY]
GO

/****** Object:  Table [dbo].[ServerInfo]    Script Date: 7/14/2006 11:25:42 AM ******/
CREATE TABLE [dbo].[ServerInfo] (
	[ServerName] [nvarchar] (255) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL ,
	[Hardware] [nvarchar] (255) COLLATE SQL_Latin1_General_CP1_CI_AS NULL ,
	[SerialNum] [nvarchar] (255) COLLATE SQL_Latin1_General_CP1_CI_AS NULL ,
	[IP] [varchar] (255) COLLATE SQL_Latin1_General_CP1_CI_AS NULL ,
	[ID] [int] IDENTITY (1, 1) NOT NULL 
) ON [PRIMARY]
GO

/****** Object:  Table [dbo].[tAdminChk]    Script Date: 7/14/2006 11:25:43 AM ******/
CREATE TABLE [dbo].[tAdminChk] (
	[AdminID] [int] IDENTITY (1, 1) NOT NULL ,
	[Role] [varchar] (50) COLLATE SQL_Latin1_General_CP1_CI_AS NULL ,
	[Login] [varchar] (50) COLLATE SQL_Latin1_General_CP1_CI_AS NULL ,
	[Server] [varchar] (50) COLLATE SQL_Latin1_General_CP1_CI_AS NULL ,
	[LastUpdated] [datetime] NOT NULL 
) ON [PRIMARY]
GO

/****** Object:  Table [dbo].[tBackupChk]    Script Date: 7/14/2006 11:25:43 AM ******/
CREATE TABLE [dbo].[tBackupChk] (
	[BackupID] [int] IDENTITY (1, 1) NOT NULL ,
	[DbName] [varchar] (50) COLLATE SQL_Latin1_General_CP1_CI_AS NULL ,
	[DaysSinceLastBackup] [varchar] (50) COLLATE SQL_Latin1_General_CP1_CI_AS NULL ,
	[LastBackupDate] [varchar] (50) COLLATE SQL_Latin1_General_CP1_CI_AS NULL ,
	[Server] [varchar] (50) COLLATE SQL_Latin1_General_CP1_CI_AS NULL ,
	[LastUpdated] [datetime] NOT NULL 
) ON [PRIMARY]
GO

/****** Object:  Table [dbo].[tBackupInfo]    Script Date: 7/14/2006 11:25:43 AM ******/
CREATE TABLE [dbo].[tBackupInfo] (
	[BackupInfoID] [int] IDENTITY (1, 1) NOT NULL ,
	[DbName] [varchar] (50) COLLATE SQL_Latin1_General_CP1_CI_AS NULL ,
	[StartDate] [varchar] (50) COLLATE SQL_Latin1_General_CP1_CI_AS NULL ,
	[FinishDate] [varchar] (50) COLLATE SQL_Latin1_General_CP1_CI_AS NULL ,
	[Type] [varchar] (3) COLLATE SQL_Latin1_General_CP1_CI_AS NULL ,
	[BackupSize] [varchar] (50) COLLATE SQL_Latin1_General_CP1_CI_AS NULL ,
	[RunBy] [varchar] (50) COLLATE SQL_Latin1_General_CP1_CI_AS NULL ,
	[Server] [varchar] (50) COLLATE SQL_Latin1_General_CP1_CI_AS NULL ,
	[LastUpdated] [datetime] NOT NULL 
) ON [PRIMARY]
GO

/****** Object:  Table [dbo].[tDbMessages]    Script Date: 7/14/2006 11:25:43 AM ******/
CREATE TABLE [dbo].[tDbMessages] (
	[MessageID] [int] IDENTITY (1, 1) NOT NULL ,
	[Message] [varchar] (3000) COLLATE SQL_Latin1_General_CP1_CI_AS NULL ,
	[EventDate] [varchar] (50) COLLATE SQL_Latin1_General_CP1_CI_AS NULL ,
	[Server] [varchar] (50) COLLATE SQL_Latin1_General_CP1_CI_AS NULL ,
	[LastUpdated] [datetime] NOT NULL 
) ON [PRIMARY]
GO

/****** Object:  Table [dbo].[tDbSizeHist]    Script Date: 7/14/2006 11:25:43 AM ******/
CREATE TABLE [dbo].[tDbSizeHist] (
	[DbSizeHistID] [int] IDENTITY (1, 1) NOT NULL ,
	[Server] [varchar] (50) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL ,
	[DbName] [varchar] (50) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL ,
	[DbSize] [numeric](18, 0) NOT NULL ,
	[DbFilename] [varchar] (200) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL ,
	[LastUpdated] [datetime] NOT NULL 
) ON [PRIMARY]
GO

/****** Object:  Table [dbo].[tDbSpaceChk]    Script Date: 7/14/2006 11:25:43 AM ******/
CREATE TABLE [dbo].[tDbSpaceChk] (
	[DbSpaceID] [int] IDENTITY (1, 1) NOT NULL ,
	[BackupStartDate] [datetime] NULL ,
	[SpaceDate] [varchar] (50) COLLATE SQL_Latin1_General_CP1_CI_AS NULL ,
	[SpaceTime] [varchar] (50) COLLATE SQL_Latin1_General_CP1_CI_AS NULL ,
	[DbName] [varchar] (50) COLLATE SQL_Latin1_General_CP1_CI_AS NULL ,
	[FilegroupName] [varchar] (50) COLLATE SQL_Latin1_General_CP1_CI_AS NULL ,
	[LogicalFilename] [varchar] (100) COLLATE SQL_Latin1_General_CP1_CI_AS NULL ,
	[PhysFilename] [varchar] (300) COLLATE SQL_Latin1_General_CP1_CI_AS NULL ,
	[FileSize] [float] NULL ,
	[GrowthPercentage] [float] NULL ,
	[Server] [varchar] (50) COLLATE SQL_Latin1_General_CP1_CI_AS NULL ,
	[LastUpdated] [datetime] NULL 
) ON [PRIMARY]
GO

/****** Object:  Table [dbo].[tDbaSec]    Script Date: 7/14/2006 11:25:43 AM ******/
CREATE TABLE [dbo].[tDbaSec] (
	[UserID] [int] IDENTITY (1, 1) NOT NULL ,
	[Username] [varchar] (50) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL ,
	[DeptNum] [varchar] (6) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL ,
	[Active] [char] (1) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL 
) ON [PRIMARY]
GO

/****** Object:  Table [dbo].[tDocs]    Script Date: 7/14/2006 11:25:43 AM ******/
CREATE TABLE [dbo].[tDocs] (
	[ServerDocID] [int] IDENTITY (1, 1) NOT NULL ,
	[Server] [varchar] (50) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL ,
	[Doc] [varchar] (100) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL 
) ON [PRIMARY]
GO

/****** Object:  Table [dbo].[tDriveInfo]    Script Date: 7/14/2006 11:25:43 AM ******/
CREATE TABLE [dbo].[tDriveInfo] (
	[DriveID] [int] NOT NULL ,
	[Server] [varchar] (50) COLLATE SQL_Latin1_General_CP1_CI_AS NULL ,
	[Drive] [varchar] (50) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL ,
	[TotalSize] [varchar] (50) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL ,
	[LastUpdated] [datetime] NOT NULL 
) ON [PRIMARY]
GO

/****** Object:  Table [dbo].[tDriveSpaceChk]    Script Date: 7/14/2006 11:25:43 AM ******/
CREATE TABLE [dbo].[tDriveSpaceChk] (
	[DriveID] [int] IDENTITY (1, 1) NOT NULL ,
	[Server] [varchar] (50) COLLATE SQL_Latin1_General_CP1_CI_AS NULL ,
	[Drive] [varchar] (50) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL ,
	[MBFree] [varchar] (50) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL ,
	[LastUpdated] [datetime] NOT NULL 
) ON [PRIMARY]
GO

/****** Object:  Table [dbo].[tJobList]    Script Date: 7/14/2006 11:25:43 AM ******/
CREATE TABLE [dbo].[tJobList] (
	[JobID] [int] IDENTITY (1, 1) NOT NULL ,
	[server] [varchar] (50) COLLATE SQL_Latin1_General_CP1_CI_AS NULL ,
	[jobname] [varchar] (100) COLLATE SQL_Latin1_General_CP1_CI_AS NULL ,
	[enabled] [varchar] (50) COLLATE SQL_Latin1_General_CP1_CI_AS NULL ,
	[description] [varchar] (500) COLLATE SQL_Latin1_General_CP1_CI_AS NULL ,
	[owner_sid] [binary] (50) NULL ,
	[owner_name] [varchar] (50) COLLATE SQL_Latin1_General_CP1_CI_AS NULL ,
	[date_created] [datetime] NULL ,
	[date_modified] [datetime] NULL ,
	[LastUpdated] [datetime] NOT NULL 
) ON [PRIMARY]
GO

/****** Object:  Table [dbo].[tJobReport]    Script Date: 7/14/2006 11:25:43 AM ******/
CREATE TABLE [dbo].[tJobReport] (
	[lngID] [int] IDENTITY (1, 1) NOT NULL ,
	[server] [varchar] (50) COLLATE SQL_Latin1_General_CP1_CI_AS NULL ,
	[jobname] [varchar] (100) COLLATE SQL_Latin1_General_CP1_CI_AS NULL ,
	[status] [varchar] (50) COLLATE SQL_Latin1_General_CP1_CI_AS NULL ,
	[enabled] [varchar] (50) COLLATE SQL_Latin1_General_CP1_CI_AS NULL ,
	[rundate] [varchar] (50) COLLATE SQL_Latin1_General_CP1_CI_AS NULL ,
	[runtime] [varchar] (50) COLLATE SQL_Latin1_General_CP1_CI_AS NULL ,
	[runduration] [varchar] (50) COLLATE SQL_Latin1_General_CP1_CI_AS NULL ,
	[LastUpdated] [datetime] NULL 
) ON [PRIMARY]
GO

/****** Object:  Table [dbo].[tLoginChk]    Script Date: 7/14/2006 11:25:43 AM ******/
CREATE TABLE [dbo].[tLoginChk] (
	[LoginID] [int] IDENTITY (1, 1) NOT NULL ,
	[Login] [varchar] (50) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL ,
	[Server] [varchar] (50) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL 
) ON [PRIMARY]
GO

/****** Object:  Table [dbo].[tMyDbs]    Script Date: 7/14/2006 11:25:44 AM ******/
CREATE TABLE [dbo].[tMyDbs] (
	[DbKey] [int] IDENTITY (1, 1) NOT NULL ,
	[dbname] [char] (50) COLLATE SQL_Latin1_General_CP1_CI_AS NULL ,
	[dbowner] [char] (50) COLLATE SQL_Latin1_General_CP1_CI_AS NULL ,
	[dbid] [varchar] (50) COLLATE SQL_Latin1_General_CP1_CI_AS NULL ,
	[crdate] [datetime] NULL ,
	[status] [varchar] (50) COLLATE SQL_Latin1_General_CP1_CI_AS NULL ,
	[category] [varchar] (50) COLLATE SQL_Latin1_General_CP1_CI_AS NULL ,
	[mode] [varchar] (50) COLLATE SQL_Latin1_General_CP1_CI_AS NULL ,
	[compatlvl] [varchar] (50) COLLATE SQL_Latin1_General_CP1_CI_AS NULL ,
	[filename] [varchar] (100) COLLATE SQL_Latin1_General_CP1_CI_AS NULL ,
	[version] [varchar] (50) COLLATE SQL_Latin1_General_CP1_CI_AS NULL ,
	[Server] [varchar] (50) COLLATE SQL_Latin1_General_CP1_CI_AS NULL ,
	[LastUpdated] [datetime] NOT NULL 
) ON [PRIMARY]
GO

/****** Object:  Table [dbo].[tTableSpace]    Script Date: 7/14/2006 11:25:44 AM ******/
CREATE TABLE [dbo].[tTableSpace] (
	[TableSpaceID] [int] IDENTITY (1, 1) NOT NULL ,
	[DatabaseName] [varchar] (50) COLLATE SQL_Latin1_General_CP1_CI_AS NULL ,
	[ServerName] [varchar] (50) COLLATE SQL_Latin1_General_CP1_CI_AS NULL ,
	[TableName] [varchar] (100) COLLATE SQL_Latin1_General_CP1_CI_AS NULL ,
	[TableRows] [int] NULL ,
	[reserved_in_KB] [varchar] (50) COLLATE SQL_Latin1_General_CP1_CI_AS NULL ,
	[data] [varchar] (100) COLLATE SQL_Latin1_General_CP1_CI_AS NULL ,
	[index_size] [varchar] (100) COLLATE SQL_Latin1_General_CP1_CI_AS NULL ,
	[unused] [varchar] (100) COLLATE SQL_Latin1_General_CP1_CI_AS NULL ,
	[LastUpdated] [smalldatetime] NULL 
) ON [PRIMARY]
GO

/****** Object:  Table [dbo].[ServerDriveCapacity]    Script Date: 7/14/2006 11:25:44 AM ******/
CREATE TABLE [dbo].[ServerDriveCapacity] (
	[ServerID] [int] NOT NULL ,
	[Drive] [char] (1) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL ,
	[Capacity] [int] NOT NULL 
) ON [PRIMARY]
GO

