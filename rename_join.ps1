function add_to_domain {
    $new_name = Read-Host "What is the new machine name?"
    Rename-Computer -NewName $new_name

    Add-Computer -Domainname corp.kbkg.com -Credential Get-Credential

    Restart-Computer -Force
}