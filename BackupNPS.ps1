Export-NpsConfiguration -Path "<Path>\$($env:COMPUTERNAME)-NPS-$(Get-Date -Uformat %Y%m%d).xml"
Copy-Item "<Same Path\$($env:COMPUTERNAME)-NPS-$(Get-Date -Uformat %Y%m%d).xml" -Destination '<UNC Path>'
exit
