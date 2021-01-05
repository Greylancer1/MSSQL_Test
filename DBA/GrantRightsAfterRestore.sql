CREATE ROLE db_executor

-- Grant execute rights to the new role
GRANT EXECUTE TO db_executor

USE master 
GO 
GRANT VIEW ANY DEFINITION TO [HYWD\PROD_BU_SQLAccess_RWE]

--Grant specific rights to all db's
SET NOCOUNT ON;

DECLARE @user_name    SYSNAME
        , @login_name SYSNAME;

SELECT @user_name = 'HYWD\PROD_BU_SQLAccess_RWE',
       @login_name = 'HYWD\PROD_BU_SQLAccess_RWE'

SELECT 'USE ' + QUOTENAME(NAME) + ';
        CREATE USER ' + QUOTENAME(@user_name)
       + ' FOR LOGIN ' + QUOTENAME(@login_name)
       + ' WITH DEFAULT_SCHEMA=[dbo];
    EXEC sys.sp_addrolemember ''db_datareader'',''' + @user_name + ''';
    EXEC sys.sp_addrolemember ''db_datawriter'', ''' + @user_name + '''; 
    EXEC sys.sp_addrolemember ''db_executor'', ''' + @user_name + '''; 
GO'
FROM   sys.databases
WHERE  database_id > 4
       AND state_desc = 'ONLINE' 


--Grant specific rights to all db's
SET NOCOUNT ON;

DECLARE @user_name    SYSNAME
        , @login_name SYSNAME;

SELECT @user_name = 'HYWD\HYWD_PHBSQL01_RW',
       @login_name = 'HYWD\HYWD_PHBSQL01_RW'

SELECT 'USE ' + QUOTENAME(NAME) + ';
        CREATE USER ' + QUOTENAME(@user_name)
       + ' FOR LOGIN ' + QUOTENAME(@login_name)
       + ' WITH DEFAULT_SCHEMA=[dbo];
    EXEC sys.sp_addrolemember ''db_datareader'',''' + @user_name + ''';
    EXEC sys.sp_addrolemember ''db_datawriter'', ''' + @user_name + '''; 
GO'
FROM   sys.databases
WHERE  database_id > 4
       AND state_desc = 'ONLINE' 
