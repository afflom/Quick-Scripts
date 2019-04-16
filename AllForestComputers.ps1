#requires -Version 3.0
#requires -Module ActiveDirectory
#requires -RunAsAdministrator 

Function Get-ForestComputers
{
  <#
      .SYNOPSIS
      Returns a CSV of all of the computers in all of the Forests.

      .EXAMPLE
      Get-ForestComputers
      Finds the AD Forests, then searches each for computers and outputs the list to a CSV

      .OUTPUTS
      Sends the report to the users desktop.
      All_Forest_Computers_DateStamp.csv a file with a date.
  #>
  
  $DateStamp = Get-Date -UFormat %Y%m%d  
  $OutputFileName = "C:\Users\Erik.Arnesen\Desktop\All_Forest_Computers_$DateStamp.csv"

  $domains = (Get-ADForest).domains
  Write-Verbose -Message ('Domains = {0}' -f $domains)
  Foreach ($domain in $domains)
  {
    Write-Verbose -Message ('This Domain = {0}' -f $domain)
 
    $domain = ((Get-ADComputer -Filter * -Server $domain).name)
    foreach($computer in $domain)
    {
      Write-Verbose -Message ('This Computer = {0}' -f $computer)
      [pscustomobject]@{
        ComputerName = $computer
        DomainName   = $domain
      } | Export-Csv -NoTypeInformation -Path $OutputFileName -Append
    }
  }
}

#Start Script
Get-ForestComputers

