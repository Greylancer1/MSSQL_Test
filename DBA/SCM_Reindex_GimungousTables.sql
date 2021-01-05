--SCM big tables in need of offline reindexing:  Total run time against DEVLOAD: 01:24:45, 40:08
--CV3OrderStatusHistory; OrderStatusHistClustIdx

ALTER INDEX OrderStatusHistClustIdx ON CV3OrderStatusHistory REBUILD WITH (ONLINE = OFF, MAXDOP = 4) --11:59, 08:06, 07:45

--CV3WorkUserItemAccess; CV3WorkUserItemAccessAI03

ALTER INDEX CV3WorkUserItemAccessAI03 ON CV3WorkUserItemAccess REBUILD WITH (ONLINE = OFF, MAXDOP = 4) --00:35, 00:38

--CV3ObsFSListValues; SCMObsFSListValuesAI03

ALTER INDEX SCMObsFSListValuesAI03 ON SCMObsFSListValues REBUILD WITH (ONLINE = OFF, MAXDOP = 4) --07:12, 07:17

--CV3OrderTaskOccurrence; CV3OrderTaskOccurrenceAI01

ALTER INDEX CV3OrderTaskOccurrenceAI01 ON CV3OrderTaskOccurrence REBUILD WITH (ONLINE = OFF, MAXDOP = 4) --01:47, 01:14

--CV3OrderStatusHistory; CV3OrderStatusHistoryPK

ALTER INDEX CV3OrderStatusHistoryPK ON CV3OrderStatusHistory REBUILD WITH (ONLINE = OFF, MAXDOP = 4) --02:44, 01:32

--CV3OrderTaskOccurrence; OrderTaskOccurClustIdx

ALTER INDEX OrderTaskOccurClustIdx ON CV3OrderTaskOccurrence REBUILD WITH (ONLINE = OFF, MAXDOP = 4) --08:33, 05:43

--CV3ObsFSListValues; SCMObsFSListValuesCI

--ALTER INDEX SCMObsFSListValuesCI ON SCMObsFSListValues REBUILD WITH (ONLINE = OFF, MAXDOP = 4) --31:53, Undoable



--Reorgs vs. rebuild?
--CV3TaskStatusHistory; CV3TaskStatusHistoryAI01

--ALTER INDEX TaskStatusHistoryAI01 ON CV3TaskStatusHistory REORGANIZE --31:34
ALTER INDEX TaskStatusHistoryAI01 ON CV3TaskStatusHistory REBUILD WITH (ONLINE = OFF, MAXDOP = 4) --01:24

--CV3TaskStatusHistory; CV3TaskStatusHistoryClustIdx

--ALTER INDEX TaskStatusHistoryClustIdx ON CV3TaskStatusHistory REORGANIZE --02:11:18
ALTER INDEX TaskStatusHistoryClustIdx ON CV3TaskStatusHistory REBUILD WITH (ONLINE = OFF, MAXDOP = 4) --03:51

--CV3OrderTaskOccurrence; CV3OrderTaskOccurrencePK

--ALTER INDEX CV3OrderTaskOccurrencePK ON CV3OrderTaskOccurrence REORGANIZE --15:41
ALTER INDEX CV3OrderTaskOccurrencePK ON CV3OrderTaskOccurrence REBUILD WITH (ONLINE = OFF, MAXDOP = 4) --00:38

--CV3TaskStatusHistory; CV3TaskStatusHistoryPK

--ALTER INDEX CV3TaskStatusHistoryPK ON CV3TaskStatusHistory REORGANIZE --21:59
ALTER INDEX CV3TaskStatusHistoryPK ON CV3TaskStatusHistory REBUILD WITH (ONLINE = OFF, MAXDOP = 4) --01:13

--CV3WorkUserItemAccess; CV3WorkUserItemAccessPK

--ALTER INDEX CV3WorkUserItemAccessPK ON CV3WorkUserItemAccess REORGANIZE --02:40
ALTER INDEX CV3WorkUserItemAccessPK ON CV3WorkUserItemAccess REBUILD WITH (ONLINE = OFF, MAXDOP = 4) --00:15

--CV3BasicObservation; BasicObservationClustIdx

--ALTER INDEX BasicObservationClustIdx ON CV3BasicObservation REORGANIZE --01:27:07
ALTER INDEX BasicObservationClustIdx ON CV3BasicObservation REBUILD WITH (ONLINE = OFF, MAXDOP = 4) --03:46

--CV3ObservationDocumentCUR; CV3ObservationDocumentCURCI

--ALTER INDEX CV3ObservationDocumentCURCI ON CV3ObservationDocumentCUR REORGANIZE --01:14
ALTER INDEX CV3ObservationDocumentCURCI ON CV3ObservationDocumentCUR REBUILD WITH (ONLINE = OFF, MAXDOP = 4) --00:20

--CV3BasicObservation; CV3BasicObservationPK

--ALTER INDEX CV3BasicObservationPK ON CV3BasicObservation REORGANIZE --13:10
ALTER INDEX CV3BasicObservationPK ON CV3BasicObservation REBUILD WITH (ONLINE = OFF, MAXDOP = 4) --00:50

--CV3OrderStatusHistory; CV3OrderStatusHistoryAI01

--ALTER INDEX CV3OrderStatusHistoryAI01 ON CV3OrderStatusHistory REORGANIZE --29:10
ALTER INDEX CV3OrderStatusHistoryAI01 ON CV3OrderStatusHistory REBUILD WITH (ONLINE = OFF, MAXDOP = 4) --01:29

--CV3DiagnosticExtension; CV3DiagnosticExtensionPK

--ALTER INDEX CV3DiagnosticExtensionPK ON CV3DiagnosticExtension REORGANIZE --05:49
ALTER INDEX CV3DiagnosticExtensionPK ON CV3DiagnosticExtension REBUILD WITH (ONLINE = OFF, MAXDOP = 4) --00:19

--CV3ClientUserData; ClientUserDataClustIdx

--ALTER INDEX ClientUserDataClustIdx ON CV3ClientUserData REORGANIZE --02:15
ALTER INDEX ClientUserDataClustIdx ON CV3ClientUserData REBUILD WITH (ONLINE = OFF, MAXDOP = 4) --00:16

--CV3CareProviderVisitRole; CV3CareProviderVisitRoleCI

--ALTER INDEX CV3CareProviderVisitRoleCI ON CV3CareProviderVisitRole REORGANIZE --03:31
ALTER INDEX CV3CareProviderVisitRoleCI ON CV3CareProviderVisitRole REBUILD WITH (ONLINE = OFF, MAXDOP = 4) --00:20