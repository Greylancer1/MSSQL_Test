Function CompareServers_Jobs ($srvOne, $srvTwo, $smo, $file, $name = $null)
{
    $nl = [Environment]::NewLine
    Add-Type -Path $smo
   
    $s1 = New-Object Microsoft.SqlServer.Management.SMO.Server($srvOne)
    $s2 = New-Object Microsoft.SqlServer.Management.SMO.Server($srvTwo)
 
    if ($name -eq $null)
    {
        $prod_tplt = $s1.JobServer.Jobs
        $cps_tplt = $s2.JobServer.Jobs
    }
    else
    {
        $prod_tplt = $s1.JobServer.Jobs | Where-Object {$_.Name -like "$name*" }
        $cps_tplt = $s2.JobServer.Jobs | Where-Object {$_.Name -like "$name*" }
    }
 
    $y_prod = Compare-Object $prod_tplt.Name $cps_tplt.Name
    $in = $srvOne + "," + $srvTwo
    Add-Content $file $in
 
    foreach ($i in $y_prod)
    {
        if ($i.SideIndicator -eq "<=")
        {
            $v = $i.InputObject + ","
            Add-Content $file $v
        }
        elseif ($i.SideIndicator -eq "=>")
        {
            $v = "," + $i.InputObject
            Add-Content $file $v
        }
    }
}
 
CompareServers_Jobs -srvOne "ServerOne\IOne" -srvTwo "ServerTwo\ITwo" -smo "C:\Program Files\Microsoft SQL Server\100\SDK\Assemblies\Microsoft.SqlServer.Smo.dll" -file "C:\Environments\jobs.csv"