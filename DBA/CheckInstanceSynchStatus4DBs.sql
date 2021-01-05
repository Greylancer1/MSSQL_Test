SELECT        DB_NAME(database_id) AS [Database Name], is_primary_replica, synchronization_state, synchronization_state_desc, synchronization_health, synchronization_health_desc, database_state, 
                         database_state_desc, is_suspended, suspend_reason, suspend_reason_desc
FROM            sys.dm_hadr_database_replica_states