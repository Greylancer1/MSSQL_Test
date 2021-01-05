USE [MSDB]
GO

-- View the Maintenance plan subplans 
select * from sysmaintplan_subplans

-- View the Maintenance plan logs 
select * from sysmaintplan_log
ORDER BY end_time DESC



USE [MSDB]
go

--Delete the Log history for the maintenance plan affected 
DELETE FROM sysmaintplan_log
WHERE subplan_id in 
  ( SELECT Subplan_ID from sysmaintplan_subplans
    -- change Subplan name where neccessary 
  WHERE subplan_id = '1512A2C3-9AB9-44ED-84A3-35AE6D2C925B' ) 

-- Delete the subplan 
DELETE FROM sysmaintplan_subplans
WHERE subplan_id = '1512A2C3-9AB9-44ED-84A3-35AE6D2C925B'