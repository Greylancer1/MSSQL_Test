USE [DBA]
GO

/****** Object:  Table [dbo].[TriggerAuditTable]    Script Date: 7/20/2017 8:48:16 AM ******/
SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO

CREATE TABLE [dbo].[TriggerAuditTable](
	[Query that fired the trigger] [nvarchar](255) NULL,
	[LoginName] [nvarchar](128) NULL,
	[UserName] [nvarchar](128) NULL,
	[CurrentTime] [datetime] NOT NULL
) ON [PRIMARY]

GO

CREATE TRIGGER TriggerAuditRecord 
ON Change2AuditedTable
FOR INSERT AS 
BEGIN
 SET NOCOUNT ON

 DECLARE @ExecStr varchar(50), @Qry nvarchar(255)

 CREATE TABLE #inputbuffer 
 (
  EventType nvarchar(30), 
  Parameters int, 
  EventInfo nvarchar(255)
 )

 SET @ExecStr = 'DBCC INPUTBUFFER(' + STR(@@SPID) + ')'

 INSERT INTO #inputbuffer 
 EXEC (@ExecStr)

 SET @Qry = (SELECT EventInfo FROM #inputbuffer)

 INSERT INTO dba.dbo.TriggerAuditTable ([Query that fired the trigger],	[LoginName], [UserName], [CurrentTime])
 SELECT @Qry AS 'Query that fired the trigger', 
 SYSTEM_USER as LoginName, 
 USER AS UserName, 
 CURRENT_TIMESTAMP AS CurrentTime

END