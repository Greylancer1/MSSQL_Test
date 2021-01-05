Function Write-MSSQLWinEventLog()
{

	#requires -Version 2
	
	<#
		.SYNOPSIS
		Write to Application LocalComputer Eventlog
		.DESCRIPTION
		Write to Application LocalComputer Eventlog
		.PARAMETER Source
		Mandatory String
		Source EventLog
		.PARAMETER EventID
		Mandatory Int
		EventID Eventlog
		.PARAMETER EntryType
		Mandatory String
		Entry Type to Eventlog . Can be Error, Information Warning
		.PARAMETER Message
		Mandatory String
		Message to Display
		.LINK
		www.laertejuniordba.spaces.live.com
		
	#>
	[CmdletBinding()]
	
	Param (
	
	[Parameter(Position=1,Mandatory=$true, ValueFromPipelineByPropertyName=$true,HelpMessage="Source")]
	[Alias("SourceName")]
	[String] $Source ,

	[Parameter(Position=2,Mandatory=$true, ValueFromPipelineByPropertyName=$true,HelpMessage="EventID")]
	[Alias("EventIDNumber")]
	[int] $EventID ,
	
	[Parameter(Position=3,Mandatory=$true, ValueFromPipelineByPropertyName=$true,HelpMessage="EntryType")]
	[Alias("EntryTypeString")]
	[ValidateScript({$_ -match "Error|Warning|Information"})]
	[string] $EntryType ,	

	[Parameter(Position=4,Mandatory=$true, ValueFromPipelineByPropertyName=$true,HelpMessage="Message")]
	[Alias("MessageString")]
	[string] $Message 


	)
	Process
	{


		if (!(test-path "HKLM:\SYSTEM\CurrentControlSet\Services\Eventlog\Application\$Source"))
		{
			[System.Diagnostics.EventLog]::CreateEventSOurce($Source,"Application")
		}	
		
		Write-EventLog  -computername $env:computername -logname Application -source $source  -eventID $eventid -entrytype $EntryType -message $Message -ErrorAction SilentlyContinue
	}	
}	

Function Get-MSSQLIndexInfo ()	
{
	#Requires Powershell 2.0
	
	<#
		.SYNOPSIS
		Returns information about index
		
		.DESCRIPTION
		Returns information about index
		Version 1.0
		Laerte Poltronieri Junior
		www.laertejuniordba.spaces.live.com
		
		.PARAMETER TXTServersList
		Optional String
		Full SQL Server file list
		"C:\<path>\<FileName>.txt"
		If not informed, the current server is used.
		
		.LINK
		www.laertejuniordba.spaces.live.com
		
		.EXAMPLE
		Get-MSSQLIndexInfo 
		Get-MSSQLIndexInfo C:\Servers.txt
		
	#>
	
	[CmdletBinding()]
	
	PARAM	(	
	
			[Parameter(Position=1,Mandatory=$False, ValueFromPipelineByPropertyName=$true,HelpMessage="SQL Servers File")]
			[Alias("FullNameTXT")]
			[String] $TXTServersList = $env:COMPUTERNAME
			)
	Begin
	{
		[reflection.assembly]::LoadWithPartialName("Microsoft.SqlServer.Smo") | out-null 
	}	

	Process
	{
		$verbosePreference="continue" 
		$TodayDate = get-date -format "yyyy-MM-dd hh:mm:ss" 
		$Error.Clear()

		if ($TXTServersList.substring($TXTServersList.length -4,4) -eq ".TXT")
		{
			try
			{
				$ServersList = get-content $TXTServersList	
			} catch {
						$msg = $error[0]
						Write-Warning -Message $msg	
						Write-MSSQLWinEventLog "Get-MSSQLIndexInfo" 70 "ERROR" $MSG
						break;
			}
		}	
		else
		{
			$ServersList = $TXTServersList
		}	
		
		$LineNumber = 1
		$FinalResult = @()
	
		foreach ($svr in  $ServersList )
		{
		
			try
			{
		
				$Server=New-Object "Microsoft.SqlServer.Management.Smo.Server" "$svr"
				$Server.Databases   | where-object {(!$_.IsSystemObject)  -and	$_.IsAccessible -and $_.name -eq "DBA" } | foreach {
					$DatabaseName = $_.name
					foreach  ($tables in $Server.Databases[$_.name].tables ) {
						if (!$tables.IsSystemObject)
						{
							$TableName = $tables.name
							$TableRowCount = $tables.rowcount
							$TableIsHeap = !($tables.hasclusteredindex)
							foreach ($index in $tables.indexes)
							{ 
								$Enum = $index.EnumFragmentation(3) 
								$Fragmentation = $enum.rows[0].AverageFragmentation
								$PageCount = $enum.rows[0].Pages
								[String] $IndexedColumns = $Index.IndexedColumns

								$ObjectIndex = New-Object PSObject -Property @{
									LineNumber 		= $LineNumber
									Date 			= $TodayDate
									ServerName 		= $Server.Name
									Databasename 	= $DatabaseName
									Tablename		= $TableName
									TableisHeap		= $TableIsHeap
									TableRowCount	= $TableRowCount
									IndexName		= $Index.name
									IndexedColumns	= $IndexedColumns
									Fragmentation 	= $Fragmentation
									PageCount 		= $PageCount
									PhysicalPartitions = $Index.PhysicalPartitions
									FillFactor      = $Index.FillFactor
									ISclustered		= $index.ISclustered
									IsSystemObject  = $index.IsSystemObject
									SpaceUsed		= $index.SpaceUsed }

								$FinalResult += $ObjectIndex
								$LineNumber ++ 
									
								
							}	
							
						}
					}
				
				}	
			}catch {
					$msg = $error[0]
					Write-Warning $msg 
					Write-MSSQLWinEventLog "Get-MSSQLIndexInfo" 70 "Information" $MSG
					continue
			
			}
	
		}	
		Write-Output $FinalResult				
	}
}	

