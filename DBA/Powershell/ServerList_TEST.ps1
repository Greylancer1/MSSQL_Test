$isodate=Get-Date -format s 
  
$isodate=$isodate -replace(":","")
  
$basepath="C:\health\SQL_Server\config\"
  
$outputfile="Instances.txt"
  
$outputfilefull = $basepath + $outputfile


$dt = new-object "System.Data.DataTable" 


$cn = new-object System.Data.SqlClient.SqlConnection "server=SCOMOPSDB1P;database=OperationsManager;Integrated Security=sspi" 
   
$cn.Open() 
      
$sql = $cn.CreateCommand() 
      
$sql.CommandText = "select DISTINCT TargetObjectDisplayName
from RelationshipGenericView
where isDeleted=0
AND SourceObjectDisplayName like 'SQL Server Computers'
ORDER BY TargetObjectDisplayName"

$rdr = $sql.ExecuteReader() 
$dt.Load($rdr) 

$dt | Export-Csv $outputfilefull -NoTypeInformation | get-content $outputfilefull | foreach-object { $- -replace """" ,""} | set-content $outputfilefull