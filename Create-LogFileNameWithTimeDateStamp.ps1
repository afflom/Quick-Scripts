function New-TimedStampFileName {

  param
  (
    [Parameter(Mandatory,HelpMessage='Prefix of file or log name')]
    [alias('Prefix')]
    [Object]$baseNAME,
    [Parameter(Mandatory,HelpMessage='Extention of file.  txt, csv, log')]
    [alias('Extension')]
    [Object]$tailNAME,
    [Parameter(Mandatory,HelpMessage='Formatting Choice 1 to 4')]
    [alias('Choice')]
    [ValidateRange(1,4)]
    [Object]$StampFormat
  )

  switch ($StampFormat){
    1{$t = Get-Date -uformat '%y%m%d%H%M'} # 1703162145 YYMMDDHHmm
    2{$t = Get-Date -uformat '%Y%m%d'} # 20170316 YYYYMMDD
    3{$t = Get-Date -uformat '%d%H%M%S'} # 16214855 DDHHmmss
    4{$t = Get-Date -uformat '%y/%m/%d_%H:%M'} # 17/03/16_21:52
    default{'No time format selected'}
  }

  $baseNAME+'-'+$t+'.'+$tailNAME
}
