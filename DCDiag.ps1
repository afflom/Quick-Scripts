dcdiag /f:<Path>\$($env:COMPUTERNAME)-DCDiag-$(Get-Date -Uformat %Y%m%d).txt
Copy-Item "<Same Path>\$($env:COMPUTERNAME)-DCDiag-$(Get-Date -Uformat %Y%m%d).txt" -Destination '<UNC Path>'
exit
