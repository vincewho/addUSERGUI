<# This form was created using POSHGUI.com  a free online gui designer for PowerShell
.NAME
    KBKG adgui
#>

Add-Type -AssemblyName System.Windows.Forms
[System.Windows.Forms.Application]::EnableVisualStyles()

$adgui                           = New-Object system.Windows.Forms.Form
$adgui.ClientSize                = '800,400'
$adgui.text                      = "Active Dir Gui"
$adgui.TopMost                   = $false

$selected_info_txt               = New-Object system.Windows.Forms.Label
$selected_info_txt.AutoSize      = $true
$selected_info_txt.width         = 25
$selected_info_txt.height        = 10
$selected_info_txt.location      = New-Object System.Drawing.Point(140,210)
$selected_info_txt.Font          = 'Microsoft Sans Serif,10'

$select_info_txt2                = New-Object system.Windows.Forms.Label
$select_info_txt2.AutoSize       = $true
$select_info_txt2.width          = 25
$select_info_txt2.height         = 10
$select_info_txt2.location       = New-Object System.Drawing.Point(140,230)
$select_info_txt2.Font           = 'Microsoft Sans Serif,10'

$select_info_txt3                = New-Object system.Windows.Forms.Label
$select_info_txt3.AutoSize       = $true
$select_info_txt3.width          = 25
$select_info_txt3.height         = 10
$select_info_txt3.location       = New-Object System.Drawing.Point(140,250)
$select_info_txt3.Font           = 'Microsoft Sans Serif,10'

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
$listbox.location                = New-Object System.Drawing.Point(25,59)

$select_btn                      = New-Object system.Windows.Forms.Button
$select_btn.text                 = "Select User"
$select_btn.width                = 100
$select_btn.height               = 30
$select_btn.location             = New-Object System.Drawing.Point(25,210)
$select_btn.Font                 = 'Microsoft Sans Serif,10'

$create_btn                      = New-Object system.Windows.Forms.Button
$create_btn.text                 = "Create User"
$create_btn.width                = 100
$create_btn.height               = 30
$create_btn.location             = New-Object System.Drawing.Point(25,250)
$create_btn.Font                 = 'Microsoft Sans Serif,10'

$adgui.controls.AddRange(@($select_info_txt3,$selected_info_txt,$select_info_txt2,$get_users_btn,$listbox,$select_btn,$create_btn))

$get_users_btn.Add_Click({ get-kbkgUser })
$select_btn.Add_Click({ get-selected })
$create_btn.Add_Click({ new-kbkguser })

function new-kbkguser {
    param (
        $selected = $listbox.SelectedItem
    )
    $hash = $selected.Split(" ")
    $users = Import-Excel -path $file -ErrorAction STOP | Select-Object -Last 10

    $select_usr = $users | Where-Object { $_."First Name:" -like "$($hash[0])*"  -and $_."Last Name:" -like $hash[1] } | Select-Object -Last 1  
    
    # $setup_user = $listbox.SelectedItem.'Profile to use for IT set-up:'
    $template_user = Get-ADUser -Filter "Name -Like ""$($select_usr.'Profile to use for IT set-up:')""" -properties Company, Department, Manager, MemberOf, Office, PrimaryGroup, ScriptPath, Title, GivenName, Surname, Mail
    while ($template_user -eq $null) {
        Write-Host "The Profile to use was not found."
        $title = 'Replacement Template User'
        $msg = 'Enter new User: Use full name'
        $usr_name = [Microsoft.VisualBasic.Interaction]::InputBox($msg, $title)

        $template_user = Get-ADUser -Filter "Name -Like ""$($usr_name)""" -properties Company, Department, Manager, MemberOf, Office, PrimaryGroup, ScriptPath, Title, GivenName, Surname, Mail
    }

    $template_user.UserPrincipalName = $null
    $template_user.GivenName = $select_usr.'First Name:'.Trim()
    $template_user.Surname = $select_usr.'Last Name:'.Trim()
    $template_user.Mail = ($select_usr.'First Name:'.Trim()+"."+$select_usr.'Last Name:'.Trim()+"@"+$select_usr.'Email address:').ToLower()

    # Create user 
    ## $last_user variable is used but can probably be changed to something more useful later
    $name = $select_usr.'First Name:'.Trim() + " " + $select_usr.'Last Name:'.Trim()
    $dot_name = $select_usr.'First Name:'.Trim()+"."+$select_usr.'Last Name:'.Trim()
    $email = $dot_name.ToLower()+'@'+$select_usr.'Email address:'
    $title = $select_usr.'Title:'
    $dept = $select_usr.'Department:'

    $pwd = get-prompt | ConvertTo-SecureString -AsPlainText -Force

    New-ADUser -Instance $template_user `
        -Name $name `
        -SamAccountName $dot_name.ToLower() `
        -DisplayName $name `
        -Title $title `
        -Department $dept `
        -HomeDrive "U" `
        -HomeDirectory "\\kbkgfs01\Home$\$($dot_name.ToLower())" `
        -AccountPassword ($pwd) `
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

    Write-Host "Completed"

    $select_info_txt3.Text = "Completed"

}

function get-selected { 
    param (
        $selected = $listbox.SelectedItem
    )
    $hash = $selected.Split(" ")
    $users = Import-Excel -path $file -ErrorAction STOP | Select-Object -Last 10

    $select_usr = $users | Where-Object { $_."First Name:" -like "$($hash[0])*"  -and $_."Last Name:" -like $hash[1] } | Select-Object -Last 1  
    
    Write-Host $select_usr
    $selected_info_txt.Text = "You have selected: " + $select_usr.'First Name:' + " " + $select_usr.'Last Name:' 
    $select_info_txt2.Text = "Template User: " + $select_usr.'Profile to use for IT set-up:'
}

function get-kbkgUser {
    $users = Import-Excel -path $file -ErrorAction STOP | Select-Object -Last 10
    $listbox.Items.Clear()
    
    foreach($user in $users){
        $user.PSObject.Properties.Remove('Start time')
        $user.PSObject.Properties.Remove('Completion time')
        $user.PSObject.Properties.Remove('Email')
        $user.PSObject.Properties.Remove('Name')
        $listbox.Items.Add(($user."First Name:").Trim() + " " + ($user."Last Name:").Trim() + " in " + $user."Department:")
    }
}

function get-prompt { 
    $title = 'Password'
    $msg   = 'Enter your Password:'

    $text = [Microsoft.VisualBasic.Interaction]::InputBox($msg, $title)
    
    $select_info_txt3.Text = $text | ConvertTo-SecureString -AsPlainText -Force
    Write-Output $text
}


#Write your logic code here

[void][Reflection.Assembly]::LoadWithPartialName('Microsoft.VisualBasic')

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
