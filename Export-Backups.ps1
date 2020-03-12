<#
<<<<<<< HEAD
 .SYNOPSIS
   Exports files and keeps a running size log

 .DESCRIPTION
   Performs the following tasks:
       1. Moves files to new location
       2. Deletes old files at destination
       3. Builds a log file in CSV format to track backup sizes

 .NOTES
   File Name      : Export-DBBackups.ps1
   Authors        : Alex F. (https://github.com/afflom)
                  : Erik A. (https://github.com/OgJAkFy8)
   Prerequisite   : PowerShell V2 over Vista and upper.
   Copyright 2018 - Alex F. & Erik A.

 .LINK
   Script posted over:
   https://github.com/afflom/quick-scripts
=======
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
>>>>>>> origin/patch-2
#>
function Export-Backups{
    param(
        [Parameter(Mandatory=$True,Position=0)]
        $SourceFolder,

<<<<<<< HEAD
        [Parameter(Mandatory=$True,Position=1)]
        $FileType,

        [Parameter(Mandatory=$True,Position=2)]
        $DestinationFolder,
=======
  param
  (
    [Parameter(HelpMessage='Prefix of file or log name')]
    [alias('Daysback')]
    [int]$daysback = -14,

    [Parameter(HelpMessage='Extention of file.  txt, csv, log')]
    [alias('Extension')]
    [string]$tailNAME ='bak',
    [Parameter(HelpMessage='Formatting Choice 1 to 4')]
    [alias('Choice')]
    [ValidateRange(1,4)]
    [int]$StampFormat,
    [Parameter(Position = 0)] [string]$SourceFolder = "$env:HOMEDRIVE\temp\BackupSource",
    [Parameter(Position = 1)] [string]$DestinationFolder = "$env:HOMEDRIVE\temp\BackupDestination"
  )

#Get Backup Directories
$folderList = (Get-ChildItem -Path '.\Documents\Powershell Scripts\BackupSandbox\').fullname

#Declare obsolete backups
$old = Get-date.addDays($daysback)


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
    Move-Item -Path $SourceFolder\*.$tailNAME -Destination $DestinationFolder\..\..\movefolder\
}
#Delete old backups
Get-ChildItem -Path $SourceFolder\..\..\movefolder\ | Where-Object { !$_.PSIsContainer -and $_.CreationTime -lt $old } | Remove-Item -Force
>>>>>>> origin/patch-2

        [Parameter(Mandatory=$True,Position=3)]
        $deleteAfterDays,

        [Parameter(Mandatory=$True,Position=4)]
        $LogDestination
    )
        #Convert DeleteAfterDays to a negative
        $deleteAfterDays = "-$deleteAfterDays"

        #Get Backup Directories
        $folderList = (Get-ChildItem -Path "$SourceFolder").fullname

        #Declare obsolete backups
        $old = (Get-date).addDays("$deleteAfterDays")
    
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
            $outputList | Export-Csv -NoTypeInformation -Path "$LogDestination\backups.csv" -Delimiter ','  -Append
            #Export backup to share
            Move-Item -Path "$Folder\*.$FileType" -Destination "$DestinationFolder"

        }
        #Delete old backups
        Get-ChildItem -Path "$DestinationFolder" | Where-Object { !$_.PSIsContainer -and $_.CreationTime -lt $old } | Remove-Item -Force
}
