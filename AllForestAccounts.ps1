
$domains = (Get-ADForest).domains


Foreach ($domain in $domains){

    $fqdn = $domain

    $domain = ((Get-ADUser -Filter * -Server $domain).objectGUID)

    foreach($GUID in $domain){

        $accountName = (Get-ADUser -Identity $GUID -Server $fqdn).distinguishedname

        $membership = (Get-ADPrincipalGroupMembership -Identity $GUID -Server $fqdn).distinguishedname

        echo $accountName

        foreach($group in $membership){

        
            [pscustomobject]@{

                AccountName = $accountName

                Groups = $group

            } | Export-Csv -NoTypeInformation All_Forest_Accounts_$(Get-Date -UFormat %Y%m%d).csv -Append
        }
    }

 }


