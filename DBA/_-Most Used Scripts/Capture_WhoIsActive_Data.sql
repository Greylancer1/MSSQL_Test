DECLARE @destination_table VARCHAR(4000);
SET @destination_table = 'WhoIsActive_' + CONVERT(VARCHAR, GETDATE(), 112);

DECLARE @schema VARCHAR(4000);
EXEC sp_WhoIsActive
    @FORMAT_OUTPUT = 0,
    @RETURN_SCHEMA = 1,
    @SCHEMA = @schema OUTPUT;

SET @schema = 
    REPLACE
    (
        @schema, 
        '<table_name>', 
        @destination_table
    );

EXEC(@schema);

DECLARE @i INT;
SET @i = 0;

WHILE @i < 10
BEGIN;
    EXEC sp_WhoIsActive
        @FORMAT_OUTPUT = 0,
        @DESTINATION_TABLE = @destination_table;
    
    SET @i = @i + 1;
    
    WAITFOR DELAY '00:00:15'
END;
GO