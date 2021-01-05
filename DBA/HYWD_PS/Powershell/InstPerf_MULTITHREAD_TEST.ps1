cls
$Throttle = 5 #threads
 
$ScriptBlock = {
   $Servers = invoke-sqlcmd -ServerInstance sqldba -Database DBA -Query "SELECT name FROM servermon WHERE monitored IS NULL"
   foreach ($Server in $Servers){
   $Server.name
   $dt = invoke-sqlcmd2 -ServerInstance $Server.name -InputFile C:\health\SQL_Server\SQL\InstancePerfStats.sql -As ‘DataTable’
   Write-DataTable -ServerInstance "SQLDBA" -Database "DBA” -TableName "InstPerfMon” -Data $dt
   }
   Return $dt
}
 
$RunspacePool = [RunspaceFactory]::CreateRunspacePool(1, $Throttle)
$RunspacePool.Open()
$Jobs = @()
 
1..20 | % {
   #Start-Sleep -Seconds 1
   $Job = [powershell]::Create().AddScript($ScriptBlock).AddArgument($_)
   $Job.RunspacePool = $RunspacePool
   $Jobs += New-Object PSObject -Property @{
      RunNum = $_
      Pipe = $Job
      Result = $Job.BeginInvoke()
   }
}
 
Write-Host "Waiting.." -NoNewline
Do {
   Write-Host "." -NoNewline
   Start-Sleep -Seconds 1
} While ( $Jobs.Result.IsCompleted -contains $false)
Write-Host "All jobs completed!"
 
$Results = @()
ForEach ($Job in $Jobs)
{   $Results += $Job.Pipe.EndInvoke($Job.Result)
}
 
$Results | Out-GridView