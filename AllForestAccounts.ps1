
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
    [Parameter(Mandatory,HelpMessage='Name of File. The Date stamp will be added by the program.')]
    [string]$OutputFileNamePrefix
  )
    
  Function Get-FileName{
      
    param
    (
      [Parameter(Mandatory,HelpMessage='Prefix of filename')]
      [string]
      $NamePrefix
    )
    $timeStamp = Get-Date -uformat %Y%m%d
    return  $NamePrefix + '_' + $timeStamp + '.csv'
  }
    
  $OutputFileName = Get-FileName -OutputFileNamePrefix 
  ﻿
  # Get list of Domains in the Forest
  $domains        = (Get-ADForest).domains
    
  # Loop through the domains
  Foreach ($domain in $domains){
      
    $AllUserGUIDS = ((Get-ADUser -Filter * -Server $domain).objectGUID)
      
    foreach($UserGUID in $AllUserGUIDS){
        
      $accountName = (Get-ADUser -Identity $UserGUID -Server $domain).distinguishedname
        
      $membership  = (Get-ADPrincipalGroupMembership -Identity $UserGUID -Server $Domain).distinguishedname
        
      Write-Output -InputObject $accountName
        
      foreach($group in $membership){
          
        $OutputList = New-Object -TypeName PSObject -Property @{
            
          AccountName = $accountName
            
          Groups      = $group
        }
        $OutputList | Export-Csv -NoTypeInformation -Path $OutputFileName -Delimiter ',' -Append
      }
    }
  }
}



# SIG # Begin signature block
  # MIID7QYJKoZIhvcNAQcCoIID3jCCA9oCAQExCzAJBgUrDgMCGgUAMGkGCisGAQQB
  # gjcCAQSgWzBZMDQGCisGAQQBgjcCAR4wJgIDAQAABBAfzDtgWUsITrck0sYpfvNR
  # AgEAAgEAAgEAAgEAAgEAMCEwCQYFKw4DAhoFAAQU2vFGYfw23LVI/yRX4lRa+uGA
  # QgigggINMIICCTCCAXagAwIBAgIQyWSKL3Rtw7JMh5kRI2JlijAJBgUrDgMCHQUA
  # MBYxFDASBgNVBAMTC0VyaWtBcm5lc2VuMB4XDTE3MTIyOTA1MDU1NVoXDTM5MTIz
  # MTIzNTk1OVowFjEUMBIGA1UEAxMLRXJpa0FybmVzZW4wgZ8wDQYJKoZIhvcNAQEB
  # BQADgY0AMIGJAoGBAKYEBA0nxXibNWtrLb8GZ/mDFF6I7tG4am2hs2Z7NHYcJPwY
  # CxCw5v9xTbCiiVcPvpBl7Vr4I2eR/ZF5GN88XzJNAeELbJHJdfcCvhgNLK/F4DFp
  # kvf2qUb6l/ayLvpBBg6lcFskhKG1vbEz+uNrg4se8pxecJ24Ln3IrxfR2o+BAgMB
  # AAGjYDBeMBMGA1UdJQQMMAoGCCsGAQUFBwMDMEcGA1UdAQRAMD6AEMry1NzZravR
  # UsYVhyFVVoyhGDAWMRQwEgYDVQQDEwtFcmlrQXJuZXNlboIQyWSKL3Rtw7JMh5kR
  # I2JlijAJBgUrDgMCHQUAA4GBAF9beeNarhSMJBRL5idYsFZCvMNeLpr3n9fjauAC
  # CDB6C+V3PQOvHXXxUqYmzZpkOPpu38TCZvBuBUchvqKRmhKARANLQt0gKBo8nf4b
  # OXpOjdXnLeI2t8SSFRltmhw8TiZEpZR1lCq9123A3LDFN94g7I7DYxY1Kp5FCBds
  # fJ/uMYIBSjCCAUYCAQEwKjAWMRQwEgYDVQQDEwtFcmlrQXJuZXNlbgIQyWSKL3Rt
  # w7JMh5kRI2JlijAJBgUrDgMCGgUAoHgwGAYKKwYBBAGCNwIBDDEKMAigAoAAoQKA
  # ADAZBgkqhkiG9w0BCQMxDAYKKwYBBAGCNwIBBDAcBgorBgEEAYI3AgELMQ4wDAYK
  # KwYBBAGCNwIBFTAjBgkqhkiG9w0BCQQxFgQUvby27ewAvTFZNxKCHDDz+fJ5U6Qw
  # DQYJKoZIhvcNAQEBBQAEgYAST7tlGYj0nyE2ci/mBEOfwIAasJT8Qgp01Ziwiiin
  # DX0+JbTNmzt/B0gPKzACA+LphUQ+K8z2wE9acuSAo5D5+geEmGieCJT+2FOOpjpD
  # t+rJPuGGOXF/ncwV7bS2Op3oIhm5k4Is9nLxpJPXRxwlefjeqgpOT+t2lkcCyWFa
  # Kw==
# SIG # End signature block
