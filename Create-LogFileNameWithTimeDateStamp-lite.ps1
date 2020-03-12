function New-TimedStampFileName {

  param
  (
    [Parameter(Mandatory,HelpMessage='Prefix of file or log name')]
    [Object]$baseNAME,
    [Parameter(Mandatory,HelpMessage='Extention of file.  txt, csv, log')]
    [Object]$Extension,
    [Parameter(Mandatory,HelpMessage='Formatting Choice 1 to 4')]
    [ValidateRange(1,4)]
    [Object]$StampFormat
  )

  switch ($StampFormat){
    1{$DateFormat = Get-Date -uformat '%y%m%d%H%M'} # 1703162145 YYMMDDHHmm
    2{$DateFormat = Get-Date -uformat '%Y%m%d'} # 20170316 YYYYMMDD
    3{$DateFormat = Get-Date -uformat '%d%H%M%S'} # 16214855 DDHHmmss
    4{$DateFormat = Get-Date -Format o | ForEach-Object -Process {$_ -replace ':', '.'}} # 17/03/16_21:52
    default{'No time format selected'}
  }

  $baseNAME+'-'+$DateFormat+'.'+$extension
}
