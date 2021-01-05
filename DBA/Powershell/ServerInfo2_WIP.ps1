$SystemInfo = GWMI Win32_ComputerSystem
$ProcessorInfo = GWMI Win32_Processor
$DriveInfo = Get-PSDrive C
$Properties= @{
ComputerName = $SystemInfo.Name
ProcessorType = $SystemInfo.SystemType
ProcessorSpeed_GHZ = [math]::Round($ProcessorInfo.MaxClockSpeed/1000,1)
SystemRam_GB = [math]::Round($SystemInfo.TotalPhysicalMemory/1GB,1)
SystemDriveFreeSpace_GB = [math]::Round($DriveInfo.Free/1GB,1)
}
$SystemConfiguration = New-Object PSObject -Property $Properties
clear
$SystemConfiguration | FT ComputerName,ProcessorType,ProcessorSpeed_GHZ,SystemRAM_GB,SystemDriveFreeSpace_GB -AutoSize

Get-WindowsFeature -Name Net-Framework*,Powershell*