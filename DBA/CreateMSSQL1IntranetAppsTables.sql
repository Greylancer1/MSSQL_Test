/****** Object:  Database IntranetApps    Script Date: 7/14/2006 11:24:49 AM ******/
IF EXISTS (SELECT name FROM master.dbo.sysdatabases WHERE name = N'IntranetApps')
	DROP DATABASE [IntranetApps]
GO

CREATE DATABASE [IntranetApps]  ON (NAME = N'IntranetApps_Data', FILENAME = N'D:\MSSQL2000\MSSQL\Data\IntranetApps_Data.MDF' , SIZE = 200, MAXSIZE = 1000, FILEGROWTH = 10%) LOG ON (NAME = N'IntranetApps_Log', FILENAME = N'D:\MSSQL2000\MSSQL\Data\IntranetApps_Log.LDF' , SIZE = 80, MAXSIZE = 100, FILEGROWTH = 10%)
 COLLATE SQL_Latin1_General_CP1_CI_AS
GO

exec sp_dboption N'IntranetApps', N'autoclose', N'false'
GO

exec sp_dboption N'IntranetApps', N'bulkcopy', N'false'
GO

exec sp_dboption N'IntranetApps', N'trunc. log', N'false'
GO

exec sp_dboption N'IntranetApps', N'torn page detection', N'true'
GO

exec sp_dboption N'IntranetApps', N'read only', N'false'
GO

exec sp_dboption N'IntranetApps', N'dbo use', N'false'
GO

exec sp_dboption N'IntranetApps', N'single', N'false'
GO

exec sp_dboption N'IntranetApps', N'autoshrink', N'false'
GO

exec sp_dboption N'IntranetApps', N'ANSI null default', N'false'
GO

exec sp_dboption N'IntranetApps', N'recursive triggers', N'false'
GO

exec sp_dboption N'IntranetApps', N'ANSI nulls', N'false'
GO

exec sp_dboption N'IntranetApps', N'concat null yields null', N'false'
GO

exec sp_dboption N'IntranetApps', N'cursor close on commit', N'false'
GO

exec sp_dboption N'IntranetApps', N'default to local cursor', N'false'
GO

exec sp_dboption N'IntranetApps', N'quoted identifier', N'false'
GO

exec sp_dboption N'IntranetApps', N'ANSI warnings', N'false'
GO

exec sp_dboption N'IntranetApps', N'auto create statistics', N'true'
GO

exec sp_dboption N'IntranetApps', N'auto update statistics', N'false'
GO

if( (@@microsoftversion / power(2, 24) = 8) and (@@microsoftversion & 0xffff >= 724) )
	exec sp_dboption N'IntranetApps', N'db chaining', N'false'
GO

use [IntranetApps]
GO

/****** Object:  Table [dbo].[ADContactInfo]    Script Date: 7/14/2006 11:24:51 AM ******/
if exists (select * from dbo.sysobjects where id = object_id(N'[dbo].[ADContactInfo]') and OBJECTPROPERTY(id, N'IsUserTable') = 1)
drop table [dbo].[ADContactInfo]
GO

/****** Object:  Table [dbo].[CM_EpfDocChk]    Script Date: 7/14/2006 11:24:51 AM ******/
if exists (select * from dbo.sysobjects where id = object_id(N'[dbo].[CM_EpfDocChk]') and OBJECTPROPERTY(id, N'IsUserTable') = 1)
drop table [dbo].[CM_EpfDocChk]
GO

/****** Object:  Table [dbo].[CM_EpfNoDocChk]    Script Date: 7/14/2006 11:24:51 AM ******/
if exists (select * from dbo.sysobjects where id = object_id(N'[dbo].[CM_EpfNoDocChk]') and OBJECTPROPERTY(id, N'IsUserTable') = 1)
drop table [dbo].[CM_EpfNoDocChk]
GO

/****** Object:  Table [dbo].[ChompForms]    Script Date: 7/14/2006 11:24:51 AM ******/
if exists (select * from dbo.sysobjects where id = object_id(N'[dbo].[ChompForms]') and OBJECTPROPERTY(id, N'IsUserTable') = 1)
drop table [dbo].[ChompForms]
GO

/****** Object:  Table [dbo].[Departments]    Script Date: 7/14/2006 11:24:51 AM ******/
if exists (select * from dbo.sysobjects where id = object_id(N'[dbo].[Departments]') and OBJECTPROPERTY(id, N'IsUserTable') = 1)
drop table [dbo].[Departments]
GO

/****** Object:  Table [dbo].[Eclipsys_ChangeControlLog]    Script Date: 7/14/2006 11:24:51 AM ******/
if exists (select * from dbo.sysobjects where id = object_id(N'[dbo].[Eclipsys_ChangeControlLog]') and OBJECTPROPERTY(id, N'IsUserTable') = 1)
drop table [dbo].[Eclipsys_ChangeControlLog]
GO

/****** Object:  Table [dbo].[Eclipsys_Clusters]    Script Date: 7/14/2006 11:24:51 AM ******/
if exists (select * from dbo.sysobjects where id = object_id(N'[dbo].[Eclipsys_Clusters]') and OBJECTPROPERTY(id, N'IsUserTable') = 1)
drop table [dbo].[Eclipsys_Clusters]
GO

/****** Object:  Table [dbo].[Eclipsys_Products]    Script Date: 7/14/2006 11:24:51 AM ******/
if exists (select * from dbo.sysobjects where id = object_id(N'[dbo].[Eclipsys_Products]') and OBJECTPROPERTY(id, N'IsUserTable') = 1)
drop table [dbo].[Eclipsys_Products]
GO

/****** Object:  Table [dbo].[Eclipsys_ResourceGroup]    Script Date: 7/14/2006 11:24:51 AM ******/
if exists (select * from dbo.sysobjects where id = object_id(N'[dbo].[Eclipsys_ResourceGroup]') and OBJECTPROPERTY(id, N'IsUserTable') = 1)
drop table [dbo].[Eclipsys_ResourceGroup]
GO

/****** Object:  Table [dbo].[Eclipsys_SysTypes]    Script Date: 7/14/2006 11:24:51 AM ******/
if exists (select * from dbo.sysobjects where id = object_id(N'[dbo].[Eclipsys_SysTypes]') and OBJECTPROPERTY(id, N'IsUserTable') = 1)
drop table [dbo].[Eclipsys_SysTypes]
GO

/****** Object:  Table [dbo].[Eclipsys_Systems]    Script Date: 7/14/2006 11:24:51 AM ******/
if exists (select * from dbo.sysobjects where id = object_id(N'[dbo].[Eclipsys_Systems]') and OBJECTPROPERTY(id, N'IsUserTable') = 1)
drop table [dbo].[Eclipsys_Systems]
GO

/****** Object:  Table [dbo].[Eclipsys_UserList]    Script Date: 7/14/2006 11:24:51 AM ******/
if exists (select * from dbo.sysobjects where id = object_id(N'[dbo].[Eclipsys_UserList]') and OBJECTPROPERTY(id, N'IsUserTable') = 1)
drop table [dbo].[Eclipsys_UserList]
GO

/****** Object:  Table [dbo].[Employees]    Script Date: 7/14/2006 11:24:51 AM ******/
if exists (select * from dbo.sysobjects where id = object_id(N'[dbo].[Employees]') and OBJECTPROPERTY(id, N'IsUserTable') = 1)
drop table [dbo].[Employees]
GO

/****** Object:  Table [dbo].[FormActions]    Script Date: 7/14/2006 11:24:51 AM ******/
if exists (select * from dbo.sysobjects where id = object_id(N'[dbo].[FormActions]') and OBJECTPROPERTY(id, N'IsUserTable') = 1)
drop table [dbo].[FormActions]
GO

/****** Object:  Table [dbo].[FormApprvlGrp]    Script Date: 7/14/2006 11:24:51 AM ******/
if exists (select * from dbo.sysobjects where id = object_id(N'[dbo].[FormApprvlGrp]') and OBJECTPROPERTY(id, N'IsUserTable') = 1)
drop table [dbo].[FormApprvlGrp]
GO

/****** Object:  Table [dbo].[FormsAPVLTypesLkpLst]    Script Date: 7/14/2006 11:24:51 AM ******/
if exists (select * from dbo.sysobjects where id = object_id(N'[dbo].[FormsAPVLTypesLkpLst]') and OBJECTPROPERTY(id, N'IsUserTable') = 1)
drop table [dbo].[FormsAPVLTypesLkpLst]
GO

/****** Object:  Table [dbo].[FormsDeptLkpLst]    Script Date: 7/14/2006 11:24:51 AM ******/
if exists (select * from dbo.sysobjects where id = object_id(N'[dbo].[FormsDeptLkpLst]') and OBJECTPROPERTY(id, N'IsUserTable') = 1)
drop table [dbo].[FormsDeptLkpLst]
GO

/****** Object:  Table [dbo].[FormsPtChartLkpLst]    Script Date: 7/14/2006 11:24:51 AM ******/
if exists (select * from dbo.sysobjects where id = object_id(N'[dbo].[FormsPtChartLkpLst]') and OBJECTPROPERTY(id, N'IsUserTable') = 1)
drop table [dbo].[FormsPtChartLkpLst]
GO

/****** Object:  Table [dbo].[FormsUOMLkpLst]    Script Date: 7/14/2006 11:24:51 AM ******/
if exists (select * from dbo.sysobjects where id = object_id(N'[dbo].[FormsUOMLkpLst]') and OBJECTPROPERTY(id, N'IsUserTable') = 1)
drop table [dbo].[FormsUOMLkpLst]
GO

/****** Object:  Table [dbo].[FromsPtChartLkpLst]    Script Date: 7/14/2006 11:24:51 AM ******/
if exists (select * from dbo.sysobjects where id = object_id(N'[dbo].[FromsPtChartLkpLst]') and OBJECTPROPERTY(id, N'IsUserTable') = 1)
drop table [dbo].[FromsPtChartLkpLst]
GO

/****** Object:  Table [dbo].[LawCRAccLvlLkp]    Script Date: 7/14/2006 11:24:51 AM ******/
if exists (select * from dbo.sysobjects where id = object_id(N'[dbo].[LawCRAccLvlLkp]') and OBJECTPROPERTY(id, N'IsUserTable') = 1)
drop table [dbo].[LawCRAccLvlLkp]
GO

/****** Object:  Table [dbo].[LawCRDBLogin]    Script Date: 7/14/2006 11:24:51 AM ******/
if exists (select * from dbo.sysobjects where id = object_id(N'[dbo].[LawCRDBLogin]') and OBJECTPROPERTY(id, N'IsUserTable') = 1)
drop table [dbo].[LawCRDBLogin]
GO

/****** Object:  Table [dbo].[LawCRDeptLkpLst]    Script Date: 7/14/2006 11:24:51 AM ******/
if exists (select * from dbo.sysobjects where id = object_id(N'[dbo].[LawCRDeptLkpLst]') and OBJECTPROPERTY(id, N'IsUserTable') = 1)
drop table [dbo].[LawCRDeptLkpLst]
GO

/****** Object:  Table [dbo].[LawCRDirLkpLstVw]    Script Date: 7/14/2006 11:24:51 AM ******/
if exists (select * from dbo.sysobjects where id = object_id(N'[dbo].[LawCRDirLkpLstVw]') and OBJECTPROPERTY(id, N'IsUserTable') = 1)
drop table [dbo].[LawCRDirLkpLstVw]
GO

/****** Object:  Table [dbo].[LawCRDirectories]    Script Date: 7/14/2006 11:24:51 AM ******/
if exists (select * from dbo.sysobjects where id = object_id(N'[dbo].[LawCRDirectories]') and OBJECTPROPERTY(id, N'IsUserTable') = 1)
drop table [dbo].[LawCRDirectories]
GO

/****** Object:  Table [dbo].[LawCRDocStatus]    Script Date: 7/14/2006 11:24:51 AM ******/
if exists (select * from dbo.sysobjects where id = object_id(N'[dbo].[LawCRDocStatus]') and OBJECTPROPERTY(id, N'IsUserTable') = 1)
drop table [dbo].[LawCRDocStatus]
GO

/****** Object:  Table [dbo].[LawCRGroupMembers]    Script Date: 7/14/2006 11:24:51 AM ******/
if exists (select * from dbo.sysobjects where id = object_id(N'[dbo].[LawCRGroupMembers]') and OBJECTPROPERTY(id, N'IsUserTable') = 1)
drop table [dbo].[LawCRGroupMembers]
GO

/****** Object:  Table [dbo].[LawCRGroups]    Script Date: 7/14/2006 11:24:51 AM ******/
if exists (select * from dbo.sysobjects where id = object_id(N'[dbo].[LawCRGroups]') and OBJECTPROPERTY(id, N'IsUserTable') = 1)
drop table [dbo].[LawCRGroups]
GO

/****** Object:  Table [dbo].[LawCrReports]    Script Date: 7/14/2006 11:24:51 AM ******/
if exists (select * from dbo.sysobjects where id = object_id(N'[dbo].[LawCrReports]') and OBJECTPROPERTY(id, N'IsUserTable') = 1)
drop table [dbo].[LawCrReports]
GO

/****** Object:  Table [dbo].[LawCrSecurity]    Script Date: 7/14/2006 11:24:51 AM ******/
if exists (select * from dbo.sysobjects where id = object_id(N'[dbo].[LawCrSecurity]') and OBJECTPROPERTY(id, N'IsUserTable') = 1)
drop table [dbo].[LawCrSecurity]
GO

/****** Object:  Table [dbo].[LawCrSecurityAudit]    Script Date: 7/14/2006 11:24:51 AM ******/
if exists (select * from dbo.sysobjects where id = object_id(N'[dbo].[LawCrSecurityAudit]') and OBJECTPROPERTY(id, N'IsUserTable') = 1)
drop table [dbo].[LawCrSecurityAudit]
GO

/****** Object:  Table [dbo].[MuseUsers]    Script Date: 7/14/2006 11:24:51 AM ******/
if exists (select * from dbo.sysobjects where id = object_id(N'[dbo].[MuseUsers]') and OBJECTPROPERTY(id, N'IsUserTable') = 1)
drop table [dbo].[MuseUsers]
GO

/****** Object:  Table [dbo].[New Table]    Script Date: 7/14/2006 11:24:51 AM ******/
if exists (select * from dbo.sysobjects where id = object_id(N'[dbo].[New Table]') and OBJECTPROPERTY(id, N'IsUserTable') = 1)
drop table [dbo].[New Table]
GO

/****** Object:  Table [dbo].[PayrollTest]    Script Date: 7/14/2006 11:24:51 AM ******/
if exists (select * from dbo.sysobjects where id = object_id(N'[dbo].[PayrollTest]') and OBJECTPROPERTY(id, N'IsUserTable') = 1)
drop table [dbo].[PayrollTest]
GO

/****** Object:  Table [dbo].[REVMAS]    Script Date: 7/14/2006 11:24:51 AM ******/
if exists (select * from dbo.sysobjects where id = object_id(N'[dbo].[REVMAS]') and OBJECTPROPERTY(id, N'IsUserTable') = 1)
drop table [dbo].[REVMAS]
GO

/****** Object:  Table [dbo].[Results]    Script Date: 7/14/2006 11:24:51 AM ******/
if exists (select * from dbo.sysobjects where id = object_id(N'[dbo].[Results]') and OBJECTPROPERTY(id, N'IsUserTable') = 1)
drop table [dbo].[Results]
GO

/****** Object:  Table [dbo].[SxaUrlAuthentication]    Script Date: 7/14/2006 11:24:51 AM ******/
if exists (select * from dbo.sysobjects where id = object_id(N'[dbo].[SxaUrlAuthentication]') and OBJECTPROPERTY(id, N'IsUserTable') = 1)
drop table [dbo].[SxaUrlAuthentication]
GO

/****** Object:  Table [dbo].[UA_All_Exceptions]    Script Date: 7/14/2006 11:24:51 AM ******/
if exists (select * from dbo.sysobjects where id = object_id(N'[dbo].[UA_All_Exceptions]') and OBJECTPROPERTY(id, N'IsUserTable') = 1)
drop table [dbo].[UA_All_Exceptions]
GO

/****** Object:  Table [dbo].[UA_All_Other_Logins]    Script Date: 7/14/2006 11:24:51 AM ******/
if exists (select * from dbo.sysobjects where id = object_id(N'[dbo].[UA_All_Other_Logins]') and OBJECTPROPERTY(id, N'IsUserTable') = 1)
drop table [dbo].[UA_All_Other_Logins]
GO

/****** Object:  Table [dbo].[UserAccLvlLkpLst]    Script Date: 7/14/2006 11:24:51 AM ******/
if exists (select * from dbo.sysobjects where id = object_id(N'[dbo].[UserAccLvlLkpLst]') and OBJECTPROPERTY(id, N'IsUserTable') = 1)
drop table [dbo].[UserAccLvlLkpLst]
GO

/****** Object:  Table [dbo].[UserAccessAll]    Script Date: 7/14/2006 11:24:51 AM ******/
if exists (select * from dbo.sysobjects where id = object_id(N'[dbo].[UserAccessAll]') and OBJECTPROPERTY(id, N'IsUserTable') = 1)
drop table [dbo].[UserAccessAll]
GO

/****** Object:  Table [dbo].[UserSecOpsLst]    Script Date: 7/14/2006 11:24:51 AM ******/
if exists (select * from dbo.sysobjects where id = object_id(N'[dbo].[UserSecOpsLst]') and OBJECTPROPERTY(id, N'IsUserTable') = 1)
drop table [dbo].[UserSecOpsLst]
GO

/****** Object:  Table [dbo].[UserSecurity]    Script Date: 7/14/2006 11:24:51 AM ******/
if exists (select * from dbo.sysobjects where id = object_id(N'[dbo].[UserSecurity]') and OBJECTPROPERTY(id, N'IsUserTable') = 1)
drop table [dbo].[UserSecurity]
GO

/****** Object:  Table [dbo].[epi_user_sec]    Script Date: 7/14/2006 11:24:51 AM ******/
if exists (select * from dbo.sysobjects where id = object_id(N'[dbo].[epi_user_sec]') and OBJECTPROPERTY(id, N'IsUserTable') = 1)
drop table [dbo].[epi_user_sec]
GO

/****** Object:  Table [dbo].[escriptionusers]    Script Date: 7/14/2006 11:24:51 AM ******/
if exists (select * from dbo.sysobjects where id = object_id(N'[dbo].[escriptionusers]') and OBJECTPROPERTY(id, N'IsUserTable') = 1)
drop table [dbo].[escriptionusers]
GO

/****** Object:  Table [dbo].[exportadinfo]    Script Date: 7/14/2006 11:24:51 AM ******/
if exists (select * from dbo.sysobjects where id = object_id(N'[dbo].[exportadinfo]') and OBJECTPROPERTY(id, N'IsUserTable') = 1)
drop table [dbo].[exportadinfo]
GO

/****** Object:  User appanalyst    Script Date: 7/14/2006 11:24:50 AM ******/
if not exists (select * from dbo.sysusers where name = N'appanalyst' and uid < 16382)
	EXEC sp_grantdbaccess N'appanalyst', N'appanalyst'
GO

/****** Object:  User IntranetApps Access    Script Date: 7/14/2006 11:24:50 AM ******/
if not exists (select * from dbo.sysusers where name = N'IntranetApps Access' and uid < 16382)
	EXEC sp_grantdbaccess N'CHOMP\IntranetApps Access', N'IntranetApps Access'
GO

/****** Object:  User ITAppMgr    Script Date: 7/14/2006 11:24:50 AM ******/
if not exists (select * from dbo.sysusers where name = N'ITAppMgr' and uid < 16382)
	EXEC sp_grantdbaccess N'ITAppMgr', N'ITAppMgr'
GO

/****** Object:  User ITAppVwr    Script Date: 7/14/2006 11:24:50 AM ******/
if not exists (select * from dbo.sysusers where name = N'ITAppVwr' and uid < 16382)
	EXEC sp_grantdbaccess N'ITAppVwr', N'ITAppVwr'
GO

/****** Object:  User OcmRptVwr    Script Date: 7/14/2006 11:24:50 AM ******/
if not exists (select * from dbo.sysusers where name = N'OcmRptVwr' and uid < 16382)
	EXEC sp_grantdbaccess N'OcmRptVwr', N'OcmRptVwr'
GO

/****** Object:  User WebReader    Script Date: 7/14/2006 11:24:50 AM ******/
if not exists (select * from dbo.sysusers where name = N'WebReader' and uid < 16382)
	EXEC sp_grantdbaccess N'WebReader', N'WebReader'
GO

/****** Object:  User appanalyst    Script Date: 7/14/2006 11:24:50 AM ******/
exec sp_addrolemember N'db_datareader', N'appanalyst'
GO

/****** Object:  User ITAppVwr    Script Date: 7/14/2006 11:24:50 AM ******/
exec sp_addrolemember N'db_datareader', N'ITAppVwr'
GO

/****** Object:  User OcmRptVwr    Script Date: 7/14/2006 11:24:50 AM ******/
exec sp_addrolemember N'db_datareader', N'OcmRptVwr'
GO

/****** Object:  User WebReader    Script Date: 7/14/2006 11:24:50 AM ******/
exec sp_addrolemember N'db_datareader', N'WebReader'
GO

/****** Object:  User ITAppMgr    Script Date: 7/14/2006 11:24:50 AM ******/
exec sp_addrolemember N'db_owner', N'ITAppMgr'
GO

/****** Object:  Table [dbo].[ADContactInfo]    Script Date: 7/14/2006 11:24:53 AM ******/
CREATE TABLE [dbo].[ADContactInfo] (
	[DN] [varchar] (8000) COLLATE SQL_Latin1_General_CP1_CI_AS NULL ,
	[memberOf] [varchar] (8000) COLLATE SQL_Latin1_General_CP1_CI_AS NULL ,
	[cn] [varchar] (8000) COLLATE SQL_Latin1_General_CP1_CI_AS NULL ,
	[department] [varchar] (8000) COLLATE SQL_Latin1_General_CP1_CI_AS NULL ,
	[displayName] [varchar] (8000) COLLATE SQL_Latin1_General_CP1_CI_AS NULL ,
	[mail] [varchar] (8000) COLLATE SQL_Latin1_General_CP1_CI_AS NULL ,
	[objectClass] [varchar] (8000) COLLATE SQL_Latin1_General_CP1_CI_AS NULL ,
	[physicalDeliveryOfficeName] [varchar] (8000) COLLATE SQL_Latin1_General_CP1_CI_AS NULL ,
	[title] [varchar] (8000) COLLATE SQL_Latin1_General_CP1_CI_AS NULL 
) ON [PRIMARY]
GO

/****** Object:  Table [dbo].[CM_EpfDocChk]    Script Date: 7/14/2006 11:24:53 AM ******/
CREATE TABLE [dbo].[CM_EpfDocChk] (
	[DISCHARGED] [datetime] NULL ,
	[CLINIC] [char] (10) COLLATE SQL_Latin1_General_CP1_CI_AS NULL ,
	[MRN] [char] (20) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL ,
	[ENCOUNTER] [char] (20) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL ,
	[NAME] [char] (40) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL ,
	[DOCUMENT] [char] (30) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL ,
	[IMAGEDATE] [varchar] (10) COLLATE SQL_Latin1_General_CP1_CI_AS NULL 
) ON [PRIMARY]
GO

/****** Object:  Table [dbo].[CM_EpfNoDocChk]    Script Date: 7/14/2006 11:24:53 AM ******/
CREATE TABLE [dbo].[CM_EpfNoDocChk] (
	[DISCHARGE_DT] [datetime] NULL ,
	[PR_DEPT_ID] [varchar] (8) COLLATE SQL_Latin1_General_CP1_CI_AS NULL ,
	[MEDREC_ID] [varchar] (20) COLLATE SQL_Latin1_General_CP1_CI_AS NULL ,
	[PATIENT_ID] [varchar] (10) COLLATE SQL_Latin1_General_CP1_CI_AS NULL ,
	[PATIENT_NAME] [varchar] (72) COLLATE SQL_Latin1_General_CP1_CI_AS NULL 
) ON [PRIMARY]
GO

/****** Object:  Table [dbo].[ChompForms]    Script Date: 7/14/2006 11:24:54 AM ******/
CREATE TABLE [dbo].[ChompForms] (
	[FormID] [int] IDENTITY (1, 1) NOT NULL ,
	[FormNum] [char] (10) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL ,
	[FormName] [varchar] (50) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL ,
	[UnitOfMeasure] [char] (10) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL ,
	[Qty] [varchar] (5) COLLATE SQL_Latin1_General_CP1_CI_AS NULL ,
	[ReplacementLvl] [varchar] (50) COLLATE SQL_Latin1_General_CP1_CI_AS NULL ,
	[OwnerID] [int] NOT NULL ,
	[DeptID] [int] NOT NULL ,
	[ActionID] [int] NOT NULL ,
	[RevisionDt] [char] (10) COLLATE SQL_Latin1_General_CP1_CI_AS NULL ,
	[Barcode] [char] (10) COLLATE SQL_Latin1_General_CP1_CI_AS NULL ,
	[ReviewDt] [char] (10) COLLATE SQL_Latin1_General_CP1_CI_AS NULL ,
	[ApprovingGrp] [varchar] (25) COLLATE SQL_Latin1_General_CP1_CI_AS NULL ,
	[PtChrtID] [int] NULL ,
	[RevOrderDt] [varchar] (50) COLLATE SQL_Latin1_General_CP1_CI_AS NULL ,
	[TransRqd] [char] (1) COLLATE SQL_Latin1_General_CP1_CI_AS NULL ,
	[APVLTypeID] [int] NULL ,
	[UserNotes] [nvarchar] (1000) COLLATE SQL_Latin1_General_CP1_CI_AS NULL ,
	[AdminNotes] [nvarchar] (1000) COLLATE SQL_Latin1_General_CP1_CI_AS NULL ,
	[AffectedDepts] [nvarchar] (500) COLLATE SQL_Latin1_General_CP1_CI_AS NULL 
) ON [PRIMARY]
GO

/****** Object:  Table [dbo].[Departments]    Script Date: 7/14/2006 11:24:54 AM ******/
CREATE TABLE [dbo].[Departments] (
	[DeptID] [int] IDENTITY (1, 1) NOT NULL ,
	[Dept] [varchar] (50) COLLATE SQL_Latin1_General_CP1_CI_AS NULL ,
	[DeptNum] [varchar] (6) COLLATE SQL_Latin1_General_CP1_CI_AS NULL 
) ON [PRIMARY]
GO

/****** Object:  Table [dbo].[Eclipsys_ChangeControlLog]    Script Date: 7/14/2006 11:24:54 AM ******/
CREATE TABLE [dbo].[Eclipsys_ChangeControlLog] (
	[EntryID] [int] IDENTITY (1, 1) NOT NULL ,
	[EntryDt] [datetime] NOT NULL ,
	[UsernameID] [int] NOT NULL ,
	[SystemID] [int] NOT NULL ,
	[SysTpID] [int] NOT NULL ,
	[Comment] [nvarchar] (2000) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL ,
	[ProductID] [int] NOT NULL ,
	[ClusterID] [int] NOT NULL ,
	[ResourceGroupID] [int] NOT NULL ,
	[EffectiveDt] [datetime] NOT NULL 
) ON [PRIMARY]
GO

/****** Object:  Table [dbo].[Eclipsys_Clusters]    Script Date: 7/14/2006 11:24:54 AM ******/
CREATE TABLE [dbo].[Eclipsys_Clusters] (
	[ClusterID] [int] IDENTITY (1, 1) NOT NULL ,
	[Cluster] [varchar] (50) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL 
) ON [PRIMARY]
GO

/****** Object:  Table [dbo].[Eclipsys_Products]    Script Date: 7/14/2006 11:24:54 AM ******/
CREATE TABLE [dbo].[Eclipsys_Products] (
	[ProductID] [int] IDENTITY (1, 1) NOT NULL ,
	[ProductNm] [varchar] (50) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL 
) ON [PRIMARY]
GO

/****** Object:  Table [dbo].[Eclipsys_ResourceGroup]    Script Date: 7/14/2006 11:24:54 AM ******/
CREATE TABLE [dbo].[Eclipsys_ResourceGroup] (
	[ResGrpID] [int] IDENTITY (1, 1) NOT NULL ,
	[ResGrp] [varchar] (50) COLLATE SQL_Latin1_General_CP1_CI_AS NULL 
) ON [PRIMARY]
GO

/****** Object:  Table [dbo].[Eclipsys_SysTypes]    Script Date: 7/14/2006 11:24:54 AM ******/
CREATE TABLE [dbo].[Eclipsys_SysTypes] (
	[SysTpID] [int] IDENTITY (1, 1) NOT NULL ,
	[SysTpNm] [varchar] (50) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL 
) ON [PRIMARY]
GO

/****** Object:  Table [dbo].[Eclipsys_Systems]    Script Date: 7/14/2006 11:24:54 AM ******/
CREATE TABLE [dbo].[Eclipsys_Systems] (
	[SystemID] [int] IDENTITY (1, 1) NOT NULL ,
	[SystemNm] [varchar] (20) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL ,
	[Alias] [varchar] (20) COLLATE SQL_Latin1_General_CP1_CI_AS NULL 
) ON [PRIMARY]
GO

/****** Object:  Table [dbo].[Eclipsys_UserList]    Script Date: 7/14/2006 11:24:54 AM ******/
CREATE TABLE [dbo].[Eclipsys_UserList] (
	[UsernameID] [int] IDENTITY (1, 1) NOT NULL ,
	[Username] [varchar] (30) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL 
) ON [PRIMARY]
GO

/****** Object:  Table [dbo].[Employees]    Script Date: 7/14/2006 11:24:54 AM ******/
CREATE TABLE [dbo].[Employees] (
	[Username] [nvarchar] (7) COLLATE SQL_Latin1_General_CP1_CI_AS NULL ,
	[dept_nbr] [varchar] (50) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL ,
	[dept_name] [varchar] (250) COLLATE SQL_Latin1_General_CP1_CI_AS NULL ,
	[MGR_NAME] [varchar] (32) COLLATE SQL_Latin1_General_CP1_CI_AS NULL ,
	[fullname] [varchar] (64) COLLATE SQL_Latin1_General_CP1_CI_AS NULL ,
	[LASTNAME] [varchar] (30) COLLATE SQL_Latin1_General_CP1_CI_AS NULL ,
	[FIRSTNAME] [varchar] (30) COLLATE SQL_Latin1_General_CP1_CI_AS NULL ,
	[EmployeeNumber] [varchar] (10) COLLATE SQL_Latin1_General_CP1_CI_AS NULL ,
	[jobcode] [varchar] (50) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL ,
	[jobname] [varchar] (250) COLLATE SQL_Latin1_General_CP1_CI_AS NULL ,
	[EmpNum] [varchar] (10) COLLATE SQL_Latin1_General_CP1_CI_AS NULL ,
	[StatusCode] [char] (1) COLLATE SQL_Latin1_General_CP1_CI_AS NULL 
) ON [PRIMARY]
GO

/****** Object:  Table [dbo].[FormActions]    Script Date: 7/14/2006 11:24:54 AM ******/
CREATE TABLE [dbo].[FormActions] (
	[ActionID] [int] IDENTITY (1, 1) NOT NULL ,
	[FormAction] [char] (10) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL 
) ON [PRIMARY]
GO

/****** Object:  Table [dbo].[FormApprvlGrp]    Script Date: 7/14/2006 11:24:54 AM ******/
CREATE TABLE [dbo].[FormApprvlGrp] (
	[ApprvlGrpID] [int] NOT NULL ,
	[ApprvlGrp] [varchar] (50) COLLATE SQL_Latin1_General_CP1_CI_AS NULL 
) ON [PRIMARY]
GO

/****** Object:  Table [dbo].[FormsAPVLTypesLkpLst]    Script Date: 7/14/2006 11:24:54 AM ******/
CREATE TABLE [dbo].[FormsAPVLTypesLkpLst] (
	[APVLType] [char] (4) COLLATE SQL_Latin1_General_CP1_CI_AS NULL ,
	[APVLTypeID] [int] IDENTITY (1, 1) NOT NULL 
) ON [PRIMARY]
GO

/****** Object:  Table [dbo].[FormsDeptLkpLst]    Script Date: 7/14/2006 11:24:54 AM ******/
CREATE TABLE [dbo].[FormsDeptLkpLst] (
	[DeptID] [varchar] (50) COLLATE SQL_Latin1_General_CP1_CI_AS NULL ,
	[Dept] [varchar] (50) COLLATE SQL_Latin1_General_CP1_CI_AS NULL 
) ON [PRIMARY]
GO

/****** Object:  Table [dbo].[FormsPtChartLkpLst]    Script Date: 7/14/2006 11:24:54 AM ******/
CREATE TABLE [dbo].[FormsPtChartLkpLst] (
	[PtChrt] [char] (1) COLLATE SQL_Latin1_General_CP1_CI_AS NULL ,
	[PtChartID] [int] NOT NULL 
) ON [PRIMARY]
GO

/****** Object:  Table [dbo].[FormsUOMLkpLst]    Script Date: 7/14/2006 11:24:54 AM ******/
CREATE TABLE [dbo].[FormsUOMLkpLst] (
	[UnitOfMeasure] [char] (10) COLLATE SQL_Latin1_General_CP1_CI_AS NULL ,
	[UOMid] [int] IDENTITY (1, 1) NOT NULL 
) ON [PRIMARY]
GO

/****** Object:  Table [dbo].[FromsPtChartLkpLst]    Script Date: 7/14/2006 11:24:55 AM ******/
CREATE TABLE [dbo].[FromsPtChartLkpLst] (
	[PtChrt] [char] (1) COLLATE SQL_Latin1_General_CP1_CI_AS NULL ,
	[PtChrtId] [int] IDENTITY (1, 1) NOT NULL 
) ON [PRIMARY]
GO

/****** Object:  Table [dbo].[LawCRAccLvlLkp]    Script Date: 7/14/2006 11:24:55 AM ******/
CREATE TABLE [dbo].[LawCRAccLvlLkp] (
	[AccLvl] [int] NOT NULL ,
	[AccLvlName] [varchar] (20) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL ,
	[AccLvlID] [int] IDENTITY (1, 1) NOT NULL ,
	[FormsOnly] [int] NULL 
) ON [PRIMARY]
GO

/****** Object:  Table [dbo].[LawCRDBLogin]    Script Date: 7/14/2006 11:24:55 AM ******/
CREATE TABLE [dbo].[LawCRDBLogin] (
	[LoginID] [int] IDENTITY (1, 1) NOT NULL ,
	[Login] [varchar] (255) COLLATE SQL_Latin1_General_CP1_CI_AS NULL ,
	[Owner] [varchar] (10) COLLATE SQL_Latin1_General_CP1_CI_AS NULL ,
	[Description] [varchar] (50) COLLATE SQL_Latin1_General_CP1_CI_AS NULL 
) ON [PRIMARY]
GO

/****** Object:  Table [dbo].[LawCRDeptLkpLst]    Script Date: 7/14/2006 11:24:55 AM ******/
CREATE TABLE [dbo].[LawCRDeptLkpLst] (
	[Dept] [varchar] (50) COLLATE SQL_Latin1_General_CP1_CI_AS NULL ,
	[DeptNum] [varchar] (6) COLLATE SQL_Latin1_General_CP1_CI_AS NULL 
) ON [PRIMARY]
GO

/****** Object:  Table [dbo].[LawCRDirLkpLstVw]    Script Date: 7/14/2006 11:24:55 AM ******/
CREATE TABLE [dbo].[LawCRDirLkpLstVw] (
	[Directory] [varchar] (50) COLLATE SQL_Latin1_General_CP1_CI_AS NULL ,
	[RptName] [varchar] (255) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL 
) ON [PRIMARY]
GO

/****** Object:  Table [dbo].[LawCRDirectories]    Script Date: 7/14/2006 11:24:55 AM ******/
CREATE TABLE [dbo].[LawCRDirectories] (
	[DirectoryID] [int] IDENTITY (1, 1) NOT NULL ,
	[Directory] [varchar] (100) COLLATE SQL_Latin1_General_CP1_CI_AS NULL ,
	[Path] [varchar] (100) COLLATE SQL_Latin1_General_CP1_CI_AS NULL ,
	[Owner] [char] (10) COLLATE SQL_Latin1_General_CP1_CI_AS NULL ,
	[Dept] [char] (10) COLLATE SQL_Latin1_General_CP1_CI_AS NULL 
) ON [PRIMARY]
GO

/****** Object:  Table [dbo].[LawCRDocStatus]    Script Date: 7/14/2006 11:24:55 AM ******/
CREATE TABLE [dbo].[LawCRDocStatus] (
	[DocStatus] [char] (10) COLLATE SQL_Latin1_General_CP1_CI_AS NULL ,
	[DocStatusID] [int] NOT NULL 
) ON [PRIMARY]
GO

/****** Object:  Table [dbo].[LawCRGroupMembers]    Script Date: 7/14/2006 11:24:55 AM ******/
CREATE TABLE [dbo].[LawCRGroupMembers] (
	[MemberID] [int] IDENTITY (1, 1) NOT NULL ,
	[GroupID] [int] NOT NULL ,
	[Member] [varchar] (50) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL 
) ON [PRIMARY]
GO

/****** Object:  Table [dbo].[LawCRGroups]    Script Date: 7/14/2006 11:24:55 AM ******/
CREATE TABLE [dbo].[LawCRGroups] (
	[GroupID] [int] IDENTITY (1, 1) NOT NULL ,
	[Owner] [varchar] (50) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL ,
	[GroupName] [varchar] (50) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL 
) ON [PRIMARY]
GO

/****** Object:  Table [dbo].[LawCrReports]    Script Date: 7/14/2006 11:24:55 AM ******/
CREATE TABLE [dbo].[LawCrReports] (
	[RptName] [varchar] (255) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL ,
	[RptLoginInfo] [varchar] (255) COLLATE SQL_Latin1_General_CP1_CI_AS NULL ,
	[Keywords] [varchar] (255) COLLATE SQL_Latin1_General_CP1_CI_AS NULL ,
	[RptID] [int] IDENTITY (1, 1) NOT NULL ,
	[LinkName] [varchar] (255) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL ,
	[Dept] [varchar] (500) COLLATE SQL_Latin1_General_CP1_CI_AS NULL ,
	[Folder] [varchar] (255) COLLATE SQL_Latin1_General_CP1_CI_AS NULL ,
	[Owner] [varchar] (10) COLLATE SQL_Latin1_General_CP1_CI_AS NULL ,
	[DateTimeStamp] [datetime] NULL ,
	[MultiAcces] [varchar] (500) COLLATE SQL_Latin1_General_CP1_CI_AS NULL ,
	[Status] [int] NULL ,
	[FormNum] [varchar] (10) COLLATE SQL_Latin1_General_CP1_CI_AS NULL ,
	[GroupID] [int] NULL 
) ON [PRIMARY]
GO

/****** Object:  Table [dbo].[LawCrSecurity]    Script Date: 7/14/2006 11:24:55 AM ******/
CREATE TABLE [dbo].[LawCrSecurity] (
	[UserID] [int] IDENTITY (1, 1) NOT NULL ,
	[UserName] [varchar] (7) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL ,
	[Dept] [varchar] (50) COLLATE SQL_Latin1_General_CP1_CI_AS NULL ,
	[AccLvl] [char] (1) COLLATE SQL_Latin1_General_CP1_CI_AS NULL ,
	[Owner] [varchar] (7) COLLATE SQL_Latin1_General_CP1_CI_AS NULL ,
	[Active] [int] NULL ,
	[UserAdmin] [char] (1) COLLATE SQL_Latin1_General_CP1_CI_AS NULL ,
	[MaxFolderSize] [int] NULL ,
	[MaxUploadSize] [int] NULL ,
	[Password] [varchar] (10) COLLATE SQL_Latin1_General_CP1_CI_AS NULL 
) ON [PRIMARY]
GO

/****** Object:  Table [dbo].[LawCrSecurityAudit]    Script Date: 7/14/2006 11:24:55 AM ******/
CREATE TABLE [dbo].[LawCrSecurityAudit] (
	[AuditId] [int] IDENTITY (1, 1) NOT NULL ,
	[Employee] [char] (10) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL ,
	[Report] [varchar] (50) COLLATE SQL_Latin1_General_CP1_CI_AS NULL ,
	[Filename] [varchar] (50) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL ,
	[Owner] [char] (10) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL ,
	[Datetimestamp] [datetime] NOT NULL 
) ON [PRIMARY]
GO

/****** Object:  Table [dbo].[MuseUsers]    Script Date: 7/14/2006 11:24:55 AM ******/
CREATE TABLE [dbo].[MuseUsers] (
	[LoginID] [varchar] (10) COLLATE SQL_Latin1_General_CP1_CI_AS NULL ,
	[UserLevel] [varchar] (10) COLLATE SQL_Latin1_General_CP1_CI_AS NULL ,
	[FirstName] [varchar] (10) COLLATE SQL_Latin1_General_CP1_CI_AS NULL ,
	[LastName] [varchar] (50) COLLATE SQL_Latin1_General_CP1_CI_AS NULL 
) ON [PRIMARY]
GO

/****** Object:  Table [dbo].[New Table]    Script Date: 7/14/2006 11:24:55 AM ******/
CREATE TABLE [dbo].[New Table] (
	[DISCHARGED] [datetime] NULL ,
	[CLINIC] [char] (10) COLLATE SQL_Latin1_General_CP1_CI_AS NULL ,
	[MRN] [char] (20) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL ,
	[ENCOUNTER] [char] (20) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL ,
	[NAME] [char] (40) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL ,
	[DOCUMENT] [char] (30) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL ,
	[IMAGEDATE] [datetime] NOT NULL 
) ON [PRIMARY]
GO

/****** Object:  Table [dbo].[PayrollTest]    Script Date: 7/14/2006 11:24:55 AM ******/
CREATE TABLE [dbo].[PayrollTest] (
	[RecordID] [int] IDENTITY (1, 1) NOT NULL ,
	[EarnCode] [char] (10) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL ,
	[ShiftCode] [char] (10) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL ,
	[Hours] [int] NOT NULL ,
	[Date] [char] (10) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL ,
	[Department] [char] (10) COLLATE SQL_Latin1_General_CP1_CI_AS NULL 
) ON [PRIMARY]
GO

/****** Object:  Table [dbo].[REVMAS]    Script Date: 7/14/2006 11:24:55 AM ******/
CREATE TABLE [dbo].[REVMAS] (
	[PROCESS_DT] [datetime] NULL ,
	[COST_CTR] [decimal](4, 0) NULL ,
	[SUB_CCTR] [varchar] (1) COLLATE SQL_Latin1_General_CP1_CI_AS NULL ,
	[PROC_NBR] [decimal](8, 0) NULL ,
	[FIN_CLASS] [varchar] (2) COLLATE SQL_Latin1_General_CP1_CI_AS NULL ,
	[PT_GRP] [varchar] (1) COLLATE SQL_Latin1_General_CP1_CI_AS NULL ,
	[YTD_AMT1] [decimal](16, 2) NULL ,
	[YTD_QTY1] [decimal](16, 0) NULL ,
	[YTD_AMT2] [decimal](16, 2) NULL ,
	[YTD_QTY2] [decimal](16, 0) NULL ,
	[YTD_AMT3] [decimal](16, 2) NULL ,
	[YTD_QTY3] [decimal](16, 0) NULL ,
	[YTD_AMT4] [decimal](16, 2) NULL ,
	[YTD_QTY4] [decimal](16, 0) NULL ,
	[YTD_AMT5] [decimal](16, 2) NULL ,
	[YTD_QTY5] [decimal](16, 0) NULL ,
	[YTD_AMT6] [decimal](16, 2) NULL ,
	[YTD_QTY6] [decimal](16, 0) NULL ,
	[YTD_AMT7] [decimal](16, 2) NULL ,
	[YTD_QTY7] [decimal](16, 0) NULL ,
	[YTD_AMT8] [decimal](16, 2) NULL ,
	[YTD_QTY8] [decimal](16, 0) NULL ,
	[YTD_AMT9] [decimal](16, 2) NULL ,
	[YTD_QTY9] [decimal](16, 0) NULL ,
	[YTD_AMT10] [decimal](16, 2) NULL ,
	[YTD_QTY10] [decimal](16, 0) NULL ,
	[YTD_AMT11] [decimal](16, 2) NULL ,
	[YTD_QTY11] [decimal](16, 0) NULL ,
	[YTD_AMT12] [decimal](16, 2) NULL ,
	[YTD_QTY12] [decimal](16, 0) NULL ,
	[YTD_AMT13] [decimal](16, 2) NULL ,
	[YTD_QTY13] [decimal](16, 0) NULL ,
	[YTD_QTY_TOT] [decimal](16, 0) NULL ,
	[YTD_AMT_TOT] [decimal](16, 2) NULL ,
	[DATE_ADDED] [datetime] NULL ,
	[DATE_MODIFIED] [datetime] NULL ,
	[BY_WHOM] [decimal](8, 0) NULL 
) ON [PRIMARY]
GO

/****** Object:  Table [dbo].[Results]    Script Date: 7/14/2006 11:24:56 AM ******/
CREATE TABLE [dbo].[Results] (
	[OCMID] [float] NULL ,
	[Application] [nvarchar] (255) COLLATE SQL_Latin1_General_CP1_CI_AS NULL ,
	[AppPriority] [float] NULL ,
	[HostID] [float] NULL ,
	[HostName] [nvarchar] (255) COLLATE SQL_Latin1_General_CP1_CI_AS NULL ,
	[HostPriority] [float] NULL 
) ON [PRIMARY]
GO

/****** Object:  Table [dbo].[SxaUrlAuthentication]    Script Date: 7/14/2006 11:24:56 AM ******/
CREATE TABLE [dbo].[SxaUrlAuthentication] (
	[LogonName] [char] (8) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL ,
	[AppName] [char] (10) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL ,
	[AppID] [char] (16) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL ,
	[AppPass] [char] (36) COLLATE SQL_Latin1_General_CP1_CI_AS NULL 
) ON [PRIMARY]
GO

/****** Object:  Table [dbo].[UA_All_Exceptions]    Script Date: 7/14/2006 11:24:56 AM ******/
CREATE TABLE [dbo].[UA_All_Exceptions] (
	[empid] [int] NULL ,
	[Application] [varchar] (12) COLLATE SQL_Latin1_General_CP1_CI_AS NULL ,
	[dept_nbr] [varchar] (50) COLLATE SQL_Latin1_General_CP1_CI_AS NULL ,
	[dept_name] [varchar] (250) COLLATE SQL_Latin1_General_CP1_CI_AS NULL ,
	[MGR_NAME] [varchar] (32) COLLATE SQL_Latin1_General_CP1_CI_AS NULL ,
	[fullname] [varchar] (64) COLLATE SQL_Latin1_General_CP1_CI_AS NULL ,
	[jobcode] [varchar] (50) COLLATE SQL_Latin1_General_CP1_CI_AS NULL ,
	[jobname] [varchar] (250) COLLATE SQL_Latin1_General_CP1_CI_AS NULL ,
	[EMPIDApp] [decimal](10, 0) NULL ,
	[LOGIN_ID] [varchar] (16) COLLATE SQL_Latin1_General_CP1_CI_AS NULL ,
	[EMP_NAME] [varchar] (64) COLLATE SQL_Latin1_General_CP1_CI_AS NULL ,
	[EMP_LAST_NAME] [varchar] (32) COLLATE SQL_Latin1_General_CP1_CI_AS NULL ,
	[EMP_FIRST_NAME] [varchar] (32) COLLATE SQL_Latin1_General_CP1_CI_AS NULL ,
	[EMP_MID_INIT] [char] (1) COLLATE SQL_Latin1_General_CP1_CI_AS NULL ,
	[EMP_INITIALS] [varchar] (4) COLLATE SQL_Latin1_General_CP1_CI_AS NULL ,
	[DEL_FLAG] [char] (1) COLLATE SQL_Latin1_General_CP1_CI_AS NULL ,
	[DEL_DATE] [varchar] (50) COLLATE SQL_Latin1_General_CP1_CI_AS NULL ,
	[INACT_FLAG] [char] (1) COLLATE SQL_Latin1_General_CP1_CI_AS NULL ,
	[INACT_DATE] [varchar] (50) COLLATE SQL_Latin1_General_CP1_CI_AS NULL ,
	[SYSTEM_ID] [nvarchar] (384) COLLATE SQL_Latin1_General_CP1_CI_AS NULL ,
	[CMD_LINE_FLAG] [char] (1) COLLATE SQL_Latin1_General_CP1_CI_AS NULL ,
	[SU_FLAG] [char] (1) COLLATE SQL_Latin1_General_CP1_CI_AS NULL ,
	[INIT_FNCT] [varchar] (30) COLLATE SQL_Latin1_General_CP1_CI_AS NULL ,
	[APP_SEC_CLASS] [varchar] (256) COLLATE SQL_Latin1_General_CP1_CI_AS NULL ,
	[COMMENTS] [varchar] (256) COLLATE SQL_Latin1_General_CP1_CI_AS NULL ,
	[DATE_ADDED] [varchar] (50) COLLATE SQL_Latin1_General_CP1_CI_AS NULL ,
	[DATE_MODIFIED] [varchar] (50) COLLATE SQL_Latin1_General_CP1_CI_AS NULL ,
	[RecordID] [int] IDENTITY (1, 1) NOT NULL 
) ON [PRIMARY]
GO

/****** Object:  Table [dbo].[UA_All_Other_Logins]    Script Date: 7/14/2006 11:24:56 AM ******/
CREATE TABLE [dbo].[UA_All_Other_Logins] (
	[RecordID] [int] IDENTITY (1, 1) NOT NULL ,
	[Application] [varchar] (12) COLLATE SQL_Latin1_General_CP1_CI_AS NULL ,
	[dept_nbr] [varchar] (50) COLLATE SQL_Latin1_General_CP1_CI_AS NULL ,
	[dept_name] [varchar] (250) COLLATE SQL_Latin1_General_CP1_CI_AS NULL ,
	[MGR_NAME] [varchar] (32) COLLATE SQL_Latin1_General_CP1_CI_AS NULL ,
	[fullname] [varchar] (64) COLLATE SQL_Latin1_General_CP1_CI_AS NULL ,
	[empid] [nvarchar] (384) COLLATE SQL_Latin1_General_CP1_CI_AS NULL ,
	[jobcode] [varchar] (50) COLLATE SQL_Latin1_General_CP1_CI_AS NULL ,
	[jobname] [varchar] (250) COLLATE SQL_Latin1_General_CP1_CI_AS NULL ,
	[EMPIDApp] [decimal](10, 0) NULL ,
	[LOGIN_ID] [varchar] (16) COLLATE SQL_Latin1_General_CP1_CI_AS NULL ,
	[EMP_NAME] [varchar] (64) COLLATE SQL_Latin1_General_CP1_CI_AS NULL ,
	[EMP_LAST_NAME] [varchar] (32) COLLATE SQL_Latin1_General_CP1_CI_AS NULL ,
	[EMP_FIRST_NAME] [varchar] (32) COLLATE SQL_Latin1_General_CP1_CI_AS NULL ,
	[EMP_MID_INIT] [char] (1) COLLATE SQL_Latin1_General_CP1_CI_AS NULL ,
	[EMP_INITIALS] [varchar] (4) COLLATE SQL_Latin1_General_CP1_CI_AS NULL ,
	[DEL_FLAG] [char] (1) COLLATE SQL_Latin1_General_CP1_CI_AS NULL ,
	[DEL_DATE] [datetime] NULL ,
	[INACT_FLAG] [char] (1) COLLATE SQL_Latin1_General_CP1_CI_AS NULL ,
	[INACT_DATE] [datetime] NULL ,
	[SYSTEM_ID] [nvarchar] (384) COLLATE SQL_Latin1_General_CP1_CI_AS NULL ,
	[CMD_LINE_FLAG] [char] (1) COLLATE SQL_Latin1_General_CP1_CI_AS NULL ,
	[SU_FLAG] [char] (1) COLLATE SQL_Latin1_General_CP1_CI_AS NULL ,
	[INIT_FNCT] [varchar] (30) COLLATE SQL_Latin1_General_CP1_CI_AS NULL ,
	[APP_SEC_CLASS] [varchar] (256) COLLATE SQL_Latin1_General_CP1_CI_AS NULL ,
	[COMMENTS] [varchar] (256) COLLATE SQL_Latin1_General_CP1_CI_AS NULL ,
	[DATE_ADDED] [datetime] NULL ,
	[DATE_MODIFIED] [datetime] NULL 
) ON [PRIMARY]
GO

/****** Object:  Table [dbo].[UserAccLvlLkpLst]    Script Date: 7/14/2006 11:24:56 AM ******/
CREATE TABLE [dbo].[UserAccLvlLkpLst] (
	[AccLvlID] [int] NOT NULL ,
	[AccLvl] [int] NOT NULL ,
	[AccLvlName] [char] (10) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL 
) ON [PRIMARY]
GO

/****** Object:  Table [dbo].[UserAccessAll]    Script Date: 7/14/2006 11:24:56 AM ******/
CREATE TABLE [dbo].[UserAccessAll] (
	[RecordID] [int] IDENTITY (1, 1) NOT NULL ,
	[Application] [varchar] (12) COLLATE SQL_Latin1_General_CP1_CI_AS NULL ,
	[dept_nbr] [varchar] (50) COLLATE SQL_Latin1_General_CP1_CI_AS NULL ,
	[dept_name] [varchar] (250) COLLATE SQL_Latin1_General_CP1_CI_AS NULL ,
	[MGR_NAME] [varchar] (32) COLLATE SQL_Latin1_General_CP1_CI_AS NULL ,
	[fullname] [varchar] (64) COLLATE SQL_Latin1_General_CP1_CI_AS NULL ,
	[empid] [nvarchar] (384) COLLATE SQL_Latin1_General_CP1_CI_AS NULL ,
	[jobcode] [varchar] (50) COLLATE SQL_Latin1_General_CP1_CI_AS NULL ,
	[jobname] [varchar] (250) COLLATE SQL_Latin1_General_CP1_CI_AS NULL ,
	[EMPIDApp] [decimal](10, 0) NULL ,
	[LOGIN_ID] [varchar] (16) COLLATE SQL_Latin1_General_CP1_CI_AS NULL ,
	[EMP_NAME] [varchar] (64) COLLATE SQL_Latin1_General_CP1_CI_AS NULL ,
	[EMP_LAST_NAME] [varchar] (32) COLLATE SQL_Latin1_General_CP1_CI_AS NULL ,
	[EMP_FIRST_NAME] [varchar] (32) COLLATE SQL_Latin1_General_CP1_CI_AS NULL ,
	[EMP_MID_INIT] [char] (1) COLLATE SQL_Latin1_General_CP1_CI_AS NULL ,
	[EMP_INITIALS] [varchar] (4) COLLATE SQL_Latin1_General_CP1_CI_AS NULL ,
	[DEL_FLAG] [char] (1) COLLATE SQL_Latin1_General_CP1_CI_AS NULL ,
	[DEL_DATE] [datetime] NULL ,
	[INACT_FLAG] [char] (1) COLLATE SQL_Latin1_General_CP1_CI_AS NULL ,
	[INACT_DATE] [datetime] NULL ,
	[SYSTEM_ID] [nvarchar] (384) COLLATE SQL_Latin1_General_CP1_CI_AS NULL ,
	[CMD_LINE_FLAG] [char] (1) COLLATE SQL_Latin1_General_CP1_CI_AS NULL ,
	[SU_FLAG] [char] (1) COLLATE SQL_Latin1_General_CP1_CI_AS NULL ,
	[INIT_FNCT] [varchar] (30) COLLATE SQL_Latin1_General_CP1_CI_AS NULL ,
	[APP_SEC_CLASS] [varchar] (256) COLLATE SQL_Latin1_General_CP1_CI_AS NULL ,
	[COMMENTS] [varchar] (256) COLLATE SQL_Latin1_General_CP1_CI_AS NULL ,
	[DATE_ADDED] [datetime] NULL ,
	[DATE_MODIFIED] [datetime] NULL 
) ON [PRIMARY]
GO

/****** Object:  Table [dbo].[UserSecOpsLst]    Script Date: 7/14/2006 11:24:56 AM ******/
CREATE TABLE [dbo].[UserSecOpsLst] (
	[OperatorID] [int] NOT NULL ,
	[Operator] [varchar] (10) COLLATE SQL_Latin1_General_CP1_CI_AS NULL 
) ON [PRIMARY]
GO

/****** Object:  Table [dbo].[UserSecurity]    Script Date: 7/14/2006 11:24:56 AM ******/
CREATE TABLE [dbo].[UserSecurity] (
	[UserID] [int] IDENTITY (9, 1) NOT NULL ,
	[UserName] [varchar] (10) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL ,
	[Dept] [varchar] (50) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL ,
	[AccLvl] [char] (1) COLLATE SQL_Latin1_General_CP1_CI_AS NULL ,
	[Active] [int] NOT NULL ,
	[Password] [varchar] (10) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL 
) ON [PRIMARY]
GO

/****** Object:  Table [dbo].[epi_user_sec]    Script Date: 7/14/2006 11:24:56 AM ******/
CREATE TABLE [dbo].[epi_user_sec] (
	[EMPID] [varchar] (4) COLLATE SQL_Latin1_General_CP1_CI_AS NULL ,
	[LOGIN_ID] [varchar] (10) COLLATE SQL_Latin1_General_CP1_CI_AS NULL ,
	[LEVELS] [varchar] (255) COLLATE SQL_Latin1_General_CP1_CI_AS NULL ,
	[USER_TYPE] [decimal](12, 0) NULL ,
	[FIRST_NAME] [varchar] (15) COLLATE SQL_Latin1_General_CP1_CI_AS NULL ,
	[LAST_NAME] [varchar] (15) COLLATE SQL_Latin1_General_CP1_CI_AS NULL ,
	[SYSTEM_ID] [decimal](12, 0) NOT NULL 
) ON [PRIMARY]
GO

/****** Object:  Table [dbo].[escriptionusers]    Script Date: 7/14/2006 11:24:57 AM ******/
CREATE TABLE [dbo].[escriptionusers] (
	[LastName] [varchar] (55) COLLATE SQL_Latin1_General_CP1_CI_AS NULL ,
	[FirstName] [varchar] (55) COLLATE SQL_Latin1_General_CP1_CI_AS NULL ,
	[Login] [varchar] (25) COLLATE SQL_Latin1_General_CP1_CI_AS NULL 
) ON [PRIMARY]
GO

/****** Object:  Table [dbo].[exportadinfo]    Script Date: 7/14/2006 11:24:57 AM ******/
CREATE TABLE [dbo].[exportadinfo] (
	[APP_SEC_CLASS] [varchar] (256) COLLATE SQL_Latin1_General_CP1_CI_AS NULL ,
	[COMMENTS] [varchar] (256) COLLATE SQL_Latin1_General_CP1_CI_AS NULL ,
	[LOGIN_ID] [varchar] (16) COLLATE SQL_Latin1_General_CP1_CI_AS NULL ,
	[EMP_NAME] [varchar] (64) COLLATE SQL_Latin1_General_CP1_CI_AS NULL ,
	[objectClass] [varchar] (25) COLLATE SQL_Latin1_General_CP1_CI_AS NULL 
) ON [PRIMARY]
GO

