----------------------------------------------------------------------
--  This SP generates the Database Space Reports. Select information
--  from table DASD is place into temp table #DASDRpt along with certain
--  computed values (see below). The contents of table #DASDRpt is finally
--  selected as the Database Space Report.
----------------------------------------------------------------------
use msdb
go
create procedure sp_DASD_Report
 as
set nocount on
 
create table #DASDRpt 
(
createDTM         varchar(20),
SQL_Server        varchar(30),
db_name           varchar(30),
group_type        varchar(20),
total_DB_space    varchar(10),
free_DB_space     varchar(10),
free_drive_space  varchar(10),
db_maxsize        int,
db_growth         int,
max_db_size       varchar(13),
autogrow          char(5)
)

---
insert into #DASDRpt
  select
       createDTM,
       SQL_Server,
       db_name,
       group_type,
       total_DB_space,
       free_DB_space,
       free_drive_space,
       db_maxsize,
       db_growth,
       '   ',
       ' YES '
   from msdb..DASD
where db_name != 'tempdb'
  and createDTM > convert(varchar(08),(dateadd(wk, -6,getdate())),112)
  and datepart(dw,(convert(datetime,substring(createDTM,1,8)))) = 6
  and substring(createDTM,9,2) = '04'
order by substring(db_name,1,30), substring(createDTM,1,16)

----------------------------------------------------------------------
-- No Autogrowth, DB restricted to current allocated space
----------------------------------------------------------------------
Update #DASDRpt
 set max_db_size = total_DB_space,
     autogrow  = '     '
where db_growth   = 0

----------------------------------------------------------------------
-- Autogrowth on, Unrestricted Growth limited only by disk space
----------------------------------------------------------------------
Update #DASDRpt 
 set max_db_size = 'Unrestricted'
where db_growth   > 0
  and db_maxsize  < 0

----------------------------------------------------------------------
-- Autogrowth on, Restrictions placed on DB growth
----------------------------------------------------------------------
Update #DASDRpt
 set max_db_size = db_maxsize
where db_growth   > 0
  and db_maxsize  > 0

----------------------------------------------------------------------
-- Select information from #DASDRpt for Database Space Reports
----------------------------------------------------------------------
select substring(createDTM,1,08) 'Date',
       substring(SQL_Server,1,14) 'SQL SERVER    ',
       db_name 'DB Name       ',
       total_DB_space 'Total DB MB  ',
       free_DB_space 'Free DB MB  ',
       autogrow 'Autogrow',
       max_db_size  'Max DB Size  ',
       free_drive_space 'Free Disk MB '
 from #DASDRpt
order by substring(db_name,1,14), substring(createDTM,1,08) 
go
