
function Get-AllForestUserAccountGroupMemberships
{
  <#
      .SYNOPSIS
      Gets a list of the users and group memberships of a forest
      
      .DESCRIPTION
      Finds all of the domains in your forest.  Then loops through each of them to give you a list of each of the domains groups and thier membership.
      
      .PARAMETER OutputFileNamePrefix
      This gives the owner the ability to customize the output file
      
      .INPUTS
      None
      
      .OUTPUTS
      Log file stored in C:\Temp\<name>.log>
      
      .NOTES
      Version:        1.0
      Author:         A.Flom
      Creation Date:  
      Purpose/Change: Initial script development
      
      .EXAMPLE
      Get-AllForestUserAccountGroupMemberships -outputfilenameprefix
      
  #>
    
  param
  (
    [Parameter(Mandatory,HelpMessage = 'Name of File. The Date stamp will be added by the program.')]
    [string]$OutputFileNamePrefix
  )
    
  Function Get-FileName
  {
    param
    (
      [Parameter(Mandatory,HelpMessage = 'Prefix of filename')]
      [string]
      $NamePrefix
    )
    $timeStamp = Get-Date -UFormat %Y%m%d
    return  $NamePrefix + '_' + $timeStamp + '.csv'
  }
    
  $OutputFileName = Get-FileName -OutputFileNamePrefix 

  # Get list of Domains in the Forest
  $domains        = (Get-ADForest).domains
    
  # Loop through the domains
  Foreach ($domain in $domains)
  {
    $AllUserGUIDS = ((Get-ADUser -Filter * -Server $domain).objectGUID)
      
    foreach($UserGUID in $AllUserGUIDS)
    {
      $accountName = (Get-ADUser -Identity $UserGUID -Server $domain).distinguishedname
        
      $membership  = (Get-ADPrincipalGroupMembership -Identity $UserGUID -Server $domain).distinguishedname
        
      Write-Output -InputObject $accountName
        
      foreach($group in $membership)
      {
        $OutputList = New-Object -TypeName PSObject -Property @{
          AccountName = $accountName
          Groups      = $group
        }
        $OutputList | Export-Csv -NoTypeInformation -Path $OutputFileName -Delimiter ',' -Append
      }
    }
  }
}


=======
function Get-AllForestUserAccountGroupMemberships
{
  <#
      .SYNOPSIS
      Gets a list of the users and group memberships of a forest
      
      .DESCRIPTION
      Finds all of the domains in your forest.  Then loops through each of them to give you a list of each of the domains groups and thier membership.
      
      .PARAMETER OutputFileNamePrefix
      This gives the owner the ability to customize the output file
      
      .INPUTS
      None
      
      .OUTPUTS
      Log file stored in C:\Temp\<name>.log>
      
      .NOTES
      Version:        1.0
      Author:         A.Flom
      Creation Date:  
      Purpose/Change: Initial script development
      
      .EXAMPLE
      Get-AllForestUserAccountGroupMemberships -outputfilenameprefix
      
  #>
    
  param
  (
    [Parameter(Mandatory,HelpMessage = 'Name of File. The Date stamp will be added by the program.')]
    [string]$OutputFileNamePrefix
  )
    
  Function Get-FileName
  {
    param
    (
      [Parameter(Mandatory,HelpMessage = 'Prefix of filename')]
      [string]
      $NamePrefix
    )
    $timeStamp = Get-Date -UFormat %Y%m%d
    return  $NamePrefix + '_' + $timeStamp + '.csv'
  }
    
  $OutputFileName = Get-FileName -OutputFileNamePrefix 
  # Get list of Domains in the Forest
  $domains        = (Get-ADForest).domains
    
  # Loop through the domains
  Foreach ($domain in $domains)
  {
    $AllUserGUIDS = ((Get-ADUser -Filter * -Server $domain).objectGUID)
      
    foreach($UserGUID in $AllUserGUIDS)
    {
      $accountName = (Get-ADUser -Identity $UserGUID -Server $domain).distinguishedname
        
      $membership  = (Get-ADPrincipalGroupMembership -Identity $UserGUID -Server $domain).distinguishedname
        
      Write-Output -InputObject $accountName
        
      foreach($group in $membership)
      {
        $OutputList = [pscustomobject]@{
          AccountName = $accountName
          Groups      = $group
        }
        $OutputList | Export-Csv -NoTypeInformation -Path $OutputFileName -Delimiter ',' -Append
      }
    }
  }
}
