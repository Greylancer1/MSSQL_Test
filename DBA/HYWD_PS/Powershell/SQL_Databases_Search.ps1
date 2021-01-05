Clear-Host
Write-Host "Please wait for the list of databases to be compiled..." -ForegroundColor Yellow
[System.Refelction.Assembly]::LoadWithPartialname('Microsoft.SQLServer.SMO')
$Instances = [System.Data.SQL.SqlDataSourceEnumerator]::Instance.GetDataSources()
$Instance = @()
[int]$ICount = ($Instances | measure).count-1
[int]$Count = 0
While ($Count -le $ICount)
{If ($Instances.InstanceName[$Count].ToString() -eq "") {$Instances += $Instances.ServerName[$Count]}
Else {$Instance += $Instances.ServerName[$Count] + "\" + $Instances.InstanceName[$Count]}
$Server = New-Object Microsoft.SqlServer.Management.Smo.Server ($Instance[$Count])
[array]$DatabaseArray += $Server.databases | Select-Object @{Name="ServerName";Expression={$Instance[$Count]}},Name,Owner,Size,RecoveryModel,ReadOnly
$Count++
}
Clear-Host
$DatabaseArray | Export-Csv C:\Databases.csv
$DatabaseArray | FT ServerName,Name,Size,RecoveryModel,ReadOnly -AutoSize
Write-Host "The Database names have been exported to C:\Databases.csv" -ForegroundColor Green