
$domains = (Get-ADForest).domains


Foreach ($domain in $domains){

    $fqdn = $domain

    $domain = ((Get-ADComputer -Filter * -Server $domain).name)


    foreach($computer in $domain){

        
        [pscustomobject]@{

            ComputerName = $computer

            DomainName = $domain

        } | Export-Csv -NoTypeInformation All_Forest_Computers_$(Get-Date -UFormat %Y%m%d).csv -Append
    }

 }


