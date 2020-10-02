# Get Password expired accts
Get-ADUser -filter {Enabled -eq $True} -properties Name, PasswordExpired| Where-Object {$_.PasswordExpired} | Out-GridView

# Get Simple info
Get-ADUser -Filter {Name -like "jason*"} -Properties PasswordLastSet, PasswordExpired, ScriptPath

# Get group membership
Get-ADUser -Filter {Name -like "stephanie c*"} -Properties * | Get-ADPrincipalGroupMembership | Select-Object Name

# Get Everything
Get-ADUser -Filter {Name -like "*"} -Properties *

# Get LockedOut accts
Search-ADAccount -LockedOut | Select-Object Name, PasswordExpired, LockedOut

# Anto way of getting user info
net user marquise.kaai /domain

######################################################
###     FUNCTIONS       ##############################
######################################################

# Get simple info
function Get-SimpleADProperties {
    param (
        [parameter(Mandatory=$true)][String]$User
    )

    Get-ADUser -Filter "Name -like '*$User*'" -Properties PasswordLastSet, PasswordExpired, ScriptPath
}
Get-SimpleADProperties

# Get group membership 
function Get-ADGroupMembership {
    param (
        [parameter(Mandatory=$true)][String]$User
    )
    Get-ADUser -Filter "Name -like '*$User*'" -Properties * | Get-ADPrincipalGroupMembership | Select-Object Name
}
Get-ADGroupMembership