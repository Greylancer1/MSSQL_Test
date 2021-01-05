CREATE TABLE [dbo].[PerfmonCounterData]
 (
 [ID] [bigint] IDENTITY(1,1) NOT NULL PRIMARY KEY CLUSTERED,
 [Server] [nvarchar](50) NOT NULL,
 [TimeStamp] [datetime2](0) NOT NULL,
 [CounterGroup] [varchar](200) NULL,
 [CounterName] [varchar](200) NOT NULL,
 [CounterValue] [decimal](18, 5) NULL
 );
 GO

USE [DBA]
 GO
 
 /****** Object: StoredProcedure [dbo].[usp_InsertPerfmonCounter] Script Date: 11/5/2013 11:27:48 AM ******/
 SET ANSI_NULLS ON
 GO
 
 SET QUOTED_IDENTIFIER ON
 GO
 
 CREATE PROCEDURE [dbo].[usp_InsertPerfmonCounter]
 (
 @xmlString varchar(max)
 )
 AS
 SET NOCOUNT ON;
 
 DECLARE @xml xml;
 SET @xml = @xmlString;
 
 INSERT INTO [dbo].[PerfmonCounterData] ([TimeStamp], [Server], [CounterGroup], [CounterName], [CounterValue])
 SELECT [Timestamp]
 , SUBSTRING([Path], 3, CHARINDEX('\',[Path],3)-3) AS [Server]
 , SUBSTRING([Path]
 , CHARINDEX('\',[Path],3)+1
 , LEN([Path]) - CHARINDEX('\',REVERSE([Path]))+1 - (CHARINDEX('\',[Path],3)+1)) AS [CounterGroup]
 , REVERSE(LEFT(REVERSE([Path]), CHARINDEX('\', REVERSE([Path]))-1)) AS [CounterName]
 , CAST([CookedValue] AS float) AS [CookedValue]
 FROM
 (SELECT
 [property].value('(./text())[1]', 'VARCHAR(200)') AS [Value]
 , [property].value('@Name', 'VARCHAR(30)') AS [Attribute]
 , DENSE_RANK() OVER (ORDER BY [object]) AS [Sampling]
 FROM @xml.nodes('Objects/Object') AS mn ([object]) 
 CROSS APPLY mn.object.nodes('./Property') AS pn (property)) AS bp
 PIVOT (MAX(value) FOR Attribute IN ([Timestamp], [Path], [CookedValue]) ) AS ap;
 
GO