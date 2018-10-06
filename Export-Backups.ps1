<#
.SYNOPSIS
    Export Backup Files to Share Drive and Delete Old Files on Share
.DESCRIPTION
    We needed to export SQL backups to a share along with deleting old files. 
    This was the workaround. Make sure you update the file paths on lines 18, 38, 40, and 43!
.NOTES
    File Name      : Export-DBBackups.ps1
    Author         : Alex Flom (https://github.com/afflom)
    Prerequisite   : PowerShell V2 over Vista and upper.
    Copyright 2018 - Alex Flom
.LINK
    Script posted over:
    https://github.com/afflom/quick-scripts
#>

#Get Backup Directories
$folderList = (Get-ChildItem -Path '.\Documents\Powershell Scripts\BackupSandbox\').fullname
#Declare obsolete backups
$old = Get-date.addDays(-14)
#Loop through the directories
foreach($folder in $folderList){
    #Find Backup in folder
    $var = Get-ChildItem -Path $folder
    #Get Backup Name
    $name = $var.BaseName
    #Get Backup size
    $size = $var.Length
    #Get Backup time
    $date = $var.CreationTime
    #Setup .CSV column names
    $outputList = [PSCustomObject]@{
        Name = $name
        Size = $size
        Date = $date
    }
    #Add to backup log
    $outputList | Export-Csv -NoTypeInformation -Path '.\Documents\Powershell Scripts\backups.csv' -Delimiter ','  -Append
    #Export backup to share
    Move-Item -Path $folder\*.bak -Destination $folder\..\..\movefolder\
}
#Delete old backups
Get-ChildItem -Path $folder\..\..\movefolder\ | Where-Object { !$_.PSIsContainer -and $_.CreationTime -lt $old } | Remove-Item -Force
