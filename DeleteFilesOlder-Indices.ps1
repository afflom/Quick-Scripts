<####################
Script Name: DeleteFilesOlder-Indices.ps1
Author Name: Raydi Haynes //rjh
Contact : raydi.j.haynes.@mail
 
Requirements - Powershell / Must be run on locally on Event Log Analyzer

.SYNOPSIS
This scripts does the following:
- Searches a directory for files older than a certain date a deletes the files and folders.  If there isn't more then 5 folders to delete it does not run.

.DESCRIPTION
 Stops the Services - Eventloganalyzer
 Deletes files and folders in "D:\ManageEngine\EventLog Analyzer\ES\data\ELA-C1\nodes\0\indices"
 Starts the Services - Eventloganalyzer


.EXAMPLE
 DeleteFilesOlder-Indices.ps1
 
Change Log:
 1.0 New Script //rjh
 1.1 Added a little more detail //eja
 1.2 Changed name to "DeleteFilesOlder-Indices.ps1" and added more detail //eja
 1.3 Added function to deal with the services. //eja
 1.4 Corrected the f_serviceControl function //eja
 1.5 A number of changes to combine tasks //eja
 1.6 Much more clean up and added Recovered ammount //eja
 

###########################>


# Parameters
param($Outputfile = "Cleanup.log") 


#Functions 
#------------

# Test if the script is "RunasAdminsitrator"
$asAdmin = ([Security.Principal.WindowsPrincipal] `
	[Security.Principal.WindowsIdentity]::GetCurrent() `
).IsInRole([Security.Principal.WindowsBuiltInRole]::Administrator)


# Creates a unique name for the log file
function f_tdFILEname ($baseNAME) {
	#$t = Get-Date -uformat "%y%m%d%H%M" # 1703162145 YYMMDDHHmm
	$t = Get-Date -uformat "%Y%m%d" # 20170316 YYYYMMDD
	#$t = Get-Date -uformat "%d%H%M%S" # 16214855 DDHHmmss
	#$t = Get-Date -uformat "%y/%m/%d_%H:%M" # 17/03/16_21:52
	return $baseNAME + "-"+ $t + ".log"
}

# Time Stamp
Function f_TimeStamp(){
 $Script:TimeStamp = Get-Date -uformat "%m/%d/%y %H:%M:%S" # 10/27/2017 21:52:34 (This matches the output for "Date Deleted to" to help readablity
return $TimeStamp
}

# Stops and starts services
Function f_serviceControl($Service, $state){
	Write-Debug -Message "ServiceControl"
	if($state -eq "Stop"){
		Stop-Service $Service #-WhatIf
	}
	if($state -eq "Start"){
		Start-Service $Service #-WhatIf
	}
}


# Output File
# Create the output file and setup the output
function f_Output($Outputfile, $strtTime, $stopTime)
{

	if(!(test-path $Outputfile)){New-Item $Outputfile -type file -Force}

	"===================================" | Out-File $Outputfile -Append
	"Start Date/Time - $strtTime" | Out-File $Outputfile -Append
	"Amount of days to save - $dayLimit" | Out-File $Outputfile -Append
	"Deleted files created before - $limit" | Out-File $Outputfile -Append

	if($filecnt -gt 4)	{
		"Number of Folders deleted - $filecnt" | Out-File $Outputfile -Append
		"Amount of space reclaimed - $spaceRecovered" | Out-File $Outputfile -Append
	}
	"Stop Date/Time - $stopTime" | Out-File $Outputfile -Append
}

# Delete files and folders
function f_deleteFileFold(){
$bforSum = f_fileMath "sum"
Get-ChildItem -Directory $path -Recurse | where CreationTime -lt $limit | Remove-Item -Force -Recurse -WhatIf
$aftrSum = f_fileMath "sum"
$Script:spaceRecovered = $bforSum.sum - $aftrSum.sum
}

function f_fileMath($r){
if ($r -eq "cnt"){
	# Count
	(		Get-ChildItem -Directory $path | where CreationTime -lt $limit).count
}
else{
	# if ($r -eq "sum"){}
	Get-ChildItem $path -Recurse | Measure-Object -Property Length -Sum
}
}

# 

# User Settings
#<><><><><><><><><><><><><><><><><><><>
# Set working and log location
Set-Location "C:\temp" #CleanUpScript"

# Service Name
#$Script:Service = Get-Service Eventloganalyzer

# Set name of file
$Script:Outputfile = "Indices-Cleanup.log"

# Sets Files for deletion
$Script:path = "C:\Users\Erik.Arnesen\Documents" #"D:\ManageEngine\EventLog Analyzer\ES\data\ELA-C1\nodes\0\indices"

# Set date of when files will be deleted before.  
# Amount of days to keep.
# Delete all files before this day.
$Script:dayLimit = 4

#<><><><><><><><><><><><><><><><><><><>

# Begin Script
# ========================
if ($asAdmin -eq $true){

	# Math
	$Script:limit = (Get-Date).AddDays(-$dayLimit)
	$Script:fileCount = f_fileMath "cnt"

	# Test if there are files to be deleted
	if ($fileCount -gt 5){
		$strtTime = f_TimeStamp
		#f_serviceControl $Service "stop"
		#f_deleteFileFold
		#f_serviceControl $Service "start"
		$stopTime = f_TimeStamp
		f_Output $Outputfile $strtTime $stopTime
	}
}
else{
	Write-Host "*********** Re-run as an administrator *************" -ForegroundColor DarkYellow
}

# SIG # Begin signature block
# MIID7QYJKoZIhvcNAQcCoIID3jCCA9oCAQExCzAJBgUrDgMCGgUAMGkGCisGAQQB
# gjcCAQSgWzBZMDQGCisGAQQBgjcCAR4wJgIDAQAABBAfzDtgWUsITrck0sYpfvNR
# AgEAAgEAAgEAAgEAAgEAMCEwCQYFKw4DAhoFAAQUl6YO/kmQMsTP8A4egDuQcQf9
# d5qgggINMIICCTCCAXagAwIBAgIQyWSKL3Rtw7JMh5kRI2JlijAJBgUrDgMCHQUA
# MBYxFDASBgNVBAMTC0VyaWtBcm5lc2VuMB4XDTE3MTIyOTA1MDU1NVoXDTM5MTIz
# MTIzNTk1OVowFjEUMBIGA1UEAxMLRXJpa0FybmVzZW4wgZ8wDQYJKoZIhvcNAQEB
# BQADgY0AMIGJAoGBAKYEBA0nxXibNWtrLb8GZ/mDFF6I7tG4am2hs2Z7NHYcJPwY
# CxCw5v9xTbCiiVcPvpBl7Vr4I2eR/ZF5GN88XzJNAeELbJHJdfcCvhgNLK/F4DFp
# kvf2qUb6l/ayLvpBBg6lcFskhKG1vbEz+uNrg4se8pxecJ24Ln3IrxfR2o+BAgMB
# AAGjYDBeMBMGA1UdJQQMMAoGCCsGAQUFBwMDMEcGA1UdAQRAMD6AEMry1NzZravR
# UsYVhyFVVoyhGDAWMRQwEgYDVQQDEwtFcmlrQXJuZXNlboIQyWSKL3Rtw7JMh5kR
# I2JlijAJBgUrDgMCHQUAA4GBAF9beeNarhSMJBRL5idYsFZCvMNeLpr3n9fjauAC
# CDB6C+V3PQOvHXXxUqYmzZpkOPpu38TCZvBuBUchvqKRmhKARANLQt0gKBo8nf4b
# OXpOjdXnLeI2t8SSFRltmhw8TiZEpZR1lCq9123A3LDFN94g7I7DYxY1Kp5FCBds
# fJ/uMYIBSjCCAUYCAQEwKjAWMRQwEgYDVQQDEwtFcmlrQXJuZXNlbgIQyWSKL3Rt
# w7JMh5kRI2JlijAJBgUrDgMCGgUAoHgwGAYKKwYBBAGCNwIBDDEKMAigAoAAoQKA
# ADAZBgkqhkiG9w0BCQMxDAYKKwYBBAGCNwIBBDAcBgorBgEEAYI3AgELMQ4wDAYK
# KwYBBAGCNwIBFTAjBgkqhkiG9w0BCQQxFgQU0BrJ2jdCa11eoTj0+aDanstxiE8w
# DQYJKoZIhvcNAQEBBQAEgYA9UCZaf0OWQIiT5ON3/PYSd7DIaoY4t2RV+/p4SHBi
# SuBHRTFgG1dwSK51EnahHAWQ4M3BuxPHsULbJ9yjSYkpsLg3r105l+985rK70Bwz
# daKrSJ12LvBmwwpAilQk3GcpBIdd3Oi/VrtflBAiCwm68bpB5BUqt0jD9aid/Pxa
# dA==
# SIG # End signature block
