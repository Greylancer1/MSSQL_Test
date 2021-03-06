/****** Object:  StoredProcedure [dbo].[SXADBReindexVolatileTablesPr_Modified]    Script Date: 8/18/2014 4:23:22 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

ALTER PROC [dbo].[SXADBReindexVolatileTablesPr_Modified]

AS
--===================================================================    
-- Stored procedure : SXADBReindexVolatileTablesPr    
-- Requires SQL 2012 or older Enterprise Edition    
-- Function : Rebuilds or Reorgs indexes ONLINE for select volatile tables depending on fragmentation.
-------------------------------------------------------------------------------------------------------------    
-- Date         | Author        |Description        |    
-------------------------------------------------------------------------------------------------------------    
-- 03/06/2014   |CDossman       |Create  


SET NOCOUNT ON
DECLARE     
    @ReturnStatus int,    
    @SQL nvarchar(2000),    
    @ObjectName sysname,    
    @IndexName sysname,    
    @StartDTM datetime,    
    @EndDTM datetime,    
    @TimeTaken int,    
    @avg_frag   FLOAT    

CREATE TABLE #VolatileTables  (TableName sysname, IndexName sysname, Fragmentation float)

INSERT #VolatileTables
SELECT h.name AS TableName, (SELECT name FROM sys.indexes WHERE object_id = h.object_id and index_id = j.Index_ID), j.avg_fragmentation_in_percent
FROM  sys.Tables h
CROSS APPLY sys.dm_db_index_physical_stats(DB_ID(), OBJECT_ID(h.Name), NULL, NULL, NULL) as j
WHERE ( h.name in(
	'CV3ActiveCareProvVisitRole',  
	'CV3ActiveVisit',  
	'CV3ActiveVisitList',  
	'CV3OrderGenerationQueue',  
	'CV3OrderVerifyXref',  
	'CV3ProcessOrderQueue',  
	'CV3SendADMQueue',  
	'CV3SendADTQueue',  
	'CV3SendADTQueuePFM',  
	'CV3SendDocsQueue',  
	'CV3SendOrderQueue',  
	'CV3SendRobotQueue', 
	'CV3SendSmartPumpQueue', 
	'CV3SendRobotQueueMessage',  
	'CV3Session',  
	'CV3SessionInvalid',  
	'CV3SecurityGroupRights',
	'CV3UserSecurityGroup',
	'CV3Rights',
	'CV3WorklistClientVisit',  
	'CV3WorkUserItemAccessUser',  
	'HVCReportCleanup',  
	'HVCRequestedReport',  
	'HVCSubmittedParameter',  
	'HVCSubmittedReport',  
	'SXACDLock',  
	'SXACDTaskQueue',  
	'SXADBChange',  
	'SXADBClientMergeQueue',  
	'SXADBClientTransferQueue',  
	'SXADBCMPTRecentMerge',  
	'SXADBMultumRxQueue',  
	'SXADBObsoleteData',  
	'SXADBWUIACatalogRightsChange',  
	'SXAEDBoardColumnXREF',  
	'SXAGNNotificationQueue',  
	'SXAMMBillingQueue',  
	'SXAMMBillingQueueDetail',  
	'SXAMMOrderTaskOccurrenceQueue',  
	'SXAMMOrderWorkQueue',  
	'SXAMMOrderWorkQueueErrorLog' ,
	'CV3ScheduledMlm',
	'SXAISSHL7Message',
	'SXAISSHL7MessageDetail',
	'SXAISSHL7MessageStatus',
	'SXAISSScheduledBatch',
	'SXAISSXltrMessaging',
	'WorkerRetry',
	'HL7OutputSequence',
	'InboundMessageSync',
	'IWSuspendedIDWIP',
	'OWSuspendedIDWIP',
	'RejectedMessages',
	'SequenceCount',
	'SuspendedIDs',
	'SuspendedMessages',
	'SCMDevIntfData' ,
	'SXACDCacheData',
	'CV3AdvancedVisitListData',
	'SXAAMBeRxAudit',
	'SXAMMClientMergeReportData',
	'SXAMMClientTransferReportData',
	'SXAMMFillingLabelData',
	'SXAMMFillingReportData',
	'SXAMMFillingReportErrorLog',
	'SXAMMFillingReport',
	'SXAMMFloorstockFillingReport',
	'SXAMMMARReport',
	'SXAAMBAWMUser',
	'SXAAMBAWMDocument',
	'SXAAMBAWMResult',
	'SXAAMBAWMAlert',
	'SXAAMClientVisitLock',
	'sxavwfcontextdetail',
	'SXAVWFScheduledWorkflowInstances',
	'SXAVWFInboundEventQueueComplete',
	'SXAVWFTrackingBookmarkResumptionEvent',
	'SXAVWFTrackingActivityInstanceEvent',
	'SXAVWFTrackingCustomTrackingEvent',
	'SXAVWFTrackingExtendedActivityEvent',
	'SXAVWFTrackingWorkflowInstanceEvent',
	'SXAVWFWorkflowDefinitionInstanceXREF',
	'SXAVWFWorkflowEngineQueue',
	'SXAGNReconciliationDocument',
	'SXASRGAppointmentInfo',
	'SXACDDirectInboundQueue',
	'SXACDDirectInboundQueueAssignedRecipientXRef')  OR 
	h.name like '%[_]R') -- Report tables
--select * from #VolatileTables


DECLARE table_cursor  CURSOR STATIC FOR   
SELECT TableName, IndexName, Fragmentation
FROM #VolatileTables h
WHERE Fragmentation >= 10

OPEN table_cursor    
FETCH NEXT FROM table_cursor INTO @ObjectName, @IndexName , @avg_frag
WHILE (@@fetch_status = 0)     
BEGIN 
    IF @avg_frag > 30 -- This will do the rebuild
	BEGIN

	--select @ObjectName
	SET @StartDTM = GETDATE()
	IF   EXISTS ( SELECT * FROM information_schema.COLUMNS WHERE Table_name = @ObjectName  AND DATA_TYPE in ( 'text','ntext','image')) -- @ObjectName in ('CV3SendADTQueue','CV3ClientDocumentJoin_R','SXAAMBeRXAudit','CV3Session')
	BEGIN
		SET @SQL = 'ALTER INDEX [' + @IndexName +'] ON [' + @ObjectName + '] REORGANIZE /* '+ convert(varchar(5),Getdate(),8) + ' */ '

		SET @SQL = @SQL + 'UPDATE STATISTICS [' + @ObjectName + ']' + ' (' + @IndexName + ')'

	END 
	ELSE
		SET @SQL = 'ALTER INDEX [' + @IndexName +'] ON [' + @ObjectName + '] REBUILD WITH (ONLINE=ON) --'+convert(varchar(5),Getdate(),8)  
	--select @sql 
	EXEC @ReturnStatus = sp_executesql @SQL  
	SET @ReturnStatus = ISNULL ( NULLIF ( @ReturnStatus, 0), @@ERROR )  
	IF @ReturnStatus <> 0  
	BEGIN  
		DEALLOCATE table_cursor   
		RAISERROR ('Error Rebuilding index on table: %s ',16,1,@ObjectName)  
		RETURN  
	END  
	SET @EndDTM = GETDATE()  
	SET @TimeTaken = dateDiff(s,@StartDTM,@EndDTM) --seconds
	INSERT VolatileTablesResults
	SELECT @ObjectName AS tablename,  @IndexName,  @avg_frag as Fragmentation,@TimeTaken AS DurationSec, @StartDTM, @EndDTM 
	FETCH NEXT FROM table_cursor INTO @ObjectName, @IndexName , @avg_frag 
	
	END 

	ELSE  -- This will do the reorg.

	BEGIN
	SET @StartDTM = GETDATE()
	    SET @SQL = 'ALTER INDEX [' + @IndexName +'] ON [' + @ObjectName + '] REORGANIZE /* '+ convert(varchar(5),Getdate(),8) + ' */ '

		SET @SQL = @SQL + 'UPDATE STATISTICS [' + @ObjectName + ']' + ' (' + @IndexName + ')'

	
	EXEC @ReturnStatus = sp_executesql @SQL 
	SET @ReturnStatus = ISNULL ( NULLIF ( @ReturnStatus, 0), @@ERROR )  
	IF @ReturnStatus <> 0  
	BEGIN  
		DEALLOCATE table_cursor   
		RAISERROR ('Error Reorganizing the index on table: %s ',16,1,@ObjectName)  
		RETURN  
	END  
	SET @EndDTM = GETDATE()  
	SET @TimeTaken = dateDiff(s,@StartDTM,@EndDTM) --seconds
	INSERT VolatileTablesResults
	SELECT @ObjectName AS tablename,  @IndexName,  @avg_frag as Fragmentation,@TimeTaken AS DurationSec, @StartDTM, @EndDTM
	FETCH NEXT FROM table_cursor INTO @ObjectName, @IndexName , @avg_frag 
	
	END

END
DEALLOCATE table_cursor  



