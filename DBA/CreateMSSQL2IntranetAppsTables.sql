/****** Object:  Database IntranetApps    Script Date: 7/14/2006 11:26:34 AM ******/
IF EXISTS (SELECT name FROM master.dbo.sysdatabases WHERE name = N'IntranetApps')
	DROP DATABASE [IntranetApps]
GO

CREATE DATABASE [IntranetApps]  ON (NAME = N'IntranetApps_Data', FILENAME = N'D:\MSSQL\data\IntranetApps_Data.MDF' , SIZE = 100, FILEGROWTH = 10%) LOG ON (NAME = N'IntranetApps_Log', FILENAME = N'D:\MSSQL\data\IntranetApps_Log.LDF' , SIZE = 14947, FILEGROWTH = 10%)
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

exec sp_dboption N'IntranetApps', N'auto create statistics', N'false'
GO

exec sp_dboption N'IntranetApps', N'auto update statistics', N'true'
GO

if( (@@microsoftversion / power(2, 24) = 8) and (@@microsoftversion & 0xffff >= 724) )
	exec sp_dboption N'IntranetApps', N'db chaining', N'false'
GO

use [IntranetApps]
GO

/****** Object:  Table [dbo].[ADContactInfo]    Script Date: 7/14/2006 11:26:37 AM ******/
if exists (select * from dbo.sysobjects where id = object_id(N'[dbo].[ADContactInfo]') and OBJECTPROPERTY(id, N'IsUserTable') = 1)
drop table [dbo].[ADContactInfo]
GO

/****** Object:  Table [dbo].[AmPfmAccLvlLkp]    Script Date: 7/14/2006 11:26:37 AM ******/
if exists (select * from dbo.sysobjects where id = object_id(N'[dbo].[AmPfmAccLvlLkp]') and OBJECTPROPERTY(id, N'IsUserTable') = 1)
drop table [dbo].[AmPfmAccLvlLkp]
GO

/****** Object:  Table [dbo].[AmPfmDirectories]    Script Date: 7/14/2006 11:26:37 AM ******/
if exists (select * from dbo.sysobjects where id = object_id(N'[dbo].[AmPfmDirectories]') and OBJECTPROPERTY(id, N'IsUserTable') = 1)
drop table [dbo].[AmPfmDirectories]
GO

/****** Object:  Table [dbo].[AmPfmFrequency]    Script Date: 7/14/2006 11:26:37 AM ******/
if exists (select * from dbo.sysobjects where id = object_id(N'[dbo].[AmPfmFrequency]') and OBJECTPROPERTY(id, N'IsUserTable') = 1)
drop table [dbo].[AmPfmFrequency]
GO

/****** Object:  Table [dbo].[AmPfmGroupMembers]    Script Date: 7/14/2006 11:26:37 AM ******/
if exists (select * from dbo.sysobjects where id = object_id(N'[dbo].[AmPfmGroupMembers]') and OBJECTPROPERTY(id, N'IsUserTable') = 1)
drop table [dbo].[AmPfmGroupMembers]
GO

/****** Object:  Table [dbo].[AmPfmGroups]    Script Date: 7/14/2006 11:26:37 AM ******/
if exists (select * from dbo.sysobjects where id = object_id(N'[dbo].[AmPfmGroups]') and OBJECTPROPERTY(id, N'IsUserTable') = 1)
drop table [dbo].[AmPfmGroups]
GO

/****** Object:  Table [dbo].[AmPfmReports]    Script Date: 7/14/2006 11:26:37 AM ******/
if exists (select * from dbo.sysobjects where id = object_id(N'[dbo].[AmPfmReports]') and OBJECTPROPERTY(id, N'IsUserTable') = 1)
drop table [dbo].[AmPfmReports]
GO

/****** Object:  Table [dbo].[AmPfmRptHistory]    Script Date: 7/14/2006 11:26:37 AM ******/
if exists (select * from dbo.sysobjects where id = object_id(N'[dbo].[AmPfmRptHistory]') and OBJECTPROPERTY(id, N'IsUserTable') = 1)
drop table [dbo].[AmPfmRptHistory]
GO

/****** Object:  Table [dbo].[AmPfmSecurity]    Script Date: 7/14/2006 11:26:37 AM ******/
if exists (select * from dbo.sysobjects where id = object_id(N'[dbo].[AmPfmSecurity]') and OBJECTPROPERTY(id, N'IsUserTable') = 1)
drop table [dbo].[AmPfmSecurity]
GO

/****** Object:  Table [dbo].[AmPfmSecurityAudit]    Script Date: 7/14/2006 11:26:37 AM ******/
if exists (select * from dbo.sysobjects where id = object_id(N'[dbo].[AmPfmSecurityAudit]') and OBJECTPROPERTY(id, N'IsUserTable') = 1)
drop table [dbo].[AmPfmSecurityAudit]
GO

/****** Object:  Table [dbo].[AmPfmTemplates]    Script Date: 7/14/2006 11:26:37 AM ******/
if exists (select * from dbo.sysobjects where id = object_id(N'[dbo].[AmPfmTemplates]') and OBJECTPROPERTY(id, N'IsUserTable') = 1)
drop table [dbo].[AmPfmTemplates]
GO

/****** Object:  Table [dbo].[Departments]    Script Date: 7/14/2006 11:26:37 AM ******/
if exists (select * from dbo.sysobjects where id = object_id(N'[dbo].[Departments]') and OBJECTPROPERTY(id, N'IsUserTable') = 1)
drop table [dbo].[Departments]
GO

/****** Object:  Table [dbo].[DeptLkpLst]    Script Date: 7/14/2006 11:26:37 AM ******/
if exists (select * from dbo.sysobjects where id = object_id(N'[dbo].[DeptLkpLst]') and OBJECTPROPERTY(id, N'IsUserTable') = 1)
drop table [dbo].[DeptLkpLst]
GO

/****** Object:  Table [dbo].[Doctors]    Script Date: 7/14/2006 11:26:37 AM ******/
if exists (select * from dbo.sysobjects where id = object_id(N'[dbo].[Doctors]') and OBJECTPROPERTY(id, N'IsUserTable') = 1)
drop table [dbo].[Doctors]
GO

/****** Object:  Table [dbo].[EPF_UserSecurity]    Script Date: 7/14/2006 11:26:37 AM ******/
if exists (select * from dbo.sysobjects where id = object_id(N'[dbo].[EPF_UserSecurity]') and OBJECTPROPERTY(id, N'IsUserTable') = 1)
drop table [dbo].[EPF_UserSecurity]
GO

/****** Object:  Table [dbo].[Employees]    Script Date: 7/14/2006 11:26:37 AM ******/
if exists (select * from dbo.sysobjects where id = object_id(N'[dbo].[Employees]') and OBJECTPROPERTY(id, N'IsUserTable') = 1)
drop table [dbo].[Employees]
GO

/****** Object:  Table [dbo].[MSO_Med_Prof]    Script Date: 7/14/2006 11:26:37 AM ******/
if exists (select * from dbo.sysobjects where id = object_id(N'[dbo].[MSO_Med_Prof]') and OBJECTPROPERTY(id, N'IsUserTable') = 1)
drop table [dbo].[MSO_Med_Prof]
GO

/****** Object:  Table [dbo].[MSO_med_prof_credentials]    Script Date: 7/14/2006 11:26:37 AM ******/
if exists (select * from dbo.sysobjects where id = object_id(N'[dbo].[MSO_med_prof_credentials]') and OBJECTPROPERTY(id, N'IsUserTable') = 1)
drop table [dbo].[MSO_med_prof_credentials]
GO

/****** Object:  Table [dbo].[MSO_med_prof_offices]    Script Date: 7/14/2006 11:26:37 AM ******/
if exists (select * from dbo.sysobjects where id = object_id(N'[dbo].[MSO_med_prof_offices]') and OBJECTPROPERTY(id, N'IsUserTable') = 1)
drop table [dbo].[MSO_med_prof_offices]
GO

/****** Object:  Table [dbo].[MSO_med_prof_specialties]    Script Date: 7/14/2006 11:26:37 AM ******/
if exists (select * from dbo.sysobjects where id = object_id(N'[dbo].[MSO_med_prof_specialties]') and OBJECTPROPERTY(id, N'IsUserTable') = 1)
drop table [dbo].[MSO_med_prof_specialties]
GO

/****** Object:  Table [dbo].[OCMFullOnCallMatrix]    Script Date: 7/14/2006 11:26:37 AM ******/
if exists (select * from dbo.sysobjects where id = object_id(N'[dbo].[OCMFullOnCallMatrix]') and OBJECTPROPERTY(id, N'IsUserTable') = 1)
drop table [dbo].[OCMFullOnCallMatrix]
GO

/****** Object:  Table [dbo].[OCMHostCCLog]    Script Date: 7/14/2006 11:26:37 AM ******/
if exists (select * from dbo.sysobjects where id = object_id(N'[dbo].[OCMHostCCLog]') and OBJECTPROPERTY(id, N'IsUserTable') = 1)
drop table [dbo].[OCMHostCCLog]
GO

/****** Object:  Table [dbo].[OCMLkpAppRecCkLst]    Script Date: 7/14/2006 11:26:37 AM ******/
if exists (select * from dbo.sysobjects where id = object_id(N'[dbo].[OCMLkpAppRecCkLst]') and OBJECTPROPERTY(id, N'IsUserTable') = 1)
drop table [dbo].[OCMLkpAppRecCkLst]
GO

/****** Object:  Table [dbo].[OCMLkpDBType]    Script Date: 7/14/2006 11:26:37 AM ******/
if exists (select * from dbo.sysobjects where id = object_id(N'[dbo].[OCMLkpDBType]') and OBJECTPROPERTY(id, N'IsUserTable') = 1)
drop table [dbo].[OCMLkpDBType]
GO

/****** Object:  Table [dbo].[OCMLkpDbEditions]    Script Date: 7/14/2006 11:26:37 AM ******/
if exists (select * from dbo.sysobjects where id = object_id(N'[dbo].[OCMLkpDbEditions]') and OBJECTPROPERTY(id, N'IsUserTable') = 1)
drop table [dbo].[OCMLkpDbEditions]
GO

/****** Object:  Table [dbo].[OCMLkpDwnTm]    Script Date: 7/14/2006 11:26:37 AM ******/
if exists (select * from dbo.sysobjects where id = object_id(N'[dbo].[OCMLkpDwnTm]') and OBJECTPROPERTY(id, N'IsUserTable') = 1)
drop table [dbo].[OCMLkpDwnTm]
GO

/****** Object:  Table [dbo].[OCMLkpHardPlat]    Script Date: 7/14/2006 11:26:37 AM ******/
if exists (select * from dbo.sysobjects where id = object_id(N'[dbo].[OCMLkpHardPlat]') and OBJECTPROPERTY(id, N'IsUserTable') = 1)
drop table [dbo].[OCMLkpHardPlat]
GO

/****** Object:  Table [dbo].[OCMLkpHost]    Script Date: 7/14/2006 11:26:37 AM ******/
if exists (select * from dbo.sysobjects where id = object_id(N'[dbo].[OCMLkpHost]') and OBJECTPROPERTY(id, N'IsUserTable') = 1)
drop table [dbo].[OCMLkpHost]
GO

/****** Object:  Table [dbo].[OCMLkpOS]    Script Date: 7/14/2006 11:26:37 AM ******/
if exists (select * from dbo.sysobjects where id = object_id(N'[dbo].[OCMLkpOS]') and OBJECTPROPERTY(id, N'IsUserTable') = 1)
drop table [dbo].[OCMLkpOS]
GO

/****** Object:  Table [dbo].[OCMLkpRacks]    Script Date: 7/14/2006 11:26:37 AM ******/
if exists (select * from dbo.sysobjects where id = object_id(N'[dbo].[OCMLkpRacks]') and OBJECTPROPERTY(id, N'IsUserTable') = 1)
drop table [dbo].[OCMLkpRacks]
GO

/****** Object:  Table [dbo].[OCMLkpRouter]    Script Date: 7/14/2006 11:26:37 AM ******/
if exists (select * from dbo.sysobjects where id = object_id(N'[dbo].[OCMLkpRouter]') and OBJECTPROPERTY(id, N'IsUserTable') = 1)
drop table [dbo].[OCMLkpRouter]
GO

/****** Object:  Table [dbo].[OCMLkpSuppGrp]    Script Date: 7/14/2006 11:26:37 AM ******/
if exists (select * from dbo.sysobjects where id = object_id(N'[dbo].[OCMLkpSuppGrp]') and OBJECTPROPERTY(id, N'IsUserTable') = 1)
drop table [dbo].[OCMLkpSuppGrp]
GO

/****** Object:  Table [dbo].[OCMLkpSupportDoc]    Script Date: 7/14/2006 11:26:37 AM ******/
if exists (select * from dbo.sysobjects where id = object_id(N'[dbo].[OCMLkpSupportDoc]') and OBJECTPROPERTY(id, N'IsUserTable') = 1)
drop table [dbo].[OCMLkpSupportDoc]
GO

/****** Object:  Table [dbo].[OCMLkpSysRecCkLst]    Script Date: 7/14/2006 11:26:37 AM ******/
if exists (select * from dbo.sysobjects where id = object_id(N'[dbo].[OCMLkpSysRecCkLst]') and OBJECTPROPERTY(id, N'IsUserTable') = 1)
drop table [dbo].[OCMLkpSysRecCkLst]
GO

/****** Object:  Table [dbo].[OCMLkpWAN]    Script Date: 7/14/2006 11:26:37 AM ******/
if exists (select * from dbo.sysobjects where id = object_id(N'[dbo].[OCMLkpWAN]') and OBJECTPROPERTY(id, N'IsUserTable') = 1)
drop table [dbo].[OCMLkpWAN]
GO

/****** Object:  Table [dbo].[OCMOSEdition]    Script Date: 7/14/2006 11:26:37 AM ******/
if exists (select * from dbo.sysobjects where id = object_id(N'[dbo].[OCMOSEdition]') and OBJECTPROPERTY(id, N'IsUserTable') = 1)
drop table [dbo].[OCMOSEdition]
GO

/****** Object:  Table [dbo].[OCM_AccLvl]    Script Date: 7/14/2006 11:26:37 AM ******/
if exists (select * from dbo.sysobjects where id = object_id(N'[dbo].[OCM_AccLvl]') and OBJECTPROPERTY(id, N'IsUserTable') = 1)
drop table [dbo].[OCM_AccLvl]
GO

/****** Object:  Table [dbo].[OCM_CCHostCats]    Script Date: 7/14/2006 11:26:37 AM ******/
if exists (select * from dbo.sysobjects where id = object_id(N'[dbo].[OCM_CCHostCats]') and OBJECTPROPERTY(id, N'IsUserTable') = 1)
drop table [dbo].[OCM_CCHostCats]
GO

/****** Object:  Table [dbo].[OCM_ITEmpList]    Script Date: 7/14/2006 11:26:37 AM ******/
if exists (select * from dbo.sysobjects where id = object_id(N'[dbo].[OCM_ITEmpList]') and OBJECTPROPERTY(id, N'IsUserTable') = 1)
drop table [dbo].[OCM_ITEmpList]
GO

/****** Object:  Table [dbo].[OCM_UserSecurity]    Script Date: 7/14/2006 11:26:37 AM ******/
if exists (select * from dbo.sysobjects where id = object_id(N'[dbo].[OCM_UserSecurity]') and OBJECTPROPERTY(id, N'IsUserTable') = 1)
drop table [dbo].[OCM_UserSecurity]
GO

/****** Object:  Table [dbo].[PMU]    Script Date: 7/14/2006 11:26:37 AM ******/
if exists (select * from dbo.sysobjects where id = object_id(N'[dbo].[PMU]') and OBJECTPROPERTY(id, N'IsUserTable') = 1)
drop table [dbo].[PMU]
GO

/****** Object:  Table [dbo].[PMU_AccLvlLkp]    Script Date: 7/14/2006 11:26:37 AM ******/
if exists (select * from dbo.sysobjects where id = object_id(N'[dbo].[PMU_AccLvlLkp]') and OBJECTPROPERTY(id, N'IsUserTable') = 1)
drop table [dbo].[PMU_AccLvlLkp]
GO

/****** Object:  Table [dbo].[PMU_AssistantShares]    Script Date: 7/14/2006 11:26:37 AM ******/
if exists (select * from dbo.sysobjects where id = object_id(N'[dbo].[PMU_AssistantShares]') and OBJECTPROPERTY(id, N'IsUserTable') = 1)
drop table [dbo].[PMU_AssistantShares]
GO

/****** Object:  Table [dbo].[PMU_DeptMgrAffectedLst]    Script Date: 7/14/2006 11:26:37 AM ******/
if exists (select * from dbo.sysobjects where id = object_id(N'[dbo].[PMU_DeptMgrAffectedLst]') and OBJECTPROPERTY(id, N'IsUserTable') = 1)
drop table [dbo].[PMU_DeptMgrAffectedLst]
GO

/****** Object:  Table [dbo].[PMU_Old]    Script Date: 7/14/2006 11:26:37 AM ******/
if exists (select * from dbo.sysobjects where id = object_id(N'[dbo].[PMU_Old]') and OBJECTPROPERTY(id, N'IsUserTable') = 1)
drop table [dbo].[PMU_Old]
GO

/****** Object:  Table [dbo].[PMU_ProcCatLkp]    Script Date: 7/14/2006 11:26:37 AM ******/
if exists (select * from dbo.sysobjects where id = object_id(N'[dbo].[PMU_ProcCatLkp]') and OBJECTPROPERTY(id, N'IsUserTable') = 1)
drop table [dbo].[PMU_ProcCatLkp]
GO

/****** Object:  Table [dbo].[PMU_QandA]    Script Date: 7/14/2006 11:26:37 AM ******/
if exists (select * from dbo.sysobjects where id = object_id(N'[dbo].[PMU_QandA]') and OBJECTPROPERTY(id, N'IsUserTable') = 1)
drop table [dbo].[PMU_QandA]
GO

/****** Object:  Table [dbo].[PMU_QueueCatLkp]    Script Date: 7/14/2006 11:26:37 AM ******/
if exists (select * from dbo.sysobjects where id = object_id(N'[dbo].[PMU_QueueCatLkp]') and OBJECTPROPERTY(id, N'IsUserTable') = 1)
drop table [dbo].[PMU_QueueCatLkp]
GO

/****** Object:  Table [dbo].[PMU_Security]    Script Date: 7/14/2006 11:26:37 AM ******/
if exists (select * from dbo.sysobjects where id = object_id(N'[dbo].[PMU_Security]') and OBJECTPROPERTY(id, N'IsUserTable') = 1)
drop table [dbo].[PMU_Security]
GO

/****** Object:  Table [dbo].[PMU_SignOff]    Script Date: 7/14/2006 11:26:37 AM ******/
if exists (select * from dbo.sysobjects where id = object_id(N'[dbo].[PMU_SignOff]') and OBJECTPROPERTY(id, N'IsUserTable') = 1)
drop table [dbo].[PMU_SignOff]
GO

/****** Object:  Table [dbo].[Results]    Script Date: 7/14/2006 11:26:37 AM ******/
if exists (select * from dbo.sysobjects where id = object_id(N'[dbo].[Results]') and OBJECTPROPERTY(id, N'IsUserTable') = 1)
drop table [dbo].[Results]
GO

/****** Object:  Table [dbo].[ServerInfo]    Script Date: 7/14/2006 11:26:37 AM ******/
if exists (select * from dbo.sysobjects where id = object_id(N'[dbo].[ServerInfo]') and OBJECTPROPERTY(id, N'IsUserTable') = 1)
drop table [dbo].[ServerInfo]
GO

/****** Object:  Table [dbo].[UniversityXWalk]    Script Date: 7/14/2006 11:26:37 AM ******/
if exists (select * from dbo.sysobjects where id = object_id(N'[dbo].[UniversityXWalk]') and OBJECTPROPERTY(id, N'IsUserTable') = 1)
drop table [dbo].[UniversityXWalk]
GO

/****** Object:  Table [dbo].[mso_DocExpertise]    Script Date: 7/14/2006 11:26:37 AM ******/
if exists (select * from dbo.sysobjects where id = object_id(N'[dbo].[mso_DocExpertise]') and OBJECTPROPERTY(id, N'IsUserTable') = 1)
drop table [dbo].[mso_DocExpertise]
GO

/****** Object:  Table [dbo].[mso_med_prof_expertise]    Script Date: 7/14/2006 11:26:37 AM ******/
if exists (select * from dbo.sysobjects where id = object_id(N'[dbo].[mso_med_prof_expertise]') and OBJECTPROPERTY(id, N'IsUserTable') = 1)
drop table [dbo].[mso_med_prof_expertise]
GO

/****** Object:  Table [dbo].[ocmchris]    Script Date: 7/14/2006 11:26:37 AM ******/
if exists (select * from dbo.sysobjects where id = object_id(N'[dbo].[ocmchris]') and OBJECTPROPERTY(id, N'IsUserTable') = 1)
drop table [dbo].[ocmchris]
GO

/****** Object:  User appanalyst    Script Date: 7/14/2006 11:26:34 AM ******/
if not exists (select * from dbo.sysusers where name = N'appanalyst' and uid < 16382)
	EXEC sp_grantdbaccess N'appanalyst', N'appanalyst'
GO

/****** Object:  User DevMgr    Script Date: 7/14/2006 11:26:34 AM ******/
if not exists (select * from dbo.sysusers where name = N'DevMgr' and uid < 16382)
	EXEC sp_grantdbaccess N'DevMgr', N'DevMgr'
GO

/****** Object:  User Geonetrics    Script Date: 7/14/2006 11:26:34 AM ******/
if not exists (select * from dbo.sysusers where name = N'Geonetrics' and uid < 16382)
	EXEC sp_grantdbaccess N'Geonetrics', N'Geonetrics'
GO

/****** Object:  User ITAppMgr    Script Date: 7/14/2006 11:26:34 AM ******/
if not exists (select * from dbo.sysusers where name = N'ITAppMgr' and uid < 16382)
	EXEC sp_grantdbaccess N'ITAppMgr', N'ITAppMgr'
GO

/****** Object:  User DevMgr    Script Date: 7/14/2006 11:26:34 AM ******/
exec sp_addrolemember N'db_owner', N'DevMgr'
GO

/****** Object:  User ITAppMgr    Script Date: 7/14/2006 11:26:34 AM ******/
exec sp_addrolemember N'db_owner', N'ITAppMgr'
GO

/****** Object:  Table [dbo].[ADContactInfo]    Script Date: 7/14/2006 11:26:42 AM ******/
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

/****** Object:  Table [dbo].[AmPfmAccLvlLkp]    Script Date: 7/14/2006 11:26:43 AM ******/
CREATE TABLE [dbo].[AmPfmAccLvlLkp] (
	[AccLvl] [int] IDENTITY (3, 1) NOT NULL ,
	[AccLvlName] [varchar] (20) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL 
) ON [PRIMARY]
GO

/****** Object:  Table [dbo].[AmPfmDirectories]    Script Date: 7/14/2006 11:26:43 AM ******/
CREATE TABLE [dbo].[AmPfmDirectories] (
	[DirectoryID] [int] IDENTITY (6, 1) NOT NULL ,
	[Directory] [varchar] (100) COLLATE SQL_Latin1_General_CP1_CI_AS NULL 
) ON [PRIMARY]
GO

/****** Object:  Table [dbo].[AmPfmFrequency]    Script Date: 7/14/2006 11:26:43 AM ******/
CREATE TABLE [dbo].[AmPfmFrequency] (
	[FrequencyID] [int] IDENTITY (6, 1) NOT NULL ,
	[Frequency] [varchar] (50) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL 
) ON [PRIMARY]
GO

/****** Object:  Table [dbo].[AmPfmGroupMembers]    Script Date: 7/14/2006 11:26:43 AM ******/
CREATE TABLE [dbo].[AmPfmGroupMembers] (
	[MemberID] [int] IDENTITY (21, 1) NOT NULL ,
	[GroupID] [int] NOT NULL ,
	[Member] [nvarchar] (4000) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL 
) ON [PRIMARY]
GO

/****** Object:  Table [dbo].[AmPfmGroups]    Script Date: 7/14/2006 11:26:43 AM ******/
CREATE TABLE [dbo].[AmPfmGroups] (
	[GroupID] [int] IDENTITY (8, 1) NOT NULL ,
	[GroupName] [varchar] (50) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL 
) ON [PRIMARY]
GO

/****** Object:  Table [dbo].[AmPfmReports]    Script Date: 7/14/2006 11:26:43 AM ******/
CREATE TABLE [dbo].[AmPfmReports] (
	[RptName] [varchar] (255) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL ,
	[RptID] [int] IDENTITY (303, 1) NOT NULL ,
	[LinkName] [varchar] (255) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL ,
	[DirectoryID] [int] NOT NULL ,
	[Dept] [varchar] (500) COLLATE SQL_Latin1_General_CP1_CI_AS NULL ,
	[Owner] [varchar] (50) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL ,
	[DateTimeStamp] [datetime] NOT NULL ,
	[MultiAccess] [nvarchar] (4000) COLLATE SQL_Latin1_General_CP1_CI_AS NULL ,
	[GroupID] [int] NULL ,
	[FrequencyID] [int] NOT NULL ,
	[IntervalID] [int] NULL ,
	[PublishID] [int] NOT NULL ,
	[HistoricalID] [int] NOT NULL ,
	[Comment] [varchar] (200) COLLATE SQL_Latin1_General_CP1_CI_AS NULL ,
	[Active] [char] (1) COLLATE SQL_Latin1_General_CP1_CI_AS NULL 
) ON [PRIMARY]
GO

/****** Object:  Table [dbo].[AmPfmRptHistory]    Script Date: 7/14/2006 11:26:44 AM ******/
CREATE TABLE [dbo].[AmPfmRptHistory] (
	[HistoricalID] [int] IDENTITY (4200, 1) NOT NULL ,
	[RptID] [int] NOT NULL ,
	[History] [int] NOT NULL ,
	[Publish] [int] NOT NULL 
) ON [PRIMARY]
GO

/****** Object:  Table [dbo].[AmPfmSecurity]    Script Date: 7/14/2006 11:26:44 AM ******/
CREATE TABLE [dbo].[AmPfmSecurity] (
	[UserID] [int] IDENTITY (2656, 1) NOT NULL ,
	[UserName] [varchar] (15) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL ,
	[Dept] [varchar] (50) COLLATE SQL_Latin1_General_CP1_CI_AS NULL ,
	[AccLvl] [char] (1) COLLATE SQL_Latin1_General_CP1_CI_AS NULL ,
	[Owner] [varchar] (7) COLLATE SQL_Latin1_General_CP1_CI_AS NULL ,
	[Active] [int] NULL ,
	[UserAdmin] [char] (1) COLLATE SQL_Latin1_General_CP1_CI_AS NULL 
) ON [PRIMARY]
GO

/****** Object:  Table [dbo].[AmPfmSecurityAudit]    Script Date: 7/14/2006 11:26:44 AM ******/
CREATE TABLE [dbo].[AmPfmSecurityAudit] (
	[AuditId] [int] IDENTITY (221, 1) NOT NULL ,
	[Employee] [varchar] (10) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL ,
	[Report] [varchar] (255) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL ,
	[Filename] [varchar] (255) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL ,
	[HistoricalID] [int] NOT NULL ,
	[PublishID] [int] NOT NULL ,
	[Datetimestamp] [datetime] NOT NULL ,
	[Directory] [varchar] (250) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL ,
	[Frequency] [varchar] (50) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL 
) ON [PRIMARY]
GO

/****** Object:  Table [dbo].[AmPfmTemplates]    Script Date: 7/14/2006 11:26:44 AM ******/
CREATE TABLE [dbo].[AmPfmTemplates] (
	[RptName] [varchar] (255) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL ,
	[TemplateID] [int] NOT NULL ,
	[LinkName] [varchar] (255) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL ,
	[DirectoryID] [int] NOT NULL ,
	[Dept] [varchar] (500) COLLATE SQL_Latin1_General_CP1_CI_AS NULL ,
	[Owner] [varchar] (10) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL ,
	[DateTimeStamp] [datetime] NOT NULL ,
	[MultiAccess] [varchar] (500) COLLATE SQL_Latin1_General_CP1_CI_AS NULL ,
	[GroupID] [int] NULL ,
	[FrequencyID] [int] NOT NULL ,
	[IntervalID] [int] NULL ,
	[PublishID] [int] NULL ,
	[HistoricalID] [int] NULL ,
	[CommentID] [varchar] (50) COLLATE SQL_Latin1_General_CP1_CI_AS NULL 
) ON [PRIMARY]
GO

/****** Object:  Table [dbo].[Departments]    Script Date: 7/14/2006 11:26:44 AM ******/
CREATE TABLE [dbo].[Departments] (
	[DeptID] [int] IDENTITY (250, 1) NOT NULL ,
	[Dept] [varchar] (50) COLLATE SQL_Latin1_General_CP1_CI_AS NULL ,
	[DeptNum] [varchar] (6) COLLATE SQL_Latin1_General_CP1_CI_AS NULL 
) ON [PRIMARY]
GO

/****** Object:  Table [dbo].[DeptLkpLst]    Script Date: 7/14/2006 11:26:44 AM ******/
CREATE TABLE [dbo].[DeptLkpLst] (
	[Dept] [varchar] (50) COLLATE SQL_Latin1_General_CP1_CI_AS NULL ,
	[DeptID] [varchar] (50) COLLATE SQL_Latin1_General_CP1_CI_AS NULL 
) ON [PRIMARY]
GO

/****** Object:  Table [dbo].[Doctors]    Script Date: 7/14/2006 11:26:44 AM ******/
CREATE TABLE [dbo].[Doctors] (
	[NAME] [char] (20) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL ,
	[FullName] [char] (30) COLLATE SQL_Latin1_General_CP1_CI_AS NULL ,
	[DEPT_NAME] [varchar] (25) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL ,
	[DEPT_CODE] [varchar] (5) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL 
) ON [PRIMARY]
GO

/****** Object:  Table [dbo].[EPF_UserSecurity]    Script Date: 7/14/2006 11:26:44 AM ******/
CREATE TABLE [dbo].[EPF_UserSecurity] (
	[EmpNo] [numeric](18, 0) NOT NULL ,
	[username] [varchar] (10) COLLATE SQL_Latin1_General_CP1_CI_AS NULL ,
	[dept] [numeric](18, 0) NULL ,
	[active] [char] (1) COLLATE SQL_Latin1_General_CP1_CI_AS NULL ,
	[firstname] [varchar] (30) COLLATE SQL_Latin1_General_CP1_CI_AS NULL ,
	[lastname] [varchar] (50) COLLATE SQL_Latin1_General_CP1_CI_AS NULL 
) ON [PRIMARY]
GO

/****** Object:  Table [dbo].[Employees]    Script Date: 7/14/2006 11:26:44 AM ******/
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

/****** Object:  Table [dbo].[MSO_Med_Prof]    Script Date: 7/14/2006 11:26:44 AM ******/
CREATE TABLE [dbo].[MSO_Med_Prof] (
	[PhysicianID] [varchar] (10) COLLATE SQL_Latin1_General_CP1_CI_AS NULL ,
	[Med_Prof_Record_No] [int] NULL ,
	[FirstName] [varchar] (50) COLLATE SQL_Latin1_General_CP1_CI_AS NULL ,
	[MiddleName] [varchar] (50) COLLATE SQL_Latin1_General_CP1_CI_AS NULL ,
	[LastName] [varchar] (50) COLLATE SQL_Latin1_General_CP1_CI_AS NULL ,
	[Gender] [varchar] (1) COLLATE SQL_Latin1_General_CP1_CI_AS NULL ,
	[Degree] [varchar] (25) COLLATE SQL_Latin1_General_CP1_CI_AS NULL ,
	[CurrentStatus] [varchar] (20) COLLATE SQL_Latin1_General_CP1_CI_AS NULL ,
	[OnStaffSince] [varchar] (4) COLLATE SQL_Latin1_General_CP1_CI_AS NULL ,
	[WebSiteLink] [varchar] (100) COLLATE SQL_Latin1_General_CP1_CI_AS NULL ,
	[EMailAddress] [varchar] (100) COLLATE SQL_Latin1_General_CP1_CI_AS NULL ,
	[LastUpdated] [datetime] NULL 
) ON [PRIMARY]
GO

/****** Object:  Table [dbo].[MSO_med_prof_credentials]    Script Date: 7/14/2006 11:26:44 AM ******/
CREATE TABLE [dbo].[MSO_med_prof_credentials] (
	[Med_Prof_Record_No] [int] NULL ,
	[UniversityName] [varchar] (100) COLLATE SQL_Latin1_General_CP1_CI_AS NULL ,
	[GraduationYear] [varchar] (4) COLLATE SQL_Latin1_General_CP1_CI_AS NULL ,
	[Order_] [smallint] NULL ,
	[Type] [varchar] (25) COLLATE SQL_Latin1_General_CP1_CI_AS NULL ,
	[LastUpdated] [datetime] NULL 
) ON [PRIMARY]
GO

/****** Object:  Table [dbo].[MSO_med_prof_offices]    Script Date: 7/14/2006 11:26:45 AM ******/
CREATE TABLE [dbo].[MSO_med_prof_offices] (
	[med_prof_record_no] [int] NULL ,
	[office_record_no] [int] NULL ,
	[PrimaryOffice] [bit] NULL ,
	[MailingOffice] [bit] NULL ,
	[BillingOffice] [bit] NULL ,
	[Order_] [smallint] NULL ,
	[OfficeName] [varchar] (100) COLLATE SQL_Latin1_General_CP1_CI_AS NULL ,
	[Address1] [varchar] (100) COLLATE SQL_Latin1_General_CP1_CI_AS NULL ,
	[Address2] [varchar] (100) COLLATE SQL_Latin1_General_CP1_CI_AS NULL ,
	[City] [varchar] (50) COLLATE SQL_Latin1_General_CP1_CI_AS NULL ,
	[State] [varchar] (2) COLLATE SQL_Latin1_General_CP1_CI_AS NULL ,
	[ZipCode] [varchar] (10) COLLATE SQL_Latin1_General_CP1_CI_AS NULL ,
	[PhoneNumber1] [varchar] (25) COLLATE SQL_Latin1_General_CP1_CI_AS NULL ,
	[FaxNumber] [varchar] (25) COLLATE SQL_Latin1_General_CP1_CI_AS NULL ,
	[OfficeSiteType] [varchar] (50) COLLATE SQL_Latin1_General_CP1_CI_AS NULL ,
	[LastUpdated] [datetime] NULL 
) ON [PRIMARY]
GO

/****** Object:  Table [dbo].[MSO_med_prof_specialties]    Script Date: 7/14/2006 11:26:45 AM ******/
CREATE TABLE [dbo].[MSO_med_prof_specialties] (
	[Med_Prof_Record_No] [int] NULL ,
	[SpecialtyName] [varchar] (50) COLLATE SQL_Latin1_General_CP1_CI_AS NULL ,
	[PrimarySpecialty] [bit] NULL ,
	[Certified] [bit] NULL ,
	[BoardName] [varchar] (50) COLLATE SQL_Latin1_General_CP1_CI_AS NULL ,
	[CertifiedYear] [varchar] (4) COLLATE SQL_Latin1_General_CP1_CI_AS NULL ,
	[Order_] [smallint] NULL ,
	[LastUpdated] [datetime] NULL 
) ON [PRIMARY]
GO

/****** Object:  Table [dbo].[OCMFullOnCallMatrix]    Script Date: 7/14/2006 11:26:45 AM ******/
CREATE TABLE [dbo].[OCMFullOnCallMatrix] (
	[OCMID] [int] IDENTITY (400, 1) NOT NULL ,
	[EscalationID] [varchar] (50) COLLATE SQL_Latin1_General_CP1_CI_AS NULL ,
	[WANID] [varchar] (50) COLLATE SQL_Latin1_General_CP1_CI_AS NULL ,
	[RouterID] [varchar] (50) COLLATE SQL_Latin1_General_CP1_CI_AS NULL ,
	[HostID] [varchar] (50) COLLATE SQL_Latin1_General_CP1_CI_AS NULL ,
	[PrimaryOperatorID] [varchar] (50) COLLATE SQL_Latin1_General_CP1_CI_AS NULL ,
	[Application] [varchar] (150) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL ,
	[PrimaryITAppAnalystID] [varchar] (50) COLLATE SQL_Latin1_General_CP1_CI_AS NULL ,
	[SecondaryITAppAnalystID] [varchar] (50) COLLATE SQL_Latin1_General_CP1_CI_AS NULL ,
	[SupGrpID] [varchar] (50) COLLATE SQL_Latin1_General_CP1_CI_AS NULL ,
	[PrimaryApplicationDbaID] [varchar] (50) COLLATE SQL_Latin1_General_CP1_CI_AS NULL ,
	[DbaseTypeID] [nvarchar] (255) COLLATE SQL_Latin1_General_CP1_CI_AS NULL ,
	[DbEditionID] [int] NULL ,
	[DbVersion] [varchar] (10) COLLATE SQL_Latin1_General_CP1_CI_AS NULL ,
	[DbHotfix] [varchar] (100) COLLATE SQL_Latin1_General_CP1_CI_AS NULL ,
	[DbSp] [varchar] (50) COLLATE SQL_Latin1_General_CP1_CI_AS NULL ,
	[WEB] [varchar] (50) COLLATE SQL_Latin1_General_CP1_CI_AS NULL ,
	[PrimaryDeptAnalystID] [varchar] (50) COLLATE SQL_Latin1_General_CP1_CI_AS NULL ,
	[SecondaryDeptAnalystID] [varchar] (50) COLLATE SQL_Latin1_General_CP1_CI_AS NULL ,
	[DepartmentID] [varchar] (50) COLLATE SQL_Latin1_General_CP1_CI_AS NULL ,
	[AppProdVersion] [varchar] (50) COLLATE SQL_Latin1_General_CP1_CI_AS NULL ,
	[AppTestVersion] [varchar] (50) COLLATE SQL_Latin1_General_CP1_CI_AS NULL ,
	[SystemDowntimeRecoverChecklist] [nvarchar] (255) COLLATE SQL_Latin1_General_CP1_CI_AS NULL ,
	[ApplicationDowntimeRecoveryChecklist] [nvarchar] (255) COLLATE SQL_Latin1_General_CP1_CI_AS NULL ,
	[SystemSupportDoc] [nvarchar] (255) COLLATE SQL_Latin1_General_CP1_CI_AS NULL ,
	[Active] [char] (1) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL ,
	[LastUpdated] [datetime] NULL ,
	[UpdatedBy] [varchar] (50) COLLATE SQL_Latin1_General_CP1_CI_AS NULL ,
	[CreatedOn] [datetime] NULL ,
	[CreatedBy] [varchar] (50) COLLATE SQL_Latin1_General_CP1_CI_AS NULL ,
	[Priority] [decimal](7, 3) NULL ,
	[Comments] [ntext] COLLATE SQL_Latin1_General_CP1_CI_AS NULL ,
	[MissionCritical] [char] (1) COLLATE SQL_Latin1_General_CP1_CI_AS NULL 
) ON [PRIMARY] TEXTIMAGE_ON [PRIMARY]
GO

/****** Object:  Table [dbo].[OCMHostCCLog]    Script Date: 7/14/2006 11:26:45 AM ******/
CREATE TABLE [dbo].[OCMHostCCLog] (
	[HostCCID] [int] IDENTITY (5, 1) NOT NULL ,
	[EffDt] [datetime] NOT NULL ,
	[Category] [int] NOT NULL ,
	[Entry] [nvarchar] (2000) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL ,
	[Admin] [varchar] (50) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL ,
	[DateTimeStamp] [datetime] NULL ,
	[HostID] [int] NOT NULL 
) ON [PRIMARY]
GO

/****** Object:  Table [dbo].[OCMLkpAppRecCkLst]    Script Date: 7/14/2006 11:26:45 AM ******/
CREATE TABLE [dbo].[OCMLkpAppRecCkLst] (
	[AppRecChklstID] [int] IDENTITY (50, 1) NOT NULL ,
	[ApplicationDowntimeRecoveryChecklist] [varchar] (255) COLLATE SQL_Latin1_General_CP1_CI_AS NULL ,
	[Active] [char] (1) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL 
) ON [PRIMARY]
GO

/****** Object:  Table [dbo].[OCMLkpDBType]    Script Date: 7/14/2006 11:26:45 AM ******/
CREATE TABLE [dbo].[OCMLkpDBType] (
	[DBTypeID] [int] IDENTITY (20, 1) NOT NULL ,
	[DBType] [varchar] (255) COLLATE SQL_Latin1_General_CP1_CI_AS NULL ,
	[DbInfoLink] [varchar] (255) COLLATE SQL_Latin1_General_CP1_CI_AS NULL ,
	[Active] [char] (1) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL 
) ON [PRIMARY]
GO

/****** Object:  Table [dbo].[OCMLkpDbEditions]    Script Date: 7/14/2006 11:26:45 AM ******/
CREATE TABLE [dbo].[OCMLkpDbEditions] (
	[DbEditionID] [int] IDENTITY (10, 1) NOT NULL ,
	[DbEdition] [varchar] (50) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL 
) ON [PRIMARY]
GO

/****** Object:  Table [dbo].[OCMLkpDwnTm]    Script Date: 7/14/2006 11:26:45 AM ******/
CREATE TABLE [dbo].[OCMLkpDwnTm] (
	[DwnTmID] [int] IDENTITY (5, 1) NOT NULL ,
	[DownTime] [varchar] (50) COLLATE SQL_Latin1_General_CP1_CI_AS NULL ,
	[Active] [char] (1) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL 
) ON [PRIMARY]
GO

/****** Object:  Table [dbo].[OCMLkpHardPlat]    Script Date: 7/14/2006 11:26:45 AM ******/
CREATE TABLE [dbo].[OCMLkpHardPlat] (
	[HardPlatID] [int] IDENTITY (50, 1) NOT NULL ,
	[HardPlat] [varchar] (50) COLLATE SQL_Latin1_General_CP1_CI_AS NULL ,
	[Active] [char] (1) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL 
) ON [PRIMARY]
GO

/****** Object:  Table [dbo].[OCMLkpHost]    Script Date: 7/14/2006 11:26:45 AM ******/
CREATE TABLE [dbo].[OCMLkpHost] (
	[HostID] [int] IDENTITY (500, 1) NOT NULL ,
	[HostName] [varchar] (50) COLLATE SQL_Latin1_General_CP1_CI_AS NULL ,
	[Active] [char] (1) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL ,
	[SP] [varchar] (15) COLLATE SQL_Latin1_General_CP1_CI_AS NULL ,
	[Hotfix] [nvarchar] (500) COLLATE SQL_Latin1_General_CP1_CI_AS NULL ,
	[IP] [varchar] (15) COLLATE SQL_Latin1_General_CP1_CI_AS NULL ,
	[RackID] [int] NULL ,
	[Comments] [nvarchar] (500) COLLATE SQL_Latin1_General_CP1_CI_AS NULL ,
	[OSID] [int] NULL ,
	[HardPlatID] [int] NULL ,
	[PrimarySystemAdminID] [varchar] (50) COLLATE SQL_Latin1_General_CP1_CI_AS NULL ,
	[SecondarySystemAdminID] [varchar] (50) COLLATE SQL_Latin1_General_CP1_CI_AS NULL ,
	[Priority] [decimal](7, 3) NULL ,
	[LastUpdated] [datetime] NULL ,
	[UpdatedBy] [varchar] (10) COLLATE SQL_Latin1_General_CP1_CI_AS NULL ,
	[CreatedOn] [varchar] (50) COLLATE SQL_Latin1_General_CP1_CI_AS NULL ,
	[SerialNum] [varchar] (50) COLLATE SQL_Latin1_General_CP1_CI_AS NULL ,
	[CarePaq] [varchar] (50) COLLATE SQL_Latin1_General_CP1_CI_AS NULL 
) ON [PRIMARY]
GO

/****** Object:  Table [dbo].[OCMLkpOS]    Script Date: 7/14/2006 11:26:46 AM ******/
CREATE TABLE [dbo].[OCMLkpOS] (
	[OS_ID] [int] IDENTITY (50, 1) NOT NULL ,
	[OS] [varchar] (50) COLLATE SQL_Latin1_General_CP1_CI_AS NULL ,
	[Active] [char] (1) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL 
) ON [PRIMARY]
GO

/****** Object:  Table [dbo].[OCMLkpRacks]    Script Date: 7/14/2006 11:26:46 AM ******/
CREATE TABLE [dbo].[OCMLkpRacks] (
	[RackID] [int] IDENTITY (100, 1) NOT NULL ,
	[Rack] [varchar] (15) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL ,
	[RackMap] [varchar] (50) COLLATE SQL_Latin1_General_CP1_CI_AS NULL ,
	[Active] [char] (1) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL 
) ON [PRIMARY]
GO

/****** Object:  Table [dbo].[OCMLkpRouter]    Script Date: 7/14/2006 11:26:46 AM ******/
CREATE TABLE [dbo].[OCMLkpRouter] (
	[RouterID] [int] IDENTITY (24, 1) NOT NULL ,
	[Router] [varchar] (50) COLLATE SQL_Latin1_General_CP1_CI_AS NULL ,
	[Active] [char] (1) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL 
) ON [PRIMARY]
GO

/****** Object:  Table [dbo].[OCMLkpSuppGrp]    Script Date: 7/14/2006 11:26:46 AM ******/
CREATE TABLE [dbo].[OCMLkpSuppGrp] (
	[SupportTypeID] [int] IDENTITY (10, 1) NOT NULL ,
	[SupportType] [varchar] (50) COLLATE SQL_Latin1_General_CP1_CI_AS NULL ,
	[Active] [char] (1) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL 
) ON [PRIMARY]
GO

/****** Object:  Table [dbo].[OCMLkpSupportDoc]    Script Date: 7/14/2006 11:26:46 AM ******/
CREATE TABLE [dbo].[OCMLkpSupportDoc] (
	[SysSptDocID] [int] IDENTITY (100, 1) NOT NULL ,
	[SupportDoc] [varchar] (255) COLLATE SQL_Latin1_General_CP1_CI_AS NULL ,
	[Active] [char] (1) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL 
) ON [PRIMARY]
GO

/****** Object:  Table [dbo].[OCMLkpSysRecCkLst]    Script Date: 7/14/2006 11:26:46 AM ******/
CREATE TABLE [dbo].[OCMLkpSysRecCkLst] (
	[SysRecChklstID] [int] IDENTITY (25, 1) NOT NULL ,
	[SystemDowntimeRecoverChecklist] [varchar] (255) COLLATE SQL_Latin1_General_CP1_CI_AS NULL ,
	[Active] [char] (1) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL 
) ON [PRIMARY]
GO

/****** Object:  Table [dbo].[OCMLkpWAN]    Script Date: 7/14/2006 11:26:46 AM ******/
CREATE TABLE [dbo].[OCMLkpWAN] (
	[WANID] [int] IDENTITY (15, 1) NOT NULL ,
	[WAN] [varchar] (50) COLLATE SQL_Latin1_General_CP1_CI_AS NULL ,
	[Active] [char] (1) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL 
) ON [PRIMARY]
GO

/****** Object:  Table [dbo].[OCMOSEdition]    Script Date: 7/14/2006 11:26:46 AM ******/
CREATE TABLE [dbo].[OCMOSEdition] (
	[OSEditionID] [int] IDENTITY (1, 1) NOT NULL ,
	[OSEdition] [varchar] (50) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL 
) ON [PRIMARY]
GO

/****** Object:  Table [dbo].[OCM_AccLvl]    Script Date: 7/14/2006 11:26:46 AM ******/
CREATE TABLE [dbo].[OCM_AccLvl] (
	[AcclLvlID] [int] IDENTITY (10, 1) NOT NULL ,
	[AccLvl] [varchar] (50) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL 
) ON [PRIMARY]
GO

/****** Object:  Table [dbo].[OCM_CCHostCats]    Script Date: 7/14/2006 11:26:46 AM ******/
CREATE TABLE [dbo].[OCM_CCHostCats] (
	[OcmCCHostCat] [int] IDENTITY (10, 1) NOT NULL ,
	[Category] [varchar] (50) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL 
) ON [PRIMARY]
GO

/****** Object:  Table [dbo].[OCM_ITEmpList]    Script Date: 7/14/2006 11:26:46 AM ******/
CREATE TABLE [dbo].[OCM_ITEmpList] (
	[EmpID] [int] IDENTITY (200, 1) NOT NULL ,
	[EmpNum] [int] NOT NULL ,
	[Fullname] [varchar] (50) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL ,
	[Active] [char] (1) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL ,
	[InHseExt] [varchar] (50) COLLATE SQL_Latin1_General_CP1_CI_AS NULL ,
	[DedExt] [varchar] (50) COLLATE SQL_Latin1_General_CP1_CI_AS NULL ,
	[InHsePager] [varchar] (50) COLLATE SQL_Latin1_General_CP1_CI_AS NULL ,
	[Pager] [varchar] (50) COLLATE SQL_Latin1_General_CP1_CI_AS NULL ,
	[HomePhone] [varchar] (50) COLLATE SQL_Latin1_General_CP1_CI_AS NULL ,
	[CellPhone] [varchar] (50) COLLATE SQL_Latin1_General_CP1_CI_AS NULL 
) ON [PRIMARY]
GO

/****** Object:  Table [dbo].[OCM_UserSecurity]    Script Date: 7/14/2006 11:26:46 AM ******/
CREATE TABLE [dbo].[OCM_UserSecurity] (
	[UserID] [int] IDENTITY (100, 1) NOT NULL ,
	[Username] [varchar] (10) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL ,
	[Dept] [varchar] (10) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL ,
	[AccLvl] [int] NOT NULL ,
	[Active] [int] NOT NULL ,
	[Password] [varchar] (10) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL 
) ON [PRIMARY]
GO

/****** Object:  Table [dbo].[PMU]    Script Date: 7/14/2006 11:26:47 AM ******/
CREATE TABLE [dbo].[PMU] (
	[PMU_ID] [int] IDENTITY (100, 1) NOT NULL ,
	[Type] [varchar] (50) COLLATE SQL_Latin1_General_CP1_CI_AS NULL ,
	[EffectiveDt] [datetime] NULL ,
	[ProcNum] [int] NOT NULL ,
	[MjrCd] [int] NULL ,
	[PnsType] [varchar] (50) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL ,
	[PrcCd] [varchar] (1) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL ,
	[ChargeComp] [varchar] (50) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL ,
	[GenProcNum] [varchar] (8) COLLATE SQL_Latin1_General_CP1_CI_AS NULL ,
	[General] [varchar] (25) COLLATE SQL_Latin1_General_CP1_CI_AS NULL ,
	[Statement] [varchar] (21) COLLATE SQL_Latin1_General_CP1_CI_AS NULL ,
	[IP_CurrPrice] [varchar] (10) COLLATE SQL_Latin1_General_CP1_CI_AS NULL ,
	[IP_EffDt] [varchar] (50) COLLATE SQL_Latin1_General_CP1_CI_AS NULL ,
	[IP_FutPrice] [varchar] (10) COLLATE SQL_Latin1_General_CP1_CI_AS NULL ,
	[OP_CurrPrice] [varchar] (10) COLLATE SQL_Latin1_General_CP1_CI_AS NULL ,
	[OP_EffDt] [varchar] (50) COLLATE SQL_Latin1_General_CP1_CI_AS NULL ,
	[OP_FutPrice] [varchar] (10) COLLATE SQL_Latin1_General_CP1_CI_AS NULL ,
	[Ob_CurrPrice] [varchar] (10) COLLATE SQL_Latin1_General_CP1_CI_AS NULL ,
	[Ob_EffDt] [varchar] (50) COLLATE SQL_Latin1_General_CP1_CI_AS NULL ,
	[Ob_FutPrice] [varchar] (10) COLLATE SQL_Latin1_General_CP1_CI_AS NULL ,
	[AdjGLAcct] [varchar] (5) COLLATE SQL_Latin1_General_CP1_CI_AS NULL ,
	[SubAcct] [varchar] (4) COLLATE SQL_Latin1_General_CP1_CI_AS NULL ,
	[RVU1] [varchar] (8) COLLATE SQL_Latin1_General_CP1_CI_AS NULL ,
	[LaborHrs] [varchar] (8) COLLATE SQL_Latin1_General_CP1_CI_AS NULL ,
	[TechCost] [varchar] (9) COLLATE SQL_Latin1_General_CP1_CI_AS NULL ,
	[Mcare] [varchar] (50) COLLATE SQL_Latin1_General_CP1_CI_AS NULL ,
	[McrOp] [varchar] (50) COLLATE SQL_Latin1_General_CP1_CI_AS NULL ,
	[Mcal] [varchar] (50) COLLATE SQL_Latin1_General_CP1_CI_AS NULL ,
	[Comm] [varchar] (50) COLLATE SQL_Latin1_General_CP1_CI_AS NULL ,
	[Tricare] [varchar] (50) COLLATE SQL_Latin1_General_CP1_CI_AS NULL ,
	[WorkComp] [varchar] (50) COLLATE SQL_Latin1_General_CP1_CI_AS NULL ,
	[CPT] [varchar] (50) COLLATE SQL_Latin1_General_CP1_CI_AS NULL ,
	[HCPCS] [varchar] (50) COLLATE SQL_Latin1_General_CP1_CI_AS NULL ,
	[Mcal2] [varchar] (50) COLLATE SQL_Latin1_General_CP1_CI_AS NULL ,
	[Comm2] [varchar] (50) COLLATE SQL_Latin1_General_CP1_CI_AS NULL ,
	[Tricare2] [varchar] (50) COLLATE SQL_Latin1_General_CP1_CI_AS NULL ,
	[WorkComp2] [varchar] (50) COLLATE SQL_Latin1_General_CP1_CI_AS NULL ,
	[Mod1] [varchar] (50) COLLATE SQL_Latin1_General_CP1_CI_AS NULL ,
	[Mod2] [varchar] (50) COLLATE SQL_Latin1_General_CP1_CI_AS NULL ,
	[MediCare] [varchar] (50) COLLATE SQL_Latin1_General_CP1_CI_AS NULL ,
	[MediCal] [varchar] (50) COLLATE SQL_Latin1_General_CP1_CI_AS NULL ,
	[Comm3] [varchar] (50) COLLATE SQL_Latin1_General_CP1_CI_AS NULL ,
	[Tricare3] [varchar] (50) COLLATE SQL_Latin1_General_CP1_CI_AS NULL ,
	[Wcomp] [varchar] (50) COLLATE SQL_Latin1_General_CP1_CI_AS NULL ,
	[RsnChng] [nvarchar] (1000) COLLATE SQL_Latin1_General_CP1_CI_AS NULL ,
	[SchedProc] [varchar] (50) COLLATE SQL_Latin1_General_CP1_CI_AS NULL ,
	[ClinicalScreen] [varchar] (15) COLLATE SQL_Latin1_General_CP1_CI_AS NULL ,
	[DeptContactNm] [varchar] (100) COLLATE SQL_Latin1_General_CP1_CI_AS NULL ,
	[Ext] [varchar] (8) COLLATE SQL_Latin1_General_CP1_CI_AS NULL ,
	[CurrentQueueCat] [int] NOT NULL ,
	[CurrentQueue] [int] NULL ,
	[LastQueue] [int] NULL ,
	[Owner] [varchar] (10) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL ,
	[CreationDt] [datetime] NOT NULL ,
	[LastUpdateDt] [datetime] NOT NULL ,
	[Active] [char] (1) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL ,
	[Status] [varchar] (50) COLLATE SQL_Latin1_General_CP1_CI_AS NULL ,
	[FastTrack] [char] (1) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL ,
	[AttachmentFilename] [varchar] (50) COLLATE SQL_Latin1_General_CP1_CI_AS NULL ,
	[FastTrackChk] [char] (1) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL ,
	[Item1] [varchar] (50) COLLATE SQL_Latin1_General_CP1_CI_AS NULL ,
	[Item2] [varchar] (50) COLLATE SQL_Latin1_General_CP1_CI_AS NULL ,
	[Item3] [varchar] (50) COLLATE SQL_Latin1_General_CP1_CI_AS NULL ,
	[Item4] [varchar] (50) COLLATE SQL_Latin1_General_CP1_CI_AS NULL ,
	[Item5] [varchar] (50) COLLATE SQL_Latin1_General_CP1_CI_AS NULL ,
	[Comments] [nvarchar] (500) COLLATE SQL_Latin1_General_CP1_CI_AS NULL 
) ON [PRIMARY]
GO

/****** Object:  Table [dbo].[PMU_AccLvlLkp]    Script Date: 7/14/2006 11:26:47 AM ******/
CREATE TABLE [dbo].[PMU_AccLvlLkp] (
	[AccLvlID] [int] IDENTITY (1, 1) NOT NULL ,
	[AccLvl] [char] (10) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL 
) ON [PRIMARY]
GO

/****** Object:  Table [dbo].[PMU_AssistantShares]    Script Date: 7/14/2006 11:26:47 AM ******/
CREATE TABLE [dbo].[PMU_AssistantShares] (
	[ShareID] [int] IDENTITY (1, 1) NOT NULL ,
	[Assistant] [varchar] (7) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL ,
	[DirectorQueue] [varchar] (4) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL 
) ON [PRIMARY]
GO

/****** Object:  Table [dbo].[PMU_DeptMgrAffectedLst]    Script Date: 7/14/2006 11:26:47 AM ******/
CREATE TABLE [dbo].[PMU_DeptMgrAffectedLst] (
	[DeptMgrAffectedID] [int] IDENTITY (1, 1) NOT NULL ,
	[DeptMgrAffected] [varchar] (10) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL ,
	[PMU_ID] [int] NOT NULL ,
	[Approved] [char] (1) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL ,
	[DeptMgrQueue] [char] (10) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL ,
	[Datetimestamp] [datetime] NOT NULL ,
	[LastUpdated] [datetime] NULL 
) ON [PRIMARY]
GO

/****** Object:  Table [dbo].[PMU_Old]    Script Date: 7/14/2006 11:26:47 AM ******/
CREATE TABLE [dbo].[PMU_Old] (
	[PMU_ID] [int] IDENTITY (100, 1) NOT NULL ,
	[Type] [varchar] (50) COLLATE SQL_Latin1_General_CP1_CI_AS NULL ,
	[EffectiveDt] [datetime] NULL ,
	[ProcNum] [int] NOT NULL ,
	[Client] [int] NULL ,
	[CostCtr] [int] NULL ,
	[ProcCat] [char] (1) COLLATE SQL_Latin1_General_CP1_CI_AS NULL ,
	[BldRoom] [char] (1) COLLATE SQL_Latin1_General_CP1_CI_AS NULL ,
	[DrReq] [char] (1) COLLATE SQL_Latin1_General_CP1_CI_AS NULL ,
	[GenProcNum] [varchar] (8) COLLATE SQL_Latin1_General_CP1_CI_AS NULL ,
	[Bill] [varchar] (25) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL ,
	[Dept] [varchar] (70) COLLATE SQL_Latin1_General_CP1_CI_AS NULL ,
	[IP_CurrPrice] [char] (10) COLLATE SQL_Latin1_General_CP1_CI_AS NULL ,
	[IP_EffDt] [varchar] (50) COLLATE SQL_Latin1_General_CP1_CI_AS NULL ,
	[IP_FutPrice] [char] (10) COLLATE SQL_Latin1_General_CP1_CI_AS NULL ,
	[OP_CurrPrice] [char] (10) COLLATE SQL_Latin1_General_CP1_CI_AS NULL ,
	[OP_EffDt] [varchar] (50) COLLATE SQL_Latin1_General_CP1_CI_AS NULL ,
	[OP_FutPrice] [char] (10) COLLATE SQL_Latin1_General_CP1_CI_AS NULL ,
	[MD_CurrPrice] [char] (10) COLLATE SQL_Latin1_General_CP1_CI_AS NULL ,
	[MD_EffDt] [varchar] (50) COLLATE SQL_Latin1_General_CP1_CI_AS NULL ,
	[MD_FutPrice] [char] (10) COLLATE SQL_Latin1_General_CP1_CI_AS NULL ,
	[Profee1] [char] (1) COLLATE SQL_Latin1_General_CP1_CI_AS NULL ,
	[Amt1] [char] (10) COLLATE SQL_Latin1_General_CP1_CI_AS NULL ,
	[Profee2] [char] (1) COLLATE SQL_Latin1_General_CP1_CI_AS NULL ,
	[Amt2] [char] (10) COLLATE SQL_Latin1_General_CP1_CI_AS NULL ,
	[Profee3] [char] (1) COLLATE SQL_Latin1_General_CP1_CI_AS NULL ,
	[Amt3] [char] (10) COLLATE SQL_Latin1_General_CP1_CI_AS NULL ,
	[HCPC] [char] (8) COLLATE SQL_Latin1_General_CP1_CI_AS NULL ,
	[CPT4] [char] (8) COLLATE SQL_Latin1_General_CP1_CI_AS NULL ,
	[RVS] [char] (8) COLLATE SQL_Latin1_General_CP1_CI_AS NULL ,
	[OTH1] [char] (8) COLLATE SQL_Latin1_General_CP1_CI_AS NULL ,
	[OTH2] [char] (8) COLLATE SQL_Latin1_General_CP1_CI_AS NULL ,
	[PIC_Cd1] [char] (3) COLLATE SQL_Latin1_General_CP1_CI_AS NULL ,
	[PIC_Cd2] [char] (3) COLLATE SQL_Latin1_General_CP1_CI_AS NULL ,
	[PIC_Cd3] [char] (3) COLLATE SQL_Latin1_General_CP1_CI_AS NULL ,
	[PIC_Cd4] [char] (3) COLLATE SQL_Latin1_General_CP1_CI_AS NULL ,
	[PIC_Cd5] [char] (3) COLLATE SQL_Latin1_General_CP1_CI_AS NULL ,
	[PIC_Cd6] [char] (3) COLLATE SQL_Latin1_General_CP1_CI_AS NULL ,
	[PIC_Cd7] [char] (3) COLLATE SQL_Latin1_General_CP1_CI_AS NULL ,
	[PIC_Cd8] [char] (3) COLLATE SQL_Latin1_General_CP1_CI_AS NULL ,
	[Lvl1_1] [char] (2) COLLATE SQL_Latin1_General_CP1_CI_AS NULL ,
	[Lvl1_2] [char] (2) COLLATE SQL_Latin1_General_CP1_CI_AS NULL ,
	[Lvl2_1] [char] (2) COLLATE SQL_Latin1_General_CP1_CI_AS NULL ,
	[Lvl2_2] [char] (2) COLLATE SQL_Latin1_General_CP1_CI_AS NULL ,
	[GLAcct] [varchar] (16) COLLATE SQL_Latin1_General_CP1_CI_AS NULL ,
	[CashOffset] [varchar] (16) COLLATE SQL_Latin1_General_CP1_CI_AS NULL ,
	[RVU1] [char] (10) COLLATE SQL_Latin1_General_CP1_CI_AS NULL ,
	[RVU2] [char] (10) COLLATE SQL_Latin1_General_CP1_CI_AS NULL ,
	[Reason] [varchar] (255) COLLATE SQL_Latin1_General_CP1_CI_AS NULL ,
	[PriceTbl] [varchar] (50) COLLATE SQL_Latin1_General_CP1_CI_AS NULL ,
	[ClinicalScreen] [varchar] (15) COLLATE SQL_Latin1_General_CP1_CI_AS NULL ,
	[DeptContactNm] [varchar] (100) COLLATE SQL_Latin1_General_CP1_CI_AS NULL ,
	[Ext] [char] (4) COLLATE SQL_Latin1_General_CP1_CI_AS NULL ,
	[CurrentQueueCat] [int] NOT NULL ,
	[CurrentQueue] [int] NULL ,
	[LastQueue] [int] NULL ,
	[Owner] [varchar] (10) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL ,
	[CreationDt] [datetime] NOT NULL ,
	[LastUpdateDt] [datetime] NOT NULL ,
	[Active] [char] (1) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL ,
	[Status] [varchar] (50) COLLATE SQL_Latin1_General_CP1_CI_AS NULL ,
	[FastTrack] [char] (1) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL ,
	[AttachmentFilename] [varchar] (50) COLLATE SQL_Latin1_General_CP1_CI_AS NULL ,
	[FastTrackChk] [char] (1) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL 
) ON [PRIMARY]
GO

/****** Object:  Table [dbo].[PMU_ProcCatLkp]    Script Date: 7/14/2006 11:26:48 AM ******/
CREATE TABLE [dbo].[PMU_ProcCatLkp] (
	[ProcCatID] [int] IDENTITY (1, 1) NOT NULL ,
	[ProcCatCd] [char] (1) COLLATE SQL_Latin1_General_CP1_CI_AS NULL ,
	[ProcCatDesc] [varchar] (50) COLLATE SQL_Latin1_General_CP1_CI_AS NULL 
) ON [PRIMARY]
GO

/****** Object:  Table [dbo].[PMU_QandA]    Script Date: 7/14/2006 11:26:48 AM ******/
CREATE TABLE [dbo].[PMU_QandA] (
	[PMU_QandA_ID] [int] IDENTITY (1, 1) NOT NULL ,
	[PMU_ID] [int] NOT NULL ,
	[QuestionTopic] [varchar] (50) COLLATE SQL_Latin1_General_CP1_CI_AS NULL ,
	[Question] [varchar] (255) COLLATE SQL_Latin1_General_CP1_CI_AS NULL ,
	[Answer] [varchar] (255) COLLATE SQL_Latin1_General_CP1_CI_AS NULL ,
	[QuestionerQueue] [varchar] (10) COLLATE SQL_Latin1_General_CP1_CI_AS NULL ,
	[DateTime] [datetime] NOT NULL ,
	[LastUpdated] [datetime] NULL 
) ON [PRIMARY]
GO

/****** Object:  Table [dbo].[PMU_QueueCatLkp]    Script Date: 7/14/2006 11:26:48 AM ******/
CREATE TABLE [dbo].[PMU_QueueCatLkp] (
	[QueueCatID] [int] NOT NULL ,
	[QueueCat] [varchar] (50) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL 
) ON [PRIMARY]
GO

/****** Object:  Table [dbo].[PMU_Security]    Script Date: 7/14/2006 11:26:48 AM ******/
CREATE TABLE [dbo].[PMU_Security] (
	[UserName] [varchar] (10) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL ,
	[Active] [char] (1) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL ,
	[QueueID] [int] IDENTITY (100, 1) NOT NULL ,
	[QueueCatID] [int] NOT NULL ,
	[AccLvl] [int] NULL ,
	[SharedQueueID] [int] NULL ,
	[Owner] [varchar] (10) COLLATE SQL_Latin1_General_CP1_CI_AS NULL ,
	[UserAdmin] [char] (1) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL 
) ON [PRIMARY]
GO

/****** Object:  Table [dbo].[PMU_SignOff]    Script Date: 7/14/2006 11:26:48 AM ******/
CREATE TABLE [dbo].[PMU_SignOff] (
	[SignOffID] [int] IDENTITY (10, 1) NOT NULL ,
	[PMU_ID] [int] NOT NULL ,
	[UserName] [varchar] (10) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL ,
	[Datetime] [datetime] NOT NULL ,
	[QueueID] [char] (10) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL 
) ON [PRIMARY]
GO

/****** Object:  Table [dbo].[Results]    Script Date: 7/14/2006 11:26:48 AM ******/
CREATE TABLE [dbo].[Results] (
	[OCMID] [float] NULL ,
	[Application] [nvarchar] (255) COLLATE SQL_Latin1_General_CP1_CI_AS NULL ,
	[AppPriority] [float] NULL ,
	[HostID] [float] NULL ,
	[HostName] [nvarchar] (255) COLLATE SQL_Latin1_General_CP1_CI_AS NULL ,
	[HostPriority] [float] NULL 
) ON [PRIMARY]
GO

/****** Object:  Table [dbo].[ServerInfo]    Script Date: 7/14/2006 11:26:48 AM ******/
CREATE TABLE [dbo].[ServerInfo] (
	[ServerName] [nvarchar] (255) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL ,
	[Hardware] [nvarchar] (255) COLLATE SQL_Latin1_General_CP1_CI_AS NULL ,
	[SerialNum] [nvarchar] (255) COLLATE SQL_Latin1_General_CP1_CI_AS NULL ,
	[IP] [varchar] (255) COLLATE SQL_Latin1_General_CP1_CI_AS NULL ,
	[ID] [int] NOT NULL 
) ON [PRIMARY]
GO

/****** Object:  Table [dbo].[UniversityXWalk]    Script Date: 7/14/2006 11:26:48 AM ******/
CREATE TABLE [dbo].[UniversityXWalk] (
	[universityrecord] [varchar] (6) COLLATE SQL_Latin1_General_CP1_CI_AS NULL ,
	[oldname] [nvarchar] (255) COLLATE SQL_Latin1_General_CP1_CI_AS NULL ,
	[newname] [nvarchar] (255) COLLATE SQL_Latin1_General_CP1_CI_AS NULL 
) ON [PRIMARY]
GO

/****** Object:  Table [dbo].[mso_DocExpertise]    Script Date: 7/14/2006 11:26:48 AM ******/
CREATE TABLE [dbo].[mso_DocExpertise] (
	[Med_Prof_Record_No] [int] NOT NULL ,
	[ExpertiseID] [int] NOT NULL 
) ON [PRIMARY]
GO

/****** Object:  Table [dbo].[mso_med_prof_expertise]    Script Date: 7/14/2006 11:26:49 AM ******/
CREATE TABLE [dbo].[mso_med_prof_expertise] (
	[ExpertiseID] [int] IDENTITY (1, 1) NOT NULL ,
	[Expertise] [varchar] (35) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL 
) ON [PRIMARY]
GO

/****** Object:  Table [dbo].[ocmchris]    Script Date: 7/14/2006 11:26:49 AM ******/
CREATE TABLE [dbo].[ocmchris] (
	[OCMID] [int] NOT NULL ,
	[EscalationID] [varchar] (50) COLLATE SQL_Latin1_General_CP1_CI_AS NULL ,
	[WANID] [varchar] (50) COLLATE SQL_Latin1_General_CP1_CI_AS NULL ,
	[RouterID] [varchar] (50) COLLATE SQL_Latin1_General_CP1_CI_AS NULL ,
	[HostID] [varchar] (50) COLLATE SQL_Latin1_General_CP1_CI_AS NULL ,
	[PrimaryOperatorID] [varchar] (50) COLLATE SQL_Latin1_General_CP1_CI_AS NULL ,
	[Application] [varchar] (150) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL ,
	[PrimaryITAppAnalystID] [varchar] (50) COLLATE SQL_Latin1_General_CP1_CI_AS NULL ,
	[SecondaryITAppAnalystID] [varchar] (50) COLLATE SQL_Latin1_General_CP1_CI_AS NULL ,
	[SupGrpID] [varchar] (50) COLLATE SQL_Latin1_General_CP1_CI_AS NULL ,
	[PrimaryApplicationDbaID] [varchar] (50) COLLATE SQL_Latin1_General_CP1_CI_AS NULL ,
	[DbaseTypeID] [nvarchar] (255) COLLATE SQL_Latin1_General_CP1_CI_AS NULL ,
	[DbEditionID] [int] NULL ,
	[DbVersion] [varchar] (10) COLLATE SQL_Latin1_General_CP1_CI_AS NULL ,
	[DbHotfix] [varchar] (100) COLLATE SQL_Latin1_General_CP1_CI_AS NULL ,
	[DbSp] [varchar] (50) COLLATE SQL_Latin1_General_CP1_CI_AS NULL ,
	[WEB] [varchar] (50) COLLATE SQL_Latin1_General_CP1_CI_AS NULL ,
	[PrimaryDeptAnalystID] [varchar] (50) COLLATE SQL_Latin1_General_CP1_CI_AS NULL ,
	[SecondaryDeptAnalystID] [varchar] (50) COLLATE SQL_Latin1_General_CP1_CI_AS NULL ,
	[DepartmentID] [varchar] (50) COLLATE SQL_Latin1_General_CP1_CI_AS NULL ,
	[AppProdVersion] [varchar] (50) COLLATE SQL_Latin1_General_CP1_CI_AS NULL ,
	[AppTestVersion] [varchar] (50) COLLATE SQL_Latin1_General_CP1_CI_AS NULL ,
	[SystemDowntimeRecoverChecklist] [nvarchar] (255) COLLATE SQL_Latin1_General_CP1_CI_AS NULL ,
	[ApplicationDowntimeRecoveryChecklist] [nvarchar] (255) COLLATE SQL_Latin1_General_CP1_CI_AS NULL ,
	[SystemSupportDoc] [nvarchar] (255) COLLATE SQL_Latin1_General_CP1_CI_AS NULL ,
	[Active] [char] (1) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL ,
	[LastUpdated] [datetime] NULL ,
	[UpdatedBy] [varchar] (50) COLLATE SQL_Latin1_General_CP1_CI_AS NULL ,
	[CreatedOn] [datetime] NULL ,
	[CreatedBy] [varchar] (50) COLLATE SQL_Latin1_General_CP1_CI_AS NULL ,
	[Priority] [decimal](7, 3) NULL ,
	[Comments] [ntext] COLLATE SQL_Latin1_General_CP1_CI_AS NULL 
) ON [PRIMARY] TEXTIMAGE_ON [PRIMARY]
GO


exec sp_addextendedproperty N'MS_Description', N'Values: Addition, Deletion, Update', N'user', N'dbo', N'table', N'PMU_Old', N'column', N'Type'
GO
exec sp_addextendedproperty N'MS_Description', N'Values: Y, N', N'user', N'dbo', N'table', N'PMU_Old', N'column', N'Active'
GO
exec sp_addextendedproperty N'MS_Description', N'Values: Saved, Processing, Completed, Question', N'user', N'dbo', N'table', N'PMU_Old', N'column', N'Status'
GO
exec sp_addextendedproperty N'MS_Description', N'Values U, N, Y ', N'user', N'dbo', N'table', N'PMU_Old', N'column', N'FastTrack'


GO

