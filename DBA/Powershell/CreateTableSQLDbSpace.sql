CREATE TABLE [dbo].[db_space](

      [server_name] [varchar](128) NOT NULL,

      [dbname] [varchar](128) NOT NULL,

      [physical_name] [varchar](260) NOT NULL,

      [dt] [datetime] NOT NULL,

      [file_group_name] [varchar](128) NOT NULL,

      [size_mb] [int] NULL,

      [free_mb] [int] NULL,

 CONSTRAINT [PK_db_space] PRIMARY KEY CLUSTERED

(

      [server_name] ASC,

      [dbname] ASC,

      [physical_name] ASC,

      [dt] ASC

)

)