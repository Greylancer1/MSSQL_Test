Function Get-ScriptByVersion {
    Param (
        [string]$server
        , [string]$location
        , [string]$name
    )
    Process
    {
        $smolibrary = "C:\Program Files (x86)\Microsoft SQL Server\110\SDK\Assemblies\Microsoft.SqlServer.Smo.dll"
        Add-Type -Path $smolibrary
        $srv = New-Object Microsoft.SqlServer.Management.SMO.Server($server)
        $version = $srv.VersionMajor.ToString()
        switch ($version)
        {
            8 { $version = "2000" }
            9 { $version = "2005" }
            10 { $version = "2008" }
            11 { $version = "2012" }
            12 { $version = "2014" }
        }
        $scriptloc = $location + $version + "\" + $name + ".sql"
        $sqlscript = Get-Content $scriptloc
        return $sqlscript
    }
}