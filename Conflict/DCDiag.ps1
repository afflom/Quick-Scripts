
<#
.SYNOPSIS
    Runs DCDIAG against all the DC in the domain.  Sets up a PSSession and runs dcdiag against that server's session.  There is no input needed, because it searches AD for all domain controllers.

.EXAMPLE Get-DcDiag
    Get-DcDiag

.INPUT
    None

.OUTPUT
    DC Diag report to file
#>

# Load the time stamp module
& ((Split-Path $MyInvocation.InvocationName) + "\Create-LogFileNameWithTimeDateStamp.ps1")


# Set variables
# $StampDateTime = Get-Date -Uformat %Y%m%d
$OutputReportPath = "$env:HOMEDRIVE\temp\"
$OutPutReportUNC = '\\UNCFileshare\'

# Get Domain Contollers
$getForest = [system.directoryservices.activedirectory.Forest]::GetCurrentForest()
$DCServers = $getForest.domains | ForEach-Object {$_.DomainControllers}

foreach($DomainController in $DCServers){

   # Create the PS session
   $session = New-PSSession -ComputerName $DomainController.Name

   # create Output report filename
   # $DcDiagReportOutput = ('{0}-DCDiag-{1}.txt' -f $DomainController.Name, $StampDateTime)
   $DcDiagReportOutput = New-TimedStampFileName -baseNAME ($DomainController.Name+'-DCDiag') -Extension txt -StampFormat 2

   # Use the invoke command to create a variable to run the dcdiag
   $dcdiag  = Invoke-Command -Session $session -Command  { dcdiag }

   # Run the DC Diag on the remote machine as defined in the Session and dcdiag lines then pass it to the outputfile.
   $dcdiag | ('{0}+{1}' -f $OutputReportPath, $DcDiagReportOutput)

   # This may be able to be removed later
   Copy-Item -Path ('{0}+{1}' -f $OutputReportPath, $DcDiagReportOutput) -Destination $OutPutReportUNC

}

<#
Future features
Remove copy item statement
Put in error catching (try / catch)
Rename using proper Verb-Noun format.  ex : Get-DCDiagStatus

Issues
Untested

#>
