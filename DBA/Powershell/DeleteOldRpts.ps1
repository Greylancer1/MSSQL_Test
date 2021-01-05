$root  = 'D:\InetPub\AmPfmReports\Rpts'
$limit = (Get-Date).AddDays(-15)

Get-ChildItem $root -Recurse | ? {
  -not $_.PSIsContainer -and $_.CreationTime -lt $limit
} | Remove-Item