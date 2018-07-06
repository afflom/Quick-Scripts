#This script must be ran from a Domain Controller


$domains = (Get-ADForest).globalcatalogs


Foreach ($GC in $domains){

    $Server = $GC

    $SCRILAccounts = (Get-ADUser -filter {SmartCardLogonRequired -eq $true} -Server $Server)
    
    echo $SCRILAccounts.Name

    foreach($account in $SCRILAccounts){

        [pscustomobject]@{

         SCRILAccounts = $account

#You might want to rename the file 

         } | Export-Csv -NoTypeInformation All_Forest_SCRIL_Accounts_$(Get-Date -UFormat %Y%m%d).csv -Append
    }
}



