--Permissions
--Always On availability groups catalog views require VIEW ANY --DEFINITION permission on the server instance. Always On --availability groups dynamic management views require VIEW SERVER --STATE permission on the server.

GRANT VIEW ANY DEFINITION TO [USER]
GRANT VIEW SERVER STATE TO [USER]