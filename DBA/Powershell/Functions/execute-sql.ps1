Function Execute-SQL {
    Param (
    [string]$server
    , [string]$database 
    , [string]$commandtext
    )
    Process
    {
        $scon = New-Object System.Data.SqlClient.SqlConnection
        $scon.ConnectionString = "Data Source=$server;Initial Catalog=$database;Integrated Security=true;Connection Timeout=0;"
        $cmd = New-Object System.Data.SqlClient.SqlCommand
        $cmd.Connection = $scon
        $cmd.CommandText = $commandtext
        $cmd.CommandTimeout = 0
        try
  {
   $scon.Open()
   $cmd.ExecuteNonQuery() | Out-Null
  }
  catch
  {
   Write-Host "Exeption message."
  }
  finally
  {
   $scon.Dispose()
   $cmd.Dispose()
  }
    }
}