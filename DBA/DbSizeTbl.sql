if exists (select * from dbo.sysobjects where id = object_id(N'[dbo].[chomp_SizeData]') and OBJECTPROPERTY(id, N'IsUserTable') = 1)
drop table [dbo].[chomp_SizeData]
GO

CREATE TABLE [dbo].[chomp_SizeData] (
	[EntryNum] [int] IDENTITY (1, 1) NOT NULL ,
	[DbName] [varchar] (50) COLLATE SQL_Latin1_General_CP1_CI_AS NULL ,
	[rec_id] [varchar] (50) COLLATE SQL_Latin1_General_CP1_CI_AS NULL ,
	[table_name] [varchar] (50) COLLATE SQL_Latin1_General_CP1_CI_AS NULL ,
	[nbr_of_rows] [varchar] (50) COLLATE SQL_Latin1_General_CP1_CI_AS NULL ,
	[data_space] [varchar] (50) COLLATE SQL_Latin1_General_CP1_CI_AS NULL ,
	[index_space] [varchar] (50) COLLATE SQL_Latin1_General_CP1_CI_AS NULL ,
	[total_size] [varchar] (50) COLLATE SQL_Latin1_General_CP1_CI_AS NULL ,
	[percent_of_db] [varchar] (50) COLLATE SQL_Latin1_General_CP1_CI_AS NULL ,
	[db_size] [varchar] (50) COLLATE SQL_Latin1_General_CP1_CI_AS NULL 
) ON [PRIMARY]
GO

