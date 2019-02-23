<#
    .SYNOPSIS
    Searches a directory for files older than a certain date a deletes the files and folders.

    .DESCRIPTION
    This does not run if there are less than 5 folders to delete.
    Stops the Services - Eventloganalyzer
    Deletes files and folders in D:\ManageEngine\EventLog Analyzer\ES\data\ELA-C1\nodes\0\indices
    Logs some metrics to a file.
    Starts the Services - Eventloganalyzer

    .PARAMETER baseNAME
    Describe parameter -baseNAME.

    .EXAMPLE
    Delete-IndicesFilesOlderThan.ps1
    Describe what this call does

    .NOTES
    Requirements - Powershell / Must be run on locally on Event Log Analyzer

    Script Name: Delete-IndicesFilesOlderThan.ps1
    Author Name: Raydi Haynes //rjh
    Contact : raydi.j.haynes.@mail

    Change Log:
    1.0 New Script --rjh
    1.1 Added a little more detail --eja
    1.2 Changed name to DeleteFilesOlder-Indices.ps1 and added more detail --eja
    1.3 Added function to deal with the services. --eja
    1.4 Corrected the f_serviceControl function --eja
    1.5 A number of changes to combine tasks --eja
    1.6 Much more clean up and added Recovered ammount --eja
    1.8 More standardization including a name change --eja

    .LINK
    URLs to related sites
    The first link is opened by Get-Help -Online New-TimeStampFileName

    .INPUTS
    List of input types that are accepted by this function.

    .OUTPUTS
    List of output types produced by this function.
#>

# Parameters
param($Outputfile = 'Cleanup.log') 

# Test if the script is "RunasAdminsitrator"
$asAdmin = ([Security.Principal.WindowsPrincipal] 	[Security.Principal.WindowsIdentity]::GetCurrent()).IsInRole([Security.Principal.WindowsBuiltInRole]::Administrator)

# Creates a unique name for the log file
function New-TimeStampFileName {
  #$t = Get-Date -uformat "%y%m%d%H%M" # 1703162145 YYMMDDHHmm
  
  param
  (
    [Parameter(Mandatory=$true)]
    $baseNAME
  )
  $t = Get-Date -uformat '%Y%m%d' # 20170316 YYYYMMDD
  #$t = Get-Date -uformat "%d%H%M%S" # 16214855 DDHHmmss
  #$t = Get-Date -uformat "%y/%m/%d_%H:%M" # 17/03/16_21:52
  return $baseNAME + '-'+ $t + '.log'
}

# Time Stamp
Function script:f_TimeStamp(){
  $Script:TimeStamp = Get-Date -uformat '%m/%d/%y %H:%M:%S' # 10/27/2017 21:52:34 (This matches the output for "Date Deleted to" to help readablity
  return $TimeStamp
}

# Stops and starts services
Function script:f_serviceControl{
  
  param
  (
    [Parameter(Mandatory=$true)]
    $Service,

    [Parameter(Mandatory=$true)]
    $state
  )
  Write-Debug -Message 'ServiceControl'
  if($state -eq 'Stop'){
    Stop-Service $Service #-WhatIf
  }
  if($state -eq 'Start'){
    Start-Service $Service #-WhatIf
  }
}


# Output File
# Create the output file and setup the output
function script:f_Output
{

  
  param
  (
    [Parameter(Mandatory=$true)]
    $Outputfile,

    [Parameter(Mandatory=$true)]
    $strtTime,

    [Parameter(Mandatory=$true)]
    $stopTime
  )
  if(!(test-path $Outputfile)){New-Item $Outputfile -type file -Force}

  '===================================' | Out-File $Outputfile -Append
  ('Start Date/Time - {0}' -f $strtTime) | Out-File $Outputfile -Append
  ('Amount of days to save - {0}' -f $dayLimit) | Out-File $Outputfile -Append
  ('Deleted files created before - {0}' -f $limit) | Out-File $Outputfile -Append

  if($filecnt -gt 4)	{
    ('Number of Folders deleted - {0}' -f $filecnt) | Out-File $Outputfile -Append
    ('Amount of space reclaimed - {0}' -f $spaceRecovered) | Out-File $Outputfile -Append
  }
  ('Stop Date/Time - {0}' -f $stopTime) | Out-File $Outputfile -Append
}

# Delete files and folders
function script:f_deleteFileFold(){
  $bforSum = Get-FileFolderMetrics 'sum'
  ### Remove the WHATIF statement to run this live
  Get-ChildItem -Directory $path -Recurse | Where-Object CreationTime -lt $limit | Remove-Item -Force -Recurse -WhatIf
  $aftrSum = Get-FileFolderMetrics 'sum'
  $Script:spaceRecovered = $bforSum.sum - $aftrSum.sum
}

function Get-FileFolderMetrics([Parameter(Mandatory=$true)][Object]$r)
{
  $FileCount = (Get-ChildItem -Directory $path | Where-Object CreationTime -lt $limit).count
  FileSum = Get-ChildItem $path -Recurse | Measure-Object -Property -Length -Sum
  
  if ($r -eq 'cnt'){
    # Count
    (		Get-ChildItem -Directory $path | Where-Object CreationTime -lt $limit).count
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
Set-Location "$env:HOMEDRIVE\temp" #CleanUpScript"

# Service Name
#$Script:Service = Get-Service Eventloganalyzer

# Set name of file
$Script:Outputfile = 'Indices-Cleanup.log' # New-TimeStampFileName Incides-Cleanup

# Sets Files for deletion
$Script:path = '.\%HomeFolder%\Documents' #"D:\ManageEngine\EventLog Analyzer\ES\data\ELA-C1\nodes\0\indices"

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
  $Script:fileCount = Get-FileFolderMetrics 'cnt'

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
  Write-Verbose -Message '*********** Re-run as an administrator *************'
}

