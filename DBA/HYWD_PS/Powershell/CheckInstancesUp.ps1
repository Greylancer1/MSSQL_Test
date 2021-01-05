#Script created by Jack Vamvas  www.sqlserver-dba.com

$isodate=Get-Date -format s 
  
$isodate=$isodate -replace(":","")
  
$basepath="C:\health\SQL_Server\"
  
$outputfile="database_status_" + $isodate + ".html"
  
$outputfilefull = $basepath + $outputfile

 

$style = "" 

$dt = new-object "System.Data.DataTable" 

foreach ($svr in get-content "C:\health\SQL_Server\config\Instances.txt")

{$cn = new-object System.Data.SqlClient.SqlConnection "server=$svr;database=master;Integrated Security=sspi" 
   
$cn.Open() 
      
$sql = $cn.CreateCommand() 
      
$sql.CommandText = " SELECT @@servername, name, state_desc as Database_status FROM sys.databases " 
      
$rdr = $sql.ExecuteReader() 
$dt.Load($rdr) 
$cn.Close()
 
}
 
$dt | select * -ExcludeProperty RowError, RowState, HasErrors, Table, ItemArray | ConvertTo-Html -head $style -body "SQL Server Database Status Report" | Set-Content $outputfilefull