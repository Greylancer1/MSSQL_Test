USE [master]
GO
/****** Object:  Database [DBA]    Script Date: 4/26/2016 11:40:47 AM ******/
CREATE DATABASE [DBA]
 CONTAINMENT = NONE
 ON  PRIMARY 
( NAME = N'DBA_Data', FILENAME = N'D:\MSSQL\DATA\DBA.mdf' , SIZE = 3286144KB , MAXSIZE = UNLIMITED, FILEGROWTH = 10%)
 LOG ON 
( NAME = N'DBA_Log', FILENAME = N'D:\MSSQL\DATA\DBA_log.ldf' , SIZE = 1024KB , MAXSIZE = 10240000KB , FILEGROWTH = 10%)
GO
ALTER DATABASE [DBA] SET COMPATIBILITY_LEVEL = 100
GO
IF (1 = FULLTEXTSERVICEPROPERTY('IsFullTextInstalled'))
begin
EXEC [DBA].[dbo].[sp_fulltext_database] @action = 'disable'
end
GO
ALTER DATABASE [DBA] SET ANSI_NULL_DEFAULT OFF 
GO
ALTER DATABASE [DBA] SET ANSI_NULLS OFF 
GO
ALTER DATABASE [DBA] SET ANSI_PADDING OFF 
GO
ALTER DATABASE [DBA] SET ANSI_WARNINGS OFF 
GO
ALTER DATABASE [DBA] SET ARITHABORT OFF 
GO
ALTER DATABASE [DBA] SET AUTO_CLOSE OFF 
GO
ALTER DATABASE [DBA] SET AUTO_CREATE_STATISTICS ON 
GO
ALTER DATABASE [DBA] SET AUTO_SHRINK ON 
GO
ALTER DATABASE [DBA] SET AUTO_UPDATE_STATISTICS ON 
GO
ALTER DATABASE [DBA] SET CURSOR_CLOSE_ON_COMMIT OFF 
GO
ALTER DATABASE [DBA] SET CURSOR_DEFAULT  GLOBAL 
GO
ALTER DATABASE [DBA] SET CONCAT_NULL_YIELDS_NULL OFF 
GO
ALTER DATABASE [DBA] SET NUMERIC_ROUNDABORT OFF 
GO
ALTER DATABASE [DBA] SET QUOTED_IDENTIFIER OFF 
GO
ALTER DATABASE [DBA] SET RECURSIVE_TRIGGERS OFF 
GO
ALTER DATABASE [DBA] SET  DISABLE_BROKER 
GO
ALTER DATABASE [DBA] SET AUTO_UPDATE_STATISTICS_ASYNC OFF 
GO
ALTER DATABASE [DBA] SET DATE_CORRELATION_OPTIMIZATION OFF 
GO
ALTER DATABASE [DBA] SET TRUSTWORTHY OFF 
GO
ALTER DATABASE [DBA] SET ALLOW_SNAPSHOT_ISOLATION OFF 
GO
ALTER DATABASE [DBA] SET PARAMETERIZATION SIMPLE 
GO
ALTER DATABASE [DBA] SET READ_COMMITTED_SNAPSHOT OFF 
GO
ALTER DATABASE [DBA] SET HONOR_BROKER_PRIORITY OFF 
GO
ALTER DATABASE [DBA] SET RECOVERY SIMPLE 
GO
ALTER DATABASE [DBA] SET  MULTI_USER 
GO
ALTER DATABASE [DBA] SET PAGE_VERIFY TORN_PAGE_DETECTION  
GO
ALTER DATABASE [DBA] SET DB_CHAINING OFF 
GO
ALTER DATABASE [DBA] SET FILESTREAM( NON_TRANSACTED_ACCESS = OFF ) 
GO
ALTER DATABASE [DBA] SET TARGET_RECOVERY_TIME = 0 SECONDS 
GO
EXEC sys.sp_db_vardecimal_storage_format N'DBA', N'ON'
GO
USE [DBA]
GO
/****** Object:  User [ITAppMgr]    Script Date: 4/26/2016 11:40:47 AM ******/
CREATE USER [ITAppMgr] WITHOUT LOGIN WITH DEFAULT_SCHEMA=[ITAppMgr]
GO
/****** Object:  User [DiskCollector]    Script Date: 4/26/2016 11:40:47 AM ******/
CREATE USER [DiskCollector] WITHOUT LOGIN WITH DEFAULT_SCHEMA=[dbo]
GO
ALTER ROLE [db_owner] ADD MEMBER [ITAppMgr]
GO
ALTER ROLE [db_datawriter] ADD MEMBER [DiskCollector]
GO
/****** Object:  Schema [ITAppMgr]    Script Date: 4/26/2016 11:40:47 AM ******/
CREATE SCHEMA [ITAppMgr]
GO
/****** Object:  StoredProcedure [dbo].[DBA_CheckDisk]    Script Date: 4/26/2016 11:40:47 AM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
-- =============================================
-- Author:		<Author,,Name>
-- Create date: <Create Date,,>
-- Description:	<Description,,>
-- =============================================
CREATE PROCEDURE [dbo].[DBA_CheckDisk] 

AS
BEGIN
	-- SET NOCOUNT ON added to prevent extra result sets from
	-- interfering with SELECT statements.
	SET NOCOUNT ON;

    -- Insert statements for procedure here
	/* Populate #disk_free_space with data */
	DECLARE @DiskFreeSpace varchar(50);
	DECLARE @MailSubject varchar(50);
	DECLARE @DriveLetter varchar(50);
	DECLARE @DriveCBenchmark varchar(50);
	DECLARE @AlertMessage varchar(50);
	DECLARE @OtherDataDriveBenchmark varchar(50);
	
INSERT INTO #disk_free_space
	EXEC master..xp_fixeddrives

SELECT @DiskFreeSpace = FreeMB FROM #disk_free_space where DriveLetter = 'C'

IF @DiskFreeSpace < @DriveCBenchmark
Begin
SET @MailSubject = 'Drive C free space is low on ' + @@SERVERNAME
SET @AlertMessage = 'Drive C on ' + @@SERVERNAME + ' has only ' +  CAST(@DiskFreeSpace AS VARCHAR) + ' MB left. Please 
free up space on this drive. C drive usually has OS installed on it. Lower space on C could slow down performance of the 
server'
-- Send out email
EXEC master..xp_sendmail @recipients = 'keith.duggins@chomp.org',
@subject = @MailSubject,
@message = @AlertMessage
End

DECLARE DriveSpace CURSOR FAST_FORWARD FOR
select DriveLetter, FreeMB from #disk_free_space where DriveLetter not in ('C')

open DriveSpace
fetch next from DriveSpace into @DriveLetter, @DiskFreeSpace

WHILE (@@FETCH_STATUS = 0)
Begin
if @DiskFreeSpace < @OtherDataDriveBenchmark
Begin
set @MailSubject = 'Drive ' + @DriveLetter + ' free space is low on ' + @@SERVERNAME
set @AlertMessage = @DriveLetter + ' has only ' + cast(@DiskFreeSpace as varchar) + ' MB left. Please increase free space 
for this drive immediately to avoid production issues'
-- Send out email
EXEC master..xp_sendmail @recipients = 'MyEmail@MyCompany.com',
@subject = @MailSubject,
@message = @AlertMessage
End
fetch next from DriveSpace into @DriveLetter, @DiskFreeSpace
End
close DriveSpace
deallocate DriveSpace
DROP TABLE #disk_free_space

END

GO
/****** Object:  StoredProcedure [dbo].[dba_indexDefrag_sp]    Script Date: 4/26/2016 11:40:47 AM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

Create Procedure [dbo].[dba_indexDefrag_sp]

    /* Declare Parameters */
      @minFragmentation     float           = 10.0  
        /* in percent, will not defrag if fragmentation less than specified */
    , @rebuildThreshold     float           = 30.0  
        /* in percent, greater than @rebuildThreshold will result in rebuild instead of reorg */
    , @executeSQL           bit             = 1     
        /* 1 = execute; 0 = print command only */
    , @defragOrderColumn    nvarchar(20)    = 'range_scan_count'
        /* Valid options are: range_scan_count, fragmentation, page_count */
    , @defragSortOrder      nvarchar(4)     = 'DESC'
        /* Valid options are: ASC, DESC */
    , @timeLimit            int             = 720 /* defaulted to 12 hours */
        /* Optional time limitation; expressed in minutes */
    , @database             varchar(128)    = Null
        /* Option to specify a database name; null will return all */
    , @tableName            varchar(4000)   = Null  -- databaseName.schema.tableName
        /* Option to specify a table name; null will return all */
    , @forceRescan          bit             = 0
        /* Whether or not to force a rescan of indexes; 1 = force, 0 = use existing scan, if available */
    , @scanMode             varchar(10)     = N'LIMITED'
        /* Options are LIMITED, SAMPLED, and DETAILED */
    , @minPageCount         int             = 8 
        /*  MS recommends > 1 extent (8 pages) */
    , @maxPageCount         int             = Null
        /* NULL = no limit */
    , @excludeMaxPartition  bit             = 0
        /* 1 = exclude right-most populated partition; 0 = do not exclude; see notes for caveats */
    , @onlineRebuild        bit             = 1     
        /* 1 = online rebuild; 0 = offline rebuild; only in Enterprise */
    , @sortInTempDB         bit             = 1
        /* 1 = perform sort operation in TempDB; 0 = perform sort operation in the index's database */
    , @maxDopRestriction    tinyint         = Null
        /* Option to restrict the number of processors for the operation; only in Enterprise */
    , @printCommands        bit             = 0     
        /* 1 = print commands; 0 = do not print commands */
    , @printFragmentation   bit             = 0
        /* 1 = print fragmentation prior to defrag; 
           0 = do not print */
    , @defragDelay          char(8)         = '00:00:05'
        /* time to wait between defrag commands */
    , @debugMode            bit             = 0
        /* display some useful comments to help determine if/where issues occur */

As
/*********************************************************************************
    Name:       dba_indexDefrag_sp

    Author:     Michelle Ufford, http://sqlfool.com

    Purpose:    Defrags one or more indexes for one or more databases

    Notes:

    CAUTION: TRANSACTION LOG SIZE SHOULD BE MONITORED CLOSELY WHEN DEFRAGMENTING.
             DO NOT RUN UNATTENDED ON LARGE DATABASES DURING BUSINESS HOURS.

      @minFragmentation     defaulted to 10%, will not defrag if fragmentation 
                            is less than that
      
      @rebuildThreshold     defaulted to 30% as recommended by Microsoft in BOL;
                            greater than 30% will result in rebuild instead

      @executeSQL           1 = execute the SQL generated by this proc; 
                            0 = print command only

      @defragOrderColumn    Defines how to prioritize the order of defrags.  Only
                            used if @executeSQL = 1.  
                            Valid options are: 
                            range_scan_count = count of range and table scans on the
                                               index; in general, this is what benefits 
                                               the most from defragmentation
                            fragmentation    = amount of fragmentation in the index;
                                               the higher the number, the worse it is
                            page_count       = number of pages in the index; affects
                                               how long it takes to defrag an index

      @defragSortOrder      The sort order of the ORDER BY clause.
                            Valid options are ASC (ascending) or DESC (descending).

      @timeLimit            Optional, limits how much time can be spent performing 
                            index defrags; expressed in minutes.

                            NOTE: The time limit is checked BEFORE an index defrag
                                  is begun, thus a long index defrag can exceed the
                                  time limitation.

      @database             Optional, specify specific database name to defrag;
                            If not specified, all non-system databases will
                            be defragged.

      @tableName            Specify if you only want to defrag indexes for a 
                            specific table, format = databaseName.schema.tableName;
                            if not specified, all tables will be defragged.

      @forceRescan          Whether or not to force a rescan of indexes.  If set
                            to 0, a rescan will not occur until all indexes have
                            been defragged.  This can span multiple executions.
                            1 = force a rescan
                            0 = use previous scan, if there are indexes left to defrag

      @scanMode             Specifies which scan mode to use to determine
                            fragmentation levels.  Options are:
                            LIMITED - scans the parent level; quickest mode,
                                      recommended for most cases.
                            SAMPLED - samples 1% of all data pages; if less than
                                      10k pages, performs a DETAILED scan.
                            DETAILED - scans all data pages.  Use great care with
                                       this mode, as it can cause performance issues.

      @minPageCount         Specifies how many pages must exist in an index in order 
                            to be considered for a defrag.  Defaulted to 8 pages, as 
                            Microsoft recommends only defragging indexes with more 
                            than 1 extent (8 pages).  

                            NOTE: The @minPageCount will restrict the indexes that
                            are stored in dba_indexDefragStatus table.

      @maxPageCount         Specifies the maximum number of pages that can exist in 
                            an index and still be considered for a defrag.  Useful
                            for scheduling small indexes during business hours and
                            large indexes for non-business hours.

                            NOTE: The @maxPageCount will restrict the indexes that
                            are defragged during the current operation; it will not
                            prevent indexes from being stored in the 
                            dba_indexDefragStatus table.  This way, a single scan
                            can support multiple page count thresholds.

      @excludeMaxPartition  If an index is partitioned, this option specifies whether
                            to exclude the right-most populated partition.  Typically,
                            this is the partition that is currently being written to in
                            a sliding-window scenario.  Enabling this feature may reduce
                            contention.  This may not be applicable in other types of 
                            partitioning scenarios.  Non-partitioned indexes are 
                            unaffected by this option.
                            1 = exclude right-most populated partition
                            0 = do not exclude

      @onlineRebuild        1 = online rebuild; 
                            0 = offline rebuild

      @sortInTempDB         Specifies whether to defrag the index in TEMPDB or in the
                            database the index belongs to.  Enabling this option may
                            result in faster defrags and prevent database file size 
                            inflation.
                            1 = perform sort operation in TempDB
                            0 = perform sort operation in the index's database 

      @maxDopRestriction    Option to specify a processor limit for index rebuilds

      @printCommands        1 = print commands to screen; 
                            0 = do not print commands

      @printFragmentation   1 = print fragmentation to screen;
                            0 = do not print fragmentation

      @defragDelay          Time to wait between defrag commands; gives the
                            server a little time to catch up 

      @debugMode            1 = display debug comments; helps with troubleshooting
                            0 = do not display debug comments

    Called by:  SQL Agent Job or DBA

    ----------------------------------------------------------------------------
    DISCLAIMER: 
    This code and information are provided "AS IS" without warranty of any kind,
    either expressed or implied, including but not limited to the implied 
    warranties or merchantability and/or fitness for a particular purpose.
    ----------------------------------------------------------------------------
    LICENSE: 
    This index defrag script is free to download and use for personal, educational, 
    and internal corporate purposes, provided that this header is preserved. 
    Redistribution or sale of this index defrag script, in whole or in part, is 
    prohibited without the author's express written consent.
    ----------------------------------------------------------------------------
    Date        Initials	Version Description
    ----------------------------------------------------------------------------
    2007-12-18  MFU         1.0     Initial Release
    2008-10-17  MFU         1.1     Added @defragDelay, CIX_temp_indexDefragList
    2008-11-17  MFU         1.2     Added page_count to log table
                                    , added @printFragmentation option
    2009-03-17  MFU         2.0     Provided support for centralized execution
                                    , consolidated Enterprise & Standard versions
                                    , added @debugMode, @maxDopRestriction
                                    , modified LOB and partition logic  
    2009-06-18  MFU         3.0     Fixed bug in LOB logic, added @scanMode option
                                    , added support for stat rebuilds (@rebuildStats)
                                    , support model and msdb defrag
                                    , added columns to the dba_indexDefragLog table
                                    , modified logging to show "in progress" defrags
                                    , added defrag exclusion list (scheduling)
    2009-08-28  MFU         3.1     Fixed read_only bug for database lists
    2010-04-20  MFU         4.0     Added time limit option
                                    , added static table with rescan logic
                                    , added parameters for page count & SORT_IN_TEMPDB
                                    , added try/catch logic and additional debug options
                                    , added options for defrag prioritization
                                    , fixed bug for indexes with allow_page_lock = off
                                    , added option to exclude right-most partition
                                    , removed @rebuildStats option
                                    , refer to http://sqlfool.com for full release notes
*********************************************************************************
    Example of how to call this script:

        Exec dbo.dba_indexDefrag_sp
              @executeSQL           = 1
            , @printCommands        = 1
            , @debugMode            = 1
            , @printFragmentation   = 1
            , @forceRescan          = 1
            , @maxDopRestriction    = 1
            , @minPageCount         = 8
            , @maxPageCount         = Null
            , @minFragmentation     = 1
            , @rebuildThreshold     = 30
            , @defragDelay          = '00:00:05'
            , @defragOrderColumn    = 'page_count'
            , @defragSortOrder      = 'DESC'
            , @excludeMaxPartition  = 1
            , @timeLimit            = Null;
*********************************************************************************/																
Set NoCount On;
Set XACT_Abort On;
Set Quoted_Identifier On;

Begin

    Begin Try

        /* Just a little validation... */
        If @minFragmentation Is Null 
            Or @minFragmentation Not Between 0.00 And 100.0
                Set @minFragmentation = 10.0;

        If @rebuildThreshold Is Null
            Or @rebuildThreshold Not Between 0.00 And 100.0
                Set @rebuildThreshold = 30.0;

        If @defragDelay Not Like '00:[0-5][0-9]:[0-5][0-9]'
            Set @defragDelay = '00:00:05';

        If @defragOrderColumn Is Null
            Or @defragOrderColumn Not In ('range_scan_count', 'fragmentation', 'page_count')
                Set @defragOrderColumn = 'range_scan_count';

        If @defragSortOrder Is Null
            Or @defragSortOrder Not In ('ASC', 'DESC')
                Set @defragSortOrder = 'DESC';

        If @scanMode Not In ('LIMITED', 'SAMPLED', 'DETAILED')
            Set @scanMode = 'LIMITED';

        If @debugMode Is Null
            Set @debugMode = 0;

        If @forceRescan Is Null
            Set @forceRescan = 0;

        If @sortInTempDB Is Null
            Set @sortInTempDB = 1;


        If @debugMode = 1 RaisError('Undusting the cogs and starting up...', 0, 42) With NoWait;

        /* Declare our variables */
        Declare   @objectID                 int
                , @databaseID               int
                , @databaseName             nvarchar(128)
                , @indexID                  int
                , @partitionCount           bigint
                , @schemaName               nvarchar(128)
                , @objectName               nvarchar(128)
                , @indexName                nvarchar(128)
                , @partitionNumber          smallint
                , @fragmentation            float
                , @pageCount                int
                , @sqlCommand               nvarchar(4000)
                , @rebuildCommand           nvarchar(200)
                , @dateTimeStart            datetime
                , @dateTimeEnd              datetime
                , @containsLOB              bit
                , @editionCheck             bit
                , @debugMessage             nvarchar(4000)
                , @updateSQL                nvarchar(4000)
                , @partitionSQL             nvarchar(4000)
                , @partitionSQL_Param       nvarchar(1000)
                , @LOB_SQL                  nvarchar(4000)
                , @LOB_SQL_Param            nvarchar(1000)
                , @indexDefrag_id           int
                , @startDateTime            datetime
                , @endDateTime              datetime
                , @getIndexSQL              nvarchar(4000)
                , @getIndexSQL_Param        nvarchar(4000)
                , @allowPageLockSQL         nvarchar(4000)
                , @allowPageLockSQL_Param   nvarchar(4000)
                , @allowPageLocks           int
                , @excludeMaxPartitionSQL   nvarchar(4000);

        /* Initialize our variables */
        Select @startDateTime = GetDate()
            , @endDateTime = DateAdd(minute, @timeLimit, GetDate());

        /* Create our temporary tables */
        Create Table #databaseList
        (
              databaseID        int
            , databaseName      varchar(128)
            , scanStatus        bit
        );

        Create Table #processor 
        (
              [index]           int
            , Name              varchar(128)
            , Internal_Value    int
            , Character_Value   int
        );

        Create Table #maxPartitionList
        (
              databaseID        int
            , objectID          int
            , indexID           int
            , maxPartition      int
        );

        If @debugMode = 1 RaisError('Beginning validation...', 0, 42) With NoWait;

        /* Make sure we're not exceeding the number of processors we have available */
        Insert Into #processor
        Execute xp_msver 'ProcessorCount';

        If @maxDopRestriction Is Not Null And @maxDopRestriction > (Select Internal_Value From #processor)
            Select @maxDopRestriction = Internal_Value
            From #processor;

        /* Check our server version; 1804890536 = Enterprise, 610778273 = Enterprise Evaluation, -2117995310 = Developer */
        If (Select ServerProperty('EditionID')) In (1804890536, 610778273, -2117995310) 
            Set @editionCheck = 1 -- supports online rebuilds
        Else
            Set @editionCheck = 0; -- does not support online rebuilds

        /* Output the parameters we're working with */
        If @debugMode = 1 
        Begin

            Select @debugMessage = 'Your selected parameters are... 
            Defrag indexes with fragmentation greater than ' + Cast(@minFragmentation As varchar(10)) + ';
            Rebuild indexes with fragmentation greater than ' + Cast(@rebuildThreshold As varchar(10)) + ';
            You' + Case When @executeSQL = 1 Then ' DO' Else ' DO NOT' End + ' want the commands to be executed automatically; 
            You want to defrag indexes in ' + @defragSortOrder + ' order of the ' + UPPER(@defragOrderColumn) + ' value;
            You have' + Case When @timeLimit Is Null Then ' not specified a time limit;' Else ' specified a time limit of ' 
                + Cast(@timeLimit As varchar(10)) End + ' minutes;
            ' + Case When @database Is Null Then 'ALL databases' Else 'The ' + @database + ' database' End + ' will be defragged;
            ' + Case When @tableName Is Null Then 'ALL tables' Else 'The ' + @tableName + ' table' End + ' will be defragged;
            We' + Case When Exists(Select Top 1 * From dbo.dba_indexDefragStatus Where defragDate Is Null)
                And @forceRescan <> 1 Then ' WILL NOT' Else ' WILL' End + ' be rescanning indexes;
            The scan will be performed in ' + @scanMode + ' mode;
            You want to limit defrags to indexes with' + Case When @maxPageCount Is Null Then ' more than ' 
                + Cast(@minPageCount As varchar(10)) Else
                ' between ' + Cast(@minPageCount As varchar(10))
                + ' and ' + Cast(@maxPageCount As varchar(10)) End + ' pages;
            Indexes will be defragged' + Case When @editionCheck = 0 Or @onlineRebuild = 0 Then ' OFFLINE;' Else ' ONLINE;' End + '
            Indexes will be sorted in' + Case When @sortInTempDB = 0 Then ' the DATABASE' Else ' TEMPDB;' End + '
            Defrag operations will utilize ' + Case When @editionCheck = 0 Or @maxDopRestriction Is Null 
                Then 'system defaults for processors;' 
                Else Cast(@maxDopRestriction As varchar(2)) + ' processors;' End + '
            You' + Case When @printCommands = 1 Then ' DO' Else ' DO NOT' End + ' want to print the ALTER INDEX commands; 
            You' + Case When @printFragmentation = 1 Then ' DO' Else ' DO NOT' End + ' want to output fragmentation levels; 
            You want to wait ' + @defragDelay + ' (hh:mm:ss) between defragging indexes;
            You want to run in' + Case When @debugMode = 1 Then ' DEBUG' Else ' SILENT' End + ' mode.';

            RaisError(@debugMessage, 0, 42) With NoWait;
        
        End;

        If @debugMode = 1 RaisError('Grabbing a list of our databases...', 0, 42) With NoWait;

        /* Retrieve the list of databases to investigate */
        Insert Into #databaseList
        Select database_id
            , name
            , 0 -- not scanned yet for fragmentation
        From sys.databases
        Where name = IsNull(@database, name)
            And [name] Not In ('master', 'tempdb')-- exclude system databases
            And [state] = 0 -- state must be ONLINE
            And is_read_only = 0;  -- cannot be read_only

        /* Check to see if we have indexes in need of defrag; otherwise, re-scan the database(s) */
        If Not Exists(Select Top 1 * From dbo.dba_indexDefragStatus Where defragDate Is Null)
            Or @forceRescan = 1
        Begin

            /* Truncate our list of indexes to prepare for a new scan */
            Truncate Table dbo.dba_indexDefragStatus;

            If @debugMode = 1 RaisError('Looping through our list of databases and checking for fragmentation...', 0, 42) With NoWait;

            /* Loop through our list of databases */
            While (Select Count(*) From #databaseList Where scanStatus = 0) > 0
            Begin

                Select Top 1 @databaseID = databaseID
                From #databaseList
                Where scanStatus = 0;

                Select @debugMessage = '  working on ' + DB_Name(@databaseID) + '...';

                If @debugMode = 1
                    RaisError(@debugMessage, 0, 42) With NoWait;

               /* Determine which indexes to defrag using our user-defined parameters */
                Insert Into dbo.dba_indexDefragStatus
                (
                      databaseID
                    , databaseName
                    , objectID
                    , indexID
                    , partitionNumber
                    , fragmentation
                    , page_count
                    , range_scan_count
                    , scanDate
                )
                Select
                      ps.database_id As 'databaseID'
                    , QuoteName(DB_Name(ps.database_id)) As 'databaseName'
                    , ps.object_id As 'objectID'
                    , ps.index_id As 'indexID'
                    , ps.partition_number As 'partitionNumber'
                    , Sum(ps.avg_fragmentation_in_percent) As 'fragmentation'
                    , Sum(ps.page_count) As 'page_count'
                    , os.range_scan_count
                    , GetDate() As 'scanDate'
                From sys.dm_db_index_physical_stats(@databaseID, Object_Id(@tableName), Null , Null, @scanMode) As ps
                Join sys.dm_db_index_operational_stats(@databaseID, Object_Id(@tableName), Null , Null) as os
                    On ps.database_id = os.database_id
                    And ps.object_id = os.object_id
                    and ps.index_id = os.index_id
                    And ps.partition_number = os.partition_number
                Where avg_fragmentation_in_percent >= @minFragmentation 
                    And ps.index_id > 0 -- ignore heaps
                    And ps.page_count > @minPageCount 
                    And ps.index_level = 0 -- leaf-level nodes only, supports @scanMode
                Group By ps.database_id 
                    , QuoteName(DB_Name(ps.database_id)) 
                    , ps.object_id 
                    , ps.index_id 
                    , ps.partition_number 
                    , os.range_scan_count
                Option (MaxDop 2);

                /* Do we want to exclude right-most populated partition of our partitioned indexes? */
                If @excludeMaxPartition = 1
                Begin

                    Set @excludeMaxPartitionSQL = '
                        Select ' + Cast(@databaseID As varchar(10)) + ' As [databaseID]
                            , [object_id]
                            , index_id
                            , Max(partition_number) As [maxPartition]
                        From ' + DB_Name(@databaseID) + '.sys.partitions
                        Where partition_number > 1
                            And [rows] > 0
                        Group By object_id
                            , index_id;';

                    Insert Into #maxPartitionList
                    Execute sp_executesql @excludeMaxPartitionSQL;

                End;
                
                /* Keep track of which databases have already been scanned */
                Update #databaseList
                Set scanStatus = 1
                Where databaseID = @databaseID;

            End

            /* We don't want to defrag the right-most populated partition, so
               delete any records for partitioned indexes where partition = Max(partition) */
            If @excludeMaxPartition = 1
            Begin

                Delete ids
                From dbo.dba_indexDefragStatus As ids
                Join #maxPartitionList As mpl
                    On ids.databaseID = mpl.databaseID
                    And ids.objectID = mpl.objectID
                    And ids.indexID = mpl.indexID
                    And ids.partitionNumber = mpl.maxPartition;

            End;

            /* Update our exclusion mask for any index that has a restriction on the days it can be defragged */
            Update ids
            Set ids.exclusionMask = ide.exclusionMask
            From dbo.dba_indexDefragStatus As ids
            Join dbo.dba_indexDefragExclusion As ide
                On ids.databaseID = ide.databaseID
                And ids.objectID = ide.objectID
                And ids.indexID = ide.indexID;
         
        End

        Select @debugMessage = 'Looping through our list... there are ' + Cast(Count(*) As varchar(10)) + ' indexes to defrag!'
        From dbo.dba_indexDefragStatus
        Where defragDate Is Null
            And page_count Between @minPageCount And IsNull(@maxPageCount, page_count);

        If @debugMode = 1 RaisError(@debugMessage, 0, 42) With NoWait;

        /* Begin our loop for defragging */
        While (Select Count(*) 
               From dbo.dba_indexDefragStatus 
               Where (
                           (@executeSQL = 1 And defragDate Is Null) 
                        Or (@executeSQL = 0 And defragDate Is Null And printStatus = 0)
                     )
                And exclusionMask & Power(2, DatePart(weekday, GetDate())-1) = 0
                And page_count Between @minPageCount And IsNull(@maxPageCount, page_count)) > 0
        Begin

            /* Check to see if we need to exit our loop because of our time limit */        
            If IsNull(@endDateTime, GetDate()) < GetDate()
            Begin
                RaisError('Our time limit has been exceeded!', 11, 42) With NoWait;
            End;

            If @debugMode = 1 RaisError('  Picking an index to beat into shape...', 0, 42) With NoWait;

            /* Grab the index with the highest priority, based on the values submitted; 
               Look at the exclusion mask to ensure it can be defragged today */
            Set @getIndexSQL = N'
            Select Top 1 
                  @objectID_Out         = objectID
                , @indexID_Out          = indexID
                , @databaseID_Out       = databaseID
                , @databaseName_Out     = databaseName
                , @fragmentation_Out    = fragmentation
                , @partitionNumber_Out  = partitionNumber
                , @pageCount_Out        = page_count
            From dbo.dba_indexDefragStatus
            Where defragDate Is Null ' 
                + Case When @executeSQL = 0 Then 'And printStatus = 0' Else '' End + '
                And exclusionMask & Power(2, DatePart(weekday, GetDate())-1) = 0
                And page_count Between @p_minPageCount and IsNull(@p_maxPageCount, page_count)
            Order By + ' + @defragOrderColumn + ' ' + @defragSortOrder;
                       
            Set @getIndexSQL_Param = N'@objectID_Out        int OutPut
                                     , @indexID_Out         int OutPut
                                     , @databaseID_Out      int OutPut
                                     , @databaseName_Out    nvarchar(128) OutPut
                                     , @fragmentation_Out   int OutPut
                                     , @partitionNumber_Out int OutPut
                                     , @pageCount_Out       int OutPut
                                     , @p_minPageCount      int
                                     , @p_maxPageCount      int';

            Execute sp_executesql @getIndexSQL
                , @getIndexSQL_Param
                , @p_minPageCount       = @minPageCount
                , @p_maxPageCount       = @maxPageCount
                , @objectID_Out         = @objectID OutPut
                , @indexID_Out          = @indexID OutPut
                , @databaseID_Out       = @databaseID OutPut
                , @databaseName_Out     = @databaseName OutPut
                , @fragmentation_Out    = @fragmentation OutPut
                , @partitionNumber_Out  = @partitionNumber OutPut
                , @pageCount_Out        = @pageCount OutPut;

            If @debugMode = 1 RaisError('  Looking up the specifics for our index...', 0, 42) With NoWait;

            /* Look up index information */
            Select @updateSQL = N'Update ids
                Set schemaName = QuoteName(s.name)
                    , objectName = QuoteName(o.name)
                    , indexName = QuoteName(i.name)
                From dbo.dba_indexDefragStatus As ids
                Inner Join ' + @databaseName + '.sys.objects As o
                    On ids.objectID = o.object_id
                Inner Join ' + @databaseName + '.sys.indexes As i
                    On o.object_id = i.object_id
                    And ids.indexID = i.index_id
                Inner Join ' + @databaseName + '.sys.schemas As s
                    On o.schema_id = s.schema_id
                Where o.object_id = ' + Cast(@objectID As varchar(10)) + '
                    And i.index_id = ' + Cast(@indexID As varchar(10)) + '
                    And i.type > 0
                    And ids.databaseID = ' + Cast(@databaseID As varchar(10));

            Execute sp_executesql @updateSQL;

            /* Grab our object names */
            Select @objectName  = objectName
                , @schemaName   = schemaName
                , @indexName    = indexName
            From dbo.dba_indexDefragStatus
            Where objectID = @objectID
                And indexID = @indexID
                And databaseID = @databaseID;

            If @debugMode = 1 RaisError('  Grabbing the partition count...', 0, 42) With NoWait;

            /* Determine if the index is partitioned */
            Select @partitionSQL = 'Select @partitionCount_OUT = Count(*)
                                        From ' + @databaseName + '.sys.partitions
                                        Where object_id = ' + Cast(@objectID As varchar(10)) + '
                                            And index_id = ' + Cast(@indexID As varchar(10)) + ';'
                , @partitionSQL_Param = '@partitionCount_OUT int OutPut';

            Execute sp_executesql @partitionSQL, @partitionSQL_Param, @partitionCount_OUT = @partitionCount OutPut;

            If @debugMode = 1 RaisError('  Seeing if there are any LOBs to be handled...', 0, 42) With NoWait;
        
            /* Determine if the table contains LOBs */
            Select @LOB_SQL = ' Select @containsLOB_OUT = Count(*)
                                From ' + @databaseName + '.sys.columns With (NoLock) 
                                Where [object_id] = ' + Cast(@objectID As varchar(10)) + '
                                   And (system_type_id In (34, 35, 99)
                                            Or max_length = -1);'
                                /*  system_type_id --> 34 = image, 35 = text, 99 = ntext
                                    max_length = -1 --> varbinary(max), varchar(max), nvarchar(max), xml */
                    , @LOB_SQL_Param = '@containsLOB_OUT int OutPut';

            Execute sp_executesql @LOB_SQL, @LOB_SQL_Param, @containsLOB_OUT = @containsLOB OutPut;

            If @debugMode = 1 RaisError('  Checking for indexes that do not allow page locks...', 0, 42) With NoWait;

            /* Determine if page locks are allowed; for those indexes, we need to always rebuild */
            Select @allowPageLockSQL = 'Select @allowPageLocks_OUT = Count(*)
                                        From ' + @databaseName + '.sys.indexes
                                        Where object_id = ' + Cast(@objectID As varchar(10)) + '
                                            And index_id = ' + Cast(@indexID As varchar(10)) + '
                                            And Allow_Page_Locks = 0;'
                , @allowPageLockSQL_Param = '@allowPageLocks_OUT int OutPut';

            Execute sp_executesql @allowPageLockSQL, @allowPageLockSQL_Param, @allowPageLocks_OUT = @allowPageLocks OutPut;

            If @debugMode = 1 RaisError('  Building our SQL statements...', 0, 42) With NoWait;

            /* If there's not a lot of fragmentation, or if we have a LOB, we should reorganize */
            If (@fragmentation < @rebuildThreshold Or @containsLOB >= 1 Or @partitionCount > 1)
                And @allowPageLocks = 0
            Begin
            
                Set @sqlCommand = N'Alter Index ' + @indexName + N' On ' + @databaseName + N'.' 
                                    + @schemaName + N'.' + @objectName + N' ReOrganize';

                /* If our index is partitioned, we should always reorganize */
                If @partitionCount > 1
                    Set @sqlCommand = @sqlCommand + N' Partition = ' 
                                    + Cast(@partitionNumber As nvarchar(10));

            End
            /* If the index is heavily fragmented and doesn't contain any partitions or LOB's, 
               or if the index does not allow page locks, rebuild it */
            Else If (@fragmentation >= @rebuildThreshold Or @allowPageLocks <> 0)
                And IsNull(@containsLOB, 0) != 1 And @partitionCount <= 1
            Begin

                /* Set online rebuild options; requires Enterprise Edition */
                If @onlineRebuild = 1 And @editionCheck = 1 
                    Set @rebuildCommand = N' Rebuild With (Online = On';
                Else
                    Set @rebuildCommand = N' Rebuild With (Online = Off';
                
                /* Set sort operation preferences */
                If @sortInTempDB = 1 
                    Set @rebuildCommand = @rebuildCommand + N', Sort_In_TempDB = On';
                Else
                    Set @rebuildCommand = @rebuildCommand + N', Sort_In_TempDB = Off';

                /* Set processor restriction options; requires Enterprise Edition */
                If @maxDopRestriction Is Not Null And @editionCheck = 1
                    Set @rebuildCommand = @rebuildCommand + N', MaxDop = ' + Cast(@maxDopRestriction As varchar(2)) + N')';
                Else
                    Set @rebuildCommand = @rebuildCommand + N')';

                Set @sqlCommand = N'Alter Index ' + @indexName + N' On ' + @databaseName + N'.'
                                + @schemaName + N'.' + @objectName + @rebuildCommand;

            End
            Else
                /* Print an error message if any indexes happen to not meet the criteria above */
                If @printCommands = 1 Or @debugMode = 1
                    RaisError('We are unable to defrag this index.', 0, 42) With NoWait;

            /* Are we executing the SQL?  If so, do it */
            If @executeSQL = 1
            Begin

                Set @debugMessage = 'Executing: ' + @sqlCommand;
                
                /* Print the commands we're executing if specified to do so */
                If @printCommands = 1 Or @debugMode = 1
                    RaisError(@debugMessage, 0, 42) With NoWait;

                /* Grab the time for logging purposes */
                Set @dateTimeStart  = GetDate();

                /* Log our actions */
                Insert Into dbo.dba_indexDefragLog
                (
                      databaseID
                    , databaseName
                    , objectID
                    , objectName
                    , indexID
                    , indexName
                    , partitionNumber
                    , fragmentation
                    , page_count
                    , dateTimeStart
                    , sqlStatement
                )
                Select
                      @databaseID
                    , @databaseName
                    , @objectID
                    , @objectName
                    , @indexID
                    , @indexName
                    , @partitionNumber
                    , @fragmentation
                    , @pageCount
                    , @dateTimeStart
                    , @sqlCommand;

                Set @indexDefrag_id = Scope_Identity();

                /* Wrap our execution attempt in a try/catch and log any errors that occur */
                Begin Try

                    /* Execute our defrag! */
                    Execute sp_executesql @sqlCommand;
                    Set @dateTimeEnd = GetDate();
                    
                    /* Update our log with our completion time */
                    Update dbo.dba_indexDefragLog
                    Set dateTimeEnd = @dateTimeEnd
                        , durationSeconds = DateDiff(second, @dateTimeStart, @dateTimeEnd)
                    Where indexDefrag_id = @indexDefrag_id;

                End Try
                Begin Catch

                    /* Update our log with our error message */
                    Update dbo.dba_indexDefragLog
                    Set dateTimeEnd = GetDate()
                        , durationSeconds = -1
                        , errorMessage = Error_Message()
                    Where indexDefrag_id = @indexDefrag_id;

                    If @debugMode = 1 
                        RaisError('  An error has occurred executing this command! Please review the dba_indexDefragLog table for details.'
                            , 0, 42) With NoWait;

                End Catch

                /* Just a little breather for the server */
                WaitFor Delay @defragDelay;

                Update dbo.dba_indexDefragStatus
                Set defragDate = GetDate()
                    , printStatus = 1
                Where databaseID       = @databaseID
                  And objectID         = @objectID
                  And indexID          = @indexID
                  And partitionNumber  = @partitionNumber;

            End
            Else
            /* Looks like we're not executing, just printing the commands */
            Begin
                If @debugMode = 1 RaisError('  Printing SQL statements...', 0, 42) With NoWait;
                
                If @printCommands = 1 Or @debugMode = 1 
                    Print IsNull(@sqlCommand, 'error!');

                Update dbo.dba_indexDefragStatus
                Set printStatus = 1
                Where databaseID       = @databaseID
                  And objectID         = @objectID
                  And indexID          = @indexID
                  And partitionNumber  = @partitionNumber;
            End

        End

        /* Do we want to output our fragmentation results? */
        If @printFragmentation = 1
        Begin

            If @debugMode = 1 RaisError('  Displaying a summary of our action...', 0, 42) With NoWait;

            Select databaseID
                , databaseName
                , objectID
                , objectName
                , indexID
                , indexName
                , partitionNumber
                , fragmentation
                , page_count
                , range_scan_count
            From dbo.dba_indexDefragStatus
            Where defragDate >= @startDateTime
            Order By defragDate;

        End;

    End Try
    Begin Catch

        Set @debugMessage = Error_Message() + ' (Line Number: ' + Cast(Error_Line() As varchar(10)) + ')';
        Print @debugMessage;

    End Catch;

    /* When everything is said and done, make sure to get rid of our temp table */
    Drop Table #databaseList;
    Drop Table #processor;
    Drop Table #maxPartitionList;

    If @debugMode = 1 RaisError('DONE!  Thank you for taking care of your indexes!  :)', 0, 42) With NoWait;

    Set NoCount Off;
    Return 0
End
GO
/****** Object:  StoredProcedure [dbo].[GetFreeSpace]    Script Date: 4/26/2016 11:40:47 AM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE procedure [dbo].[GetFreeSpace] @servername sysname
as

set nocount on

declare @sql varchar(1000),
@serverid int

select @serverid = ServerID
from Server
where Servername = @servername

select @sql = 'EXEC ' + @servername + '.master.dbo.xp_fixeddrives'

create table #t1
(drive char(1), freespace int)
insert into #t1 exec(@sql)

insert into ServerFreeSpaceHistory
(ServerID, Drive, Freespace)
select @serverid, Drive, freespace
from #t1

drop table #t1


GO
/****** Object:  StoredProcedure [dbo].[prGetErrorLog]    Script Date: 4/26/2016 11:40:47 AM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE procedure [dbo].[prGetErrorLog]
@servername sysname
as

delete from ServerErrorLog

declare @sql varchar(255)
set @sql = @servername + '.master.dbo.xp_readerrorlog '

insert into ServerErrorLog
(ErrorLogText, ContinuationRow)
exec @sql

update ServerErrorLog
set Servername = @servername
where Servername IS NULL


insert into ServerHistory
(ErrorLogText, Servername, EventDate)
select
CASE WHEN ErrorLogText LIKE '%Database backed up%' THEN SUBSTRING(ErrorLogText,34,20) + SUBSTRING(ErrorLogText,64,CHARINDEX(',',ErrorLogText,64)-64)
WHEN ErrorLogText LIKE '%DBCC CHECKDB%' THEN RTRIM(SUBSTRING(ErrorLogText,34,221))
WHEN ErrorLogText like '%BACKUP FAILED%' THEN SUBSTRING(ErrorLogText,34,256)
END,
ServerName,
SUBSTRING(ErrorLogText,1,22)
from ServerErrorLog
where ErrorLogText like '%Database backed up%'
or ErrorLogText like '%DBCC CHECKDB%'
or ErrorLogText like '%BACKUP FAILED%'


GO
/****** Object:  StoredProcedure [dbo].[prssr]    Script Date: 4/26/2016 11:40:47 AM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE procedure [dbo].[prssr]
as
SET NOCOUNT ON

SELECT EventDate, Servername, ErrorLogText AS 'Events for all servers'
FROM ServerHistory
WHERE (DATEDIFF(HOUR, EventDate, GETDATE()) < 24)
ORDER BY Servername, EventDate


SET NOCOUNT OFF

GO
/****** Object:  StoredProcedure [dbo].[prssr_backup]    Script Date: 4/26/2016 11:40:47 AM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

CREATE procedure [dbo].[prssr_backup]
as
SET NOCOUNT ON

SELECT EventDate, Servername, ErrorLogText AS 'Backup Events for all servers'
FROM ServerHistory
WHERE (DATEDIFF(HOUR, EventDate, GETDATE()) < 24)
AND ErrorLogText LIKE '%back%'
ORDER BY Servername, EventDate


SET NOCOUNT OFF

GO
/****** Object:  StoredProcedure [dbo].[prssr_DBCC]    Script Date: 4/26/2016 11:40:47 AM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

CREATE procedure [dbo].[prssr_DBCC]
as

SET NOCOUNT ON

SELECT EventDate, Servername, ErrorLogText AS 'DBCC Events for all servers'
FROM ServerHistory
WHERE (DATEDIFF(HOUR, EventDate, GETDATE()) < 24)
AND ErrorLogText LIKE '%DBCC%'
ORDER BY Servername, EventDate


SET NOCOUNT OFF


GO
/****** Object:  StoredProcedure [dbo].[s_SpaceUsed]    Script Date: 4/26/2016 11:40:47 AM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

Create procedure [dbo].[s_SpaceUsed]
@SourceDB	varchar(128)
as
/*
exec s_SpaceUsed 'mydb'
*/

set nocount on

declare @sql varchar(128)
	create table #tables(name varchar(128))
	
	select @sql = 'insert #tables select TABLE_NAME from ' + @SourceDB + '.INFORMATION_SCHEMA.TABLES where TABLE_TYPE = ''BASE TABLE'''
	exec (@sql)
	
	create table #SpaceUsed (name varchar(128), rows varchar(11), reserved varchar(18), data varchar(18), index_size varchar(18), unused varchar(18))
	declare @name varchar(128)
	select @name = ''
	while exists (select * from #tables where name > @name)
	begin
		select @name = min(name) from #tables where name > @name
		select @sql = 'exec ' + @SourceDB + '..sp_executesql N''insert #SpaceUsed exec sp_spaceused ' + @name + ''''
		exec (@sql)
	end
	select * from #SpaceUsed
	drop table #tables
	drop table #SpaceUsed

GO
/****** Object:  StoredProcedure [dbo].[usp_InsertPerfmonCounter]    Script Date: 4/26/2016 11:40:47 AM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
 
 CREATE PROCEDURE [dbo].[usp_InsertPerfmonCounter]
 (
 @xmlString varchar(max)
 )
 AS
 SET NOCOUNT ON;
 
 DECLARE @xml xml;
 SET @xml = @xmlString;
 
 INSERT INTO [dbo].[PerfmonCounterData] ([TimeStamp], [Server], [CounterGroup], [CounterName], [CounterValue])
 SELECT [Timestamp]
 , SUBSTRING([Path], 3, CHARINDEX('\',[Path],3)-3) AS [Server]
 , SUBSTRING([Path]
 , CHARINDEX('\',[Path],3)+1
 , LEN([Path]) - CHARINDEX('\',REVERSE([Path]))+1 - (CHARINDEX('\',[Path],3)+1)) AS [CounterGroup]
 , REVERSE(LEFT(REVERSE([Path]), CHARINDEX('\', REVERSE([Path]))-1)) AS [CounterName]
 , CAST([CookedValue] AS float) AS [CookedValue]
 FROM
 (SELECT
 [property].value('(./text())[1]', 'VARCHAR(200)') AS [Value]
 , [property].value('@Name', 'VARCHAR(30)') AS [Attribute]
 , DENSE_RANK() OVER (ORDER BY [object]) AS [Sampling]
 FROM @xml.nodes('Objects/Object') AS mn ([object]) 
 CROSS APPLY mn.object.nodes('./Property') AS pn (property)) AS bp
 PIVOT (MAX(value) FOR Attribute IN ([Timestamp], [Path], [CookedValue]) ) AS ap;
 

GO
/****** Object:  UserDefinedFunction [dbo].[quotestring]    Script Date: 4/26/2016 11:40:47 AM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE FUNCTION [dbo].[quotestring](@str nvarchar(1998)) RETURNS nvarchar(4000) AS
   BEGIN
      DECLARE @ret nvarchar(4000),
              @sq  char(1)
      SELECT @sq = ''''
      SELECT @ret = replace(@str, @sq, @sq + @sq)
      RETURN(@sq + @ret + @sq)
   END

GO
/****** Object:  Table [dbo].[ColumnInfoMon]    Script Date: 4/26/2016 11:40:47 AM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
SET ANSI_PADDING ON
GO
CREATE TABLE [dbo].[ColumnInfoMon](
	[servername] [varchar](100) NULL,
	[dtm] [datetime] NULL,
	[tablename] [varchar](150) NULL,
	[type_desc] [varchar](150) NULL,
	[columnname] [varchar](150) NULL,
	[dataType] [varchar](150) NULL,
	[size] [varchar](50) NULL,
	[nullable] [varchar](5) NULL,
	[precision] [varchar](50) NULL
) ON [PRIMARY]

GO
SET ANSI_PADDING OFF
GO
/****** Object:  Table [dbo].[ConfigMon]    Script Date: 4/26/2016 11:40:47 AM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
SET ANSI_PADDING ON
GO
CREATE TABLE [dbo].[ConfigMon](
	[ServerName] [varchar](50) NULL,
	[Version] [varchar](50) NULL,
	[Name] [varchar](50) NULL,
	[Value] [varchar](50) NULL,
	[Minimum] [int] NULL,
	[Maximum] [int] NULL,
	[ValueInUse] [int] NULL,
	[Description] [varchar](250) NULL,
	[Dynamic] [varchar](50) NULL,
	[Advanced] [varchar](50) NULL
) ON [PRIMARY]

GO
SET ANSI_PADDING OFF
GO
/****** Object:  Table [dbo].[CounterData]    Script Date: 4/26/2016 11:40:47 AM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
SET ANSI_PADDING ON
GO
CREATE TABLE [dbo].[CounterData](
	[GUID] [uniqueidentifier] NOT NULL,
	[CounterID] [int] NOT NULL,
	[RecordIndex] [int] NOT NULL,
	[CounterDateTime] [char](24) NOT NULL,
	[CounterValue] [float] NOT NULL,
	[FirstValueA] [float] NULL,
	[FirstValueB] [float] NULL,
	[SecondValueA] [float] NULL,
	[SecondValueB] [float] NULL,
	[MultiCount] [int] NULL,
 CONSTRAINT [PK__CounterData__2F9A1060] PRIMARY KEY CLUSTERED 
(
	[GUID] ASC,
	[CounterID] ASC,
	[RecordIndex] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, FILLFACTOR = 90) ON [PRIMARY]
) ON [PRIMARY]

GO
SET ANSI_PADDING OFF
GO
/****** Object:  Table [dbo].[CounterDetails]    Script Date: 4/26/2016 11:40:47 AM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
SET ANSI_PADDING ON
GO
CREATE TABLE [dbo].[CounterDetails](
	[CounterID] [int] IDENTITY(1,1) NOT NULL,
	[MachineName] [varchar](1024) NOT NULL,
	[ObjectName] [varchar](1024) NOT NULL,
	[CounterName] [varchar](1024) NOT NULL,
	[CounterType] [int] NOT NULL,
	[DefaultScale] [int] NOT NULL,
	[InstanceName] [varchar](1024) NULL,
	[InstanceIndex] [int] NULL,
	[ParentName] [varchar](1024) NULL,
	[ParentObjectID] [int] NULL,
	[TimeBaseA] [int] NULL,
	[TimeBaseB] [int] NULL,
PRIMARY KEY CLUSTERED 
(
	[CounterID] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, FILLFACTOR = 90) ON [PRIMARY]
) ON [PRIMARY]

GO
SET ANSI_PADDING OFF
GO
/****** Object:  Table [dbo].[DataAndLogFilesMon]    Script Date: 4/26/2016 11:40:47 AM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
SET ANSI_PADDING ON
GO
CREATE TABLE [dbo].[DataAndLogFilesMon](
	[ServerName] [varchar](50) NULL,
	[dbname] [varchar](100) NULL,
	[Physical_Name] [varchar](300) NULL,
	[Dt] [date] NULL,
	[Size_MB] [int] NULL,
	[Free_MB] [int] NULL,
	[Dtm] [datetime] NULL
) ON [PRIMARY]

GO
SET ANSI_PADDING OFF
GO
/****** Object:  Table [dbo].[db_space]    Script Date: 4/26/2016 11:40:47 AM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
SET ANSI_PADDING ON
GO
CREATE TABLE [dbo].[db_space](
	[server_name] [varchar](128) NOT NULL,
	[dbname] [varchar](128) NOT NULL,
	[physical_name] [varchar](260) NOT NULL,
	[dt] [datetime] NOT NULL,
	[file_group_name] [varchar](128) NOT NULL,
	[size_mb] [int] NULL,
	[free_mb] [int] NULL,
 CONSTRAINT [PK_db_space] PRIMARY KEY CLUSTERED 
(
	[server_name] ASC,
	[dbname] ASC,
	[physical_name] ASC,
	[dt] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
) ON [PRIMARY]

GO
SET ANSI_PADDING OFF
GO
/****** Object:  Table [dbo].[dba_indexDefragExclusion]    Script Date: 4/26/2016 11:40:47 AM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[dba_indexDefragExclusion](
	[databaseID] [int] NOT NULL,
	[databaseName] [nvarchar](128) NOT NULL,
	[objectID] [int] NOT NULL,
	[objectName] [nvarchar](128) NOT NULL,
	[indexID] [int] NOT NULL,
	[indexName] [nvarchar](128) NOT NULL,
	[exclusionMask] [int] NOT NULL,
 CONSTRAINT [PK_indexDefragExclusion_v40] PRIMARY KEY CLUSTERED 
(
	[databaseID] ASC,
	[objectID] ASC,
	[indexID] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
) ON [PRIMARY]

GO
/****** Object:  Table [dbo].[dba_indexDefragLog]    Script Date: 4/26/2016 11:40:47 AM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
SET ANSI_PADDING ON
GO
CREATE TABLE [dbo].[dba_indexDefragLog](
	[indexDefrag_id] [int] IDENTITY(1,1) NOT NULL,
	[databaseID] [int] NOT NULL,
	[databaseName] [nvarchar](128) NOT NULL,
	[objectID] [int] NOT NULL,
	[objectName] [nvarchar](128) NOT NULL,
	[indexID] [int] NOT NULL,
	[indexName] [nvarchar](128) NOT NULL,
	[partitionNumber] [smallint] NOT NULL,
	[fragmentation] [float] NOT NULL,
	[page_count] [int] NOT NULL,
	[dateTimeStart] [datetime] NOT NULL,
	[dateTimeEnd] [datetime] NULL,
	[durationSeconds] [int] NULL,
	[sqlStatement] [varchar](4000) NULL,
	[errorMessage] [varchar](1000) NULL,
 CONSTRAINT [PK_indexDefragLog_v40] PRIMARY KEY CLUSTERED 
(
	[indexDefrag_id] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
) ON [PRIMARY]

GO
SET ANSI_PADDING OFF
GO
/****** Object:  Table [dbo].[dba_indexDefragStatus]    Script Date: 4/26/2016 11:40:47 AM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[dba_indexDefragStatus](
	[databaseID] [int] NOT NULL,
	[databaseName] [nvarchar](128) NULL,
	[objectID] [int] NOT NULL,
	[indexID] [int] NOT NULL,
	[partitionNumber] [smallint] NOT NULL,
	[fragmentation] [float] NULL,
	[page_count] [int] NULL,
	[range_scan_count] [bigint] NULL,
	[schemaName] [nvarchar](128) NULL,
	[objectName] [nvarchar](128) NULL,
	[indexName] [nvarchar](128) NULL,
	[scanDate] [datetime] NULL,
	[defragDate] [datetime] NULL,
	[printStatus] [bit] NULL,
	[exclusionMask] [int] NULL,
 CONSTRAINT [PK_indexDefragStatus_v40] PRIMARY KEY CLUSTERED 
(
	[databaseID] ASC,
	[objectID] ASC,
	[indexID] ASC,
	[partitionNumber] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
) ON [PRIMARY]

GO
/****** Object:  Table [dbo].[DBCompatLvlMon]    Script Date: 4/26/2016 11:40:47 AM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
SET ANSI_PADDING ON
GO
CREATE TABLE [dbo].[DBCompatLvlMon](
	[ServerName] [varchar](50) NULL,
	[DBName] [varchar](50) NULL,
	[CompatLvl] [int] NULL
) ON [PRIMARY]

GO
SET ANSI_PADDING OFF
GO
/****** Object:  Table [dbo].[DBConfigMon]    Script Date: 4/26/2016 11:40:47 AM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
SET ANSI_PADDING ON
GO
CREATE TABLE [dbo].[DBConfigMon](
	[ServerName] [varchar](50) NULL,
	[DBName] [varchar](50) NULL,
	[RecoveryMode] [varchar](50) NULL,
	[Status] [varchar](50) NULL,
	[AutoClose] [bit] NULL,
	[AutoStats] [bit] NULL,
	[AutoShrink] [bit] NULL,
	[FullText] [bit] NULL
) ON [PRIMARY]

GO
SET ANSI_PADDING OFF
GO
/****** Object:  Table [dbo].[DisplayToID]    Script Date: 4/26/2016 11:40:47 AM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
SET ANSI_PADDING ON
GO
CREATE TABLE [dbo].[DisplayToID](
	[GUID] [uniqueidentifier] NOT NULL,
	[RunID] [int] NULL,
	[DisplayString] [varchar](1024) NOT NULL,
	[LogStartTime] [char](24) NULL,
	[LogStopTime] [char](24) NULL,
	[NumberOfRecords] [int] NULL,
	[MinutesToUTC] [int] NULL,
	[TimeZoneName] [char](32) NULL,
PRIMARY KEY CLUSTERED 
(
	[GUID] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, FILLFACTOR = 90) ON [PRIMARY],
UNIQUE NONCLUSTERED 
(
	[DisplayString] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, FILLFACTOR = 90) ON [PRIMARY]
) ON [PRIMARY]

GO
SET ANSI_PADDING OFF
GO
/****** Object:  Table [dbo].[EPF]    Script Date: 4/26/2016 11:40:47 AM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
SET ANSI_PADDING ON
GO
CREATE TABLE [dbo].[EPF](
	[RowNumber] [int] NOT NULL,
	[EventClass] [int] NULL,
	[TextData] [text] NULL,
	[NTUserName] [varchar](9) NULL,
	[HostName] [varchar](13) NULL,
	[ClientProcessID] [int] NULL,
	[ApplicationName] [varchar](74) NULL,
	[LoginName] [nvarchar](128) NULL,
	[SPID] [int] NULL,
	[Duration] [bigint] NULL,
	[StartTime] [datetime] NULL,
	[EndTime] [datetime] NULL,
	[Reads] [bigint] NULL,
	[Writes] [bigint] NULL,
	[CPU] [int] NULL,
	[ServerName] [varchar](5) NULL
) ON [PRIMARY] TEXTIMAGE_ON [PRIMARY]

GO
SET ANSI_PADDING OFF
GO
/****** Object:  Table [dbo].[EventClasses]    Script Date: 4/26/2016 11:40:47 AM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
SET ANSI_PADDING ON
GO
CREATE TABLE [dbo].[EventClasses](
	[EventClass] [int] NOT NULL,
	[EventName] [varchar](32) NOT NULL
) ON [PRIMARY]

GO
SET ANSI_PADDING OFF
GO
/****** Object:  Table [dbo].[FilesMon]    Script Date: 4/26/2016 11:40:47 AM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
SET ANSI_PADDING ON
GO
CREATE TABLE [dbo].[FilesMon](
	[ServerName] [varchar](50) NULL,
	[dbname] [varchar](100) NULL,
	[Physical_Name] [varchar](300) NULL,
	[Dt] [date] NULL,
	[File_Group_Name] [varchar](50) NULL,
	[Size_MB] [int] NULL,
	[Free_MB] [int] NULL,
	[Dtm] [datetime] NULL
) ON [PRIMARY]

GO
SET ANSI_PADDING OFF
GO
/****** Object:  Table [dbo].[HPF]    Script Date: 4/26/2016 11:40:47 AM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
SET ANSI_PADDING ON
GO
CREATE TABLE [dbo].[HPF](
	[Column 0] [varchar](50) NULL,
	[Column 1] [varchar](50) NULL
) ON [PRIMARY]

GO
SET ANSI_PADDING OFF
GO
/****** Object:  Table [dbo].[HPF_9-12PM_Perf]    Script Date: 4/26/2016 11:40:47 AM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[HPF_9-12PM_Perf](
	[RowNumber] [int] IDENTITY(0,1) NOT NULL,
	[EventClass] [int] NULL,
	[TextData] [ntext] NULL,
	[ApplicationName] [nvarchar](128) NULL,
	[NTUserName] [nvarchar](128) NULL,
	[LoginName] [nvarchar](128) NULL,
	[CPU] [int] NULL,
	[Reads] [bigint] NULL,
	[Writes] [bigint] NULL,
	[Duration] [bigint] NULL,
	[ClientProcessID] [int] NULL,
	[SPID] [int] NULL,
	[StartTime] [datetime] NULL,
	[BinaryData] [image] NULL,
PRIMARY KEY CLUSTERED 
(
	[RowNumber] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, FILLFACTOR = 90) ON [PRIMARY]
) ON [PRIMARY] TEXTIMAGE_ON [PRIMARY]

GO
/****** Object:  Table [dbo].[HPFD_PERF]    Script Date: 4/26/2016 11:40:47 AM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[HPFD_PERF](
	[RowNumber] [int] IDENTITY(0,1) NOT NULL,
	[EventClass] [int] NULL,
	[TextData] [ntext] NULL,
	[ApplicationName] [nvarchar](128) NULL,
	[NTUserName] [nvarchar](128) NULL,
	[LoginName] [nvarchar](128) NULL,
	[CPU] [int] NULL,
	[Reads] [bigint] NULL,
	[Writes] [bigint] NULL,
	[Duration] [bigint] NULL,
	[ClientProcessID] [int] NULL,
	[SPID] [int] NULL,
	[StartTime] [datetime] NULL,
	[BinaryData] [image] NULL,
PRIMARY KEY CLUSTERED 
(
	[RowNumber] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, FILLFACTOR = 90) ON [PRIMARY]
) ON [PRIMARY] TEXTIMAGE_ON [PRIMARY]

GO
/****** Object:  Table [dbo].[HPFUserList]    Script Date: 4/26/2016 11:40:47 AM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[HPFUserList](
	[User] [nvarchar](250) NULL,
	[Database] [nvarchar](250) NULL,
	[Host] [nvarchar](250) NULL
) ON [PRIMARY]

GO
/****** Object:  Table [dbo].[IdxFragMon]    Script Date: 4/26/2016 11:40:47 AM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
SET ANSI_PADDING ON
GO
CREATE TABLE [dbo].[IdxFragMon](
	[ServerName] [varchar](50) NULL,
	[DbName] [varchar](50) NULL,
	[IndexName] [varchar](150) NULL,
	[AvgFragPercent] [int] NULL,
	[PageCount] [int] NULL
) ON [PRIMARY]

GO
SET ANSI_PADDING OFF
GO
/****** Object:  Table [dbo].[IndexListMon]    Script Date: 4/26/2016 11:40:47 AM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
SET ANSI_PADDING ON
GO
CREATE TABLE [dbo].[IndexListMon](
	[ServerName] [varchar](50) NULL,
	[DBName] [varchar](50) NULL,
	[SchemaName] [varchar](50) NULL,
	[TableName] [varchar](100) NULL,
	[IndexName] [varchar](150) NULL,
	[IndexType] [varchar](50) NULL
) ON [PRIMARY]

GO
SET ANSI_PADDING OFF
GO
/****** Object:  Table [dbo].[InstanceHistMon]    Script Date: 4/26/2016 11:40:47 AM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[InstanceHistMon](
	[InstanceCt] [int] NULL,
	[Year] [int] NULL
) ON [PRIMARY]

GO
/****** Object:  Table [dbo].[InstanceInfo]    Script Date: 4/26/2016 11:40:47 AM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
SET ANSI_PADDING ON
GO
CREATE TABLE [dbo].[InstanceInfo](
	[ServerName] [varchar](50) NOT NULL,
	[ProductVersion] [varchar](50) NOT NULL,
	[ProductLevel] [varchar](50) NOT NULL,
	[Edition] [varchar](50) NOT NULL
) ON [PRIMARY]

GO
SET ANSI_PADDING OFF
GO
/****** Object:  Table [dbo].[InstanceInfoMon]    Script Date: 4/26/2016 11:40:47 AM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[InstanceInfoMon](
	[ServerName] [nvarchar](50) NULL,
	[ProductVersion] [nvarchar](50) NULL,
	[ProductLevel] [nvarchar](50) NULL,
	[Edition] [nvarchar](50) NULL,
	[EngineEdition] [nvarchar](50) NULL
) ON [PRIMARY]

GO
/****** Object:  Table [dbo].[InstanceInfoMonMan]    Script Date: 4/26/2016 11:40:47 AM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[InstanceInfoMonMan](
	[ServerName] [nvarchar](50) NULL,
	[ProductVersion] [nvarchar](50) NULL,
	[ProductLevel] [nvarchar](50) NULL,
	[Edition] [nvarchar](50) NULL,
	[EngineEdition] [nvarchar](50) NULL
) ON [PRIMARY]

GO
/****** Object:  Table [dbo].[InstPerfMon]    Script Date: 4/26/2016 11:40:47 AM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
SET ANSI_PADDING ON
GO
CREATE TABLE [dbo].[InstPerfMon](
	[ServerName] [varchar](50) NULL,
	[BufferCacheHitRatio] [int] NULL,
	[PageReadsSec] [int] NULL,
	[PageWritesSec] [int] NULL,
	[UserConns] [int] NULL,
	[PLE] [int] NULL,
	[CheckpointPagesSec] [int] NULL,
	[LazyWritesSec] [int] NULL,
	[FreeSpaceInTempDB] [int] NULL,
	[BatchRequestsSec] [int] NULL,
	[SQLCompsSec] [int] NULL,
	[SQLRecompsSec] [int] NULL,
	[TargetServerMemory_KB] [int] NULL,
	[TotServerMemory_KB] [int] NULL,
	[MeasurementTime] [datetime] NULL,
	[AvgTaskCount] [int] NULL,
	[AvgRunnableTaskCount] [int] NULL,
	[AvgPendingDiskIOCount] [int] NULL,
	[PercentSignalWait] [int] NULL,
	[PageLookupsSec] [int] NULL,
	[TransSec] [int] NULL,
	[MemoryGrantsPending] [int] NULL
) ON [PRIMARY]

GO
SET ANSI_PADDING OFF
GO
/****** Object:  Table [dbo].[JobMon]    Script Date: 4/26/2016 11:40:47 AM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
SET ANSI_PADDING ON
GO
CREATE TABLE [dbo].[JobMon](
	[ServerName] [varchar](50) NULL,
	[JobName] [varchar](300) NULL,
	[RunStatus] [varchar](50) NULL,
	[RunDt] [datetime] NULL
) ON [PRIMARY]

GO
SET ANSI_PADDING OFF
GO
/****** Object:  Table [dbo].[LogMon]    Script Date: 4/26/2016 11:40:47 AM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
SET ANSI_PADDING ON
GO
CREATE TABLE [dbo].[LogMon](
	[ServerName] [varchar](50) NULL,
	[LogDt] [datetime] NULL,
	[Entry] [varchar](500) NULL
) ON [PRIMARY]

GO
SET ANSI_PADDING OFF
GO
/****** Object:  Table [dbo].[LogSizeMon]    Script Date: 4/26/2016 11:40:47 AM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
SET ANSI_PADDING ON
GO
CREATE TABLE [dbo].[LogSizeMon](
	[ServerName] [varchar](50) NULL,
	[DBName] [varchar](50) NULL,
	[Dtm] [datetime] NULL,
	[TotalSize] [float] NULL,
	[LogSize] [float] NULL,
	[LogPercentUsed] [float] NULL
) ON [PRIMARY]

GO
SET ANSI_PADDING OFF
GO
/****** Object:  Table [dbo].[PerfmonCounterData]    Script Date: 4/26/2016 11:40:47 AM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
SET ANSI_PADDING ON
GO
CREATE TABLE [dbo].[PerfmonCounterData](
	[ID] [bigint] IDENTITY(1,1) NOT NULL,
	[Server] [nvarchar](50) NOT NULL,
	[TimeStamp] [datetime2](0) NOT NULL,
	[CounterGroup] [varchar](200) NULL,
	[CounterName] [varchar](200) NOT NULL,
	[CounterValue] [decimal](18, 5) NULL,
PRIMARY KEY CLUSTERED 
(
	[ID] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
) ON [PRIMARY]

GO
SET ANSI_PADDING OFF
GO
/****** Object:  Table [dbo].[Server]    Script Date: 4/26/2016 11:40:47 AM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[Server](
	[ServerID] [int] IDENTITY(1,1) NOT NULL,
	[Servername] [sysname] NOT NULL,
PRIMARY KEY CLUSTERED 
(
	[ServerID] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, FILLFACTOR = 90) ON [PRIMARY]
) ON [PRIMARY]

GO
/****** Object:  Table [dbo].[ServerDriveCapacity]    Script Date: 4/26/2016 11:40:47 AM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
SET ANSI_PADDING ON
GO
CREATE TABLE [dbo].[ServerDriveCapacity](
	[ServerID] [int] NOT NULL,
	[Drive] [char](1) NOT NULL,
	[Capacity] [int] NOT NULL,
 CONSTRAINT [pk_01] PRIMARY KEY CLUSTERED 
(
	[ServerID] ASC,
	[Drive] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, FILLFACTOR = 90) ON [PRIMARY]
) ON [PRIMARY]

GO
SET ANSI_PADDING OFF
GO
/****** Object:  Table [dbo].[ServerErrorLog]    Script Date: 4/26/2016 11:40:47 AM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
SET ANSI_PADDING ON
GO
CREATE TABLE [dbo].[ServerErrorLog](
	[ErrorLogText] [varchar](256) NULL,
	[ContinuationRow] [bit] NULL,
	[Servername] [sysname] NULL,
	[InsertDate] [datetime] NOT NULL
) ON [PRIMARY]

GO
SET ANSI_PADDING OFF
GO
/****** Object:  Table [dbo].[ServerFreeSpaceHistory]    Script Date: 4/26/2016 11:40:47 AM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
SET ANSI_PADDING ON
GO
CREATE TABLE [dbo].[ServerFreeSpaceHistory](
	[ServerID] [int] NULL,
	[Drive] [char](1) NOT NULL,
	[FreeSpace] [int] NOT NULL,
	[CheckDate] [datetime] NOT NULL
) ON [PRIMARY]

GO
SET ANSI_PADDING OFF
GO
/****** Object:  Table [dbo].[ServerHistory]    Script Date: 4/26/2016 11:40:47 AM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
SET ANSI_PADDING ON
GO
CREATE TABLE [dbo].[ServerHistory](
	[SHID] [int] IDENTITY(1,1) NOT NULL,
	[ErrorLogText] [varchar](256) NULL,
	[Servername] [sysname] NULL,
	[EventDate] [datetime] NOT NULL,
	[InsertDate] [datetime] NOT NULL,
PRIMARY KEY NONCLUSTERED 
(
	[SHID] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, FILLFACTOR = 90) ON [PRIMARY]
) ON [PRIMARY]

GO
SET ANSI_PADDING OFF
GO
/****** Object:  Table [dbo].[ServerInfo]    Script Date: 4/26/2016 11:40:47 AM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
SET ANSI_PADDING ON
GO
CREATE TABLE [dbo].[ServerInfo](
	[ServerName] [nvarchar](255) NOT NULL,
	[Hardware] [nvarchar](255) NULL,
	[SerialNum] [nvarchar](255) NULL,
	[IP] [varchar](255) NULL,
	[ID] [int] IDENTITY(1,1) NOT NULL,
 CONSTRAINT [PK_ServerInfo] PRIMARY KEY CLUSTERED 
(
	[ServerName] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, FILLFACTOR = 90) ON [PRIMARY]
) ON [PRIMARY]

GO
SET ANSI_PADDING OFF
GO
/****** Object:  Table [dbo].[ServerMon]    Script Date: 4/26/2016 11:40:47 AM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
SET ANSI_PADDING ON
GO
CREATE TABLE [dbo].[ServerMon](
	[name] [nvarchar](50) NULL,
	[monitored] [nvarchar](50) NULL,
	[IdxChk] [varchar](50) NULL,
	[Perf] [varchar](50) NULL
) ON [PRIMARY]

GO
SET ANSI_PADDING OFF
GO
/****** Object:  Table [dbo].[SrvrDbTblColMon]    Script Date: 4/26/2016 11:40:47 AM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
SET ANSI_PADDING ON
GO
CREATE TABLE [dbo].[SrvrDbTblColMon](
	[ServerNm] [varchar](150) NULL,
	[DbNm] [varchar](150) NULL,
	[TblNm] [varchar](150) NULL,
	[ColNm] [varchar](150) NULL
) ON [PRIMARY]

GO
SET ANSI_PADDING OFF
GO
/****** Object:  Table [dbo].[SrvrPerfMon]    Script Date: 4/26/2016 11:40:47 AM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
SET ANSI_PADDING ON
GO
CREATE TABLE [dbo].[SrvrPerfMon](
	[ServerName] [varchar](50) NULL,
	[MemoryUsage] [float] NULL,
	[CPUUsage] [float] NULL,
	[Dt] [datetime] NULL
) ON [PRIMARY]

GO
SET ANSI_PADDING OFF
GO
/****** Object:  Table [dbo].[TableMon]    Script Date: 4/26/2016 11:40:48 AM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
SET ANSI_PADDING ON
GO
CREATE TABLE [dbo].[TableMon](
	[ServerName] [varchar](100) NOT NULL,
	[DBName] [varchar](100) NULL,
	[TableName] [varchar](100) NULL
) ON [PRIMARY]

GO
SET ANSI_PADDING OFF
GO
/****** Object:  Table [dbo].[TableRowCountMon]    Script Date: 4/26/2016 11:40:48 AM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
SET ANSI_PADDING ON
GO
CREATE TABLE [dbo].[TableRowCountMon](
	[servername] [varchar](100) NULL,
	[dbname] [varchar](100) NULL,
	[tablename] [varchar](150) NULL,
	[dt] [datetime] NULL,
	[rows] [int] NULL
) ON [PRIMARY]

GO
SET ANSI_PADDING OFF
GO
/****** Object:  Table [dbo].[tAdminChk]    Script Date: 4/26/2016 11:40:48 AM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
SET ANSI_PADDING ON
GO
CREATE TABLE [dbo].[tAdminChk](
	[AdminID] [int] IDENTITY(1,1) NOT NULL,
	[Login] [varchar](100) NULL,
	[Server] [varchar](50) NULL,
	[LastUpdated] [datetime] NOT NULL,
 CONSTRAINT [PK_tAdminChk] PRIMARY KEY CLUSTERED 
(
	[AdminID] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, FILLFACTOR = 90) ON [PRIMARY]
) ON [PRIMARY]

GO
SET ANSI_PADDING OFF
GO
/****** Object:  Table [dbo].[tBackupChk]    Script Date: 4/26/2016 11:40:48 AM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
SET ANSI_PADDING ON
GO
CREATE TABLE [dbo].[tBackupChk](
	[BackupID] [int] IDENTITY(1,1) NOT NULL,
	[DbName] [varchar](100) NULL,
	[DaysSinceLastBackup] [varchar](50) NULL,
	[LastBackupDate] [varchar](50) NULL,
	[Server] [varchar](100) NULL,
	[LastUpdated] [datetime] NOT NULL,
 CONSTRAINT [PK_tBackupChk] PRIMARY KEY CLUSTERED 
(
	[BackupID] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, FILLFACTOR = 90) ON [PRIMARY]
) ON [PRIMARY]

GO
SET ANSI_PADDING OFF
GO
/****** Object:  Table [dbo].[tBackupInfo]    Script Date: 4/26/2016 11:40:48 AM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
SET ANSI_PADDING ON
GO
CREATE TABLE [dbo].[tBackupInfo](
	[BackupInfoID] [int] IDENTITY(1,1) NOT NULL,
	[DbName] [varchar](100) NULL,
	[StartDate] [varchar](50) NULL,
	[FinishDate] [varchar](50) NULL,
	[Type] [varchar](3) NULL,
	[BackupSize] [varchar](50) NULL,
	[RunBy] [varchar](50) NULL,
	[Server] [varchar](100) NULL,
	[LastUpdated] [datetime] NOT NULL
) ON [PRIMARY]

GO
SET ANSI_PADDING OFF
GO
/****** Object:  Table [dbo].[TC83]    Script Date: 4/26/2016 11:40:48 AM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[TC83](
	[ProductID] [int] NOT NULL,
	[Date] [datetime] NOT NULL,
	[TotalLines] [int] NULL,
	[LinesOutOfService] [int] NULL,
	[CustomerCalls] [int] NULL
) ON [PRIMARY]

GO
/****** Object:  Table [dbo].[tDbaSec]    Script Date: 4/26/2016 11:40:48 AM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
SET ANSI_PADDING ON
GO
CREATE TABLE [dbo].[tDbaSec](
	[UserID] [int] IDENTITY(1,1) NOT NULL,
	[Username] [varchar](50) NOT NULL,
	[DeptNum] [varchar](6) NOT NULL,
	[Active] [char](1) NOT NULL,
 CONSTRAINT [PK_tDbaSec] PRIMARY KEY CLUSTERED 
(
	[UserID] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, FILLFACTOR = 90) ON [PRIMARY]
) ON [PRIMARY]

GO
SET ANSI_PADDING OFF
GO
/****** Object:  Table [dbo].[tDbMessages]    Script Date: 4/26/2016 11:40:48 AM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
SET ANSI_PADDING ON
GO
CREATE TABLE [dbo].[tDbMessages](
	[MessageID] [int] IDENTITY(1,1) NOT NULL,
	[Message] [varchar](3000) NULL,
	[EventDate] [varchar](50) NULL,
	[Server] [varchar](50) NULL,
	[LastUpdated] [datetime] NOT NULL,
 CONSTRAINT [PK_tDbMessages] PRIMARY KEY CLUSTERED 
(
	[MessageID] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, FILLFACTOR = 90) ON [PRIMARY]
) ON [PRIMARY]

GO
SET ANSI_PADDING OFF
GO
/****** Object:  Table [dbo].[tDbSizeHist]    Script Date: 4/26/2016 11:40:48 AM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
SET ANSI_PADDING ON
GO
CREATE TABLE [dbo].[tDbSizeHist](
	[DbSizeHistID] [int] IDENTITY(1,1) NOT NULL,
	[Server] [varchar](50) NOT NULL,
	[DbName] [varchar](50) NOT NULL,
	[DbSize] [numeric](18, 0) NOT NULL,
	[DbFilename] [varchar](200) NOT NULL,
	[LastUpdated] [datetime] NOT NULL
) ON [PRIMARY]

GO
SET ANSI_PADDING OFF
GO
/****** Object:  Table [dbo].[tDbSpaceChk]    Script Date: 4/26/2016 11:40:48 AM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
SET ANSI_PADDING ON
GO
CREATE TABLE [dbo].[tDbSpaceChk](
	[DbSpaceID] [int] IDENTITY(1,1) NOT NULL,
	[BackupStartDate] [datetime] NULL,
	[SpaceDate] [varchar](50) NULL,
	[SpaceTime] [varchar](50) NULL,
	[DbName] [varchar](50) NULL,
	[FilegroupName] [varchar](50) NULL,
	[LogicalFilename] [varchar](100) NULL,
	[PhysFilename] [varchar](300) NULL,
	[FileSize] [float] NULL,
	[GrowthPercentage] [float] NULL,
	[Server] [varchar](50) NULL,
	[LastUpdated] [datetime] NULL,
 CONSTRAINT [PK_tDbSpaceChk] PRIMARY KEY CLUSTERED 
(
	[DbSpaceID] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, FILLFACTOR = 90) ON [PRIMARY]
) ON [PRIMARY]

GO
SET ANSI_PADDING OFF
GO
/****** Object:  Table [dbo].[tDocs]    Script Date: 4/26/2016 11:40:48 AM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
SET ANSI_PADDING ON
GO
CREATE TABLE [dbo].[tDocs](
	[ServerDocID] [int] IDENTITY(1,1) NOT NULL,
	[Server] [varchar](50) NOT NULL,
	[Doc] [varchar](100) NOT NULL,
 CONSTRAINT [PK_tDocs] PRIMARY KEY CLUSTERED 
(
	[ServerDocID] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, FILLFACTOR = 90) ON [PRIMARY]
) ON [PRIMARY]

GO
SET ANSI_PADDING OFF
GO
/****** Object:  Table [dbo].[tDriveInfo]    Script Date: 4/26/2016 11:40:48 AM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
SET ANSI_PADDING ON
GO
CREATE TABLE [dbo].[tDriveInfo](
	[DriveID] [int] IDENTITY(69,1) NOT NULL,
	[Server] [varchar](50) NULL,
	[Drive] [varchar](50) NOT NULL,
	[TotalSize] [varchar](50) NOT NULL,
	[LastUpdated] [datetime] NOT NULL
) ON [PRIMARY]

GO
SET ANSI_PADDING OFF
GO
/****** Object:  Table [dbo].[tDriveSpaceChk]    Script Date: 4/26/2016 11:40:48 AM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
SET ANSI_PADDING ON
GO
CREATE TABLE [dbo].[tDriveSpaceChk](
	[DriveID] [int] IDENTITY(1,1) NOT NULL,
	[Server] [varchar](50) NULL,
	[Drive] [varchar](50) NOT NULL,
	[MBFree] [varchar](50) NOT NULL,
	[LastUpdated] [datetime] NOT NULL,
 CONSTRAINT [PK_tDriveSpaceChk] PRIMARY KEY CLUSTERED 
(
	[DriveID] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, FILLFACTOR = 90) ON [PRIMARY]
) ON [PRIMARY]

GO
SET ANSI_PADDING OFF
GO
/****** Object:  Table [dbo].[tFreeSpace]    Script Date: 4/26/2016 11:40:48 AM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
SET ANSI_PADDING ON
GO
CREATE TABLE [dbo].[tFreeSpace](
	[Computer] [varchar](128) NULL,
	[Drive] [varchar](2) NULL,
	[DiskSize] [decimal](28, 5) NULL,
	[FreeSpace] [decimal](28, 5) NULL,
	[Percentage] [decimal](10, 5) NULL,
	[Date] [datetime] NULL
) ON [PRIMARY]

GO
SET ANSI_PADDING OFF
GO
/****** Object:  Table [dbo].[tInstance]    Script Date: 4/26/2016 11:40:48 AM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
SET ANSI_PADDING ON
GO
CREATE TABLE [dbo].[tInstance](
	[ServerName] [varchar](50) NOT NULL,
	[ProductVersion] [varchar](50) NOT NULL,
	[ProductLevel] [varchar](50) NOT NULL,
	[Edition] [varchar](50) NOT NULL
) ON [PRIMARY]

GO
SET ANSI_PADDING OFF
GO
/****** Object:  Table [dbo].[tJobList]    Script Date: 4/26/2016 11:40:48 AM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
SET ANSI_PADDING ON
GO
CREATE TABLE [dbo].[tJobList](
	[JobID] [int] IDENTITY(1,1) NOT NULL,
	[server] [varchar](50) NULL,
	[jobname] [varchar](100) NULL,
	[enabled] [varchar](50) NULL,
	[description] [varchar](500) NULL,
	[owner_sid] [binary](50) NULL,
	[owner_name] [varchar](50) NULL,
	[date_created] [datetime] NULL,
	[date_modified] [datetime] NULL,
	[LastUpdated] [datetime] NOT NULL,
 CONSTRAINT [PK_tJobList] PRIMARY KEY CLUSTERED 
(
	[JobID] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, FILLFACTOR = 90) ON [PRIMARY]
) ON [PRIMARY]

GO
SET ANSI_PADDING OFF
GO
/****** Object:  Table [dbo].[tJobReport]    Script Date: 4/26/2016 11:40:48 AM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
SET ANSI_PADDING ON
GO
CREATE TABLE [dbo].[tJobReport](
	[lngID] [int] IDENTITY(1,1) NOT NULL,
	[server] [varchar](100) NULL,
	[jobname] [varchar](255) NULL,
	[status] [varchar](100) NULL,
	[enabled] [varchar](100) NULL,
	[rundate] [varchar](100) NULL,
	[runtime] [varchar](100) NULL,
	[runduration] [varchar](100) NULL,
	[LastUpdated] [datetime] NULL
) ON [PRIMARY]

GO
SET ANSI_PADDING OFF
GO
/****** Object:  Table [dbo].[tLoginChk]    Script Date: 4/26/2016 11:40:48 AM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
SET ANSI_PADDING ON
GO
CREATE TABLE [dbo].[tLoginChk](
	[LoginID] [int] IDENTITY(1,1) NOT NULL,
	[Login] [varchar](255) NOT NULL,
	[Server] [varchar](255) NOT NULL,
 CONSTRAINT [PK_tLoginChk] PRIMARY KEY CLUSTERED 
(
	[LoginID] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, FILLFACTOR = 90) ON [PRIMARY]
) ON [PRIMARY]

GO
SET ANSI_PADDING OFF
GO
/****** Object:  Table [dbo].[tMyDbs]    Script Date: 4/26/2016 11:40:48 AM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
SET ANSI_PADDING ON
GO
CREATE TABLE [dbo].[tMyDbs](
	[DbKey] [int] IDENTITY(1,1) NOT NULL,
	[dbname] [varchar](75) NULL,
	[dbowner] [char](50) NULL,
	[dbid] [varchar](50) NULL,
	[crdate] [datetime] NULL,
	[status] [varchar](50) NULL,
	[category] [varchar](50) NULL,
	[mode] [varchar](50) NULL,
	[compatlvl] [varchar](50) NULL,
	[filename] [varchar](250) NULL,
	[version] [varchar](50) NULL,
	[Server] [varchar](50) NULL,
	[LastUpdated] [datetime] NOT NULL,
 CONSTRAINT [PK_tMyDbs] PRIMARY KEY CLUSTERED 
(
	[DbKey] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, FILLFACTOR = 90) ON [PRIMARY]
) ON [PRIMARY]

GO
SET ANSI_PADDING OFF
GO
/****** Object:  Table [dbo].[tTableSpace]    Script Date: 4/26/2016 11:40:48 AM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
SET ANSI_PADDING ON
GO
CREATE TABLE [dbo].[tTableSpace](
	[TableSpaceID] [int] IDENTITY(1,1) NOT NULL,
	[DatabaseName] [varchar](50) NULL,
	[ServerName] [varchar](50) NULL,
	[TableName] [varchar](100) NULL,
	[TableRows] [int] NULL,
	[reserved_in_KB] [varchar](50) NULL,
	[data] [varchar](100) NULL,
	[index_size] [varchar](100) NULL,
	[unused] [varchar](100) NULL,
	[LastUpdated] [smalldatetime] NULL,
 CONSTRAINT [PK_tTableSpace] PRIMARY KEY CLUSTERED 
(
	[TableSpaceID] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, FILLFACTOR = 90) ON [PRIMARY]
) ON [PRIMARY]

GO
SET ANSI_PADDING OFF
GO
/****** Object:  Table [dbo].[USERS]    Script Date: 4/26/2016 11:40:48 AM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
SET ANSI_PADDING ON
GO
CREATE TABLE [dbo].[USERS](
	[NAME] [char](20) NOT NULL,
	[PASSWD] [char](32) NOT NULL,
	[PIN] [char](32) NULL,
	[LOCKOUT] [char](1) NULL,
	[IDLE] [smallint] NULL,
	[RV_GROUP] [char](40) NULL,
	[RV_DEFAULT] [char](40) NULL,
	[PV_GROUP] [char](40) NULL,
	[PV_DEFAULT] [char](40) NULL,
	[SIGN] [char](40) NULL,
	[TEXT_NAME] [char](40) NULL,
	[GROUP_LIMIT] [char](30) NULL,
	[KEYID_LIMIT] [char](30) NULL,
	[DEPT_CODE] [varchar](10) NULL,
	[USERACTIVE] [char](1) NULL,
	[FullName] [char](30) NULL,
	[Description] [char](50) NULL,
	[AccountDisabled] [smallint] NULL,
	[Administrator] [smallint] NULL,
	[UserInstanceId] [int] NULL,
	[Override_Type] [int] NULL,
	[Restrict_Results] [int] NULL,
	[PHYS_GROUP] [char](10) NULL,
	[PHYS_GROUP_SIGN] [smallint] NULL,
	[PHYS_GROUP_TEXT] [smallint] NULL,
	[PHYS_GROUP_DICT] [smallint] NULL,
	[AUDIT] [char](5) NULL,
	[DomainInstanceID] [int] NULL,
	[Invalid_Logon_Count] [smallint] NULL,
	[Change_Password] [smallint] NULL
) ON [PRIMARY]

GO
SET ANSI_PADDING OFF
GO
/****** Object:  Table [dbo].[VolatileTablesResults]    Script Date: 4/26/2016 11:40:48 AM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
SET ANSI_PADDING ON
GO
CREATE TABLE [dbo].[VolatileTablesResults](
	[Tablename] [varchar](50) NULL,
	[Indexname] [varchar](50) NULL,
	[Fragmentation] [varchar](50) NULL,
	[DurationSec] [varchar](50) NULL,
	[StartDtm] [varchar](50) NULL,
	[EndDtm] [varchar](50) NULL
) ON [PRIMARY]

GO
SET ANSI_PADDING OFF
GO
/****** Object:  Table [dbo].[WEBLOG]    Script Date: 4/26/2016 11:40:48 AM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[WEBLOG](
	[COOKIE_ID] [int] NOT NULL,
	[VISIT_DATE] [date] NOT NULL,
	[TRANSACTION_VALUE] [money] NOT NULL
) ON [PRIMARY]

GO
/****** Object:  Table [dbo].[WorstSPMon]    Script Date: 4/26/2016 11:40:48 AM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[WorstSPMon](
	[ServerName] [nvarchar](50) NULL,
	[DBName] [nvarchar](150) NULL,
	[SchemaName] [nvarchar](150) NULL,
	[SPName] [nvarchar](150) NULL,
	[CacheTm] [datetime] NULL,
	[LastExecTm] [datetime] NULL,
	[ExecCnt] [bigint] NULL,
	[TotWorkerTm] [bigint] NULL,
	[TotElapsedTm] [bigint] NULL,
	[TotLogicalRds] [bigint] NULL,
	[TotLogicalWrts] [bigint] NULL,
	[TotPhysRds] [bigint] NULL,
	[Dtm] [datetime] NULL
) ON [PRIMARY]

GO
/****** Object:  View [dbo].[2007SxaPerfData]    Script Date: 4/26/2016 11:40:48 AM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE VIEW [dbo].[2007SxaPerfData]
AS
SELECT     dbo.CounterDetails.MachineName, dbo.CounterDetails.ObjectName, 
                      CASE WHEN CounterDetails.CounterName = '% Processor Time' THEN '% Processor Time - Consistent values over 85% suggests a processor bottleneck'
                       WHEN CounterDetails.CounterName = 'Pages/Sec' THEN 'Pages/Sec - Extended periods of 20 or greater suggests a memory bottleneck.' WHEN CounterDetails.CounterName
                       = 'Buffer cache hit ratio' THEN 'Buffer cache hit ratio - dipping below 85-95% suggests a memory bottleneck' WHEN CounterDetails.CounterName = '% Disk Time'
                       THEN '% Disk Time - Consistent periods exceeding 90% suggests an I/O bottleneck' ELSE CounterDetails.CounterName END AS CounterName, 
                      CAST(LEFT(dbo.CounterData.CounterDateTime, 19) AS smalldatetime) AS CounterDate, DATEPART(YEAR, 
                      CAST(LEFT(dbo.CounterData.CounterDateTime, 19) AS smalldatetime)) AS CounterYear, DATENAME(MONTH, 
                      CAST(LEFT(dbo.CounterData.CounterDateTime, 19) AS smalldatetime)) AS CounterMonth, DATENAME(WEEK, 
                      CAST(LEFT(dbo.CounterData.CounterDateTime, 19) AS smalldatetime)) AS CounterWeek, DATENAME(WEEKDAY, 
                      CAST(LEFT(dbo.CounterData.CounterDateTime, 19) AS smalldatetime)) AS CounterWeekDay, DATENAME(DAY, 
                      CAST(LEFT(dbo.CounterData.CounterDateTime, 19) AS smalldatetime)) AS CounterDay, CAST(CAST(DATEPART(HOUR, 
                      CAST(LEFT(dbo.CounterData.CounterDateTime, 19) AS smalldatetime)) AS varchar) + CAST(CASE WHEN datepart(MINUTE, 
                      (CAST(LEFT(CounterDateTime, 19) AS smalldatetime))) BETWEEN 1 AND 15 THEN 15 WHEN datepart(minute, (CAST(LEFT(CounterDateTime, 19) 
                      AS smalldatetime))) BETWEEN 16 AND 30 THEN 30 WHEN datepart(minute, (CAST(LEFT(CounterDateTime, 19) AS smalldatetime))) BETWEEN 31 AND 
                      45 THEN 45 ELSE 59 END AS varchar) AS int) AS CounterTime, ROUND(dbo.CounterData.CounterValue, 0) AS CounterValue
FROM         dbo.CounterData INNER JOIN
                      dbo.CounterDetails ON dbo.CounterDetails.CounterID = dbo.CounterData.CounterID
WHERE     (dbo.CounterDetails.MachineName = '\\CHSXAREPP' OR
                      dbo.CounterDetails.MachineName = '\\CHSXAMAP') AND (DATEPART(YEAR, CAST(LEFT(dbo.CounterData.CounterDateTime, 19) AS smalldatetime)) 
                      = '2007') AND (dbo.CounterDetails.CounterName LIKE '% Processor Time%' OR
                      dbo.CounterDetails.CounterName LIKE '% Disk Time%' OR
                      dbo.CounterDetails.CounterName LIKE '% Disk Write Time' OR
                      dbo.CounterDetails.CounterName = '% Disk Read Time' OR
                      dbo.CounterDetails.CounterName LIKE 'Buffer Cache Hit Ratio%' OR
                      dbo.CounterDetails.CounterName LIKE 'Pages/Sec%')

GO
/****** Object:  View [dbo].[DB_BackupRunTimesChk]    Script Date: 4/26/2016 11:40:48 AM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE VIEW [dbo].[DB_BackupRunTimesChk]
AS
SELECT     TOP 100 PERCENT Server, DbName, ROUND(CONVERT(float, BackupSize) / 1024 / 1024, 0) AS SizeInMB, StartDate, FinishDate, DATEDIFF(mi, 
                      StartDate, FinishDate) AS BackupTimeInMins
FROM         dbo.tBackupInfo
WHERE     (Type = 'D')
ORDER BY Server, DbName, FinishDate DESC

GO
/****** Object:  View [dbo].[DB_BackupsCompletingAfterMidnight]    Script Date: 4/26/2016 11:40:48 AM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE VIEW [dbo].[DB_BackupsCompletingAfterMidnight]
AS
SELECT     TOP 100 PERCENT Server, DbName, ROUND(CONVERT(float, BackupSize) / 1024 / 1024, 0) AS SizeInMB, StartDate, FinishDate, DATEDIFF(mi, 
                      StartDate, FinishDate) AS BackupTimeInMins, CONVERT(int, DATEPART(hh, FinishDate)) AS [Hour], BackupInfoID
FROM         dbo.tBackupInfo
WHERE     (Type = 'D') AND (Server NOT IN ('IT170105', 'IT170106')) AND (CONVERT(varchar, DATEPART(hh, FinishDate)) < 21) AND (BackupInfoID IN
                          (SELECT     BackupInfoID
                            FROM          dbo.tBackupInfo
                            WHERE      Type = 'D' AND FinishDate + DbName IN
                                                       (SELECT     MAX(FinishDate) + DbName
                                                         FROM          dbo.tBackupInfo
                                                         WHERE      Type = 'D'
                                                         GROUP BY DbName)))
ORDER BY FinishDate, Server, DbName DESC

GO
/****** Object:  View [dbo].[DBA_DriveFreeSpaceVw]    Script Date: 4/26/2016 11:40:48 AM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE VIEW [dbo].[DBA_DriveFreeSpaceVw]
AS
SELECT     TOP 100 PERCENT dbo.tMyDbsMoreInfo.server, UPPER(SUBSTRING(dbo.tMyDbsMoreInfo.dbfilename, 1, 1)) AS DbDrive, SUM(CONVERT(int, 
                      ROUND(CONVERT(float, LEFT(LTRIM(dbo.tMyDbs.dbsize), LEN(LTRIM(dbo.tMyDbs.dbsize)) - 6)), 0))) AS TotalSpaceUsed, 
                      dbo.tDriveSpaceChk.Drive AS ServerDrive, dbo.tDriveSpaceChk.MBFree AS SpaceFree
FROM         dbo.tMyDbsMoreInfo INNER JOIN
                      dbo.tMyDbs ON dbo.tMyDbsMoreInfo.dbname = dbo.tMyDbs.dbname INNER JOIN
                      dbo.tDriveSpaceChk ON UPPER(SUBSTRING(dbo.tMyDbsMoreInfo.dbfilename, 1, 1)) = dbo.tDriveSpaceChk.Drive AND 
                      dbo.tMyDbsMoreInfo.server = dbo.tDriveSpaceChk.Server
GROUP BY dbo.tMyDbsMoreInfo.server, UPPER(SUBSTRING(dbo.tMyDbsMoreInfo.dbfilename, 1, 1)), dbo.tDriveSpaceChk.MBFree, 
                      dbo.tDriveSpaceChk.Drive
ORDER BY dbo.tMyDbsMoreInfo.server

GO
/****** Object:  View [dbo].[DBA_LinkedSQLServers_Vw]    Script Date: 4/26/2016 11:40:48 AM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE VIEW [dbo].[DBA_LinkedSQLServers_Vw]
AS
SELECT     *
FROM         master.dbo.sysservers
WHERE     (srvname NOT IN ('KRONOS', 'LAWSON', 'USERACCESS'))

GO
/****** Object:  View [dbo].[FreeSpaceSummary]    Script Date: 4/26/2016 11:40:48 AM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE VIEW [dbo].[FreeSpaceSummary]
AS

SELECT os.Servername,
fs.Drive,
convert(decimal,100 * fs.FreeSpace / dc.Capacity) as PercentFree,
fs.FreeSpace,
dc.Capacity
FROM ServerFreeSpaceHistory fs
JOIN Server os
ON fs.ServerID=os.ServerID
JOIN ServerDriveCapacity dc
ON dc.Drive=fs.Drive
AND dc.ServerId = fs.ServerID
WHERE Checkdate>Dateadd(day,-1,getdate())

GO
/****** Object:  View [dbo].[JobList2DaysVw]    Script Date: 4/26/2016 11:40:48 AM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE VIEW [dbo].[JobList2DaysVw]
AS
SELECT     server, jobname, status, enabled, rundate, runtime, runduration
FROM         dbo.tJobReport
WHERE     (CONVERT(datetime, rundate + ' ' + runtime) >= DATEADD(hh, - 72, GETDATE()))

GO
/****** Object:  View [dbo].[MonColInfo]    Script Date: 4/26/2016 11:40:48 AM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE VIEW [dbo].[MonColInfo]
AS
SELECT     dbo.SrvrDbTblColMon.ServerNm, dbo.SrvrDbTblColMon.DbNm, dbo.ColumnInfoMon.tablename, dbo.ColumnInfoMon.type_desc, dbo.ColumnInfoMon.columnname, 
                      dbo.ColumnInfoMon.dataType, dbo.ColumnInfoMon.size, dbo.ColumnInfoMon.nullable, dbo.ColumnInfoMon.precision
FROM         dbo.SrvrDbTblColMon INNER JOIN
                      dbo.ColumnInfoMon ON dbo.SrvrDbTblColMon.ServerNm = dbo.ColumnInfoMon.servername
WHERE     (dbo.SrvrDbTblColMon.DbNm NOT IN ('master', 'msdb', 'model', 'tempdb', 'reportserver', 'reportservertempdb'))

GO
/****** Object:  View [dbo].[MonDataMB]    Script Date: 4/26/2016 11:40:48 AM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE VIEW [dbo].[MonDataMB]
AS
SELECT     TOP (100) PERCENT SUM(Size_MB) AS TotalDataMB, ServerName
FROM         dbo.FilesMon
GROUP BY ServerName
ORDER BY TotalDataMB DESC

GO
/****** Object:  View [dbo].[MonDBDataMB]    Script Date: 4/26/2016 11:40:48 AM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE VIEW [dbo].[MonDBDataMB]
AS
SELECT     TOP (100) PERCENT SUM(Size_MB) AS TotalDataMB, dbname
FROM         dbo.FilesMon
GROUP BY dbname
ORDER BY TotalDataMB DESC

GO
/****** Object:  View [dbo].[MonDBIndexCount]    Script Date: 4/26/2016 11:40:48 AM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE VIEW [dbo].[MonDBIndexCount]
AS
SELECT     TOP (100) PERCENT COUNT(IndexName) AS IndexCount, DBName
FROM         dbo.IndexListMon
GROUP BY DBName
ORDER BY DBName

GO
/****** Object:  View [dbo].[MonDBLogData]    Script Date: 4/26/2016 11:40:48 AM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE VIEW [dbo].[MonDBLogData]
AS
SELECT     TOP (100) PERCENT SUM(Size_MB) AS TotalDataMB, dbname
FROM         dbo.DataAndLogFilesMon
WHERE     (RIGHT(Physical_Name, 3) = 'ldf')
GROUP BY dbname
ORDER BY TotalDataMB DESC

GO
/****** Object:  View [dbo].[MonFraggedIndexes]    Script Date: 4/26/2016 11:40:48 AM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE VIEW [dbo].[MonFraggedIndexes]
AS
SELECT     TOP (100) PERCENT COUNT(IndexName) AS Expr1, ServerName, DbName
FROM         dbo.IdxFragMon
GROUP BY ServerName, DbName
ORDER BY DbName

GO
/****** Object:  View [dbo].[MonIndexList]    Script Date: 4/26/2016 11:40:48 AM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE VIEW [dbo].[MonIndexList]
AS
SELECT     TOP (100) PERCENT COUNT(IndexName) AS Expr1, ServerName, DBName
FROM         dbo.IndexListMon
GROUP BY ServerName, DBName
ORDER BY ServerName

GO
/****** Object:  View [dbo].[MonInstanceList]    Script Date: 4/26/2016 11:40:48 AM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE VIEW [dbo].[MonInstanceList]
AS
SELECT     ServerName, CASE SUBSTRING(ProductVersion, 0, 3) 
                      WHEN '10' THEN '2008' WHEN '11' THEN '2012' WHEN '12' THEN '2014' WHEN '9.' THEN '2005' WHEN '8.' THEN '2000' ELSE 'Other' END AS Version, ProductLevel, 
                      Edition
FROM         dbo.InstanceInfoMon
UNION ALL
SELECT     ServerName, CASE SUBSTRING(ProductVersion, 0, 5) 
                      WHEN '10.5' THEN '2008 R2' WHEN '10.0' THEN '2008' WHEN '11.0' THEN '2012' WHEN '12.0' THEN '2014' WHEN '9.0.' THEN '2005' WHEN '8.0.' THEN '2000' ELSE 'Other' END AS Version, ProductLevel, 
                      Edition
FROM         dbo.InstanceInfoMonMan

GO
/****** Object:  View [dbo].[MonLogMB]    Script Date: 4/26/2016 11:40:48 AM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE VIEW [dbo].[MonLogMB]
AS
SELECT     TOP (100) PERCENT SUM(Size_MB) AS TotalDataMB, ServerName
FROM         dbo.DataAndLogFilesMon
WHERE     (RIGHT(Physical_Name, 3) = 'ldf')
GROUP BY ServerName
ORDER BY TotalDataMB DESC

GO
/****** Object:  View [dbo].[MonSQLEditionCountVw]    Script Date: 4/26/2016 11:40:48 AM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE VIEW [dbo].[MonSQLEditionCountVw]
AS
SELECT     ServerName, ProductVersion, ProductLevel, Edition, EngineEdition
FROM         dbo.InstanceInfoMon
UNION ALL
SELECT     ServerName, ProductVersion, ProductLevel, Edition, EngineEdition
FROM         dbo.InstanceInfoMonMan

GO
/****** Object:  View [dbo].[MonSQLVersionCountsVw]    Script Date: 4/26/2016 11:40:48 AM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE VIEW [dbo].[MonSQLVersionCountsVw]
AS
SELECT     ServerName, ProductVersion, ProductLevel, Edition, EngineEdition
FROM         dbo.InstanceInfoMon
UNION ALL
SELECT     ServerName, ProductVersion, ProductLevel, Edition, EngineEdition
FROM         dbo.InstanceInfoMonMan

GO
/****** Object:  View [dbo].[RFM]    Script Date: 4/26/2016 11:40:48 AM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

-- Create view
CREATE VIEW [dbo].[RFM] WITH SCHEMABINDING AS
SELECT COOKIE_ID, SUM(TRANSACTION_VALUE) AS MONETARY
,COUNT_BIG(*) AS FREQUENCY
FROM [DBO].WEBLOG
GROUP BY COOKIE_ID

GO
/****** Object:  View [dbo].[vServers]    Script Date: 4/26/2016 11:40:48 AM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE VIEW [dbo].[vServers]
AS
SELECT DISTINCT Server, version
FROM         dbo.tMyDbs

GO
/****** Object:  View [dbo].[vSQLPerfMon]    Script Date: 4/26/2016 11:40:48 AM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
/***********************************************************
DESCRIPTION:	Format the Counter Log data to be used in the reports
Author:		Shawn Calderon/Keith Duggins
DATE WRITTEN:	06/05/2006
**********************************************************
*/
CREATE VIEW [dbo].[vSQLPerfMon]
AS
SELECT     dbo.CounterDetails.MachineName, dbo.CounterDetails.ObjectName, 
                      CASE WHEN CounterDetails.CounterName = '% Processor Time' THEN '% Processor Time - Consistent values over 85% suggests a processor bottleneck'
                       WHEN CounterDetails.CounterName = 'Pages/Sec' THEN 'Pages/Sec - Extended periods of 20 or greater suggests a memory bottleneck.' WHEN CounterDetails.CounterName
                       = 'Buffer cache hit ratio' THEN 'Buffer cache hit ratio - dipping below 85-95% suggests a memory bottleneck' WHEN CounterDetails.CounterName = '% Disk Time'
                       THEN '% Disk Time - Consistent periods exceeding 90% suggests an I/O bottleneck' ELSE CounterDetails.CounterName END AS CounterName, 
                      CAST(LEFT(dbo.CounterData.CounterDateTime, 19) AS smalldatetime) AS CounterDate, DATEPART([YEAR], 
                      CAST(LEFT(dbo.CounterData.CounterDateTime, 19) AS smalldatetime)) AS CounterYear, DATENAME([MONTH], 
                      CAST(LEFT(dbo.CounterData.CounterDateTime, 19) AS smalldatetime)) AS CounterMonth, DATENAME(WEEK, 
                      CAST(LEFT(dbo.CounterData.CounterDateTime, 19) AS smalldatetime)) AS CounterWeek, DATENAME(WEEKDAY, 
                      CAST(LEFT(dbo.CounterData.CounterDateTime, 19) AS smalldatetime)) AS CounterWeekDay, DATENAME([DAY], 
                      CAST(LEFT(dbo.CounterData.CounterDateTime, 19) AS smalldatetime)) AS CounterDay, CAST(CAST(DATEPART([HOUR], 
                      CAST(LEFT(dbo.CounterData.CounterDateTime, 19) AS smalldatetime)) AS varchar) + CAST(CASE WHEN datepart(MINUTE, (cast(LEFT(CounterDateTime, 
                      19) AS smalldatetime))) BETWEEN 1 AND 15 THEN 15 WHEN datepart(minute, (cast(LEFT(CounterDateTime, 19) AS smalldatetime))) BETWEEN 16 AND 
                      30 THEN 30 WHEN datepart(minute, (cast(LEFT(CounterDateTime, 19) AS smalldatetime))) BETWEEN 31 AND 45 THEN 45 ELSE 59 END AS varchar) 
                      AS int) AS CounterTime, ROUND(dbo.CounterData.CounterValue, 4) AS CounterValue
FROM         dbo.CounterData INNER JOIN
                      dbo.CounterDetails ON dbo.CounterDetails.CounterID = dbo.CounterData.CounterID
WHERE     (CAST(CAST(DATEPART([hour], CAST(LEFT(dbo.CounterData.CounterDateTime, 19) AS smalldatetime)) AS varchar) + CAST(CASE WHEN datepart(minute, 
                      (cast(LEFT(CounterDateTime, 19) AS smalldatetime))) BETWEEN 1 AND 15 THEN 15 WHEN datepart(minute, (cast(LEFT(CounterDateTime, 19) 
                      AS smalldatetime))) BETWEEN 16 AND 30 THEN 30 WHEN datepart(minute, (cast(LEFT(CounterDateTime, 19) AS smalldatetime))) BETWEEN 31 AND 
                      45 THEN 45 ELSE 59 END AS varchar) AS int) BETWEEN 659 AND 1901)

GO
/****** Object:  View [dbo].[vSQLPerfSXA]    Script Date: 4/26/2016 11:40:48 AM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE VIEW [dbo].[vSQLPerfSXA]
AS
SELECT     dbo.CounterDetails.MachineName, dbo.CounterDetails.ObjectName, 
                      CASE WHEN CounterDetails.CounterName = '% Processor Time' THEN '% Processor Time - Consistent values over 85% suggests a processor bottleneck'
                       WHEN CounterDetails.CounterName = 'Pages/Sec' THEN 'Pages/Sec - Extended periods of 20 or greater suggests a memory bottleneck.' WHEN CounterDetails.CounterName
                       = 'Buffer cache hit ratio' THEN 'Buffer cache hit ratio - dipping below 85-95% suggests a memory bottleneck' WHEN CounterDetails.CounterName = '% Disk Time'
                       THEN '% Disk Time - Consistent periods exceeding 90% suggests an I/O bottleneck' ELSE CounterDetails.CounterName END AS CounterName, 
                      CAST(LEFT(dbo.CounterData.CounterDateTime, 19) AS smalldatetime) AS CounterDate, DATEPART([YEAR], 
                      CAST(LEFT(dbo.CounterData.CounterDateTime, 19) AS smalldatetime)) AS CounterYear, DATENAME([MONTH], 
                      CAST(LEFT(dbo.CounterData.CounterDateTime, 19) AS smalldatetime)) AS CounterMonth, DATENAME(WEEK, 
                      CAST(LEFT(dbo.CounterData.CounterDateTime, 19) AS smalldatetime)) AS CounterWeek, DATENAME(WEEKDAY, 
                      CAST(LEFT(dbo.CounterData.CounterDateTime, 19) AS smalldatetime)) AS CounterWeekDay, DATENAME([DAY], 
                      CAST(LEFT(dbo.CounterData.CounterDateTime, 19) AS smalldatetime)) AS CounterDay, CAST(CAST(DATEPART([HOUR], 
                      CAST(LEFT(dbo.CounterData.CounterDateTime, 19) AS smalldatetime)) AS varchar) + CAST(CASE WHEN datepart(MINUTE, (cast(LEFT(CounterDateTime, 
                      19) AS smalldatetime))) BETWEEN 1 AND 15 THEN 15 WHEN datepart(minute, (cast(LEFT(CounterDateTime, 19) AS smalldatetime))) BETWEEN 16 AND 
                      30 THEN 30 WHEN datepart(minute, (cast(LEFT(CounterDateTime, 19) AS smalldatetime))) BETWEEN 31 AND 45 THEN 45 ELSE 59 END AS varchar) 
                      AS int) AS CounterTime, ROUND(dbo.CounterData.CounterValue, 0) AS CounterValue
FROM         dbo.CounterData INNER JOIN
                      dbo.CounterDetails ON dbo.CounterDetails.CounterID = dbo.CounterData.CounterID
WHERE     (CAST(CAST(DATEPART([hour], CAST(LEFT(dbo.CounterData.CounterDateTime, 19) AS smalldatetime)) AS varchar) + CAST(CASE WHEN datepart(minute, 
                      (cast(LEFT(CounterDateTime, 19) AS smalldatetime))) BETWEEN 1 AND 15 THEN 15 WHEN datepart(minute, (cast(LEFT(CounterDateTime, 19) 
                      AS smalldatetime))) BETWEEN 16 AND 30 THEN 30 WHEN datepart(minute, (cast(LEFT(CounterDateTime, 19) AS smalldatetime))) BETWEEN 31 AND 
                      45 THEN 45 ELSE 59 END AS varchar) AS int) BETWEEN 659 AND 1901) AND (dbo.CounterDetails.MachineName = '\\CHSXAMAP') AND 
                      (dbo.CounterDetails.CounterName LIKE '% Processor Time%' OR
                      dbo.CounterDetails.CounterName LIKE '% Disk Time%' OR
                      dbo.CounterDetails.CounterName LIKE '% Disk Write Time' OR
                      dbo.CounterDetails.CounterName = '% Disk Read Time' OR
                      dbo.CounterDetails.CounterName LIKE 'Buffer Cache Hit Ratio%' OR
                      dbo.CounterDetails.CounterName LIKE 'Pages/Sec%')

GO
/****** Object:  View [dbo].[vSQLPerfSXA2DaysAgo]    Script Date: 4/26/2016 11:40:48 AM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE VIEW [dbo].[vSQLPerfSXA2DaysAgo]
AS
SELECT     dbo.CounterDetails.MachineName, dbo.CounterDetails.ObjectName, 
                      CASE WHEN CounterDetails.CounterName = '% Processor Time' THEN '% Processor Time - Consistent values over 85% suggests a processor bottleneck'
                       WHEN CounterDetails.CounterName = 'Pages/Sec' THEN 'Pages/Sec - Extended periods of 20 or greater suggests a memory bottleneck.' WHEN CounterDetails.CounterName
                       = 'Buffer cache hit ratio' THEN 'Buffer cache hit ratio - dipping below 85-95% suggests a memory bottleneck' WHEN CounterDetails.CounterName = '% Disk Time'
                       THEN '% Disk Time - Consistent periods exceeding 90% suggests an I/O bottleneck' ELSE CounterDetails.CounterName END AS CounterName, 
                      CAST(LEFT(dbo.CounterData.CounterDateTime, 19) AS smalldatetime) AS CounterDate, DATEPART([YEAR], 
                      CAST(LEFT(dbo.CounterData.CounterDateTime, 19) AS smalldatetime)) AS CounterYear, DATENAME([MONTH], 
                      CAST(LEFT(dbo.CounterData.CounterDateTime, 19) AS smalldatetime)) AS CounterMonth, DATENAME(WEEK, 
                      CAST(LEFT(dbo.CounterData.CounterDateTime, 19) AS smalldatetime)) AS CounterWeek, DATENAME(WEEKDAY, 
                      CAST(LEFT(dbo.CounterData.CounterDateTime, 19) AS smalldatetime)) AS CounterWeekDay, DATENAME([DAY], 
                      CAST(LEFT(dbo.CounterData.CounterDateTime, 19) AS smalldatetime)) AS CounterDay, CAST(CAST(DATEPART([HOUR], 
                      CAST(LEFT(dbo.CounterData.CounterDateTime, 19) AS smalldatetime)) AS varchar) + CAST(CASE WHEN datepart(MINUTE, (cast(LEFT(CounterDateTime, 
                      19) AS smalldatetime))) BETWEEN 1 AND 15 THEN 15 WHEN datepart(minute, (cast(LEFT(CounterDateTime, 19) AS smalldatetime))) BETWEEN 16 AND 
                      30 THEN 30 WHEN datepart(minute, (cast(LEFT(CounterDateTime, 19) AS smalldatetime))) BETWEEN 31 AND 45 THEN 45 ELSE 59 END AS varchar) 
                      AS int) AS CounterTime, ROUND(dbo.CounterData.CounterValue, 4) AS CounterValue
FROM         dbo.CounterData INNER JOIN
                      dbo.CounterDetails ON dbo.CounterDetails.CounterID = dbo.CounterData.CounterID
WHERE     (DATEPART(m, CAST(LEFT(dbo.CounterData.CounterDateTime, 19) AS smalldatetime)) = DATEPART(m, GETDATE())) AND (DATEPART(d, 
                      CAST(LEFT(dbo.CounterData.CounterDateTime, 19) AS smalldatetime)) = DATEPART(d, DATEADD([day], - 2, GETDATE()))) AND (DATEPART(yyyy, 
                      CAST(LEFT(dbo.CounterData.CounterDateTime, 19) AS smalldatetime)) = DATEPART(yyyy, GETDATE()))

GO
/****** Object:  View [dbo].[vSQLPerfSXA3DaysAgo]    Script Date: 4/26/2016 11:40:48 AM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE VIEW [dbo].[vSQLPerfSXA3DaysAgo]
AS
SELECT     dbo.CounterDetails.MachineName, dbo.CounterDetails.ObjectName, 
                      CASE WHEN CounterDetails.CounterName = '% Processor Time' THEN '% Processor Time - Consistent values over 85% suggests a processor bottleneck'
                       WHEN CounterDetails.CounterName = 'Pages/Sec' THEN 'Pages/Sec - Extended periods of 20 or greater suggests a memory bottleneck.' WHEN CounterDetails.CounterName
                       = 'Buffer cache hit ratio' THEN 'Buffer cache hit ratio - dipping below 85-95% suggests a memory bottleneck' WHEN CounterDetails.CounterName = '% Disk Time'
                       THEN '% Disk Time - Consistent periods exceeding 90% suggests an I/O bottleneck' ELSE CounterDetails.CounterName END AS CounterName, 
                      CAST(LEFT(dbo.CounterData.CounterDateTime, 19) AS smalldatetime) AS CounterDate, DATEPART([YEAR], 
                      CAST(LEFT(dbo.CounterData.CounterDateTime, 19) AS smalldatetime)) AS CounterYear, DATENAME([MONTH], 
                      CAST(LEFT(dbo.CounterData.CounterDateTime, 19) AS smalldatetime)) AS CounterMonth, DATENAME(WEEK, 
                      CAST(LEFT(dbo.CounterData.CounterDateTime, 19) AS smalldatetime)) AS CounterWeek, DATENAME(WEEKDAY, 
                      CAST(LEFT(dbo.CounterData.CounterDateTime, 19) AS smalldatetime)) AS CounterWeekDay, DATENAME([DAY], 
                      CAST(LEFT(dbo.CounterData.CounterDateTime, 19) AS smalldatetime)) AS CounterDay, CAST(CAST(DATEPART([HOUR], 
                      CAST(LEFT(dbo.CounterData.CounterDateTime, 19) AS smalldatetime)) AS varchar) + CAST(CASE WHEN datepart(MINUTE, (cast(LEFT(CounterDateTime, 
                      19) AS smalldatetime))) BETWEEN 1 AND 15 THEN 15 WHEN datepart(minute, (cast(LEFT(CounterDateTime, 19) AS smalldatetime))) BETWEEN 16 AND 
                      30 THEN 30 WHEN datepart(minute, (cast(LEFT(CounterDateTime, 19) AS smalldatetime))) BETWEEN 31 AND 45 THEN 45 ELSE 59 END AS varchar) 
                      AS int) AS CounterTime, ROUND(dbo.CounterData.CounterValue, 4) AS CounterValue
FROM         dbo.CounterData INNER JOIN
                      dbo.CounterDetails ON dbo.CounterDetails.CounterID = dbo.CounterData.CounterID
WHERE     (DATEPART(m, CAST(LEFT(dbo.CounterData.CounterDateTime, 19) AS smalldatetime)) = DATEPART(m, GETDATE())) AND (DATEPART(d, 
                      CAST(LEFT(dbo.CounterData.CounterDateTime, 19) AS smalldatetime)) = DATEPART(d, DATEADD([day], - 3, GETDATE()))) AND (DATEPART(yyyy, 
                      CAST(LEFT(dbo.CounterData.CounterDateTime, 19) AS smalldatetime)) = DATEPART(yyyy, GETDATE()))

GO
/****** Object:  View [dbo].[vSQLPerfSXA4DaysAgo]    Script Date: 4/26/2016 11:40:48 AM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE VIEW [dbo].[vSQLPerfSXA4DaysAgo]
AS
SELECT     dbo.CounterDetails.MachineName, dbo.CounterDetails.ObjectName, 
                      CASE WHEN CounterDetails.CounterName = '% Processor Time' THEN '% Processor Time - Consistent values over 85% suggests a processor bottleneck'
                       WHEN CounterDetails.CounterName = 'Pages/Sec' THEN 'Pages/Sec - Extended periods of 20 or greater suggests a memory bottleneck.' WHEN CounterDetails.CounterName
                       = 'Buffer cache hit ratio' THEN 'Buffer cache hit ratio - dipping below 85-95% suggests a memory bottleneck' WHEN CounterDetails.CounterName = '% Disk Time'
                       THEN '% Disk Time - Consistent periods exceeding 90% suggests an I/O bottleneck' ELSE CounterDetails.CounterName END AS CounterName, 
                      CAST(LEFT(dbo.CounterData.CounterDateTime, 19) AS smalldatetime) AS CounterDate, DATEPART([YEAR], 
                      CAST(LEFT(dbo.CounterData.CounterDateTime, 19) AS smalldatetime)) AS CounterYear, DATENAME([MONTH], 
                      CAST(LEFT(dbo.CounterData.CounterDateTime, 19) AS smalldatetime)) AS CounterMonth, DATENAME(WEEK, 
                      CAST(LEFT(dbo.CounterData.CounterDateTime, 19) AS smalldatetime)) AS CounterWeek, DATENAME(WEEKDAY, 
                      CAST(LEFT(dbo.CounterData.CounterDateTime, 19) AS smalldatetime)) AS CounterWeekDay, DATENAME([DAY], 
                      CAST(LEFT(dbo.CounterData.CounterDateTime, 19) AS smalldatetime)) AS CounterDay, CAST(CAST(DATEPART([HOUR], 
                      CAST(LEFT(dbo.CounterData.CounterDateTime, 19) AS smalldatetime)) AS varchar) + CAST(CASE WHEN datepart(MINUTE, (cast(LEFT(CounterDateTime, 
                      19) AS smalldatetime))) BETWEEN 1 AND 15 THEN 15 WHEN datepart(minute, (cast(LEFT(CounterDateTime, 19) AS smalldatetime))) BETWEEN 16 AND 
                      30 THEN 30 WHEN datepart(minute, (cast(LEFT(CounterDateTime, 19) AS smalldatetime))) BETWEEN 31 AND 45 THEN 45 ELSE 59 END AS varchar) 
                      AS int) AS CounterTime, ROUND(dbo.CounterData.CounterValue, 0) AS CounterValue
FROM         dbo.CounterData INNER JOIN
                      dbo.CounterDetails ON dbo.CounterDetails.CounterID = dbo.CounterData.CounterID
WHERE     (DATEPART(m, CAST(LEFT(dbo.CounterData.CounterDateTime, 19) AS smalldatetime)) = DATEPART(m, GETDATE())) AND (DATEPART(d, 
                      CAST(LEFT(dbo.CounterData.CounterDateTime, 19) AS smalldatetime)) = DATEPART(d, DATEADD([day], - 4, GETDATE()))) AND (DATEPART(yyyy, 
                      CAST(LEFT(dbo.CounterData.CounterDateTime, 19) AS smalldatetime)) = DATEPART(yyyy, GETDATE()))

GO
/****** Object:  View [dbo].[vSQLPerfSXA5DaysAgo]    Script Date: 4/26/2016 11:40:48 AM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE VIEW [dbo].[vSQLPerfSXA5DaysAgo]
AS
SELECT     dbo.CounterDetails.MachineName, dbo.CounterDetails.ObjectName, 
                      CASE WHEN CounterDetails.CounterName = '% Processor Time' THEN '% Processor Time - Consistent values over 85% suggests a processor bottleneck'
                       WHEN CounterDetails.CounterName = 'Pages/Sec' THEN 'Pages/Sec - Extended periods of 20 or greater suggests a memory bottleneck.' WHEN CounterDetails.CounterName
                       = 'Buffer cache hit ratio' THEN 'Buffer cache hit ratio - dipping below 85-95% suggests a memory bottleneck' WHEN CounterDetails.CounterName = '% Disk Time'
                       THEN '% Disk Time - Consistent periods exceeding 90% suggests an I/O bottleneck' ELSE CounterDetails.CounterName END AS CounterName, 
                      CAST(LEFT(dbo.CounterData.CounterDateTime, 19) AS smalldatetime) AS CounterDate, DATEPART([YEAR], 
                      CAST(LEFT(dbo.CounterData.CounterDateTime, 19) AS smalldatetime)) AS CounterYear, DATENAME([MONTH], 
                      CAST(LEFT(dbo.CounterData.CounterDateTime, 19) AS smalldatetime)) AS CounterMonth, DATENAME(WEEK, 
                      CAST(LEFT(dbo.CounterData.CounterDateTime, 19) AS smalldatetime)) AS CounterWeek, DATENAME(WEEKDAY, 
                      CAST(LEFT(dbo.CounterData.CounterDateTime, 19) AS smalldatetime)) AS CounterWeekDay, DATENAME([DAY], 
                      CAST(LEFT(dbo.CounterData.CounterDateTime, 19) AS smalldatetime)) AS CounterDay, CAST(CAST(DATEPART([HOUR], 
                      CAST(LEFT(dbo.CounterData.CounterDateTime, 19) AS smalldatetime)) AS varchar) + CAST(CASE WHEN datepart(MINUTE, (cast(LEFT(CounterDateTime, 
                      19) AS smalldatetime))) BETWEEN 1 AND 15 THEN 15 WHEN datepart(minute, (cast(LEFT(CounterDateTime, 19) AS smalldatetime))) BETWEEN 16 AND 
                      30 THEN 30 WHEN datepart(minute, (cast(LEFT(CounterDateTime, 19) AS smalldatetime))) BETWEEN 31 AND 45 THEN 45 ELSE 59 END AS varchar) 
                      AS int) AS CounterTime, ROUND(dbo.CounterData.CounterValue, 4) AS CounterValue
FROM         dbo.CounterData INNER JOIN
                      dbo.CounterDetails ON dbo.CounterDetails.CounterID = dbo.CounterData.CounterID
WHERE     (DATEPART(m, CAST(LEFT(dbo.CounterData.CounterDateTime, 19) AS smalldatetime)) = DATEPART(m, GETDATE())) AND (DATEPART(d, 
                      CAST(LEFT(dbo.CounterData.CounterDateTime, 19) AS smalldatetime)) = DATEPART(d, DATEADD([day], - 5, GETDATE()))) AND (DATEPART(yyyy, 
                      CAST(LEFT(dbo.CounterData.CounterDateTime, 19) AS smalldatetime)) = DATEPART(yyyy, GETDATE()))


GO
/****** Object:  View [dbo].[vSQLPerfSXA6DaysAgo]    Script Date: 4/26/2016 11:40:48 AM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE VIEW [dbo].[vSQLPerfSXA6DaysAgo]
AS
SELECT     dbo.CounterDetails.MachineName, dbo.CounterDetails.ObjectName, 
                      CASE WHEN CounterDetails.CounterName = '% Processor Time' THEN '% Processor Time - Consistent values over 85% suggests a processor bottleneck'
                       WHEN CounterDetails.CounterName = 'Pages/Sec' THEN 'Pages/Sec - Extended periods of 20 or greater suggests a memory bottleneck.' WHEN CounterDetails.CounterName
                       = 'Buffer cache hit ratio' THEN 'Buffer cache hit ratio - dipping below 85-95% suggests a memory bottleneck' WHEN CounterDetails.CounterName = '% Disk Time'
                       THEN '% Disk Time - Consistent periods exceeding 90% suggests an I/O bottleneck' ELSE CounterDetails.CounterName END AS CounterName, 
                      CAST(LEFT(dbo.CounterData.CounterDateTime, 19) AS smalldatetime) AS CounterDate, DATEPART([YEAR], 
                      CAST(LEFT(dbo.CounterData.CounterDateTime, 19) AS smalldatetime)) AS CounterYear, DATENAME([MONTH], 
                      CAST(LEFT(dbo.CounterData.CounterDateTime, 19) AS smalldatetime)) AS CounterMonth, DATENAME(WEEK, 
                      CAST(LEFT(dbo.CounterData.CounterDateTime, 19) AS smalldatetime)) AS CounterWeek, DATENAME(WEEKDAY, 
                      CAST(LEFT(dbo.CounterData.CounterDateTime, 19) AS smalldatetime)) AS CounterWeekDay, DATENAME([DAY], 
                      CAST(LEFT(dbo.CounterData.CounterDateTime, 19) AS smalldatetime)) AS CounterDay, CAST(CAST(DATEPART([HOUR], 
                      CAST(LEFT(dbo.CounterData.CounterDateTime, 19) AS smalldatetime)) AS varchar) + CAST(CASE WHEN datepart(MINUTE, (cast(LEFT(CounterDateTime, 
                      19) AS smalldatetime))) BETWEEN 1 AND 15 THEN 15 WHEN datepart(minute, (cast(LEFT(CounterDateTime, 19) AS smalldatetime))) BETWEEN 16 AND 
                      30 THEN 30 WHEN datepart(minute, (cast(LEFT(CounterDateTime, 19) AS smalldatetime))) BETWEEN 31 AND 45 THEN 45 ELSE 59 END AS varchar) 
                      AS int) AS CounterTime, ROUND(dbo.CounterData.CounterValue, 4) AS CounterValue
FROM         dbo.CounterData INNER JOIN
                      dbo.CounterDetails ON dbo.CounterDetails.CounterID = dbo.CounterData.CounterID
WHERE     (DATEPART(m, CAST(LEFT(dbo.CounterData.CounterDateTime, 19) AS smalldatetime)) = DATEPART(m, GETDATE())) AND (DATEPART(d, 
                      CAST(LEFT(dbo.CounterData.CounterDateTime, 19) AS smalldatetime)) = DATEPART(d, DATEADD([day], - 6, GETDATE()))) AND (DATEPART(yyyy, 
                      CAST(LEFT(dbo.CounterData.CounterDateTime, 19) AS smalldatetime)) = DATEPART(yyyy, GETDATE()))


GO
/****** Object:  View [dbo].[vSQLPerfSXA7DaysAgo]    Script Date: 4/26/2016 11:40:48 AM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE VIEW [dbo].[vSQLPerfSXA7DaysAgo]
AS
SELECT     dbo.CounterDetails.MachineName, dbo.CounterDetails.ObjectName, 
                      CASE WHEN CounterDetails.CounterName = '% Processor Time' THEN '% Processor Time - Consistent values over 85% suggests a processor bottleneck'
                       WHEN CounterDetails.CounterName = 'Pages/Sec' THEN 'Pages/Sec - Extended periods of 20 or greater suggests a memory bottleneck.' WHEN CounterDetails.CounterName
                       = 'Buffer cache hit ratio' THEN 'Buffer cache hit ratio - dipping below 85-95% suggests a memory bottleneck' WHEN CounterDetails.CounterName = '% Disk Time'
                       THEN '% Disk Time - Consistent periods exceeding 90% suggests an I/O bottleneck' ELSE CounterDetails.CounterName END AS CounterName, 
                      CAST(LEFT(dbo.CounterData.CounterDateTime, 19) AS smalldatetime) AS CounterDate, DATEPART([YEAR], 
                      CAST(LEFT(dbo.CounterData.CounterDateTime, 19) AS smalldatetime)) AS CounterYear, DATENAME([MONTH], 
                      CAST(LEFT(dbo.CounterData.CounterDateTime, 19) AS smalldatetime)) AS CounterMonth, DATENAME(WEEK, 
                      CAST(LEFT(dbo.CounterData.CounterDateTime, 19) AS smalldatetime)) AS CounterWeek, DATENAME(WEEKDAY, 
                      CAST(LEFT(dbo.CounterData.CounterDateTime, 19) AS smalldatetime)) AS CounterWeekDay, DATENAME([DAY], 
                      CAST(LEFT(dbo.CounterData.CounterDateTime, 19) AS smalldatetime)) AS CounterDay, CAST(CAST(DATEPART([HOUR], 
                      CAST(LEFT(dbo.CounterData.CounterDateTime, 19) AS smalldatetime)) AS varchar) + CAST(CASE WHEN datepart(MINUTE, (cast(LEFT(CounterDateTime, 
                      19) AS smalldatetime))) BETWEEN 1 AND 15 THEN 15 WHEN datepart(minute, (cast(LEFT(CounterDateTime, 19) AS smalldatetime))) BETWEEN 16 AND 
                      30 THEN 30 WHEN datepart(minute, (cast(LEFT(CounterDateTime, 19) AS smalldatetime))) BETWEEN 31 AND 45 THEN 45 ELSE 59 END AS varchar) 
                      AS int) AS CounterTime, ROUND(dbo.CounterData.CounterValue, 4) AS CounterValue
FROM         dbo.CounterData INNER JOIN
                      dbo.CounterDetails ON dbo.CounterDetails.CounterID = dbo.CounterData.CounterID
WHERE     (DATEPART(m, CAST(LEFT(dbo.CounterData.CounterDateTime, 19) AS smalldatetime)) = DATEPART(m, GETDATE())) AND (DATEPART(d, 
                      CAST(LEFT(dbo.CounterData.CounterDateTime, 19) AS smalldatetime)) = DATEPART(d, DATEADD([day], - 7, GETDATE()))) AND (DATEPART(yyyy, 
                      CAST(LEFT(dbo.CounterData.CounterDateTime, 19) AS smalldatetime)) = DATEPART(yyyy, GETDATE()))


GO
/****** Object:  View [dbo].[vSQLPerfSXADriveInfo]    Script Date: 4/26/2016 11:40:48 AM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE VIEW [dbo].[vSQLPerfSXADriveInfo]
AS
SELECT     dbo.CounterDetails.MachineName, dbo.CounterDetails.ObjectName, 
                      CASE WHEN CounterDetails.CounterName = '% Processor Time' THEN '% Processor Time - Consistent values over 85% suggests a processor bottleneck'
                       WHEN CounterDetails.CounterName = 'Pages/Sec' THEN 'Pages/Sec - Extended periods of 20 or greater suggests a memory bottleneck.' WHEN CounterDetails.CounterName
                       = 'Buffer cache hit ratio' THEN 'Buffer cache hit ratio - dipping below 85-95% suggests a memory bottleneck' WHEN CounterDetails.CounterName = '% Disk Time'
                       THEN '% Disk Time - Consistent periods exceeding 90% suggests an I/O bottleneck' ELSE CounterDetails.CounterName END AS CounterName, 
                      CAST(LEFT(dbo.CounterData.CounterDateTime, 19) AS smalldatetime) AS CounterDate, DATEPART([YEAR], 
                      CAST(LEFT(dbo.CounterData.CounterDateTime, 19) AS smalldatetime)) AS CounterYear, DATENAME([MONTH], 
                      CAST(LEFT(dbo.CounterData.CounterDateTime, 19) AS smalldatetime)) AS CounterMonth, DATENAME(WEEK, 
                      CAST(LEFT(dbo.CounterData.CounterDateTime, 19) AS smalldatetime)) AS CounterWeek, DATENAME(WEEKDAY, 
                      CAST(LEFT(dbo.CounterData.CounterDateTime, 19) AS smalldatetime)) AS CounterWeekDay, DATENAME([DAY], 
                      CAST(LEFT(dbo.CounterData.CounterDateTime, 19) AS smalldatetime)) AS CounterDay, CAST(CAST(DATEPART([HOUR], 
                      CAST(LEFT(dbo.CounterData.CounterDateTime, 19) AS smalldatetime)) AS varchar) + CAST(CASE WHEN datepart(MINUTE, (cast(LEFT(CounterDateTime, 
                      19) AS smalldatetime))) BETWEEN 1 AND 15 THEN 15 WHEN datepart(minute, (cast(LEFT(CounterDateTime, 19) AS smalldatetime))) BETWEEN 16 AND 
                      30 THEN 30 WHEN datepart(minute, (cast(LEFT(CounterDateTime, 19) AS smalldatetime))) BETWEEN 31 AND 45 THEN 45 ELSE 59 END AS varchar) 
                      AS int) AS CounterTime, ROUND(dbo.CounterData.CounterValue, 4) AS CounterValue, dbo.CounterDetails.InstanceName
FROM         dbo.CounterData INNER JOIN
                      dbo.CounterDetails ON dbo.CounterDetails.CounterID = dbo.CounterData.CounterID
WHERE     (DATEPART(m, CAST(LEFT(dbo.CounterData.CounterDateTime, 19) AS smalldatetime)) = DATEPART(d, GETDATE())) AND (DATEPART(d, CAST(LEFT(dbo.CounterData.CounterDateTime, 19) AS smalldatetime)) = DATEPART(d, DATEADD(day, - 1, GETDATE()))) AND (DATEPART(yyyy, 
                      CAST(LEFT(dbo.CounterData.CounterDateTime, 19) AS smalldatetime)) = DATEPART(yyyy, GETDATE()))

GO
/****** Object:  View [dbo].[vSQLPerfSXAFDriveYesterday]    Script Date: 4/26/2016 11:40:48 AM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE VIEW [dbo].[vSQLPerfSXAFDriveYesterday]
AS
SELECT DISTINCT 
                      dbo.CounterDetails.MachineName, dbo.CounterDetails.ObjectName, 
                      CASE WHEN CounterDetails.CounterName = '% Processor Time' THEN '% Processor Time - Consistent values over 85% suggests a processor bottleneck'
                       WHEN CounterDetails.CounterName = 'Pages/Sec' THEN 'Pages/Sec - Extended periods of 20 or greater suggests a memory bottleneck.' WHEN CounterDetails.CounterName
                       = 'Buffer cache hit ratio' THEN 'Buffer cache hit ratio - dipping below 85-95% suggests a memory bottleneck' WHEN CounterDetails.CounterName = '% Disk Time'
                       THEN '% Disk Time - Consistent periods exceeding 90% suggests an I/O bottleneck' ELSE CounterDetails.CounterName END AS CounterName, 
                      CAST(LEFT(dbo.CounterData.CounterDateTime, 19) AS smalldatetime) AS CounterDate, DATEPART(YEAR, 
                      CAST(LEFT(dbo.CounterData.CounterDateTime, 19) AS smalldatetime)) AS CounterYear, DATENAME(MONTH, 
                      CAST(LEFT(dbo.CounterData.CounterDateTime, 19) AS smalldatetime)) AS CounterMonth, DATENAME(WEEK, 
                      CAST(LEFT(dbo.CounterData.CounterDateTime, 19) AS smalldatetime)) AS CounterWeek, DATENAME(WEEKDAY, 
                      CAST(LEFT(dbo.CounterData.CounterDateTime, 19) AS smalldatetime)) AS CounterWeekDay, DATENAME(DAY, 
                      CAST(LEFT(dbo.CounterData.CounterDateTime, 19) AS smalldatetime)) AS CounterDay, CAST(CAST(DATEPART(HOUR, 
                      CAST(LEFT(dbo.CounterData.CounterDateTime, 19) AS smalldatetime)) AS varchar) + CAST(CASE WHEN datepart(MINUTE, 
                      (CAST(LEFT(CounterDateTime, 19) AS smalldatetime))) BETWEEN 1 AND 15 THEN 15 WHEN datepart(minute, (CAST(LEFT(CounterDateTime, 19) 
                      AS smalldatetime))) BETWEEN 16 AND 30 THEN 30 WHEN datepart(minute, (CAST(LEFT(CounterDateTime, 19) AS smalldatetime))) BETWEEN 31 AND 
                      45 THEN 45 ELSE 59 END AS varchar) AS int) AS CounterTime, ROUND(dbo.CounterData.CounterValue, 4) AS CounterValue, 
                      dbo.CounterDetails.InstanceName
FROM         dbo.CounterData INNER JOIN
                      dbo.CounterDetails ON dbo.CounterDetails.CounterID = dbo.CounterData.CounterID
WHERE     (DATEPART(m, CAST(LEFT(dbo.CounterData.CounterDateTime, 19) AS smalldatetime)) = DATEPART(m, GETDATE())) AND (DATEPART(d, 
                      CAST(LEFT(dbo.CounterData.CounterDateTime, 19) AS smalldatetime)) = DATEPART(d, DATEADD(day, - 1, GETDATE()))) AND (DATEPART(yyyy, 
                      CAST(LEFT(dbo.CounterData.CounterDateTime, 19) AS smalldatetime)) = DATEPART(yyyy, GETDATE())) AND 
                      (dbo.CounterDetails.InstanceName = '_Total')

GO
/****** Object:  View [dbo].[vSQLPerfSXAToday]    Script Date: 4/26/2016 11:40:48 AM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE VIEW [dbo].[vSQLPerfSXAToday]
AS
SELECT     dbo.CounterDetails.MachineName, dbo.CounterDetails.ObjectName, 
                      CASE WHEN CounterDetails.CounterName = '% Processor Time' THEN '% Processor Time - Consistent values over 85% suggests a processor bottleneck'
                       WHEN CounterDetails.CounterName = 'Pages/Sec' THEN 'Pages/Sec - Extended periods of 20 or greater suggests a memory bottleneck.' WHEN CounterDetails.CounterName
                       = 'Buffer cache hit ratio' THEN 'Buffer cache hit ratio - dipping below 85-95% suggests a memory bottleneck' WHEN CounterDetails.CounterName = '% Disk Time'
                       THEN '% Disk Time - Consistent periods exceeding 90% suggests an I/O bottleneck' ELSE CounterDetails.CounterName END AS CounterName, 
                      CAST(LEFT(dbo.CounterData.CounterDateTime, 19) AS smalldatetime) AS CounterDate, DATEPART(YEAR, 
                      CAST(LEFT(dbo.CounterData.CounterDateTime, 19) AS smalldatetime)) AS CounterYear, DATENAME(MONTH, 
                      CAST(LEFT(dbo.CounterData.CounterDateTime, 19) AS smalldatetime)) AS CounterMonth, DATENAME(WEEK, 
                      CAST(LEFT(dbo.CounterData.CounterDateTime, 19) AS smalldatetime)) AS CounterWeek, DATENAME(WEEKDAY, 
                      CAST(LEFT(dbo.CounterData.CounterDateTime, 19) AS smalldatetime)) AS CounterWeekDay, DATENAME(DAY, 
                      CAST(LEFT(dbo.CounterData.CounterDateTime, 19) AS smalldatetime)) AS CounterDay, CAST(CAST(DATEPART(HOUR, 
                      CAST(LEFT(dbo.CounterData.CounterDateTime, 19) AS smalldatetime)) AS varchar) + CAST(CASE WHEN datepart(MINUTE, 
                      (CAST(LEFT(CounterDateTime, 19) AS smalldatetime))) BETWEEN 1 AND 15 THEN 15 WHEN datepart(minute, (CAST(LEFT(CounterDateTime, 19) 
                      AS smalldatetime))) BETWEEN 16 AND 30 THEN 30 WHEN datepart(minute, (CAST(LEFT(CounterDateTime, 19) AS smalldatetime))) BETWEEN 31 AND 
                      45 THEN 45 ELSE 59 END AS varchar) AS int) AS CounterTime, ROUND(dbo.CounterData.CounterValue, 4) AS CounterValue, 
                      dbo.CounterDetails.InstanceName
FROM         dbo.CounterData INNER JOIN
                      dbo.CounterDetails ON dbo.CounterDetails.CounterID = dbo.CounterData.CounterID
WHERE     (DATEPART(m, CAST(LEFT(dbo.CounterData.CounterDateTime, 19) AS smalldatetime)) = DATEPART(m, GETDATE())) AND (DATEPART(d, 
                      CAST(LEFT(dbo.CounterData.CounterDateTime, 19) AS smalldatetime)) = DATEPART(d, GETDATE())) AND (DATEPART(yyyy, 
                      CAST(LEFT(dbo.CounterData.CounterDateTime, 19) AS smalldatetime)) = DATEPART(yyyy, GETDATE())) AND 
                      (dbo.CounterDetails.InstanceName = '_Total' OR
                      dbo.CounterDetails.InstanceName IS NULL)

GO
/****** Object:  View [dbo].[vSQLPerfSXAWeek]    Script Date: 4/26/2016 11:40:48 AM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE VIEW [dbo].[vSQLPerfSXAWeek]
AS
SELECT     dbo.CounterDetails.MachineName, dbo.CounterDetails.ObjectName, 
                      CASE WHEN CounterDetails.CounterName = '% Processor Time' THEN '% Processor Time - Consistent values over 85% suggests a processor bottleneck'
                       WHEN CounterDetails.CounterName = 'Pages/Sec' THEN 'Pages/Sec - Extended periods of 20 or greater suggests a memory bottleneck.' WHEN CounterDetails.CounterName
                       = 'Buffer cache hit ratio' THEN 'Buffer cache hit ratio - dipping below 85-95% suggests a memory bottleneck' WHEN CounterDetails.CounterName = '% Disk Time'
                       THEN '% Disk Time - Consistent periods exceeding 90% suggests an I/O bottleneck' ELSE CounterDetails.CounterName END AS CounterName, 
                      CAST(LEFT(dbo.CounterData.CounterDateTime, 19) AS smalldatetime) AS CounterDate, DATEPART(YEAR, 
                      CAST(LEFT(dbo.CounterData.CounterDateTime, 19) AS smalldatetime)) AS CounterYear, DATENAME(MONTH, 
                      CAST(LEFT(dbo.CounterData.CounterDateTime, 19) AS smalldatetime)) AS CounterMonth, DATENAME(WEEK, 
                      CAST(LEFT(dbo.CounterData.CounterDateTime, 19) AS smalldatetime)) AS CounterWeek, DATENAME(WEEKDAY, 
                      CAST(LEFT(dbo.CounterData.CounterDateTime, 19) AS smalldatetime)) AS CounterWeekDay, DATENAME(DAY, 
                      CAST(LEFT(dbo.CounterData.CounterDateTime, 19) AS smalldatetime)) AS CounterDay, CAST(CAST(DATEPART(HOUR, 
                      CAST(LEFT(dbo.CounterData.CounterDateTime, 19) AS smalldatetime)) AS varchar) + CAST(CASE WHEN datepart(MINUTE, 
                      (CAST(LEFT(CounterDateTime, 19) AS smalldatetime))) BETWEEN 1 AND 15 THEN 15 WHEN datepart(minute, (CAST(LEFT(CounterDateTime, 19) 
                      AS smalldatetime))) BETWEEN 16 AND 30 THEN 30 WHEN datepart(minute, (CAST(LEFT(CounterDateTime, 19) AS smalldatetime))) BETWEEN 31 AND 
                      45 THEN 45 ELSE 59 END AS varchar) AS int) AS CounterTime, ROUND(dbo.CounterData.CounterValue, 4) AS CounterValue
FROM         dbo.CounterData INNER JOIN
                      dbo.CounterDetails ON dbo.CounterDetails.CounterID = dbo.CounterData.CounterID
WHERE     (CAST(CAST(DATEPART(hour, CAST(LEFT(dbo.CounterData.CounterDateTime, 19) AS smalldatetime)) AS varchar) + CAST(CASE WHEN datepart(minute, 
                      (CAST(LEFT(CounterDateTime, 19) AS smalldatetime))) BETWEEN 1 AND 15 THEN 15 WHEN datepart(minute, (CAST(LEFT(CounterDateTime, 19) 
                      AS smalldatetime))) BETWEEN 16 AND 30 THEN 30 WHEN datepart(minute, (CAST(LEFT(CounterDateTime, 19) AS smalldatetime))) BETWEEN 31 AND 
                      45 THEN 45 ELSE 59 END AS varchar) AS int) BETWEEN 659 AND 1901) AND (dbo.CounterDetails.MachineName = '\\CHSXAMAP' OR dbo.CounterDetails.MachineName = '\\CHSXAREPP') AND 
                      (dbo.CounterDetails.CounterName LIKE '% Processor Time%' OR
                      dbo.CounterDetails.CounterName LIKE '% Disk Time%' OR
                      dbo.CounterDetails.CounterName LIKE '% Disk Write Time' OR
                      dbo.CounterDetails.CounterName = '% Disk Read Time' OR
                      dbo.CounterDetails.CounterName LIKE 'Buffer Cache Hit Ratio%' OR
                      dbo.CounterDetails.CounterName LIKE 'Pages/Sec%') AND (DATEPART(m, CAST(LEFT(dbo.CounterData.CounterDateTime, 19) AS smalldatetime)) 
                      = DATEPART(m, GETDATE())) AND (DATEPART(d, CAST(LEFT(dbo.CounterData.CounterDateTime, 19) AS smalldatetime)) >= DATEPART(d, DATEADD(day, - 7, GETDATE()))) AND
                       (DATEPART(yyyy, CAST(LEFT(dbo.CounterData.CounterDateTime, 19) AS smalldatetime)) = DATEPART(yyyy, GETDATE())) AND 
                      (dbo.CounterDetails.InstanceName = '_Total' OR
                      dbo.CounterDetails.InstanceName IS NULL)

GO
/****** Object:  View [dbo].[vSQLPerfSXAYesterday]    Script Date: 4/26/2016 11:40:48 AM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE VIEW [dbo].[vSQLPerfSXAYesterday]
AS
SELECT     dbo.CounterDetails.MachineName, dbo.CounterDetails.ObjectName, 
                      CASE WHEN CounterDetails.CounterName = '% Processor Time' THEN '% Processor Time - Consistent values over 85% suggests a processor bottleneck'
                       WHEN CounterDetails.CounterName = 'Pages/Sec' THEN 'Pages/Sec - Extended periods of 20 or greater suggests a memory bottleneck.' WHEN CounterDetails.CounterName
                       = 'Buffer cache hit ratio' THEN 'Buffer cache hit ratio - dipping below 85-95% suggests a memory bottleneck' WHEN CounterDetails.CounterName = '% Disk Time'
                       THEN '% Disk Time - Consistent periods exceeding 90% suggests an I/O bottleneck' ELSE CounterDetails.CounterName END AS CounterName, 
                      CAST(LEFT(dbo.CounterData.CounterDateTime, 19) AS smalldatetime) AS CounterDate, DATEPART(YEAR, 
                      CAST(LEFT(dbo.CounterData.CounterDateTime, 19) AS smalldatetime)) AS CounterYear, DATENAME(MONTH, 
                      CAST(LEFT(dbo.CounterData.CounterDateTime, 19) AS smalldatetime)) AS CounterMonth, DATENAME(WEEK, 
                      CAST(LEFT(dbo.CounterData.CounterDateTime, 19) AS smalldatetime)) AS CounterWeek, DATENAME(WEEKDAY, 
                      CAST(LEFT(dbo.CounterData.CounterDateTime, 19) AS smalldatetime)) AS CounterWeekDay, DATENAME(DAY, 
                      CAST(LEFT(dbo.CounterData.CounterDateTime, 19) AS smalldatetime)) AS CounterDay, CAST(CAST(DATEPART(HOUR, 
                      CAST(LEFT(dbo.CounterData.CounterDateTime, 19) AS smalldatetime)) AS varchar) + CAST(CASE WHEN datepart(MINUTE, 
                      (CAST(LEFT(CounterDateTime, 19) AS smalldatetime))) BETWEEN 1 AND 15 THEN 15 WHEN datepart(minute, (CAST(LEFT(CounterDateTime, 19) 
                      AS smalldatetime))) BETWEEN 16 AND 30 THEN 30 WHEN datepart(minute, (CAST(LEFT(CounterDateTime, 19) AS smalldatetime))) BETWEEN 31 AND 
                      45 THEN 45 ELSE 59 END AS varchar) AS int) AS CounterTime, ROUND(dbo.CounterData.CounterValue, 4) AS CounterValue, 
                      dbo.CounterDetails.InstanceName
FROM         dbo.CounterData INNER JOIN
                      dbo.CounterDetails ON dbo.CounterDetails.CounterID = dbo.CounterData.CounterID
WHERE     (DATEPART(m, CAST(LEFT(dbo.CounterData.CounterDateTime, 19) AS smalldatetime)) = DATEPART(m, GETDATE())) AND (DATEPART(d, 
                      CAST(LEFT(dbo.CounterData.CounterDateTime, 19) AS smalldatetime)) = DATEPART(d, DATEADD(day, - 1, GETDATE()))) AND (DATEPART(yyyy, 
                      CAST(LEFT(dbo.CounterData.CounterDateTime, 19) AS smalldatetime)) = DATEPART(yyyy, GETDATE())) AND 
                      (dbo.CounterDetails.InstanceName = '_Total' OR
                      dbo.CounterDetails.InstanceName IS NULL)

GO
/****** Object:  Index [SFSH_01]    Script Date: 4/26/2016 11:40:48 AM ******/
CREATE CLUSTERED INDEX [SFSH_01] ON [dbo].[ServerFreeSpaceHistory]
(
	[CheckDate] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, SORT_IN_TEMPDB = OFF, DROP_EXISTING = OFF, ONLINE = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, FILLFACTOR = 90) ON [PRIMARY]
GO
/****** Object:  Index [Event_Date_cnu]    Script Date: 4/26/2016 11:40:48 AM ******/
CREATE CLUSTERED INDEX [Event_Date_cnu] ON [dbo].[ServerHistory]
(
	[EventDate] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, SORT_IN_TEMPDB = OFF, DROP_EXISTING = OFF, ONLINE = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, FILLFACTOR = 90) ON [PRIMARY]
GO
/****** Object:  Index [IX_VISIT_DATE]    Script Date: 4/26/2016 11:40:48 AM ******/
CREATE CLUSTERED INDEX [IX_VISIT_DATE] ON [dbo].[WEBLOG]
(
	[VISIT_DATE] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, SORT_IN_TEMPDB = OFF, DROP_EXISTING = OFF, ONLINE = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
GO
SET ARITHABORT ON
SET CONCAT_NULL_YIELDS_NULL ON
SET QUOTED_IDENTIFIER ON
SET ANSI_NULLS ON
SET ANSI_PADDING ON
SET ANSI_WARNINGS ON
SET NUMERIC_ROUNDABORT OFF

GO
/****** Object:  Index [IDX_RFM_V]    Script Date: 4/26/2016 11:40:48 AM ******/
CREATE UNIQUE CLUSTERED INDEX [IDX_RFM_V] ON [dbo].[RFM]
(
	[COOKIE_ID] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, SORT_IN_TEMPDB = OFF, IGNORE_DUP_KEY = OFF, DROP_EXISTING = OFF, ONLINE = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
GO
SET ANSI_PADDING ON

GO
/****** Object:  Index [NonClusteredIndex-20160406-093228]    Script Date: 4/26/2016 11:40:48 AM ******/
CREATE NONCLUSTERED INDEX [NonClusteredIndex-20160406-093228] ON [dbo].[ColumnInfoMon]
(
	[servername] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, SORT_IN_TEMPDB = OFF, DROP_EXISTING = OFF, ONLINE = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
GO
SET ANSI_PADDING ON

GO
/****** Object:  Index [missing_index_727]    Script Date: 4/26/2016 11:40:48 AM ******/
CREATE NONCLUSTERED INDEX [missing_index_727] ON [dbo].[CounterData]
(
	[CounterID] ASC
)
INCLUDE ( 	[CounterDateTime],
	[CounterValue]) WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, SORT_IN_TEMPDB = OFF, DROP_EXISTING = OFF, ONLINE = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, FILLFACTOR = 90) ON [PRIMARY]
GO
SET ANSI_PADDING ON

GO
/****** Object:  Index [SFSH_02]    Script Date: 4/26/2016 11:40:48 AM ******/
CREATE NONCLUSTERED INDEX [SFSH_02] ON [dbo].[ServerFreeSpaceHistory]
(
	[ServerID] ASC,
	[Drive] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, SORT_IN_TEMPDB = OFF, DROP_EXISTING = OFF, ONLINE = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, FILLFACTOR = 90) ON [PRIMARY]
GO
SET ANSI_PADDING ON

GO
/****** Object:  Index [NonClusteredIndex-20160406-093314]    Script Date: 4/26/2016 11:40:48 AM ******/
CREATE NONCLUSTERED INDEX [NonClusteredIndex-20160406-093314] ON [dbo].[SrvrDbTblColMon]
(
	[ServerNm] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, SORT_IN_TEMPDB = OFF, DROP_EXISTING = OFF, ONLINE = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
GO
SET ANSI_PADDING ON

GO
/****** Object:  Index [NonClusteredIndex-20160406-093335]    Script Date: 4/26/2016 11:40:48 AM ******/
CREATE NONCLUSTERED INDEX [NonClusteredIndex-20160406-093335] ON [dbo].[SrvrDbTblColMon]
(
	[DbNm] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, SORT_IN_TEMPDB = OFF, DROP_EXISTING = OFF, ONLINE = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
GO
SET ANSI_PADDING ON

GO
/****** Object:  Index [ServerIndex]    Script Date: 4/26/2016 11:40:48 AM ******/
CREATE NONCLUSTERED INDEX [ServerIndex] ON [dbo].[tDbMessages]
(
	[Server] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, SORT_IN_TEMPDB = OFF, DROP_EXISTING = OFF, ONLINE = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, FILLFACTOR = 90) ON [PRIMARY]
GO
SET ANSI_PADDING ON

GO
/****** Object:  Index [missing_index_1650]    Script Date: 4/26/2016 11:40:48 AM ******/
CREATE NONCLUSTERED INDEX [missing_index_1650] ON [dbo].[tJobReport]
(
	[rundate] ASC,
	[runtime] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, SORT_IN_TEMPDB = OFF, DROP_EXISTING = OFF, ONLINE = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, FILLFACTOR = 90) ON [PRIMARY]
GO
/****** Object:  Index [IX_RFM]    Script Date: 4/26/2016 11:40:48 AM ******/
CREATE NONCLUSTERED INDEX [IX_RFM] ON [dbo].[WEBLOG]
(
	[COOKIE_ID] ASC
)
INCLUDE ( 	[TRANSACTION_VALUE]) WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, SORT_IN_TEMPDB = OFF, DROP_EXISTING = OFF, ONLINE = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
GO
ALTER TABLE [dbo].[DataAndLogFilesMon] ADD  CONSTRAINT [DF_DataAndLogFilesMon_Dtm]  DEFAULT (getdate()) FOR [Dtm]
GO
ALTER TABLE [dbo].[dba_indexDefragStatus] ADD  DEFAULT ((0)) FOR [printStatus]
GO
ALTER TABLE [dbo].[dba_indexDefragStatus] ADD  DEFAULT ((0)) FOR [exclusionMask]
GO
ALTER TABLE [dbo].[FilesMon] ADD  CONSTRAINT [DF_FilesMon_Dtm]  DEFAULT (getdate()) FOR [Dtm]
GO
ALTER TABLE [dbo].[ServerErrorLog] ADD  CONSTRAINT [DF_Serv__Inser__182C9B23]  DEFAULT (getdate()) FOR [InsertDate]
GO
ALTER TABLE [dbo].[ServerFreeSpaceHistory] ADD  CONSTRAINT [DF__Serv__Check__59063A47]  DEFAULT (getdate()) FOR [CheckDate]
GO
ALTER TABLE [dbo].[ServerHistory] ADD  CONSTRAINT [DF__Serv__Inser__24927208]  DEFAULT (getdate()) FOR [InsertDate]
GO
ALTER TABLE [dbo].[tAdminChk] ADD  CONSTRAINT [DF_tAdminChk_LastUpdated]  DEFAULT (getdate()) FOR [LastUpdated]
GO
ALTER TABLE [dbo].[tBackupChk] ADD  CONSTRAINT [DF_tBackupChk_LastUpdated]  DEFAULT (getdate()) FOR [LastUpdated]
GO
ALTER TABLE [dbo].[tBackupInfo] ADD  CONSTRAINT [DF_tBackupInfo_LastUpdated]  DEFAULT (getdate()) FOR [LastUpdated]
GO
ALTER TABLE [dbo].[tDbaSec] ADD  CONSTRAINT [DF_tDbaSec_Active]  DEFAULT ('Y') FOR [Active]
GO
ALTER TABLE [dbo].[tDbMessages] ADD  CONSTRAINT [DF_tDbMessages_LastUpdated]  DEFAULT (getdate()) FOR [LastUpdated]
GO
ALTER TABLE [dbo].[tDbSizeHist] ADD  CONSTRAINT [DF_tDbSizeHist_LastUpdated]  DEFAULT (getdate()) FOR [LastUpdated]
GO
ALTER TABLE [dbo].[tDbSpaceChk] ADD  CONSTRAINT [DF_tDbSpaceChk_LastUpdated]  DEFAULT (getdate()) FOR [LastUpdated]
GO
ALTER TABLE [dbo].[tDriveInfo] ADD  CONSTRAINT [DF_tDriveInfo_LastUpdated]  DEFAULT (getdate()) FOR [LastUpdated]
GO
ALTER TABLE [dbo].[tDriveSpaceChk] ADD  CONSTRAINT [DF_tDriveSpaceChk_LastUpdated]  DEFAULT (getdate()) FOR [LastUpdated]
GO
ALTER TABLE [dbo].[tFreeSpace] ADD  CONSTRAINT [DF_FreeSpace_Date]  DEFAULT (getdate()) FOR [Date]
GO
ALTER TABLE [dbo].[tJobList] ADD  CONSTRAINT [DF_tJobList_LastUpdated]  DEFAULT (getdate()) FOR [LastUpdated]
GO
ALTER TABLE [dbo].[tJobReport] ADD  CONSTRAINT [DF_tJobReport_LastUpdated]  DEFAULT (getdate()) FOR [LastUpdated]
GO
ALTER TABLE [dbo].[tMyDbs] ADD  CONSTRAINT [DF_tMyDbs_LastUpdated]  DEFAULT (getdate()) FOR [LastUpdated]
GO
ALTER TABLE [dbo].[tTableSpace] ADD  CONSTRAINT [DF_tTableSpace_LastUpdated]  DEFAULT (getdate()) FOR [LastUpdated]
GO
ALTER TABLE [dbo].[WorstSPMon] ADD  CONSTRAINT [DF_WorstSPMon_Dtm]  DEFAULT (getdate()) FOR [Dtm]
GO
ALTER TABLE [dbo].[ServerDriveCapacity]  WITH CHECK ADD  CONSTRAINT [fk_01] FOREIGN KEY([ServerID])
REFERENCES [dbo].[Server] ([ServerID])
GO
ALTER TABLE [dbo].[ServerDriveCapacity] CHECK CONSTRAINT [fk_01]
GO
EXEC sys.sp_addextendedproperty @name=N'MS_DiagramPane1', @value=N'[0E232FF0-B466-11cf-A24F-00AA00A3EFFF, 1.00]
Begin DesignProperties = 
   Begin PaneConfigurations = 
      Begin PaneConfiguration = 0
         NumPanes = 4
         Configuration = "(H (1[40] 4[20] 2[20] 3) )"
      End
      Begin PaneConfiguration = 1
         NumPanes = 3
         Configuration = "(H (1 [50] 4 [25] 3))"
      End
      Begin PaneConfiguration = 2
         NumPanes = 3
         Configuration = "(H (1 [50] 2 [25] 3))"
      End
      Begin PaneConfiguration = 3
         NumPanes = 3
         Configuration = "(H (4 [30] 2 [40] 3))"
      End
      Begin PaneConfiguration = 4
         NumPanes = 2
         Configuration = "(H (1 [56] 3))"
      End
      Begin PaneConfiguration = 5
         NumPanes = 2
         Configuration = "(H (2 [66] 3))"
      End
      Begin PaneConfiguration = 6
         NumPanes = 2
         Configuration = "(H (4 [50] 3))"
      End
      Begin PaneConfiguration = 7
         NumPanes = 1
         Configuration = "(V (3))"
      End
      Begin PaneConfiguration = 8
         NumPanes = 3
         Configuration = "(H (1[56] 4[18] 2) )"
      End
      Begin PaneConfiguration = 9
         NumPanes = 2
         Configuration = "(H (1 [75] 4))"
      End
      Begin PaneConfiguration = 10
         NumPanes = 2
         Configuration = "(H (1[66] 2) )"
      End
      Begin PaneConfiguration = 11
         NumPanes = 2
         Configuration = "(H (4 [60] 2))"
      End
      Begin PaneConfiguration = 12
         NumPanes = 1
         Configuration = "(H (1) )"
      End
      Begin PaneConfiguration = 13
         NumPanes = 1
         Configuration = "(V (4))"
      End
      Begin PaneConfiguration = 14
         NumPanes = 1
         Configuration = "(V (2))"
      End
      ActivePaneConfig = 0
   End
   Begin DiagramPane = 
      Begin Origin = 
         Top = 0
         Left = 0
      End
      Begin Tables = 
         Begin Table = "CounterData"
            Begin Extent = 
               Top = 6
               Left = 38
               Bottom = 114
               Right = 202
            End
            DisplayFlags = 280
            TopColumn = 0
         End
         Begin Table = "CounterDetails"
            Begin Extent = 
               Top = 6
               Left = 240
               Bottom = 114
               Right = 395
            End
            DisplayFlags = 280
            TopColumn = 0
         End
      End
   End
   Begin SQLPane = 
   End
   Begin DataPane = 
      Begin ParameterDefaults = ""
      End
   End
   Begin CriteriaPane = 
      Begin ColumnWidths = 11
         Column = 1440
         Alias = 900
         Table = 1170
         Output = 720
         Append = 1400
         NewValue = 1170
         SortType = 1350
         SortOrder = 1410
         GroupBy = 1350
         Filter = 1350
         Or = 1350
         Or = 1350
         Or = 1350
      End
   End
End
' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'VIEW',@level1name=N'2007SxaPerfData'
GO
EXEC sys.sp_addextendedproperty @name=N'MS_DiagramPaneCount', @value=1 , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'VIEW',@level1name=N'2007SxaPerfData'
GO
EXEC sys.sp_addextendedproperty @name=N'MS_DiagramPane1', @value=N'[0E232FF0-B466-11cf-A24F-00AA00A3EFFF, 1.00]
Begin DesignProperties = 
   Begin PaneConfigurations = 
      Begin PaneConfiguration = 0
         NumPanes = 4
         Configuration = "(H (1[40] 4[20] 2[20] 3) )"
      End
      Begin PaneConfiguration = 1
         NumPanes = 3
         Configuration = "(H (1 [50] 4 [25] 3))"
      End
      Begin PaneConfiguration = 2
         NumPanes = 3
         Configuration = "(H (1[50] 2[25] 3) )"
      End
      Begin PaneConfiguration = 3
         NumPanes = 3
         Configuration = "(H (4 [30] 2 [40] 3))"
      End
      Begin PaneConfiguration = 4
         NumPanes = 2
         Configuration = "(H (1 [56] 3))"
      End
      Begin PaneConfiguration = 5
         NumPanes = 2
         Configuration = "(H (2[17] 3) )"
      End
      Begin PaneConfiguration = 6
         NumPanes = 2
         Configuration = "(H (4 [50] 3))"
      End
      Begin PaneConfiguration = 7
         NumPanes = 1
         Configuration = "(V (3))"
      End
      Begin PaneConfiguration = 8
         NumPanes = 3
         Configuration = "(H (1[56] 4[18] 2) )"
      End
      Begin PaneConfiguration = 9
         NumPanes = 2
         Configuration = "(H (1 [75] 4))"
      End
      Begin PaneConfiguration = 10
         NumPanes = 2
         Configuration = "(H (1[66] 2) )"
      End
      Begin PaneConfiguration = 11
         NumPanes = 2
         Configuration = "(H (4 [60] 2))"
      End
      Begin PaneConfiguration = 12
         NumPanes = 1
         Configuration = "(H (1) )"
      End
      Begin PaneConfiguration = 13
         NumPanes = 1
         Configuration = "(V (4))"
      End
      Begin PaneConfiguration = 14
         NumPanes = 1
         Configuration = "(V (2))"
      End
      ActivePaneConfig = 2
   End
   Begin DiagramPane = 
      Begin Origin = 
         Top = 0
         Left = 0
      End
      Begin Tables = 
         Begin Table = "SrvrDbTblColMon"
            Begin Extent = 
               Top = 6
               Left = 227
               Bottom = 247
               Right = 378
            End
            DisplayFlags = 280
            TopColumn = 0
         End
         Begin Table = "ColumnInfoMon"
            Begin Extent = 
               Top = 6
               Left = 38
               Bottom = 251
               Right = 189
            End
            DisplayFlags = 280
            TopColumn = 0
         End
      End
   End
   Begin SQLPane = 
   End
   Begin DataPane = 
      Begin ParameterDefaults = ""
      End
      Begin ColumnWidths = 10
         Width = 284
         Width = 2685
         Width = 1500
         Width = 1500
         Width = 1500
         Width = 1500
         Width = 1500
         Width = 1500
         Width = 1500
         Width = 1500
      End
   End
   Begin CriteriaPane = 
      PaneHidden = 
      Begin ColumnWidths = 11
         Column = 1440
         Alias = 900
         Table = 1170
         Output = 720
         Append = 1400
         NewValue = 1170
         SortType = 1350
         SortOrder = 1410
         GroupBy = 1350
         Filter = 1350
         Or = 1350
         Or = 1350
         Or = 1350
      End
   End
End
' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'VIEW',@level1name=N'MonColInfo'
GO
EXEC sys.sp_addextendedproperty @name=N'MS_DiagramPaneCount', @value=1 , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'VIEW',@level1name=N'MonColInfo'
GO
EXEC sys.sp_addextendedproperty @name=N'MS_DiagramPane1', @value=N'[0E232FF0-B466-11cf-A24F-00AA00A3EFFF, 1.00]
Begin DesignProperties = 
   Begin PaneConfigurations = 
      Begin PaneConfiguration = 0
         NumPanes = 4
         Configuration = "(H (1[40] 4[20] 2[20] 3) )"
      End
      Begin PaneConfiguration = 1
         NumPanes = 3
         Configuration = "(H (1 [50] 4 [25] 3))"
      End
      Begin PaneConfiguration = 2
         NumPanes = 3
         Configuration = "(H (1[50] 2[25] 3) )"
      End
      Begin PaneConfiguration = 3
         NumPanes = 3
         Configuration = "(H (4 [30] 2 [40] 3))"
      End
      Begin PaneConfiguration = 4
         NumPanes = 2
         Configuration = "(H (1 [56] 3))"
      End
      Begin PaneConfiguration = 5
         NumPanes = 2
         Configuration = "(H (2[24] 3) )"
      End
      Begin PaneConfiguration = 6
         NumPanes = 2
         Configuration = "(H (4 [50] 3))"
      End
      Begin PaneConfiguration = 7
         NumPanes = 1
         Configuration = "(V (3))"
      End
      Begin PaneConfiguration = 8
         NumPanes = 3
         Configuration = "(H (1[56] 4[18] 2) )"
      End
      Begin PaneConfiguration = 9
         NumPanes = 2
         Configuration = "(H (1 [75] 4))"
      End
      Begin PaneConfiguration = 10
         NumPanes = 2
         Configuration = "(H (1[66] 2) )"
      End
      Begin PaneConfiguration = 11
         NumPanes = 2
         Configuration = "(H (4 [60] 2))"
      End
      Begin PaneConfiguration = 12
         NumPanes = 1
         Configuration = "(H (1) )"
      End
      Begin PaneConfiguration = 13
         NumPanes = 1
         Configuration = "(V (4))"
      End
      Begin PaneConfiguration = 14
         NumPanes = 1
         Configuration = "(V (2))"
      End
      ActivePaneConfig = 5
   End
   Begin DiagramPane = 
      PaneHidden = 
      Begin Origin = 
         Top = 0
         Left = 0
      End
      Begin Tables = 
         Begin Table = "FilesMon"
            Begin Extent = 
               Top = 6
               Left = 38
               Bottom = 255
               Right = 202
            End
            DisplayFlags = 280
            TopColumn = 0
         End
      End
   End
   Begin SQLPane = 
   End
   Begin DataPane = 
      Begin ParameterDefaults = ""
      End
      Begin ColumnWidths = 9
         Width = 284
         Width = 1500
         Width = 1500
         Width = 1500
         Width = 1500
         Width = 1500
         Width = 1500
         Width = 1500
         Width = 1500
      End
   End
   Begin CriteriaPane = 
      PaneHidden = 
      Begin ColumnWidths = 12
         Column = 1440
         Alias = 900
         Table = 1170
         Output = 720
         Append = 1400
         NewValue = 1170
         SortType = 1350
         SortOrder = 1410
         GroupBy = 1350
         Filter = 1350
         Or = 1350
         Or = 1350
         Or = 1350
      End
   End
End
' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'VIEW',@level1name=N'MonDataMB'
GO
EXEC sys.sp_addextendedproperty @name=N'MS_DiagramPaneCount', @value=1 , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'VIEW',@level1name=N'MonDataMB'
GO
EXEC sys.sp_addextendedproperty @name=N'MS_DiagramPane1', @value=N'[0E232FF0-B466-11cf-A24F-00AA00A3EFFF, 1.00]
Begin DesignProperties = 
   Begin PaneConfigurations = 
      Begin PaneConfiguration = 0
         NumPanes = 4
         Configuration = "(H (1[40] 4[20] 2[20] 3) )"
      End
      Begin PaneConfiguration = 1
         NumPanes = 3
         Configuration = "(H (1 [50] 4 [25] 3))"
      End
      Begin PaneConfiguration = 2
         NumPanes = 3
         Configuration = "(H (1 [50] 2 [25] 3))"
      End
      Begin PaneConfiguration = 3
         NumPanes = 3
         Configuration = "(H (4[30] 2[40] 3) )"
      End
      Begin PaneConfiguration = 4
         NumPanes = 2
         Configuration = "(H (1 [56] 3))"
      End
      Begin PaneConfiguration = 5
         NumPanes = 2
         Configuration = "(H (2[24] 3) )"
      End
      Begin PaneConfiguration = 6
         NumPanes = 2
         Configuration = "(H (4 [50] 3))"
      End
      Begin PaneConfiguration = 7
         NumPanes = 1
         Configuration = "(V (3))"
      End
      Begin PaneConfiguration = 8
         NumPanes = 3
         Configuration = "(H (1[56] 4[18] 2) )"
      End
      Begin PaneConfiguration = 9
         NumPanes = 2
         Configuration = "(H (1 [75] 4))"
      End
      Begin PaneConfiguration = 10
         NumPanes = 2
         Configuration = "(H (1[66] 2) )"
      End
      Begin PaneConfiguration = 11
         NumPanes = 2
         Configuration = "(H (4 [60] 2))"
      End
      Begin PaneConfiguration = 12
         NumPanes = 1
         Configuration = "(H (1) )"
      End
      Begin PaneConfiguration = 13
         NumPanes = 1
         Configuration = "(V (4))"
      End
      Begin PaneConfiguration = 14
         NumPanes = 1
         Configuration = "(V (2))"
      End
      ActivePaneConfig = 5
   End
   Begin DiagramPane = 
      PaneHidden = 
      Begin Origin = 
         Top = 0
         Left = 0
      End
      Begin Tables = 
         Begin Table = "FilesMon"
            Begin Extent = 
               Top = 6
               Left = 38
               Bottom = 114
               Right = 218
            End
            DisplayFlags = 280
            TopColumn = 0
         End
      End
   End
   Begin SQLPane = 
   End
   Begin DataPane = 
      Begin ParameterDefaults = ""
      End
      Begin ColumnWidths = 9
         Width = 284
         Width = 1500
         Width = 1500
         Width = 1500
         Width = 1500
         Width = 1500
         Width = 1500
         Width = 1500
         Width = 1500
      End
   End
   Begin CriteriaPane = 
      PaneHidden = 
      Begin ColumnWidths = 12
         Column = 1440
         Alias = 900
         Table = 1170
         Output = 720
         Append = 1400
         NewValue = 1170
         SortType = 1350
         SortOrder = 1410
         GroupBy = 1350
         Filter = 1350
         Or = 1350
         Or = 1350
         Or = 1350
      End
   End
End
' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'VIEW',@level1name=N'MonDBDataMB'
GO
EXEC sys.sp_addextendedproperty @name=N'MS_DiagramPaneCount', @value=1 , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'VIEW',@level1name=N'MonDBDataMB'
GO
EXEC sys.sp_addextendedproperty @name=N'MS_DiagramPane1', @value=N'[0E232FF0-B466-11cf-A24F-00AA00A3EFFF, 1.00]
Begin DesignProperties = 
   Begin PaneConfigurations = 
      Begin PaneConfiguration = 0
         NumPanes = 4
         Configuration = "(H (1[40] 4[20] 2[20] 3) )"
      End
      Begin PaneConfiguration = 1
         NumPanes = 3
         Configuration = "(H (1 [50] 4 [25] 3))"
      End
      Begin PaneConfiguration = 2
         NumPanes = 3
         Configuration = "(H (1 [50] 2 [25] 3))"
      End
      Begin PaneConfiguration = 3
         NumPanes = 3
         Configuration = "(H (4[30] 2[40] 3) )"
      End
      Begin PaneConfiguration = 4
         NumPanes = 2
         Configuration = "(H (1 [56] 3))"
      End
      Begin PaneConfiguration = 5
         NumPanes = 2
         Configuration = "(H (2[66] 3) )"
      End
      Begin PaneConfiguration = 6
         NumPanes = 2
         Configuration = "(H (4 [50] 3))"
      End
      Begin PaneConfiguration = 7
         NumPanes = 1
         Configuration = "(V (3))"
      End
      Begin PaneConfiguration = 8
         NumPanes = 3
         Configuration = "(H (1[56] 4[18] 2) )"
      End
      Begin PaneConfiguration = 9
         NumPanes = 2
         Configuration = "(H (1 [75] 4))"
      End
      Begin PaneConfiguration = 10
         NumPanes = 2
         Configuration = "(H (1[66] 2) )"
      End
      Begin PaneConfiguration = 11
         NumPanes = 2
         Configuration = "(H (4 [60] 2))"
      End
      Begin PaneConfiguration = 12
         NumPanes = 1
         Configuration = "(H (1) )"
      End
      Begin PaneConfiguration = 13
         NumPanes = 1
         Configuration = "(V (4))"
      End
      Begin PaneConfiguration = 14
         NumPanes = 1
         Configuration = "(V (2))"
      End
      ActivePaneConfig = 5
   End
   Begin DiagramPane = 
      PaneHidden = 
      Begin Origin = 
         Top = 0
         Left = 0
      End
      Begin Tables = 
         Begin Table = "IndexListMon"
            Begin Extent = 
               Top = 6
               Left = 38
               Bottom = 114
               Right = 205
            End
            DisplayFlags = 280
            TopColumn = 0
         End
      End
   End
   Begin SQLPane = 
   End
   Begin DataPane = 
      Begin ParameterDefaults = ""
      End
      Begin ColumnWidths = 9
         Width = 284
         Width = 1500
         Width = 1500
         Width = 1500
         Width = 1500
         Width = 1500
         Width = 1500
         Width = 1500
         Width = 1500
      End
   End
   Begin CriteriaPane = 
      PaneHidden = 
      Begin ColumnWidths = 12
         Column = 1440
         Alias = 900
         Table = 1170
         Output = 720
         Append = 1400
         NewValue = 1170
         SortType = 1350
         SortOrder = 1410
         GroupBy = 1350
         Filter = 1350
         Or = 1350
         Or = 1350
         Or = 1350
      End
   End
End
' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'VIEW',@level1name=N'MonDBIndexCount'
GO
EXEC sys.sp_addextendedproperty @name=N'MS_DiagramPaneCount', @value=1 , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'VIEW',@level1name=N'MonDBIndexCount'
GO
EXEC sys.sp_addextendedproperty @name=N'MS_DiagramPane1', @value=N'[0E232FF0-B466-11cf-A24F-00AA00A3EFFF, 1.00]
Begin DesignProperties = 
   Begin PaneConfigurations = 
      Begin PaneConfiguration = 0
         NumPanes = 4
         Configuration = "(H (1[40] 4[20] 2[20] 3) )"
      End
      Begin PaneConfiguration = 1
         NumPanes = 3
         Configuration = "(H (1 [50] 4 [25] 3))"
      End
      Begin PaneConfiguration = 2
         NumPanes = 3
         Configuration = "(H (1 [50] 2 [25] 3))"
      End
      Begin PaneConfiguration = 3
         NumPanes = 3
         Configuration = "(H (4[30] 2[40] 3) )"
      End
      Begin PaneConfiguration = 4
         NumPanes = 2
         Configuration = "(H (1 [56] 3))"
      End
      Begin PaneConfiguration = 5
         NumPanes = 2
         Configuration = "(H (2[66] 3) )"
      End
      Begin PaneConfiguration = 6
         NumPanes = 2
         Configuration = "(H (4 [50] 3))"
      End
      Begin PaneConfiguration = 7
         NumPanes = 1
         Configuration = "(V (3))"
      End
      Begin PaneConfiguration = 8
         NumPanes = 3
         Configuration = "(H (1[56] 4[18] 2) )"
      End
      Begin PaneConfiguration = 9
         NumPanes = 2
         Configuration = "(H (1 [75] 4))"
      End
      Begin PaneConfiguration = 10
         NumPanes = 2
         Configuration = "(H (1[66] 2) )"
      End
      Begin PaneConfiguration = 11
         NumPanes = 2
         Configuration = "(H (4 [60] 2))"
      End
      Begin PaneConfiguration = 12
         NumPanes = 1
         Configuration = "(H (1) )"
      End
      Begin PaneConfiguration = 13
         NumPanes = 1
         Configuration = "(V (4))"
      End
      Begin PaneConfiguration = 14
         NumPanes = 1
         Configuration = "(V (2))"
      End
      ActivePaneConfig = 5
   End
   Begin DiagramPane = 
      PaneHidden = 
      Begin Origin = 
         Top = 0
         Left = 0
      End
      Begin Tables = 
         Begin Table = "DataAndLogFilesMon"
            Begin Extent = 
               Top = 6
               Left = 38
               Bottom = 114
               Right = 205
            End
            DisplayFlags = 280
            TopColumn = 0
         End
      End
   End
   Begin SQLPane = 
   End
   Begin DataPane = 
      Begin ParameterDefaults = ""
      End
      Begin ColumnWidths = 9
         Width = 284
         Width = 1500
         Width = 1500
         Width = 1500
         Width = 1500
         Width = 1500
         Width = 1500
         Width = 1500
         Width = 1500
      End
   End
   Begin CriteriaPane = 
      PaneHidden = 
      Begin ColumnWidths = 12
         Column = 1440
         Alias = 900
         Table = 1170
         Output = 720
         Append = 1400
         NewValue = 1170
         SortType = 1350
         SortOrder = 1410
         GroupBy = 1350
         Filter = 1350
         Or = 1350
         Or = 1350
         Or = 1350
      End
   End
End
' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'VIEW',@level1name=N'MonDBLogData'
GO
EXEC sys.sp_addextendedproperty @name=N'MS_DiagramPaneCount', @value=1 , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'VIEW',@level1name=N'MonDBLogData'
GO
EXEC sys.sp_addextendedproperty @name=N'MS_DiagramPane1', @value=N'[0E232FF0-B466-11cf-A24F-00AA00A3EFFF, 1.00]
Begin DesignProperties = 
   Begin PaneConfigurations = 
      Begin PaneConfiguration = 0
         NumPanes = 4
         Configuration = "(H (1[40] 4[20] 2[20] 3) )"
      End
      Begin PaneConfiguration = 1
         NumPanes = 3
         Configuration = "(H (1 [50] 4 [25] 3))"
      End
      Begin PaneConfiguration = 2
         NumPanes = 3
         Configuration = "(H (1[50] 2[25] 3) )"
      End
      Begin PaneConfiguration = 3
         NumPanes = 3
         Configuration = "(H (4 [30] 2 [40] 3))"
      End
      Begin PaneConfiguration = 4
         NumPanes = 2
         Configuration = "(H (1 [56] 3))"
      End
      Begin PaneConfiguration = 5
         NumPanes = 2
         Configuration = "(H (2[66] 3) )"
      End
      Begin PaneConfiguration = 6
         NumPanes = 2
         Configuration = "(H (4 [50] 3))"
      End
      Begin PaneConfiguration = 7
         NumPanes = 1
         Configuration = "(V (3))"
      End
      Begin PaneConfiguration = 8
         NumPanes = 3
         Configuration = "(H (1[56] 4[18] 2) )"
      End
      Begin PaneConfiguration = 9
         NumPanes = 2
         Configuration = "(H (1 [75] 4))"
      End
      Begin PaneConfiguration = 10
         NumPanes = 2
         Configuration = "(H (1[66] 2) )"
      End
      Begin PaneConfiguration = 11
         NumPanes = 2
         Configuration = "(H (4 [60] 2))"
      End
      Begin PaneConfiguration = 12
         NumPanes = 1
         Configuration = "(H (1) )"
      End
      Begin PaneConfiguration = 13
         NumPanes = 1
         Configuration = "(V (4))"
      End
      Begin PaneConfiguration = 14
         NumPanes = 1
         Configuration = "(V (2))"
      End
      ActivePaneConfig = 5
   End
   Begin DiagramPane = 
      PaneHidden = 
      Begin Origin = 
         Top = 0
         Left = 0
      End
      Begin Tables = 
         Begin Table = "IdxFragMon"
            Begin Extent = 
               Top = 6
               Left = 38
               Bottom = 114
               Right = 212
            End
            DisplayFlags = 280
            TopColumn = 0
         End
      End
   End
   Begin SQLPane = 
   End
   Begin DataPane = 
      Begin ParameterDefaults = ""
      End
   End
   Begin CriteriaPane = 
      PaneHidden = 
      Begin ColumnWidths = 12
         Column = 1440
         Alias = 900
         Table = 1170
         Output = 720
         Append = 1400
         NewValue = 1170
         SortType = 1350
         SortOrder = 1410
         GroupBy = 1350
         Filter = 1350
         Or = 1350
         Or = 1350
         Or = 1350
      End
   End
End
' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'VIEW',@level1name=N'MonFraggedIndexes'
GO
EXEC sys.sp_addextendedproperty @name=N'MS_DiagramPaneCount', @value=1 , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'VIEW',@level1name=N'MonFraggedIndexes'
GO
EXEC sys.sp_addextendedproperty @name=N'MS_DiagramPane1', @value=N'[0E232FF0-B466-11cf-A24F-00AA00A3EFFF, 1.00]
Begin DesignProperties = 
   Begin PaneConfigurations = 
      Begin PaneConfiguration = 0
         NumPanes = 4
         Configuration = "(H (1[40] 4[20] 2[20] 3) )"
      End
      Begin PaneConfiguration = 1
         NumPanes = 3
         Configuration = "(H (1 [50] 4 [25] 3))"
      End
      Begin PaneConfiguration = 2
         NumPanes = 3
         Configuration = "(H (1[50] 2[25] 3) )"
      End
      Begin PaneConfiguration = 3
         NumPanes = 3
         Configuration = "(H (4 [30] 2 [40] 3))"
      End
      Begin PaneConfiguration = 4
         NumPanes = 2
         Configuration = "(H (1 [56] 3))"
      End
      Begin PaneConfiguration = 5
         NumPanes = 2
         Configuration = "(H (2[66] 3) )"
      End
      Begin PaneConfiguration = 6
         NumPanes = 2
         Configuration = "(H (4 [50] 3))"
      End
      Begin PaneConfiguration = 7
         NumPanes = 1
         Configuration = "(V (3))"
      End
      Begin PaneConfiguration = 8
         NumPanes = 3
         Configuration = "(H (1[56] 4[18] 2) )"
      End
      Begin PaneConfiguration = 9
         NumPanes = 2
         Configuration = "(H (1 [75] 4))"
      End
      Begin PaneConfiguration = 10
         NumPanes = 2
         Configuration = "(H (1[66] 2) )"
      End
      Begin PaneConfiguration = 11
         NumPanes = 2
         Configuration = "(H (4 [60] 2))"
      End
      Begin PaneConfiguration = 12
         NumPanes = 1
         Configuration = "(H (1) )"
      End
      Begin PaneConfiguration = 13
         NumPanes = 1
         Configuration = "(V (4))"
      End
      Begin PaneConfiguration = 14
         NumPanes = 1
         Configuration = "(V (2))"
      End
      ActivePaneConfig = 5
   End
   Begin DiagramPane = 
      PaneHidden = 
      Begin Origin = 
         Top = 0
         Left = 0
      End
      Begin Tables = 
         Begin Table = "IndexListMon"
            Begin Extent = 
               Top = 6
               Left = 38
               Bottom = 114
               Right = 205
            End
            DisplayFlags = 280
            TopColumn = 0
         End
      End
   End
   Begin SQLPane = 
   End
   Begin DataPane = 
      Begin ParameterDefaults = ""
      End
   End
   Begin CriteriaPane = 
      PaneHidden = 
      Begin ColumnWidths = 12
         Column = 1440
         Alias = 900
         Table = 1170
         Output = 720
         Append = 1400
         NewValue = 1170
         SortType = 1350
         SortOrder = 1410
         GroupBy = 1350
         Filter = 1350
         Or = 1350
         Or = 1350
         Or = 1350
      End
   End
End
' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'VIEW',@level1name=N'MonIndexList'
GO
EXEC sys.sp_addextendedproperty @name=N'MS_DiagramPaneCount', @value=1 , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'VIEW',@level1name=N'MonIndexList'
GO
EXEC sys.sp_addextendedproperty @name=N'MS_DiagramPane1', @value=N'[0E232FF0-B466-11cf-A24F-00AA00A3EFFF, 1.00]
Begin DesignProperties = 
   Begin PaneConfigurations = 
      Begin PaneConfiguration = 0
         NumPanes = 4
         Configuration = "(H (1[40] 4[20] 2[20] 3) )"
      End
      Begin PaneConfiguration = 1
         NumPanes = 3
         Configuration = "(H (1 [50] 4 [25] 3))"
      End
      Begin PaneConfiguration = 2
         NumPanes = 3
         Configuration = "(H (1 [50] 2 [25] 3))"
      End
      Begin PaneConfiguration = 3
         NumPanes = 3
         Configuration = "(H (4[30] 2[40] 3) )"
      End
      Begin PaneConfiguration = 4
         NumPanes = 2
         Configuration = "(H (1 [56] 3))"
      End
      Begin PaneConfiguration = 5
         NumPanes = 2
         Configuration = "(H (2[66] 3) )"
      End
      Begin PaneConfiguration = 6
         NumPanes = 2
         Configuration = "(H (4 [50] 3))"
      End
      Begin PaneConfiguration = 7
         NumPanes = 1
         Configuration = "(V (3))"
      End
      Begin PaneConfiguration = 8
         NumPanes = 3
         Configuration = "(H (1[56] 4[18] 2) )"
      End
      Begin PaneConfiguration = 9
         NumPanes = 2
         Configuration = "(H (1 [75] 4))"
      End
      Begin PaneConfiguration = 10
         NumPanes = 2
         Configuration = "(H (1[66] 2) )"
      End
      Begin PaneConfiguration = 11
         NumPanes = 2
         Configuration = "(H (4 [60] 2))"
      End
      Begin PaneConfiguration = 12
         NumPanes = 1
         Configuration = "(H (1) )"
      End
      Begin PaneConfiguration = 13
         NumPanes = 1
         Configuration = "(V (4))"
      End
      Begin PaneConfiguration = 14
         NumPanes = 1
         Configuration = "(V (2))"
      End
      ActivePaneConfig = 5
   End
   Begin DiagramPane = 
      PaneHidden = 
      Begin Origin = 
         Top = 0
         Left = 0
      End
      Begin Tables = 
      End
   End
   Begin SQLPane = 
   End
   Begin DataPane = 
      Begin ParameterDefaults = ""
      End
      Begin ColumnWidths = 9
         Width = 284
         Width = 1500
         Width = 1500
         Width = 1500
         Width = 1500
         Width = 1500
         Width = 1500
         Width = 1500
         Width = 1500
      End
   End
   Begin CriteriaPane = 
      PaneHidden = 
      Begin ColumnWidths = 11
         Column = 1440
         Alias = 900
         Table = 1170
         Output = 720
         Append = 1400
         NewValue = 1170
         SortType = 1350
         SortOrder = 1410
         GroupBy = 1350
         Filter = 1350
         Or = 1350
         Or = 1350
         Or = 1350
      End
   End
End
' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'VIEW',@level1name=N'MonInstanceList'
GO
EXEC sys.sp_addextendedproperty @name=N'MS_DiagramPaneCount', @value=1 , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'VIEW',@level1name=N'MonInstanceList'
GO
EXEC sys.sp_addextendedproperty @name=N'MS_DiagramPane1', @value=N'[0E232FF0-B466-11cf-A24F-00AA00A3EFFF, 1.00]
Begin DesignProperties = 
   Begin PaneConfigurations = 
      Begin PaneConfiguration = 0
         NumPanes = 4
         Configuration = "(H (1[40] 4[20] 2[20] 3) )"
      End
      Begin PaneConfiguration = 1
         NumPanes = 3
         Configuration = "(H (1 [50] 4 [25] 3))"
      End
      Begin PaneConfiguration = 2
         NumPanes = 3
         Configuration = "(H (1 [50] 2 [25] 3))"
      End
      Begin PaneConfiguration = 3
         NumPanes = 3
         Configuration = "(H (4[30] 2[40] 3) )"
      End
      Begin PaneConfiguration = 4
         NumPanes = 2
         Configuration = "(H (1 [56] 3))"
      End
      Begin PaneConfiguration = 5
         NumPanes = 2
         Configuration = "(H (2[21] 3) )"
      End
      Begin PaneConfiguration = 6
         NumPanes = 2
         Configuration = "(H (4 [50] 3))"
      End
      Begin PaneConfiguration = 7
         NumPanes = 1
         Configuration = "(V (3))"
      End
      Begin PaneConfiguration = 8
         NumPanes = 3
         Configuration = "(H (1[56] 4[18] 2) )"
      End
      Begin PaneConfiguration = 9
         NumPanes = 2
         Configuration = "(H (1 [75] 4))"
      End
      Begin PaneConfiguration = 10
         NumPanes = 2
         Configuration = "(H (1[66] 2) )"
      End
      Begin PaneConfiguration = 11
         NumPanes = 2
         Configuration = "(H (4 [60] 2))"
      End
      Begin PaneConfiguration = 12
         NumPanes = 1
         Configuration = "(H (1) )"
      End
      Begin PaneConfiguration = 13
         NumPanes = 1
         Configuration = "(V (4))"
      End
      Begin PaneConfiguration = 14
         NumPanes = 1
         Configuration = "(V (2))"
      End
      ActivePaneConfig = 5
   End
   Begin DiagramPane = 
      PaneHidden = 
      Begin Origin = 
         Top = 0
         Left = 0
      End
      Begin Tables = 
         Begin Table = "DataAndLogFilesMon"
            Begin Extent = 
               Top = 6
               Left = 38
               Bottom = 114
               Right = 205
            End
            DisplayFlags = 280
            TopColumn = 0
         End
      End
   End
   Begin SQLPane = 
   End
   Begin DataPane = 
      Begin ParameterDefaults = ""
      End
      Begin ColumnWidths = 9
         Width = 284
         Width = 1500
         Width = 1500
         Width = 1500
         Width = 1500
         Width = 1500
         Width = 1500
         Width = 1500
         Width = 1500
      End
   End
   Begin CriteriaPane = 
      PaneHidden = 
      Begin ColumnWidths = 12
         Column = 1440
         Alias = 900
         Table = 1170
         Output = 720
         Append = 1400
         NewValue = 1170
         SortType = 1350
         SortOrder = 1410
         GroupBy = 1350
         Filter = 1350
         Or = 1350
         Or = 1350
         Or = 1350
      End
   End
End
' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'VIEW',@level1name=N'MonLogMB'
GO
EXEC sys.sp_addextendedproperty @name=N'MS_DiagramPaneCount', @value=1 , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'VIEW',@level1name=N'MonLogMB'
GO
EXEC sys.sp_addextendedproperty @name=N'MS_DiagramPane1', @value=N'[0E232FF0-B466-11cf-A24F-00AA00A3EFFF, 1.00]
Begin DesignProperties = 
   Begin PaneConfigurations = 
      Begin PaneConfiguration = 0
         NumPanes = 4
         Configuration = "(H (1[40] 4[20] 2[20] 3) )"
      End
      Begin PaneConfiguration = 1
         NumPanes = 3
         Configuration = "(H (1 [50] 4 [25] 3))"
      End
      Begin PaneConfiguration = 2
         NumPanes = 3
         Configuration = "(H (1[29] 2[8] 3) )"
      End
      Begin PaneConfiguration = 3
         NumPanes = 3
         Configuration = "(H (4 [30] 2 [40] 3))"
      End
      Begin PaneConfiguration = 4
         NumPanes = 2
         Configuration = "(H (1 [56] 3))"
      End
      Begin PaneConfiguration = 5
         NumPanes = 2
         Configuration = "(H (2 [66] 3))"
      End
      Begin PaneConfiguration = 6
         NumPanes = 2
         Configuration = "(H (4 [50] 3))"
      End
      Begin PaneConfiguration = 7
         NumPanes = 1
         Configuration = "(V (3))"
      End
      Begin PaneConfiguration = 8
         NumPanes = 3
         Configuration = "(H (1[56] 4[18] 2) )"
      End
      Begin PaneConfiguration = 9
         NumPanes = 2
         Configuration = "(H (1 [75] 4))"
      End
      Begin PaneConfiguration = 10
         NumPanes = 2
         Configuration = "(H (1[66] 2) )"
      End
      Begin PaneConfiguration = 11
         NumPanes = 2
         Configuration = "(H (4 [60] 2))"
      End
      Begin PaneConfiguration = 12
         NumPanes = 1
         Configuration = "(H (1) )"
      End
      Begin PaneConfiguration = 13
         NumPanes = 1
         Configuration = "(V (4))"
      End
      Begin PaneConfiguration = 14
         NumPanes = 1
         Configuration = "(V (2))"
      End
      ActivePaneConfig = 2
   End
   Begin DiagramPane = 
      Begin Origin = 
         Top = 0
         Left = 0
      End
      Begin Tables = 
         Begin Table = "InstanceInfoMon"
            Begin Extent = 
               Top = 6
               Left = 38
               Bottom = 194
               Right = 190
            End
            DisplayFlags = 280
            TopColumn = 0
         End
      End
   End
   Begin SQLPane = 
   End
   Begin DataPane = 
      Begin ParameterDefaults = ""
      End
      Begin ColumnWidths = 9
         Width = 284
         Width = 4935
         Width = 1500
         Width = 1500
         Width = 1500
         Width = 1500
         Width = 1500
         Width = 1500
         Width = 1500
      End
   End
   Begin CriteriaPane = 
      PaneHidden = 
      Begin ColumnWidths = 11
         Column = 1440
         Alias = 900
         Table = 1170
         Output = 720
         Append = 1400
         NewValue = 1170
         SortType = 1350
         SortOrder = 1410
         GroupBy = 1350
         Filter = 1350
         Or = 1350
         Or = 1350
         Or = 1350
      End
   End
End
' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'VIEW',@level1name=N'MonSQLEditionCountVw'
GO
EXEC sys.sp_addextendedproperty @name=N'MS_DiagramPaneCount', @value=1 , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'VIEW',@level1name=N'MonSQLEditionCountVw'
GO
EXEC sys.sp_addextendedproperty @name=N'MS_DiagramPane1', @value=N'[0E232FF0-B466-11cf-A24F-00AA00A3EFFF, 1.00]
Begin DesignProperties = 
   Begin PaneConfigurations = 
      Begin PaneConfiguration = 0
         NumPanes = 4
         Configuration = "(H (1[40] 4[20] 2[20] 3) )"
      End
      Begin PaneConfiguration = 1
         NumPanes = 3
         Configuration = "(H (1 [50] 4 [25] 3))"
      End
      Begin PaneConfiguration = 2
         NumPanes = 3
         Configuration = "(H (1[28] 2[20] 3) )"
      End
      Begin PaneConfiguration = 3
         NumPanes = 3
         Configuration = "(H (4 [30] 2 [40] 3))"
      End
      Begin PaneConfiguration = 4
         NumPanes = 2
         Configuration = "(H (1 [56] 3))"
      End
      Begin PaneConfiguration = 5
         NumPanes = 2
         Configuration = "(H (2 [66] 3))"
      End
      Begin PaneConfiguration = 6
         NumPanes = 2
         Configuration = "(H (4 [50] 3))"
      End
      Begin PaneConfiguration = 7
         NumPanes = 1
         Configuration = "(V (3))"
      End
      Begin PaneConfiguration = 8
         NumPanes = 3
         Configuration = "(H (1[56] 4[18] 2) )"
      End
      Begin PaneConfiguration = 9
         NumPanes = 2
         Configuration = "(H (1 [75] 4))"
      End
      Begin PaneConfiguration = 10
         NumPanes = 2
         Configuration = "(H (1[66] 2) )"
      End
      Begin PaneConfiguration = 11
         NumPanes = 2
         Configuration = "(H (4 [60] 2))"
      End
      Begin PaneConfiguration = 12
         NumPanes = 1
         Configuration = "(H (1) )"
      End
      Begin PaneConfiguration = 13
         NumPanes = 1
         Configuration = "(V (4))"
      End
      Begin PaneConfiguration = 14
         NumPanes = 1
         Configuration = "(V (2))"
      End
      ActivePaneConfig = 2
   End
   Begin DiagramPane = 
      Begin Origin = 
         Top = 0
         Left = 0
      End
      Begin Tables = 
         Begin Table = "InstanceInfoMon"
            Begin Extent = 
               Top = 6
               Left = 38
               Bottom = 139
               Right = 307
            End
            DisplayFlags = 280
            TopColumn = 0
         End
      End
   End
   Begin SQLPane = 
   End
   Begin DataPane = 
      Begin ParameterDefaults = ""
      End
      Begin ColumnWidths = 9
         Width = 284
         Width = 5385
         Width = 1500
         Width = 1500
         Width = 1500
         Width = 1500
         Width = 1500
         Width = 1500
         Width = 1500
      End
   End
   Begin CriteriaPane = 
      PaneHidden = 
      Begin ColumnWidths = 11
         Column = 1440
         Alias = 900
         Table = 1170
         Output = 720
         Append = 1400
         NewValue = 1170
         SortType = 1350
         SortOrder = 1410
         GroupBy = 1350
         Filter = 1350
         Or = 1350
         Or = 1350
         Or = 1350
      End
   End
End
' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'VIEW',@level1name=N'MonSQLVersionCountsVw'
GO
EXEC sys.sp_addextendedproperty @name=N'MS_DiagramPaneCount', @value=1 , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'VIEW',@level1name=N'MonSQLVersionCountsVw'
GO
EXEC sys.sp_addextendedproperty @name=N'MS_DiagramPane1', @value=N'[0E232FF0-B466-11cf-A24F-00AA00A3EFFF, 1.00]
Begin DesignProperties = 
   Begin PaneConfigurations = 
      Begin PaneConfiguration = 0
         NumPanes = 4
         Configuration = "(H (1[40] 4[20] 2[20] 3) )"
      End
      Begin PaneConfiguration = 1
         NumPanes = 3
         Configuration = "(H (1 [50] 4 [25] 3))"
      End
      Begin PaneConfiguration = 2
         NumPanes = 3
         Configuration = "(H (1 [50] 2 [25] 3))"
      End
      Begin PaneConfiguration = 3
         NumPanes = 3
         Configuration = "(H (4 [30] 2 [40] 3))"
      End
      Begin PaneConfiguration = 4
         NumPanes = 2
         Configuration = "(H (1 [56] 3))"
      End
      Begin PaneConfiguration = 5
         NumPanes = 2
         Configuration = "(H (2 [66] 3))"
      End
      Begin PaneConfiguration = 6
         NumPanes = 2
         Configuration = "(H (4 [50] 3))"
      End
      Begin PaneConfiguration = 7
         NumPanes = 1
         Configuration = "(V (3))"
      End
      Begin PaneConfiguration = 8
         NumPanes = 3
         Configuration = "(H (1[56] 4[18] 2) )"
      End
      Begin PaneConfiguration = 9
         NumPanes = 2
         Configuration = "(H (1 [75] 4))"
      End
      Begin PaneConfiguration = 10
         NumPanes = 2
         Configuration = "(H (1[66] 2) )"
      End
      Begin PaneConfiguration = 11
         NumPanes = 2
         Configuration = "(H (4 [60] 2))"
      End
      Begin PaneConfiguration = 12
         NumPanes = 1
         Configuration = "(H (1) )"
      End
      Begin PaneConfiguration = 13
         NumPanes = 1
         Configuration = "(V (4))"
      End
      Begin PaneConfiguration = 14
         NumPanes = 1
         Configuration = "(V (2))"
      End
      ActivePaneConfig = 0
   End
   Begin DiagramPane = 
      Begin Origin = 
         Top = 0
         Left = 0
      End
      Begin Tables = 
         Begin Table = "tMyDbs"
            Begin Extent = 
               Top = 6
               Left = 38
               Bottom = 307
               Right = 189
            End
            DisplayFlags = 280
            TopColumn = 0
         End
      End
   End
   Begin SQLPane = 
   End
   Begin DataPane = 
      Begin ParameterDefaults = ""
      End
   End
   Begin CriteriaPane = 
      Begin ColumnWidths = 11
         Column = 1440
         Alias = 900
         Table = 1170
         Output = 720
         Append = 1400
         NewValue = 1170
         SortType = 1350
         SortOrder = 1410
         GroupBy = 1350
         Filter = 1350
         Or = 1350
         Or = 1350
         Or = 1350
      End
   End
End
' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'VIEW',@level1name=N'vServers'
GO
EXEC sys.sp_addextendedproperty @name=N'MS_DiagramPaneCount', @value=1 , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'VIEW',@level1name=N'vServers'
GO
EXEC sys.sp_addextendedproperty @name=N'MS_DiagramPane1', @value=N'[0E232FF0-B466-11cf-A24F-00AA00A3EFFF, 1.00]
Begin DesignProperties = 
   Begin PaneConfigurations = 
      Begin PaneConfiguration = 0
         NumPanes = 4
         Configuration = "(H (1[40] 4[20] 2[20] 3) )"
      End
      Begin PaneConfiguration = 1
         NumPanes = 3
         Configuration = "(H (1 [50] 4 [25] 3))"
      End
      Begin PaneConfiguration = 2
         NumPanes = 3
         Configuration = "(H (1[50] 2[25] 3) )"
      End
      Begin PaneConfiguration = 3
         NumPanes = 3
         Configuration = "(H (4 [30] 2 [40] 3))"
      End
      Begin PaneConfiguration = 4
         NumPanes = 2
         Configuration = "(H (1 [56] 3))"
      End
      Begin PaneConfiguration = 5
         NumPanes = 2
         Configuration = "(H (2 [66] 3))"
      End
      Begin PaneConfiguration = 6
         NumPanes = 2
         Configuration = "(H (4 [50] 3))"
      End
      Begin PaneConfiguration = 7
         NumPanes = 1
         Configuration = "(V (3))"
      End
      Begin PaneConfiguration = 8
         NumPanes = 3
         Configuration = "(H (1 [56] 4 [18] 2))"
      End
      Begin PaneConfiguration = 9
         NumPanes = 2
         Configuration = "(H (1 [75] 4))"
      End
      Begin PaneConfiguration = 10
         NumPanes = 2
         Configuration = "(H (1[66] 2) )"
      End
      Begin PaneConfiguration = 11
         NumPanes = 2
         Configuration = "(H (4 [60] 2))"
      End
      Begin PaneConfiguration = 12
         NumPanes = 1
         Configuration = "(H (1) )"
      End
      Begin PaneConfiguration = 13
         NumPanes = 1
         Configuration = "(V (4))"
      End
      Begin PaneConfiguration = 14
         NumPanes = 1
         Configuration = "(V (2))"
      End
      ActivePaneConfig = 0
   End
   Begin DiagramPane = 
      Begin Origin = 
         Top = 0
         Left = 0
      End
      Begin Tables = 
         Begin Table = "CounterData"
            Begin Extent = 
               Top = 6
               Left = 38
               Bottom = 114
               Right = 202
            End
            DisplayFlags = 280
            TopColumn = 0
         End
         Begin Table = "CounterDetails"
            Begin Extent = 
               Top = 6
               Left = 240
               Bottom = 114
               Right = 395
            End
            DisplayFlags = 280
            TopColumn = 0
         End
      End
   End
   Begin SQLPane = 
   End
   Begin DataPane = 
      Begin ParameterDefaults = ""
      End
      RowHeights = 220
   End
   Begin CriteriaPane = 
      Begin ColumnWidths = 11
         Column = 1440
         Alias = 900
         Table = 1170
         Output = 720
         Append = 1400
         NewValue = 1170
         SortType = 1350
         SortOrder = 1410
         GroupBy = 1350
         Filter = 1350
         Or = 1350
         Or = 1350
         Or = 1350
      End
   End
End
' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'VIEW',@level1name=N'vSQLPerfMon'
GO
EXEC sys.sp_addextendedproperty @name=N'MS_DiagramPaneCount', @value=1 , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'VIEW',@level1name=N'vSQLPerfMon'
GO
EXEC sys.sp_addextendedproperty @name=N'MS_DiagramPane1', @value=N'[0E232FF0-B466-11cf-A24F-00AA00A3EFFF, 1.00]
Begin DesignProperties = 
   Begin PaneConfigurations = 
      Begin PaneConfiguration = 0
         NumPanes = 4
         Configuration = "(H (1[40] 4[20] 2[20] 3) )"
      End
      Begin PaneConfiguration = 1
         NumPanes = 3
         Configuration = "(H (1 [50] 4 [25] 3))"
      End
      Begin PaneConfiguration = 2
         NumPanes = 3
         Configuration = "(H (1[50] 2[25] 3) )"
      End
      Begin PaneConfiguration = 3
         NumPanes = 3
         Configuration = "(H (4[30] 2[40] 3) )"
      End
      Begin PaneConfiguration = 4
         NumPanes = 2
         Configuration = "(H (1 [56] 3))"
      End
      Begin PaneConfiguration = 5
         NumPanes = 2
         Configuration = "(H (2[66] 3) )"
      End
      Begin PaneConfiguration = 6
         NumPanes = 2
         Configuration = "(H (4 [50] 3))"
      End
      Begin PaneConfiguration = 7
         NumPanes = 1
         Configuration = "(V (3))"
      End
      Begin PaneConfiguration = 8
         NumPanes = 3
         Configuration = "(H (1 [56] 4 [18] 2))"
      End
      Begin PaneConfiguration = 9
         NumPanes = 2
         Configuration = "(H (1 [75] 4))"
      End
      Begin PaneConfiguration = 10
         NumPanes = 2
         Configuration = "(H (1[66] 2) )"
      End
      Begin PaneConfiguration = 11
         NumPanes = 2
         Configuration = "(H (4 [60] 2))"
      End
      Begin PaneConfiguration = 12
         NumPanes = 1
         Configuration = "(H (1) )"
      End
      Begin PaneConfiguration = 13
         NumPanes = 1
         Configuration = "(V (4))"
      End
      Begin PaneConfiguration = 14
         NumPanes = 1
         Configuration = "(V (2))"
      End
      ActivePaneConfig = 5
   End
   Begin DiagramPane = 
      PaneHidden = 
      Begin Origin = 
         Top = 0
         Left = 0
      End
      Begin Tables = 
         Begin Table = "CounterData"
            Begin Extent = 
               Top = 6
               Left = 38
               Bottom = 114
               Right = 202
            End
            DisplayFlags = 280
            TopColumn = 0
         End
         Begin Table = "CounterDetails"
            Begin Extent = 
               Top = 6
               Left = 240
               Bottom = 114
               Right = 395
            End
            DisplayFlags = 280
            TopColumn = 0
         End
      End
   End
   Begin SQLPane = 
   End
   Begin DataPane = 
      Begin ParameterDefaults = ""
      End
      RowHeights = 220
      Begin ColumnWidths = 12
         Width = 284
         Width = 1440
         Width = 1440
         Width = 1440
         Width = 1440
         Width = 1440
         Width = 1440
         Width = 1440
         Width = 1440
         Width = 1440
         Width = 1440
         Width = 1440
      End
   End
   Begin CriteriaPane = 
      PaneHidden = 
      Begin ColumnWidths = 11
         Column = 1440
         Alias = 900
         Table = 1170
         Output = 720
         Append = 1400
         NewValue = 1170
         SortType = 1350
         SortOrder = 1410
         GroupBy = 1350
         Filter = 1350
         Or = 1350
         Or = 1350
         Or = 1350
      End
   End
End
' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'VIEW',@level1name=N'vSQLPerfSXA'
GO
EXEC sys.sp_addextendedproperty @name=N'MS_DiagramPaneCount', @value=1 , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'VIEW',@level1name=N'vSQLPerfSXA'
GO
EXEC sys.sp_addextendedproperty @name=N'MS_DiagramPane1', @value=N'[0E232FF0-B466-11cf-A24F-00AA00A3EFFF, 1.00]
Begin DesignProperties = 
   Begin PaneConfigurations = 
      Begin PaneConfiguration = 0
         NumPanes = 4
         Configuration = "(H (1[40] 4[20] 2[20] 3) )"
      End
      Begin PaneConfiguration = 1
         NumPanes = 3
         Configuration = "(H (1 [50] 4 [25] 3))"
      End
      Begin PaneConfiguration = 2
         NumPanes = 3
         Configuration = "(H (1[50] 2[25] 3) )"
      End
      Begin PaneConfiguration = 3
         NumPanes = 3
         Configuration = "(H (4[30] 2[40] 3) )"
      End
      Begin PaneConfiguration = 4
         NumPanes = 2
         Configuration = "(H (1 [56] 3))"
      End
      Begin PaneConfiguration = 5
         NumPanes = 2
         Configuration = "(H (2[66] 3) )"
      End
      Begin PaneConfiguration = 6
         NumPanes = 2
         Configuration = "(H (4 [50] 3))"
      End
      Begin PaneConfiguration = 7
         NumPanes = 1
         Configuration = "(V (3))"
      End
      Begin PaneConfiguration = 8
         NumPanes = 3
         Configuration = "(H (1 [56] 4 [18] 2))"
      End
      Begin PaneConfiguration = 9
         NumPanes = 2
         Configuration = "(H (1 [75] 4))"
      End
      Begin PaneConfiguration = 10
         NumPanes = 2
         Configuration = "(H (1[66] 2) )"
      End
      Begin PaneConfiguration = 11
         NumPanes = 2
         Configuration = "(H (4 [60] 2))"
      End
      Begin PaneConfiguration = 12
         NumPanes = 1
         Configuration = "(H (1) )"
      End
      Begin PaneConfiguration = 13
         NumPanes = 1
         Configuration = "(V (4))"
      End
      Begin PaneConfiguration = 14
         NumPanes = 1
         Configuration = "(V (2))"
      End
      ActivePaneConfig = 5
   End
   Begin DiagramPane = 
      PaneHidden = 
      Begin Origin = 
         Top = 0
         Left = 0
      End
      Begin Tables = 
         Begin Table = "CounterData"
            Begin Extent = 
               Top = 6
               Left = 38
               Bottom = 114
               Right = 202
            End
            DisplayFlags = 280
            TopColumn = 0
         End
         Begin Table = "CounterDetails"
            Begin Extent = 
               Top = 6
               Left = 240
               Bottom = 114
               Right = 395
            End
            DisplayFlags = 280
            TopColumn = 0
         End
      End
   End
   Begin SQLPane = 
   End
   Begin DataPane = 
      Begin ParameterDefaults = ""
      End
      RowHeights = 220
      Begin ColumnWidths = 12
         Width = 284
         Width = 1440
         Width = 1440
         Width = 1440
         Width = 1440
         Width = 1440
         Width = 1440
         Width = 1440
         Width = 1440
         Width = 1440
         Width = 1440
         Width = 1440
      End
   End
   Begin CriteriaPane = 
      PaneHidden = 
      Begin ColumnWidths = 14
         Column = 1440
         Alias = 900
         Table = 1170
         Output = 720
         Append = 1400
         NewValue = 1170
         SortType = 1350
         SortOrder = 1410
         GroupBy = 1350
         Filter = 1350
         Or = 1350
         Or = 1350
         Or = 1350
         Or = 1350
         Or = 1350
         Or = 1350
      End
   End
End
' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'VIEW',@level1name=N'vSQLPerfSXA2DaysAgo'
GO
EXEC sys.sp_addextendedproperty @name=N'MS_DiagramPaneCount', @value=1 , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'VIEW',@level1name=N'vSQLPerfSXA2DaysAgo'
GO
EXEC sys.sp_addextendedproperty @name=N'MS_DiagramPane1', @value=N'[0E232FF0-B466-11cf-A24F-00AA00A3EFFF, 1.00]
Begin DesignProperties = 
   Begin PaneConfigurations = 
      Begin PaneConfiguration = 0
         NumPanes = 4
         Configuration = "(H (1[40] 4[20] 2[20] 3) )"
      End
      Begin PaneConfiguration = 1
         NumPanes = 3
         Configuration = "(H (1 [50] 4 [25] 3))"
      End
      Begin PaneConfiguration = 2
         NumPanes = 3
         Configuration = "(H (1[50] 2[25] 3) )"
      End
      Begin PaneConfiguration = 3
         NumPanes = 3
         Configuration = "(H (4[30] 2[40] 3) )"
      End
      Begin PaneConfiguration = 4
         NumPanes = 2
         Configuration = "(H (1 [56] 3))"
      End
      Begin PaneConfiguration = 5
         NumPanes = 2
         Configuration = "(H (2[66] 3) )"
      End
      Begin PaneConfiguration = 6
         NumPanes = 2
         Configuration = "(H (4 [50] 3))"
      End
      Begin PaneConfiguration = 7
         NumPanes = 1
         Configuration = "(V (3))"
      End
      Begin PaneConfiguration = 8
         NumPanes = 3
         Configuration = "(H (1 [56] 4 [18] 2))"
      End
      Begin PaneConfiguration = 9
         NumPanes = 2
         Configuration = "(H (1 [75] 4))"
      End
      Begin PaneConfiguration = 10
         NumPanes = 2
         Configuration = "(H (1[66] 2) )"
      End
      Begin PaneConfiguration = 11
         NumPanes = 2
         Configuration = "(H (4 [60] 2))"
      End
      Begin PaneConfiguration = 12
         NumPanes = 1
         Configuration = "(H (1) )"
      End
      Begin PaneConfiguration = 13
         NumPanes = 1
         Configuration = "(V (4))"
      End
      Begin PaneConfiguration = 14
         NumPanes = 1
         Configuration = "(V (2))"
      End
      ActivePaneConfig = 5
   End
   Begin DiagramPane = 
      PaneHidden = 
      Begin Origin = 
         Top = 0
         Left = 0
      End
      Begin Tables = 
         Begin Table = "CounterData"
            Begin Extent = 
               Top = 6
               Left = 38
               Bottom = 114
               Right = 202
            End
            DisplayFlags = 280
            TopColumn = 0
         End
         Begin Table = "CounterDetails"
            Begin Extent = 
               Top = 6
               Left = 240
               Bottom = 114
               Right = 395
            End
            DisplayFlags = 280
            TopColumn = 0
         End
      End
   End
   Begin SQLPane = 
   End
   Begin DataPane = 
      Begin ParameterDefaults = ""
      End
      RowHeights = 220
      Begin ColumnWidths = 12
         Width = 284
         Width = 1440
         Width = 1440
         Width = 1440
         Width = 1440
         Width = 1440
         Width = 1440
         Width = 1440
         Width = 1440
         Width = 1440
         Width = 1440
         Width = 1440
      End
   End
   Begin CriteriaPane = 
      PaneHidden = 
      Begin ColumnWidths = 14
         Column = 1440
         Alias = 900
         Table = 1170
         Output = 720
         Append = 1400
         NewValue = 1170
         SortType = 1350
         SortOrder = 1410
         GroupBy = 1350
         Filter = 1350
         Or = 1350
         Or = 1350
         Or = 1350
         Or = 1350
         Or = 1350
         Or = 1350
      End
   End
End
' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'VIEW',@level1name=N'vSQLPerfSXA3DaysAgo'
GO
EXEC sys.sp_addextendedproperty @name=N'MS_DiagramPaneCount', @value=1 , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'VIEW',@level1name=N'vSQLPerfSXA3DaysAgo'
GO
EXEC sys.sp_addextendedproperty @name=N'MS_DiagramPane1', @value=N'[0E232FF0-B466-11cf-A24F-00AA00A3EFFF, 1.00]
Begin DesignProperties = 
   Begin PaneConfigurations = 
      Begin PaneConfiguration = 0
         NumPanes = 4
         Configuration = "(H (1[40] 4[20] 2[20] 3) )"
      End
      Begin PaneConfiguration = 1
         NumPanes = 3
         Configuration = "(H (1 [50] 4 [25] 3))"
      End
      Begin PaneConfiguration = 2
         NumPanes = 3
         Configuration = "(H (1[50] 2[25] 3) )"
      End
      Begin PaneConfiguration = 3
         NumPanes = 3
         Configuration = "(H (4[30] 2[40] 3) )"
      End
      Begin PaneConfiguration = 4
         NumPanes = 2
         Configuration = "(H (1 [56] 3))"
      End
      Begin PaneConfiguration = 5
         NumPanes = 2
         Configuration = "(H (2[66] 3) )"
      End
      Begin PaneConfiguration = 6
         NumPanes = 2
         Configuration = "(H (4 [50] 3))"
      End
      Begin PaneConfiguration = 7
         NumPanes = 1
         Configuration = "(V (3))"
      End
      Begin PaneConfiguration = 8
         NumPanes = 3
         Configuration = "(H (1 [56] 4 [18] 2))"
      End
      Begin PaneConfiguration = 9
         NumPanes = 2
         Configuration = "(H (1 [75] 4))"
      End
      Begin PaneConfiguration = 10
         NumPanes = 2
         Configuration = "(H (1[66] 2) )"
      End
      Begin PaneConfiguration = 11
         NumPanes = 2
         Configuration = "(H (4 [60] 2))"
      End
      Begin PaneConfiguration = 12
         NumPanes = 1
         Configuration = "(H (1) )"
      End
      Begin PaneConfiguration = 13
         NumPanes = 1
         Configuration = "(V (4))"
      End
      Begin PaneConfiguration = 14
         NumPanes = 1
         Configuration = "(V (2))"
      End
      ActivePaneConfig = 5
   End
   Begin DiagramPane = 
      PaneHidden = 
      Begin Origin = 
         Top = 0
         Left = 0
      End
      Begin Tables = 
         Begin Table = "CounterData"
            Begin Extent = 
               Top = 6
               Left = 38
               Bottom = 114
               Right = 202
            End
            DisplayFlags = 280
            TopColumn = 0
         End
         Begin Table = "CounterDetails"
            Begin Extent = 
               Top = 6
               Left = 240
               Bottom = 114
               Right = 395
            End
            DisplayFlags = 280
            TopColumn = 0
         End
      End
   End
   Begin SQLPane = 
   End
   Begin DataPane = 
      Begin ParameterDefaults = ""
      End
      RowHeights = 220
   End
   Begin CriteriaPane = 
      PaneHidden = 
      Begin ColumnWidths = 11
         Column = 1440
         Alias = 900
         Table = 1170
         Output = 720
         Append = 1400
         NewValue = 1170
         SortType = 1350
         SortOrder = 1410
         GroupBy = 1350
         Filter = 1350
         Or = 1350
         Or = 1350
         Or = 1350
      End
   End
End
' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'VIEW',@level1name=N'vSQLPerfSXA4DaysAgo'
GO
EXEC sys.sp_addextendedproperty @name=N'MS_DiagramPaneCount', @value=1 , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'VIEW',@level1name=N'vSQLPerfSXA4DaysAgo'
GO
EXEC sys.sp_addextendedproperty @name=N'MS_DiagramPane1', @value=N'[0E232FF0-B466-11cf-A24F-00AA00A3EFFF, 1.00]
Begin DesignProperties = 
   Begin PaneConfigurations = 
      Begin PaneConfiguration = 0
         NumPanes = 4
         Configuration = "(H (1[40] 4[20] 2[20] 3) )"
      End
      Begin PaneConfiguration = 1
         NumPanes = 3
         Configuration = "(H (1 [50] 4 [25] 3))"
      End
      Begin PaneConfiguration = 2
         NumPanes = 3
         Configuration = "(H (1[50] 2[25] 3) )"
      End
      Begin PaneConfiguration = 3
         NumPanes = 3
         Configuration = "(H (4[30] 2[40] 3) )"
      End
      Begin PaneConfiguration = 4
         NumPanes = 2
         Configuration = "(H (1 [56] 3))"
      End
      Begin PaneConfiguration = 5
         NumPanes = 2
         Configuration = "(H (2[66] 3) )"
      End
      Begin PaneConfiguration = 6
         NumPanes = 2
         Configuration = "(H (4 [50] 3))"
      End
      Begin PaneConfiguration = 7
         NumPanes = 1
         Configuration = "(V (3))"
      End
      Begin PaneConfiguration = 8
         NumPanes = 3
         Configuration = "(H (1 [56] 4 [18] 2))"
      End
      Begin PaneConfiguration = 9
         NumPanes = 2
         Configuration = "(H (1 [75] 4))"
      End
      Begin PaneConfiguration = 10
         NumPanes = 2
         Configuration = "(H (1[66] 2) )"
      End
      Begin PaneConfiguration = 11
         NumPanes = 2
         Configuration = "(H (4 [60] 2))"
      End
      Begin PaneConfiguration = 12
         NumPanes = 1
         Configuration = "(H (1) )"
      End
      Begin PaneConfiguration = 13
         NumPanes = 1
         Configuration = "(V (4))"
      End
      Begin PaneConfiguration = 14
         NumPanes = 1
         Configuration = "(V (2))"
      End
      ActivePaneConfig = 5
   End
   Begin DiagramPane = 
      PaneHidden = 
      Begin Origin = 
         Top = 0
         Left = 0
      End
      Begin Tables = 
         Begin Table = "CounterData"
            Begin Extent = 
               Top = 6
               Left = 38
               Bottom = 114
               Right = 202
            End
            DisplayFlags = 280
            TopColumn = 0
         End
         Begin Table = "CounterDetails"
            Begin Extent = 
               Top = 6
               Left = 240
               Bottom = 114
               Right = 395
            End
            DisplayFlags = 280
            TopColumn = 0
         End
      End
   End
   Begin SQLPane = 
   End
   Begin DataPane = 
      Begin ParameterDefaults = ""
      End
      RowHeights = 220
      Begin ColumnWidths = 12
         Width = 284
         Width = 1440
         Width = 1440
         Width = 1440
         Width = 1440
         Width = 1440
         Width = 1440
         Width = 1440
         Width = 1440
         Width = 1440
         Width = 1440
         Width = 1440
      End
   End
   Begin CriteriaPane = 
      PaneHidden = 
      Begin ColumnWidths = 14
         Column = 1440
         Alias = 900
         Table = 1170
         Output = 720
         Append = 1400
         NewValue = 1170
         SortType = 1350
         SortOrder = 1410
         GroupBy = 1350
         Filter = 1350
         Or = 1350
         Or = 1350
         Or = 1350
         Or = 1350
         Or = 1350
         Or = 1350
      End
   End
End
' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'VIEW',@level1name=N'vSQLPerfSXA5DaysAgo'
GO
EXEC sys.sp_addextendedproperty @name=N'MS_DiagramPaneCount', @value=1 , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'VIEW',@level1name=N'vSQLPerfSXA5DaysAgo'
GO
EXEC sys.sp_addextendedproperty @name=N'MS_DiagramPane1', @value=N'[0E232FF0-B466-11cf-A24F-00AA00A3EFFF, 1.00]
Begin DesignProperties = 
   Begin PaneConfigurations = 
      Begin PaneConfiguration = 0
         NumPanes = 4
         Configuration = "(H (1[40] 4[20] 2[20] 3) )"
      End
      Begin PaneConfiguration = 1
         NumPanes = 3
         Configuration = "(H (1 [50] 4 [25] 3))"
      End
      Begin PaneConfiguration = 2
         NumPanes = 3
         Configuration = "(H (1[50] 2[25] 3) )"
      End
      Begin PaneConfiguration = 3
         NumPanes = 3
         Configuration = "(H (4[30] 2[40] 3) )"
      End
      Begin PaneConfiguration = 4
         NumPanes = 2
         Configuration = "(H (1 [56] 3))"
      End
      Begin PaneConfiguration = 5
         NumPanes = 2
         Configuration = "(H (2[66] 3) )"
      End
      Begin PaneConfiguration = 6
         NumPanes = 2
         Configuration = "(H (4 [50] 3))"
      End
      Begin PaneConfiguration = 7
         NumPanes = 1
         Configuration = "(V (3))"
      End
      Begin PaneConfiguration = 8
         NumPanes = 3
         Configuration = "(H (1 [56] 4 [18] 2))"
      End
      Begin PaneConfiguration = 9
         NumPanes = 2
         Configuration = "(H (1 [75] 4))"
      End
      Begin PaneConfiguration = 10
         NumPanes = 2
         Configuration = "(H (1[66] 2) )"
      End
      Begin PaneConfiguration = 11
         NumPanes = 2
         Configuration = "(H (4 [60] 2))"
      End
      Begin PaneConfiguration = 12
         NumPanes = 1
         Configuration = "(H (1) )"
      End
      Begin PaneConfiguration = 13
         NumPanes = 1
         Configuration = "(V (4))"
      End
      Begin PaneConfiguration = 14
         NumPanes = 1
         Configuration = "(V (2))"
      End
      ActivePaneConfig = 5
   End
   Begin DiagramPane = 
      PaneHidden = 
      Begin Origin = 
         Top = 0
         Left = 0
      End
      Begin Tables = 
         Begin Table = "CounterData"
            Begin Extent = 
               Top = 6
               Left = 38
               Bottom = 114
               Right = 202
            End
            DisplayFlags = 280
            TopColumn = 0
         End
         Begin Table = "CounterDetails"
            Begin Extent = 
               Top = 6
               Left = 240
               Bottom = 114
               Right = 395
            End
            DisplayFlags = 280
            TopColumn = 0
         End
      End
   End
   Begin SQLPane = 
   End
   Begin DataPane = 
      Begin ParameterDefaults = ""
      End
      RowHeights = 220
      Begin ColumnWidths = 12
         Width = 284
         Width = 1440
         Width = 1440
         Width = 1440
         Width = 1440
         Width = 1440
         Width = 1440
         Width = 1440
         Width = 1440
         Width = 1440
         Width = 1440
         Width = 1440
      End
   End
   Begin CriteriaPane = 
      PaneHidden = 
      Begin ColumnWidths = 14
         Column = 1440
         Alias = 900
         Table = 1170
         Output = 720
         Append = 1400
         NewValue = 1170
         SortType = 1350
         SortOrder = 1410
         GroupBy = 1350
         Filter = 1350
         Or = 1350
         Or = 1350
         Or = 1350
         Or = 1350
         Or = 1350
         Or = 1350
      End
   End
End
' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'VIEW',@level1name=N'vSQLPerfSXA6DaysAgo'
GO
EXEC sys.sp_addextendedproperty @name=N'MS_DiagramPaneCount', @value=1 , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'VIEW',@level1name=N'vSQLPerfSXA6DaysAgo'
GO
EXEC sys.sp_addextendedproperty @name=N'MS_DiagramPane1', @value=N'[0E232FF0-B466-11cf-A24F-00AA00A3EFFF, 1.00]
Begin DesignProperties = 
   Begin PaneConfigurations = 
      Begin PaneConfiguration = 0
         NumPanes = 4
         Configuration = "(H (1[40] 4[20] 2[20] 3) )"
      End
      Begin PaneConfiguration = 1
         NumPanes = 3
         Configuration = "(H (1 [50] 4 [25] 3))"
      End
      Begin PaneConfiguration = 2
         NumPanes = 3
         Configuration = "(H (1[50] 2[25] 3) )"
      End
      Begin PaneConfiguration = 3
         NumPanes = 3
         Configuration = "(H (4[30] 2[40] 3) )"
      End
      Begin PaneConfiguration = 4
         NumPanes = 2
         Configuration = "(H (1 [56] 3))"
      End
      Begin PaneConfiguration = 5
         NumPanes = 2
         Configuration = "(H (2[66] 3) )"
      End
      Begin PaneConfiguration = 6
         NumPanes = 2
         Configuration = "(H (4 [50] 3))"
      End
      Begin PaneConfiguration = 7
         NumPanes = 1
         Configuration = "(V (3))"
      End
      Begin PaneConfiguration = 8
         NumPanes = 3
         Configuration = "(H (1 [56] 4 [18] 2))"
      End
      Begin PaneConfiguration = 9
         NumPanes = 2
         Configuration = "(H (1 [75] 4))"
      End
      Begin PaneConfiguration = 10
         NumPanes = 2
         Configuration = "(H (1[66] 2) )"
      End
      Begin PaneConfiguration = 11
         NumPanes = 2
         Configuration = "(H (4 [60] 2))"
      End
      Begin PaneConfiguration = 12
         NumPanes = 1
         Configuration = "(H (1) )"
      End
      Begin PaneConfiguration = 13
         NumPanes = 1
         Configuration = "(V (4))"
      End
      Begin PaneConfiguration = 14
         NumPanes = 1
         Configuration = "(V (2))"
      End
      ActivePaneConfig = 5
   End
   Begin DiagramPane = 
      PaneHidden = 
      Begin Origin = 
         Top = 0
         Left = 0
      End
      Begin Tables = 
         Begin Table = "CounterData"
            Begin Extent = 
               Top = 6
               Left = 38
               Bottom = 114
               Right = 202
            End
            DisplayFlags = 280
            TopColumn = 0
         End
         Begin Table = "CounterDetails"
            Begin Extent = 
               Top = 6
               Left = 240
               Bottom = 114
               Right = 395
            End
            DisplayFlags = 280
            TopColumn = 0
         End
      End
   End
   Begin SQLPane = 
   End
   Begin DataPane = 
      Begin ParameterDefaults = ""
      End
      RowHeights = 220
   End
   Begin CriteriaPane = 
      PaneHidden = 
      Begin ColumnWidths = 11
         Column = 1440
         Alias = 900
         Table = 1170
         Output = 720
         Append = 1400
         NewValue = 1170
         SortType = 1350
         SortOrder = 1410
         GroupBy = 1350
         Filter = 1350
         Or = 1350
         Or = 1350
         Or = 1350
      End
   End
End
' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'VIEW',@level1name=N'vSQLPerfSXA7DaysAgo'
GO
EXEC sys.sp_addextendedproperty @name=N'MS_DiagramPaneCount', @value=1 , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'VIEW',@level1name=N'vSQLPerfSXA7DaysAgo'
GO
EXEC sys.sp_addextendedproperty @name=N'MS_DiagramPane1', @value=N'[0E232FF0-B466-11cf-A24F-00AA00A3EFFF, 1.00]
Begin DesignProperties = 
   Begin PaneConfigurations = 
      Begin PaneConfiguration = 0
         NumPanes = 4
         Configuration = "(H (1[40] 4[20] 2[20] 3) )"
      End
      Begin PaneConfiguration = 1
         NumPanes = 3
         Configuration = "(H (1 [50] 4 [25] 3))"
      End
      Begin PaneConfiguration = 2
         NumPanes = 3
         Configuration = "(H (1[50] 2[25] 3) )"
      End
      Begin PaneConfiguration = 3
         NumPanes = 3
         Configuration = "(H (4[30] 2[40] 3) )"
      End
      Begin PaneConfiguration = 4
         NumPanes = 2
         Configuration = "(H (1 [56] 3))"
      End
      Begin PaneConfiguration = 5
         NumPanes = 2
         Configuration = "(H (2[66] 3) )"
      End
      Begin PaneConfiguration = 6
         NumPanes = 2
         Configuration = "(H (4 [50] 3))"
      End
      Begin PaneConfiguration = 7
         NumPanes = 1
         Configuration = "(V (3))"
      End
      Begin PaneConfiguration = 8
         NumPanes = 3
         Configuration = "(H (1 [56] 4 [18] 2))"
      End
      Begin PaneConfiguration = 9
         NumPanes = 2
         Configuration = "(H (1 [75] 4))"
      End
      Begin PaneConfiguration = 10
         NumPanes = 2
         Configuration = "(H (1[66] 2) )"
      End
      Begin PaneConfiguration = 11
         NumPanes = 2
         Configuration = "(H (4 [60] 2))"
      End
      Begin PaneConfiguration = 12
         NumPanes = 1
         Configuration = "(H (1) )"
      End
      Begin PaneConfiguration = 13
         NumPanes = 1
         Configuration = "(V (4))"
      End
      Begin PaneConfiguration = 14
         NumPanes = 1
         Configuration = "(V (2))"
      End
      ActivePaneConfig = 5
   End
   Begin DiagramPane = 
      PaneHidden = 
      Begin Origin = 
         Top = 0
         Left = 0
      End
      Begin Tables = 
         Begin Table = "CounterData"
            Begin Extent = 
               Top = 6
               Left = 38
               Bottom = 114
               Right = 202
            End
            DisplayFlags = 280
            TopColumn = 0
         End
         Begin Table = "CounterDetails"
            Begin Extent = 
               Top = 6
               Left = 240
               Bottom = 114
               Right = 395
            End
            DisplayFlags = 280
            TopColumn = 0
         End
      End
   End
   Begin SQLPane = 
   End
   Begin DataPane = 
      Begin ParameterDefaults = ""
      End
      RowHeights = 220
      Begin ColumnWidths = 13
         Width = 284
         Width = 1440
         Width = 1440
         Width = 1440
         Width = 1440
         Width = 1440
         Width = 1440
         Width = 1440
         Width = 1440
         Width = 1440
         Width = 1440
         Width = 1440
         Width = 1440
      End
   End
   Begin CriteriaPane = 
      PaneHidden = 
      Begin ColumnWidths = 11
         Column = 1440
         Alias = 900
         Table = 1170
         Output = 720
         Append = 1400
         NewValue = 1170
         SortType = 1350
         SortOrder = 1410
         GroupBy = 1350
         Filter = 1350
         Or = 1350
         Or = 1350
         Or = 1350
      End
   End
End
' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'VIEW',@level1name=N'vSQLPerfSXADriveInfo'
GO
EXEC sys.sp_addextendedproperty @name=N'MS_DiagramPaneCount', @value=1 , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'VIEW',@level1name=N'vSQLPerfSXADriveInfo'
GO
EXEC sys.sp_addextendedproperty @name=N'MS_DiagramPane1', @value=N'[0E232FF0-B466-11cf-A24F-00AA00A3EFFF, 1.00]
Begin DesignProperties = 
   Begin PaneConfigurations = 
      Begin PaneConfiguration = 0
         NumPanes = 4
         Configuration = "(H (1[40] 4[20] 2[20] 3) )"
      End
      Begin PaneConfiguration = 1
         NumPanes = 3
         Configuration = "(H (1 [50] 4 [25] 3))"
      End
      Begin PaneConfiguration = 2
         NumPanes = 3
         Configuration = "(H (1[50] 2[25] 3) )"
      End
      Begin PaneConfiguration = 3
         NumPanes = 3
         Configuration = "(H (4[30] 2[40] 3) )"
      End
      Begin PaneConfiguration = 4
         NumPanes = 2
         Configuration = "(H (1 [56] 3))"
      End
      Begin PaneConfiguration = 5
         NumPanes = 2
         Configuration = "(H (2[66] 3) )"
      End
      Begin PaneConfiguration = 6
         NumPanes = 2
         Configuration = "(H (4 [50] 3))"
      End
      Begin PaneConfiguration = 7
         NumPanes = 1
         Configuration = "(V (3))"
      End
      Begin PaneConfiguration = 8
         NumPanes = 3
         Configuration = "(H (1 [56] 4 [18] 2))"
      End
      Begin PaneConfiguration = 9
         NumPanes = 2
         Configuration = "(H (1 [75] 4))"
      End
      Begin PaneConfiguration = 10
         NumPanes = 2
         Configuration = "(H (1[66] 2) )"
      End
      Begin PaneConfiguration = 11
         NumPanes = 2
         Configuration = "(H (4 [60] 2))"
      End
      Begin PaneConfiguration = 12
         NumPanes = 1
         Configuration = "(H (1) )"
      End
      Begin PaneConfiguration = 13
         NumPanes = 1
         Configuration = "(V (4))"
      End
      Begin PaneConfiguration = 14
         NumPanes = 1
         Configuration = "(V (2))"
      End
      ActivePaneConfig = 5
   End
   Begin DiagramPane = 
      PaneHidden = 
      Begin Origin = 
         Top = 0
         Left = 0
      End
      Begin Tables = 
         Begin Table = "CounterData"
            Begin Extent = 
               Top = 6
               Left = 38
               Bottom = 114
               Right = 202
            End
            DisplayFlags = 280
            TopColumn = 0
         End
         Begin Table = "CounterDetails"
            Begin Extent = 
               Top = 6
               Left = 240
               Bottom = 114
               Right = 395
            End
            DisplayFlags = 280
            TopColumn = 0
         End
      End
   End
   Begin SQLPane = 
   End
   Begin DataPane = 
      Begin ParameterDefaults = ""
      End
      Begin ColumnWidths = 13
         Width = 284
         Width = 1440
         Width = 1440
         Width = 2925
         Width = 2235
         Width = 1440
         Width = 1440
         Width = 1440
         Width = 1440
         Width = 1440
         Width = 1440
         Width = 1440
         Width = 1440
      End
   End
   Begin CriteriaPane = 
      PaneHidden = 
      Begin ColumnWidths = 11
         Column = 1440
         Alias = 900
         Table = 1170
         Output = 720
         Append = 1400
         NewValue = 1170
         SortType = 1350
         SortOrder = 1410
         GroupBy = 1350
         Filter = 1350
         Or = 1350
         Or = 1350
         Or = 1350
      End
   End
End
' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'VIEW',@level1name=N'vSQLPerfSXAFDriveYesterday'
GO
EXEC sys.sp_addextendedproperty @name=N'MS_DiagramPaneCount', @value=1 , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'VIEW',@level1name=N'vSQLPerfSXAFDriveYesterday'
GO
EXEC sys.sp_addextendedproperty @name=N'MS_DiagramPane1', @value=N'[0E232FF0-B466-11cf-A24F-00AA00A3EFFF, 1.00]
Begin DesignProperties = 
   Begin PaneConfigurations = 
      Begin PaneConfiguration = 0
         NumPanes = 4
         Configuration = "(H (1[40] 4[20] 2[20] 3) )"
      End
      Begin PaneConfiguration = 1
         NumPanes = 3
         Configuration = "(H (1 [50] 4 [25] 3))"
      End
      Begin PaneConfiguration = 2
         NumPanes = 3
         Configuration = "(H (1[50] 2[25] 3) )"
      End
      Begin PaneConfiguration = 3
         NumPanes = 3
         Configuration = "(H (4[30] 2[40] 3) )"
      End
      Begin PaneConfiguration = 4
         NumPanes = 2
         Configuration = "(H (1 [56] 3))"
      End
      Begin PaneConfiguration = 5
         NumPanes = 2
         Configuration = "(H (2[66] 3) )"
      End
      Begin PaneConfiguration = 6
         NumPanes = 2
         Configuration = "(H (4 [50] 3))"
      End
      Begin PaneConfiguration = 7
         NumPanes = 1
         Configuration = "(V (3))"
      End
      Begin PaneConfiguration = 8
         NumPanes = 3
         Configuration = "(H (1 [56] 4 [18] 2))"
      End
      Begin PaneConfiguration = 9
         NumPanes = 2
         Configuration = "(H (1 [75] 4))"
      End
      Begin PaneConfiguration = 10
         NumPanes = 2
         Configuration = "(H (1[66] 2) )"
      End
      Begin PaneConfiguration = 11
         NumPanes = 2
         Configuration = "(H (4 [60] 2))"
      End
      Begin PaneConfiguration = 12
         NumPanes = 1
         Configuration = "(H (1) )"
      End
      Begin PaneConfiguration = 13
         NumPanes = 1
         Configuration = "(V (4))"
      End
      Begin PaneConfiguration = 14
         NumPanes = 1
         Configuration = "(V (2))"
      End
      ActivePaneConfig = 5
   End
   Begin DiagramPane = 
      PaneHidden = 
      Begin Origin = 
         Top = 0
         Left = 0
      End
      Begin Tables = 
         Begin Table = "CounterData"
            Begin Extent = 
               Top = 6
               Left = 38
               Bottom = 114
               Right = 202
            End
            DisplayFlags = 280
            TopColumn = 0
         End
         Begin Table = "CounterDetails"
            Begin Extent = 
               Top = 6
               Left = 240
               Bottom = 114
               Right = 395
            End
            DisplayFlags = 280
            TopColumn = 0
         End
      End
   End
   Begin SQLPane = 
   End
   Begin DataPane = 
      Begin ParameterDefaults = ""
      End
      Begin ColumnWidths = 12
         Width = 284
         Width = 1440
         Width = 1440
         Width = 1440
         Width = 1440
         Width = 1440
         Width = 1440
         Width = 1440
         Width = 1440
         Width = 1440
         Width = 1440
         Width = 1440
      End
   End
   Begin CriteriaPane = 
      PaneHidden = 
      Begin ColumnWidths = 11
         Column = 1440
         Alias = 900
         Table = 1170
         Output = 720
         Append = 1400
         NewValue = 1170
         SortType = 1350
         SortOrder = 1410
         GroupBy = 1350
         Filter = 1350
         Or = 1350
         Or = 1350
         Or = 1350
      End
   End
End
' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'VIEW',@level1name=N'vSQLPerfSXAToday'
GO
EXEC sys.sp_addextendedproperty @name=N'MS_DiagramPaneCount', @value=1 , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'VIEW',@level1name=N'vSQLPerfSXAToday'
GO
EXEC sys.sp_addextendedproperty @name=N'MS_DiagramPane1', @value=N'[0E232FF0-B466-11cf-A24F-00AA00A3EFFF, 1.00]
Begin DesignProperties = 
   Begin PaneConfigurations = 
      Begin PaneConfiguration = 0
         NumPanes = 4
         Configuration = "(H (1[40] 4[20] 2[20] 3) )"
      End
      Begin PaneConfiguration = 1
         NumPanes = 3
         Configuration = "(H (1 [50] 4 [25] 3))"
      End
      Begin PaneConfiguration = 2
         NumPanes = 3
         Configuration = "(H (1[50] 2[25] 3) )"
      End
      Begin PaneConfiguration = 3
         NumPanes = 3
         Configuration = "(H (4[30] 2[40] 3) )"
      End
      Begin PaneConfiguration = 4
         NumPanes = 2
         Configuration = "(H (1 [56] 3))"
      End
      Begin PaneConfiguration = 5
         NumPanes = 2
         Configuration = "(H (2[52] 3) )"
      End
      Begin PaneConfiguration = 6
         NumPanes = 2
         Configuration = "(H (4 [50] 3))"
      End
      Begin PaneConfiguration = 7
         NumPanes = 1
         Configuration = "(V (3))"
      End
      Begin PaneConfiguration = 8
         NumPanes = 3
         Configuration = "(H (1 [56] 4 [18] 2))"
      End
      Begin PaneConfiguration = 9
         NumPanes = 2
         Configuration = "(H (1 [75] 4))"
      End
      Begin PaneConfiguration = 10
         NumPanes = 2
         Configuration = "(H (1[66] 2) )"
      End
      Begin PaneConfiguration = 11
         NumPanes = 2
         Configuration = "(H (4 [60] 2))"
      End
      Begin PaneConfiguration = 12
         NumPanes = 1
         Configuration = "(H (1) )"
      End
      Begin PaneConfiguration = 13
         NumPanes = 1
         Configuration = "(V (4))"
      End
      Begin PaneConfiguration = 14
         NumPanes = 1
         Configuration = "(V (2))"
      End
      ActivePaneConfig = 5
   End
   Begin DiagramPane = 
      PaneHidden = 
      Begin Origin = 
         Top = 0
         Left = 0
      End
      Begin Tables = 
         Begin Table = "CounterData"
            Begin Extent = 
               Top = 6
               Left = 38
               Bottom = 114
               Right = 202
            End
            DisplayFlags = 280
            TopColumn = 0
         End
         Begin Table = "CounterDetails"
            Begin Extent = 
               Top = 6
               Left = 240
               Bottom = 114
               Right = 395
            End
            DisplayFlags = 280
            TopColumn = 0
         End
      End
   End
   Begin SQLPane = 
   End
   Begin DataPane = 
      Begin ParameterDefaults = ""
      End
      Begin ColumnWidths = 12
         Width = 284
         Width = 1440
         Width = 1440
         Width = 1440
         Width = 1440
         Width = 1440
         Width = 1440
         Width = 1440
         Width = 1440
         Width = 1440
         Width = 1440
         Width = 1440
      End
   End
   Begin CriteriaPane = 
      PaneHidden = 
      Begin ColumnWidths = 11
         Column = 1440
         Alias = 900
         Table = 1170
         Output = 720
         Append = 1400
         NewValue = 1170
         SortType = 1350
         SortOrder = 1410
         GroupBy = 1350
         Filter = 1350
         Or = 1350
         Or = 1350
         Or = 1350
      End
   End
End
' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'VIEW',@level1name=N'vSQLPerfSXAWeek'
GO
EXEC sys.sp_addextendedproperty @name=N'MS_DiagramPaneCount', @value=1 , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'VIEW',@level1name=N'vSQLPerfSXAWeek'
GO
EXEC sys.sp_addextendedproperty @name=N'MS_DiagramPane1', @value=N'[0E232FF0-B466-11cf-A24F-00AA00A3EFFF, 1.00]
Begin DesignProperties = 
   Begin PaneConfigurations = 
      Begin PaneConfiguration = 0
         NumPanes = 4
         Configuration = "(H (1[40] 4[20] 2[20] 3) )"
      End
      Begin PaneConfiguration = 1
         NumPanes = 3
         Configuration = "(H (1 [50] 4 [25] 3))"
      End
      Begin PaneConfiguration = 2
         NumPanes = 3
         Configuration = "(H (1[42] 2[42] 3) )"
      End
      Begin PaneConfiguration = 3
         NumPanes = 3
         Configuration = "(H (4[30] 2[40] 3) )"
      End
      Begin PaneConfiguration = 4
         NumPanes = 2
         Configuration = "(H (1 [56] 3))"
      End
      Begin PaneConfiguration = 5
         NumPanes = 2
         Configuration = "(H (2[81] 3) )"
      End
      Begin PaneConfiguration = 6
         NumPanes = 2
         Configuration = "(H (4 [50] 3))"
      End
      Begin PaneConfiguration = 7
         NumPanes = 1
         Configuration = "(V (3))"
      End
      Begin PaneConfiguration = 8
         NumPanes = 3
         Configuration = "(H (1 [56] 4 [18] 2))"
      End
      Begin PaneConfiguration = 9
         NumPanes = 2
         Configuration = "(H (1 [75] 4))"
      End
      Begin PaneConfiguration = 10
         NumPanes = 2
         Configuration = "(H (1[66] 2) )"
      End
      Begin PaneConfiguration = 11
         NumPanes = 2
         Configuration = "(H (4 [60] 2))"
      End
      Begin PaneConfiguration = 12
         NumPanes = 1
         Configuration = "(H (1) )"
      End
      Begin PaneConfiguration = 13
         NumPanes = 1
         Configuration = "(V (4))"
      End
      Begin PaneConfiguration = 14
         NumPanes = 1
         Configuration = "(V (2))"
      End
      ActivePaneConfig = 5
   End
   Begin DiagramPane = 
      PaneHidden = 
      Begin Origin = 
         Top = 0
         Left = 0
      End
      Begin Tables = 
         Begin Table = "CounterData"
            Begin Extent = 
               Top = 6
               Left = 38
               Bottom = 353
               Right = 202
            End
            DisplayFlags = 280
            TopColumn = 0
         End
         Begin Table = "CounterDetails"
            Begin Extent = 
               Top = 6
               Left = 240
               Bottom = 360
               Right = 395
            End
            DisplayFlags = 280
            TopColumn = 0
         End
      End
   End
   Begin SQLPane = 
   End
   Begin DataPane = 
      Begin ParameterDefaults = ""
      End
      Begin ColumnWidths = 13
         Width = 284
         Width = 1440
         Width = 1440
         Width = 1440
         Width = 1440
         Width = 1440
         Width = 1440
         Width = 1440
         Width = 1440
         Width = 1440
         Width = 1440
         Width = 1440
         Width = 1440
      End
   End
   Begin CriteriaPane = 
      PaneHidden = 
      Begin ColumnWidths = 11
         Column = 1440
         Alias = 900
         Table = 1170
         Output = 720
         Append = 1400
         NewValue = 1170
         SortType = 1350
         SortOrder = 1410
         GroupBy = 1350
         Filter = 1350
         Or = 1350
         Or = 1350
         Or = 1350
         Or = 1350
         Or = 1350
         Or = 1350
      End
   End
End
' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'VIEW',@level1name=N'vSQLPerfSXAYesterday'
GO
EXEC sys.sp_addextendedproperty @name=N'MS_DiagramPaneCount', @value=1 , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'VIEW',@level1name=N'vSQLPerfSXAYesterday'
GO
USE [master]
GO
ALTER DATABASE [DBA] SET  READ_WRITE 
GO
