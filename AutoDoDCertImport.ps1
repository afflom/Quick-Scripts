#What's my name?
$hostName = (Get-WmiObject -Class win32_computersystem).name

#Is there a machine Cert?
$hasCert = Get-ChildItem -Path Cert:\LocalMachine\My | Select-Object

#Is it a DoD Cert?
$hasDodCert = Get-ChildItem -Path Cert:\LocalMachine\My | Select-Object -Property PSComputerName, Subject | Select-String -Pattern DoD

#Will it be expiring in the next 90 days or is it expired?
$certExpiring = Get-ChildItem -Path Cert:\LocalMachine\My | Select-Object -Property PSComputerName, Subject, @{n=’ExpireInDays’;e={($_.notafter – (Get-Date)).Days}} | Where-Object {$_.ExpireInDays -lt 90}  

#Find out if the cert has a private key and repair if possible
Function VerifyImport{
    #Does the new cert have a private key?
    $DoDCert = (Get-ChildItem -Path Cert:\LocalMachine\My | Where-Object -Property Issuer -Match "DoD").HasPrivateKey

    if ($DoDCert -eq 'True'){
        #Good, now exit.
        exit

    }

    else{

        #Get the serial number of the problem cert
        $DoDCertSerial = (Get-ChildItem -Path 'Cert:\LocalMachine\My' | Where-Object -Property Issuer -Match "DoD").SerialNumber

        #Try to fix it
        certutil -repairstore My "$DoDCertSerial"

        #All done. Hope that worked!
        exit

    }
}

Function ImportCert{

    #Import the cert
    Import-Certificate -FilePath "C:\CSR\$hostName.cer" -CertStoreLocation 'cert:\localmachine\my'

    #Delete any Old Certs
    Get-ChildItem -Path 'Cert:\LocalMachine\My' | Select-Object -Property PSComputerName, Subject, @{n=’ExpireInDays’;e={($_.notafter – (Get-Date)).Days}} | Where-Object {$_.ExpireInDays -lt 90} | Remove-Item

    #Finishing up
    VerifyImport

}

Function CheckAndDownload{

    #Is the cert available?
    if ((Get-ChildItem -Path '\\<UNC Path>\*.cer') -match $hostName) {

        #Download the cert from the share    
        Copy-Item "\\<UNC Path>\$HostName.cer" -Destination 'c:\CSR'
    
        #And install it
        ImportCert

    }

    else{

        #Quit...    
        Exit
    }
}


#Start here
#Is ther a cert on the device?
if ($hasCert -eq $null){
    CheckAndDownload
    exit
}

#Is it a DoD cert?
else{

    if ($hasDodCert -eq $null){
        CheckAndDownload
        exit
     }

    else{

        #Is it about to expire or expired?
        if ($certExpiring -eq $null){
            exit
        }

        else{

            #Try to Download a new cert
            CheckAndDownload
            exit
        } 
    }
} 
