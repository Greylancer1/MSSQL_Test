/*
	INSTRUCTIONS:
		Replace Parameters (CTRL+SHIFT+M or Query > Specify Values for Templates)
			For more information on parameters (i.e., ) see the following:
				http://www.sqlservervideos.com/video/sql-server-2008-t-sql-enhancements/ 

	PARAMETERS:
		 - Name of the Operator/Alias to alert. 
		 - Bitmap of notification types/options: 1 = email, 2 = pager, 4 = netsend

*/


-- 1480 - AG Role Change (failover)
EXEC msdb.dbo.sp_add_alert
	@name = N'AG Role Change',
	@message_id = 1480,
    @severity = 0,
    @enabled = 1,
    @delay_between_responses = 0,
    @include_event_description_in = 1;
GO
EXEC msdb.dbo.sp_add_notification 
	@alert_name = N'AG Role Change', 
	@operator_name = N'', 
	@notification_method = ; 
GO

-- 35264 - AG Data Movement - Resumed
EXEC msdb.dbo.sp_add_alert
	@name = N'AG Data Movement - Suspended',
	@message_id = 35264,
    @severity = 0,
    @enabled = 1,
    @delay_between_responses = 0,
    @include_event_description_in = 1;
GO
EXEC msdb.dbo.sp_add_notification 
	@alert_name = N'AG Data Movement - Suspended', 
	@operator_name = N'', 
	@notification_method = ; 
GO

-- 35265 - AG Data Movement - Resumed
EXEC msdb.dbo.sp_add_alert
	@name = N'AG Data Movement - Resumed',
	@message_id = 35265,
    @severity = 0,
    @enabled = 1,
    @delay_between_responses = 0,
    @include_event_description_in = 1;
GO
EXEC msdb.dbo.sp_add_notification 
	@alert_name = N'AG Data Movement - Resumed', 
	@operator_name = N'', 
	@notification_method = ; 
GO