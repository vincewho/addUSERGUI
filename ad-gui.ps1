<# This form was created using POSHGUI.com  a free online gui designer for PowerShell
.NAME
    adgui
#>

Add-Type -AssemblyName System.Windows.Forms
[System.Windows.Forms.Application]::EnableVisualStyles()

$adgui                           = New-Object system.Windows.Forms.Form
$adgui.ClientSize                = '800,400'
$adgui.text                      = "Active Dir Gui"
$adgui.TopMost                   = $false

$get_users_btn                   = New-Object system.Windows.Forms.Button
$get_users_btn.text              = "Get Users"
$get_users_btn.width             = 100
$get_users_btn.height            = 30
$get_users_btn.location          = New-Object System.Drawing.Point(25,20)
$get_users_btn.Font              = 'Microsoft Sans Serif,10'

$listbox                         = New-Object system.Windows.Forms.ListBox
$listbox.text                    = "listBox"
$listbox.width                   = 750
$listbox.height                  = 140
$listbox.location                = New-Object System.Drawing.Point(25,60)

$select_btn                      = New-Object system.Windows.Forms.Button
$select_btn.text                 = "Select"
$select_btn.width                = 100
$select_btn.height               = 30
$select_btn.location             = New-Object System.Drawing.Point(25,210)
$select_btn.Font                 = 'Microsoft Sans Serif,10'

$selected_info_txt               = New-Object system.Windows.Forms.Label
$selected_info_txt.AutoSize      = $true
$selected_info_txt.width         = 25
$selected_info_txt.height        = 10
$selected_info_txt.location      = New-Object System.Drawing.Point(140,210)
$selected_info_txt.Font          = 'Microsoft Sans Serif,10'

$create_btn                      = New-Object system.Windows.Forms.Button
$create_btn.text                 = "Create User"
$create_btn.width                = 100
$create_btn.height               = 30
$create_btn.location             = New-Object System.Drawing.Point(25,250)
$create_btn.Font                 = 'Microsoft Sans Serif,10'

$adgui.controls.AddRange(@($get_users_btn,$listbox,$select_btn,$selected_info_txt,$create_btn))

$get_users_btn.Add_Click({ get-kbkgUser })
$select_btn.Add_Click({ get-selected })
$create_btn.Add_Click({ new-kbkguser })

function new-kbkguser {
    $setup_user = $listbox.SelectedItem.'Profile to use for IT set-up:'
    $template_user = Get-ADUser -Filter "Name -Like ""$($setup_user)""" -properties Company, Department, Manager, MemberOf, Office, PrimaryGroup, ScriptPath, Title, GivenName, Surname, Mail

    while ($template_user -eq $null) {
        Write-Host "The Profile to use was not found."
        $user = Read-Host "Try entering another user"
        $template_user = Get-ADUser -Filter "Name -Like ""$($user)""" -properties Company, Department, Manager, MemberOf, Office, PrimaryGroup, ScriptPath, Title, GivenName, Surname, Mail
    }

    $template_user.UserPrincipalName = $null
    $template_user.GivenName = $last_user.'First Name:'.Trim()
    $template_user.Surname = $last_user.'Last Name:'.Trim()
    $template_user.Mail = ($last_user.'First Name:'.Trim()+"."+$last_user.'Last Name:'.Trim()+"@"+$last_user.'Email address:').ToLower()

    # Create user 
    ## $last_user variable is used but can probably be changed to something more useful later
    $name = $last_user.'First Name:'.Trim() + " " + $last_user.'Last Name:'.Trim()
    $dot_name = $last_user.'First Name:'.Trim()+"."+$last_user.'Last Name:'.Trim()
    $email = $dot_name.ToLower()+'@'+$last_user.'Email address:'
    $title = $last_user.'Title:'
    $dept = $last_user.'Department:'

    New-ADUser -Instance $template_user `
        -Name $name `
        -SamAccountName $dot_name.ToLower() `
        -DisplayName $name `
        -Title $title `
        -Department $dept `
        -HomeDrive "U" `
        -HomeDirectory "\\kbkgfs01\Home$\$($dot_name.ToLower())" `
        -AccountPassword (Read-Host -AsSecureString "Input Passwd for the user") `
        -Enabled $True

    # Edit other necessary properties that the New-ADUser command could not copy
    ## After the user has been created, the variable holding the new user is $new_user
    $new_user = Get-ADUser -Filter "Mail -Like ""$($email)"""
    $new_user.UserPrincipalName = $email
    Set-ADUser $new_user -Add @{proxyAddresses = "SMTP:" + $($email)}
    Set-ADUser $new_user -Add @{targetAddress = "SMTP:" + $($email)}

    # Copy the same memberships from the template_user 
    # $template_user.MemberOf
    Write-Host "User will be part of the following groups:"

    Get-ADUser -Identity $template_user -Properties MemberOf |
    Select-Object -ExpandProperty MemberOf |
    Add-ADGroupMember -Members $new_user -PassThru |
    Select-Object -Property SamAccountName

    # Move the user from default OU to the template_user OU
    # $template_user.DistinguishedName.Split(",", 2)[1]
    $new_user | Move-ADObject -TargetPath ($template_user.DistinguishedName.Split(",", 2)[1])
}

function get-selected { 
    param (
    )
    Write-Host $listbox.SelectedItem
    $selected_info_txt.Text = "You have selected: " + $listbox.SelectedItem.'First Name:' + " " + $listbox.SelectedItem.'Last Name:' 
}

function get-kbkgUser {
    $users = Import-Excel -path $file -ErrorAction STOP | Select-Object -Last 10

    foreach($user in $users){
        $user.PSObject.Properties.Remove('Start time')
        $user.PSObject.Properties.Remove('Completion time')
        $user.PSObject.Properties.Remove('Email')
        $user.PSObject.Properties.Remove('Name')
        $listbox.Items.Add($user)
    }
}


#Write your logic code here
try {
    If (Get-Module -ListAvailable -Name ImportExcel) {
        Write-Host "Module exists"
    } 
    else {
        Install-Module ImportExcel
    }
}
catch {
    Write-Host "Please Install ImportExcel"
}

# File to grab users
$file = "\\kbkgfs01\Combined_Firm_Folders\Information Technology\Powershell Script\new_user\Krost CPAs New Hire Request.xlsx"
[void]$adgui.ShowDialog()