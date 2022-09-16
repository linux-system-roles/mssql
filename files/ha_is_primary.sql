IF EXISTS(
  SELECT role
  FROM sys.dm_hadr_availability_replica_states states
  JOIN sys.availability_replicas replicas
  ON states.replica_id = replicas.replica_id
  WHERE states.is_local = 1
    AND
    role = 1
)
BEGIN
  PRINT(1)
END
ELSE
BEGIN
  PRINT(0)
END
