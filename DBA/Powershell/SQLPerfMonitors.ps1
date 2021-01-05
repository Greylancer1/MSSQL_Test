$Servers = invoke-sqlcmd -ServerInstance sqldba -Database DBA -Query "SELECT server FROM vservers"
 
    $Servers | ForEach-Object{
 $a = 0 
 do
 {
 $server = $_.server
 $monitorServer = "sqldba" 
 $monitorDB = "DBA" 
 $counters = @("\Memory\Available MBytes",
 "\Memory\Pages/sec",
 "\PhysicalDisk(_Total)\Avg. Disk sec/Read",
 "\PhysicalDisk(_Total)\Avg. Disk sec/Write",
 "\PhysicalDisk(_Total)\Current Disk Queue Length",
 "\PhysicalDisk(*)\Avg. Disk sec/Read",
 "\PhysicalDisk(*)\Avg. Disk sec/Write",
 "\PhysicalDisk(*)\Current Disk Queue Length",
 "\Process(sqlservr)\% Privileged Time",
 "\Process(sqlservr)\% Processor Time",
 "\Processor(_Total)\% Privileged Time",
 "\Processor(_Total)\% Processor Time",
 "\SQLServer:Buffer Manager\Buffer cache hit ratio",
 "\SQLServer:Buffer Manager\Lazy writes/sec",
 "\SQLServer:Buffer Manager\Page life expectancy",
 "\SQLSERVER:Memory Manager\Memory Grants Pending" ,
 "\SQLServer:SQL Statistics\Batch Requests/sec",
 "\System\Context Switches/sec",
 "\System\Processor Queue Length" 
 ) 
 $sequence=1 
 $collections = Get-Counter -ComputerName $server -Counter $counters -SampleInterval 10 -MaxSamples 1
 Write-Output $collections 
 foreach ($collection in $collections) 
 {$sampling = $collection.CounterSamples | Select-Object -Property TimeStamp, Path, Cookedvalue 
 $xmlString = $sampling | ConvertTo-Xml -As String
 #dbo.usp_InserPerfmonCounter is the stored procedure that is used to insert collected data to testperf database
 $query = "dbo.usp_InsertPerfmonCounter '$xmlString';" 
 Invoke-Sqlcmd -ServerInstance $monitorServer -Database $monitorDB -Query $query
 Write-Output $sampling
 $sequence+=1}
 #Write-Output $sampling 
 #Write-Output $xmlString 
 #Write-Output $query 
 $a+=1
 Write-Output $a
 }
 while($a-lt 1) 
 }