SELECT IncidentClassification.DisplayName As Display_Name 
,COUNT(*) As Total 
,AVG([Priority_B930B964_A1C4_0B5A_B2D1_BFBE9ECDC794]) AS Average_Priority 
,CONVERT(Decimal(10,2)
, (AVG (CONVERT(Decimal(10,2)
, DATEDIFF (HOUR, [CreatedDate_6258638D_B885_AB3C_E316_D00782B8F688]
, [ResolvedDate_D2A4C73F_01B8_29C5_895B_5BE4C3DFAC4E])))) / 24) As  Average_Days_Open 
FROM [ServiceManager].[dbo].[MT_System$WorkItem$Incident]   
INNER JOIN [ServiceManager].[dbo].[Relationship] AssignedToUserRel ON [ServiceManager].[dbo].[MT_System$WorkItem$Incident].[BaseManagedEntityId] = AssignedToUserRel.[SourceEntityId] 
AND AssignedToUserRel.[RelationshipTypeId] = '15E577A3-6BF9-6713-4EAC-BA5A5B7C4722' 
INNER JOIN [ServiceManager].[dbo].[MT_System$Domain$User] AssignedToUser ON AssignedToUserRel.[TargetEntityId] = AssignedToUser.[BaseManagedEntityId]   
INNER JOIN [ServiceManager].[dbo].[Relationship] AffectedUserRel ON [ServiceManager].[dbo].[MT_System$WorkItem$Incident].[BaseManagedEntityId] = AffectedUserRel.[SourceEntityId] 
AND AffectedUserRel.[RelationshipTypeId] = 'DFF9BE66-38B0-B6D6-6144-A412A3EBD4CE' 
INNER JOIN [ServiceManager].[dbo].[MT_System$Domain$User] AffectedUser ON AffectedUserRel.[TargetEntityId] = AffectedUser.[BaseManagedEntityId]   
INNER JOIN [ServiceManager].[dbo].[DisplayStringView] IncidentClassification ON [ServiceManager].[dbo].[MT_System$WorkItem$Incident].[Classification_00B528BF_FB8F_2ED4_2434_5DF2966EA5FA] = IncidentClassification.LTStringId 
AND IncidentClassification.LanguageCode = 'ENU'   
INNER JOIN [ServiceManager].[dbo].[DisplayStringView] IncidentStatus ON [ServiceManager].[dbo].[MT_System$WorkItem$Incident].[Status_785407A9_729D_3A74_A383_575DB0CD50ED] = IncidentStatus.LTStringId 
AND IncidentStatus.LanguageCode = 'ENU' 
AND IncidentStatus.DisplayName = 'Closed'   
OR  [ServiceManager].[dbo].[MT_System$WorkItem$Incident].[Status_785407A9_729D_3A74_A383_575DB0CD50ED] = IncidentStatus.LTStringId 
AND IncidentStatus.LanguageCode = 'ENU' 
AND IncidentStatus.DisplayName = 'Resolved' 
WHERE DATEDIFF (DAY, [CreatedDate_6258638D_B885_AB3C_E316_D00782B8F688], CURRENT_TIMESTAMP) < 30   
GROUP BY IncidentClassification.[DisplayName] 
ORDER BY Total DESC 