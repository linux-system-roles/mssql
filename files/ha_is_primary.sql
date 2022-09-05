SELECT role
FROM sys.dm_hadr_availability_replica_states states
JOIN sys.availability_replicas replicas
ON states.replica_id = replicas.replica_id
WHERE states.is_local = 1
