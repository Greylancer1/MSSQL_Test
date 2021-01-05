SELECT *
FROM dbo.MTV_System$WorkItem$ServiceRequest AS SR
LEFT OUTER JOIN dbo.BaseManagedEntity AS BME --Grab the BaseManagedEntity to make sure SR is not currently deleted
	ON BME.BaseManagedEntityId = SR.BaseManagedEntityId AND BME.IsDeleted = 0
LEFT OUTER JOIN dbo.Relationship AS RelationshipAffectedUser --Join with the Relationship table
	ON SR.BaseManagedEntityId = RelationshipAffectedUser.SourceEntityId AND --where the source of the relationship is the service request
       RelationshipAffectedUser.RelationshipTypeId = 'DFF9BE66-38B0-B6D6-6144-A412A3EBD4CE' AND --and the relationship type id is for System.WorkItemAffectedUser
       RelationshipAffectedUser.IsDeleted = 0 --and where the relationship instance itself is not deleted
LEFT OUTER JOIN dbo.MTV_System$Domain$User AS WorkItemAffectedUser --Join with the User table
	ON RelationshipAffectedUser.TargetEntityId = WorkItemAffectedUser.BaseManagedEntityId AND --where the target of the relationship is the user
       WorkItemAffectedUser.ObjectStatus_4AE3E5FE_BC03_1336_0A45_80BF58DEE57B <> '47101e64-237f-12c8-e3f5-ec5a665412fb' --and the user's object status is not pending delete