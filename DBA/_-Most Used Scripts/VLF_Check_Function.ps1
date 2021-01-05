#requires -version 2
<#
.Synopsis
   This function returns the  VLFCount for databases against severs passed into it. 
.Description 
   Connects to each server and runs DBCC LOGINFO, returning the RowCount
.EXAMPLE
   Get-VLFCount -ComputerName ComputerName
.EXAMPLE
   Get-Content D:\ServerList.txt | Get-VLFCount

   If you are using Windows Authentication and have a list of servers you can use this.
.EXAMPLE
   Get-VLFCount -ComputerName ComputerName1, ComputerName2

#>
function Get-VLFCount
{
    [CmdletBinding()]
    Param
    (
        # SQLInstance is the name(s) of the SQL Instances to scan        
        [Parameter(Mandatory=$true,
                   ValueFromPipeline=$True,
                   ValueFromPipelineByPropertyName=$true,
                   Position=0)]
        $SQLInstance
    )  
    Begin
    {
        #Load the Assembly to connect to the SQL Instance. #The begin block is appropriate location for this since only needs to be loaded once.
        #PowerShell v1 way of loading Assembly        
        [System.Reflection.Assembly]::LoadWithPartialName('Microsoft.SqlServer.SMO') | out-null
        [System.Reflection.Assembly]::LoadWithPartialName('Microsoft.SqlServer.ConnectionInfo') | out-null
        #PowerShell v2 way of loading Assembly but you have to specify Path to .dll
        #Add-type -Path 'C:\Program Files\Microsoft SQL Server\110\SDK\Assemblies\Microsoft.SqlServer.Smo.dll'    
    }
    Process
    {
        ForEach ($Instance in $SQLInstance)
        {       
            $SrvConn = new-object Microsoft.SqlServer.Management.Common.ServerConnection
            $SrvConn.ServerInstance = $Instance
            #Use Integrated Authentication
            $SrvConn.LoginSecure =$true
            $SrvConn.ConnectTimeout =5
            Write-Debug "Attempting to check $Instance for VLF Counts"
            $srv  =new-object Microsoft.SqlServer.Management.SMO.Server($SrvConn)
            $dbs = $srv.Databases
            try
            {
                ForEach ($db in $dbs) 
                {
                    Write-Debug "Getting VLFInfo for $db"
                    if ($db.IsAccessible)            
                    {

                        $VLFs=$db.ExecuteWithResults("DBCC LOGINFO")
                        $NumVLFs=$VLFs.Tables[0].Rows.count
                        $VLFinfo=$db | Select @{Name='InstanceName'; expression={$Instance}}, @{Name='DBName'; Expression = {$_.name}} `
                        , @{Name='VLFCount'; Expression={$NumVLFs}}

                    }
                    else
                    {
                        $VLFInfo=New-Object psobject
                        $VLFInfo | Add-Member-type NoteProperty -name InstanceName ($Instance)
                        $VLFInfo | Add-Member-type NoteProperty -name DBName ("$DB is Inaccessible")
                        $VLFInfo | Add-Member-type NoteProperty -name VLFCount 0
                    }
                    Write-Output $VLFinfo
                }

            }
            catch
            {
                $ex=$_.Exception 
                Write-Debug "$ex.Message"
                Write-Error "Could not pull SQL DB Info on $Instance"
            }

        }
    }
} #Get-VLFCount 