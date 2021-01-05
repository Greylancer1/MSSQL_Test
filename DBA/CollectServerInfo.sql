select serverproperty('MachineName') MachineName
,serverproperty('ServerName') ServerInstanceName
,replace(cast(serverproperty('Edition')as varchar),'Edition','') EditionInstalled
,serverproperty('productVersion') ProductBuildLevel
,serverproperty('productLevel') SPLevel
,serverproperty('Collation') Collation_Type
,serverproperty('IsClustered') [IsClustered?]
,convert(varchar,getdate(),102) QueryDate,
case
when  exists (select * from msdb.dbo.backupset where name like 'data protector%') then 'HPDPused'
else 'NotOnDRP' -- where you would replace the
--data protector string with your third party backup solution
end