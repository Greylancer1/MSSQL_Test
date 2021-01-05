USE msdb ;  

SELECT * FROM dbo.sysmail_faileditems

SELECT * FROM msdb.dbo.sysmail_unsentitems

SELECT * FROM msdb.dbo.sysmail_sentitems
ORDER BY sent_date DESC

SELECT * FROM msdb.dbo.sysmail_mailattachments