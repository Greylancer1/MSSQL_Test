USE [DBA]
GO

/****** Object:  Table [dbo].[InstanceInfo]    Script Date: 9/15/2015 12:55:05 PM ******/
SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO

SET ANSI_PADDING ON
GO

CREATE TABLE [dbo].[InstanceInfo](
	[ServerName] [varchar](50) NOT NULL,
	[ProductVersion] [varchar](50) NOT NULL,
	[ProductLevel] [varchar](50) NOT NULL,
	[Edition] [varchar](50) NOT NULL
) ON [PRIMARY]

GO

SET ANSI_PADDING OFF
GO


