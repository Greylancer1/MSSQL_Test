USE LeadFlow SELECT name, sid FROM sys.sysusers WHERE name = 'ReportingOnly1'
USE MASTER SELECT name, sid FROM sys.sql_logins WHERE name = 'ReportingOnly1'


USE [master]
GO

/* For security reasons the login is created disabled and with a random password. */
/****** Object:  Login [ReportingOnly1]    Script Date: 2/1/2017 12:52:07 PM ******/
CREATE LOGIN [ReportingOnly1] WITH PASSWORD=N'czXkjFz4s/2H53jXOIIHuKBbM2rph9X4oQ5LJkQlsBQ=', DEFAULT_DATABASE=[master], DEFAULT_LANGUAGE=[us_english], CHECK_EXPIRATION=OFF, CHECK_POLICY=OFF, SID = 0x8B620367E4575A4993BD3D2864DEAB58
GO
