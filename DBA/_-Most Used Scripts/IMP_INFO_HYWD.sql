SELECT * FROM 
( 
     Select S.SampleDate, S.Value, VC.ColumnName as Name FROM aaLogging..SystemStatusSamples S 
          inner join aaLogging..SystemStatusValueCodes VC ON VC.ValueCode = S.SampleType 
          where S.SampleType <> 57 and VC.SampleInterval = 5 
) Data 
pivot 
( 
     max(value) for Name in (QuotePushQueue, OldestQuotePushEntry, ContactPostQueue, OldestContactPostEntry, ProspectPushQueue, LeadPushQueue, PendingDeltaWorkgroups, PendingDeltaAccounts, ListLoadQueue, LeadDataAppend, ProspectDataAppend, TomCatInBookQueue, UserSessionsInitiated, ProspectPushProcessed, LeadPushProcessed, QuotePushProcessed, ContactPostProcessed, ProspectDataAppendProcessed, LeadDataAppendProcessed, ILeadsDelivered, ILeadsReceived, ILeadsRejected, ContactPostTTFD, QuoteImportQueue, QuoteImportQueueErrors, DNCHits, ContactsViewed, QuickReportsRun, QuickReportsErrors, AnalyzerQueriesRun, DNMHits, SMPTriggers, SMPTriggersCreated, WorkgroupsWithTriggers, SMPInstancesFromTriggers, AddressStandardizationQueue, AddressStandardizationErrors, AddressStandardizationComplete, WorkgroupsWithLeadAlerts, LeadAlertsDesktop, LeadAlertsText, LeadAlertsCall, WorkgroupsWithCampaignCalls, CampaignCallsStarted, WorkgroupsWithWFActivity, WorkgroupsWithWFPrograms, WorkflowActivities, AgentAnalyzerQueries, CorporateAnalyzerQueries, PreQuotesPerformed, PreQuoteBatchRequested, PreQuoteBatchReceived, SearchesExecuted, SearchesWithNoResults, SearchTimeAverage, ExternalSearchesExecuted, ILeadsErrors, PreQuoteRequests, PreQuoteErrors) 
) piv 
WHERE SampleDate > dateadd(day, -1, getutcdate()) 
order by SampleDate desc


*****

SELECT COUNT(*), [Status]
  FROM [SIMSQueue].[quotepush].[Queue]
  GROUP BY [Status]