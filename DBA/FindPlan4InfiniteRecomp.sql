Declare @ErrorLog Table (LogID int identity(1, 1) not null primary key,
        LogDate datetime null, 
        ProcessInfo nvarchar(100) null,
        LogText nvarchar(4000) null);
 
Insert Into @ErrorLog (LogDate, ProcessInfo, LogText)
Exec master..xp_readerrorlog;
 
With Recompiles
As (Select LogID, LogDate,
        SPID = Replace(ProcessInfo, 'spid', ''),
        SQLHandle = Convert(varbinary(64),
                SUBSTRING(LogText, CHARINDEX('SQLHANDLE', LogText) + 10,
                    CharIndex(',', LogText) - CHARINDEX('SQLHANDLE', LogText) - 10), 1),
        PlanHandle = Convert(varbinary(64),
                SUBSTRING(LogText, CHARINDEX('PLANHANDLE', LogText) + 11,
                    CharIndex(',', LogText, CHARINDEX('PLANHANDLE', LogText)) -
                    CHARINDEX('PLANHANDLE', LogText) - 11), 1),
        StartingOffset = Convert(int,
                SUBSTRING(LogText, CHARINDEX('starting offset', LogText) + 16,
                    CharIndex(',', LogText, CHARINDEX('starting offset', LogText)) -
                    CHARINDEX('starting offset', LogText) - 16)),
        EndingOffset = Convert(int,
                SUBSTRING(LogText, CHARINDEX('ending offset', LogText) + 14,
                    CharIndex('.', LogText, CHARINDEX('ending offset', LogText)) -
                    CHARINDEX('ending offset', LogText) - 14)),
        LastRecompileReason = SUBSTRING(LogText, CHARINDEX('last recompile reason was', LogText) + 26,
                CharIndex('.', LogText, CHARINDEX('last recompile reason was', LogText)) -
                CHARINDEX('last recompile reason was', LogText) - 26)
    From @ErrorLog
    Where CharIndex('A possible infinite recompile was detected for SQLHANDLE', LogText) > 0)
Select R.SPID, R.LogDate,
    LastRecompileReason = Case R.LastRecompileReason When 1 Then 'Schema changed'
            When 2 Then 'Statistics changed (' + R.LastRecompileReason + ')'
            When 3 Then 'Deferred compile (' + R.LastRecompileReason + ')'
            When 4 Then 'Set option changed (' + R.LastRecompileReason + ')'
            When 5 Then 'Temp table changed (' + R.LastRecompileReason + ')'
            When 6 Then 'Remote rowset changed (' + R.LastRecompileReason + ')'
            When 7 Then 'For Browse permissions changed (' + R.LastRecompileReason + ')'
            When 8 Then 'Query notification environment changed (' + R.LastRecompileReason + ')'
            When 9 Then 'Partition view changed (' + R.LastRecompileReason + ')'
            When 10 Then 'Cursor options changed (' + R.LastRecompileReason + ')'
            When 11 Then 'Option (recompile) requested (' + R.LastRecompileReason + ')'
            Else 'Unknown (' + R.LastRecompileReason + ')'
        End,
    DBName = DB_NAME(ST.dbid),
    ObjectName = IsNull(OBJECT_SCHEMA_NAME(ST.objectid, ST.dbid) + N'.', '') +
        IsNull(OBJECT_NAME(ST.objectid, ST.dbid), N'ad hoc or prepared'),
    Command = SUBSTRING(ST.TEXT,
            R.StartingOffset / 2 + 1,
            ((Case R.EndingOffset When -1 THEN DATALENGTH(ST.text)
                Else R.EndingOffset
            End) - R.StartingOffset) / 2 + 1),
    QueryPlan = QP.query_plan,
    FullSQLText = ST.text
From Recompiles As R
Outer Apply sys.dm_exec_sql_text(R.SQLHandle) As ST
Outer Apply sys.dm_exec_query_plan(R.PlanHandle) As QP
Order By R.LogID Desc;