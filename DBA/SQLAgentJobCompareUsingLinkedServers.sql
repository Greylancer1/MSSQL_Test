--Create Linked Server to other node
SELECT @@servername AS 'Exists On', * FROM [VHYTestCSQL01.hywd.ipzo.net\SIMSAFTSQL1].[msdb].[dbo].[sysjobs]
WHERE name NOT IN (SELECT name FROM [msdb].[dbo].[sysjobs])