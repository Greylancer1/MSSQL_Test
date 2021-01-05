/****** Script for SelectTopNRows command from SSMS  ******/
SELECT TOP 1000 [session_id]
      ,[wait_type]
      ,[wait_duration_ms]
      ,[blocking_session_id]
      ,[reource_description]
      ,[dtm]
      ,[resourcetype]
      ,[SQLTxt]
  FROM [DBA].[dbo].[TempDBContentionSnapshot]
  ORDER BY dtm DESC

DECLARE
    @destination_table VARCHAR(4000) ,
    @msg NVARCHAR(1000) ;

SET @destination_table = 'WhoIsActive_' + CONVERT(VARCHAR, GETDATE(), 112) ;

DECLARE @numberOfRuns INT ;
SET @numberOfRuns = 10 ;

WHILE @numberOfRuns > 0
    BEGIN;
        EXEC dbo.sp_WhoIsActive @get_transaction_info = 1, @get_plans = 1,
            @destination_table = @destination_table ;

        SET @numberOfRuns = @numberOfRuns - 1 ;

        IF @numberOfRuns > 0
            BEGIN
                SET @msg = CONVERT(CHAR(19), GETDATE(), 121) + ': ' +
                 'Logged info. Waiting...'
                RAISERROR(@msg,0,0) WITH nowait ;

                WAITFOR DELAY '00:00:05'
            END
        ELSE
            BEGIN
                SET @msg = CONVERT(CHAR(19), GETDATE(), 121) + ': ' + 'Done.'
                RAISERROR(@msg,0,0) WITH nowait ;
            END

    END ;
GO


---Different Table
DECLARE
    @destination_table VARCHAR(4000) ,
    @msg NVARCHAR(1000) ;

SET @destination_table = 'DBA_WhoIsActive' ;

DECLARE @numberOfRuns INT ;
SET @numberOfRuns = 10 ;

WHILE @numberOfRuns > 0
    BEGIN;
        EXEC dbo.sp_WhoIsActive @get_transaction_info = 1, @get_plans = 1,
            @destination_table = @destination_table ;

        SET @numberOfRuns = @numberOfRuns - 1 ;

        IF @numberOfRuns > 0
            BEGIN
                SET @msg = CONVERT(CHAR(19), GETDATE(), 121) + ': ' +
                 'Logged info. Waiting...'
                RAISERROR(@msg,0,0) WITH nowait ;

                WAITFOR DELAY '00:00:05'
            END
        ELSE
            BEGIN
                SET @msg = CONVERT(CHAR(19), GETDATE(), 121) + ': ' + 'Done.'
                RAISERROR(@msg,0,0) WITH nowait ;
            END

    END ;
GO




DECLARE @destination_table NVARCHAR(2000), @dSQL NVARCHAR(4000) ;
SET @destination_table = 'WhoIsActive_' + CONVERT(VARCHAR, GETDATE(), 112) ;
SET @dSQL = N'SELECT collection_time, * FROM dbo.' +
 QUOTENAME(@destination_table) + N' order by 1 desc' ;
print @dSQL
EXEC sp_executesql @dSQL