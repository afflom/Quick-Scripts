

$StampDateTime = Get-Date -Uformat %Y%m%d
$OutputReportPath = "$env:HOMEDRIVE\Temp\"
$OutPutReportUNC = '\\UNCFileshare'
$getForest = [system.directoryservices.activedirectory.Forest]::GetCurrentForest() 

$DCServers = $getForest.domains | ForEach-Object {$_.DomainControllers} | ForEach-Object {$_.Name} 


foreach($DomainController in $DCServers){
   $DcDiagReportOutput = ('{0}-DCDiag-{1}.txt' -f $DomainController, $StampDateTime)
   
   dcdiag /f: ('{0}+{1}' -f $OutputReportPath, $DcDiagReportOutput)
   Copy-Item -Path ('{0}+{1}' -f $OutputReportPath, $DcDiagReportOutput) -Destination $OutPutReportUNC
   exit

}
