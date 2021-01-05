CREATE TABLE [dbo].[#TMP] ( 
[SRVRNAME] NVARCHAR(256) NULL,
[DBNAME] NVARCHAR(256) NULL,
[TABLENAME] NVARCHAR(256) NULL);

EXEC sp_MSforeachdb 'USE [?] INSERT INTO #TMP SELECT @@Servername, ''[?]'', Name AS TableName FROM sysobjects WHERE xtype = ''U'' AND ''[?]'' NOT IN (''master'', ''msdb'', ''tempdb'', ''ReportServer'', ''ReportServerTempDB'') ORDER BY name'
SELECT * FROM #TMP
DROP TABLE #TMP