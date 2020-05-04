<# This form was created using POSHGUI.com  a free online gui designer for PowerShell
.NAME
    Untitled
#>

Add-Type -AssemblyName System.Windows.Forms
[System.Windows.Forms.Application]::EnableVisualStyles()

$NewADUser                       = New-Object system.Windows.Forms.Form
$NewADUser.ClientSize            = '400,400'
$NewADUser.text                  = "New AD User"
$NewADUser.TopMost               = $false

$get_btn                         = New-Object system.Windows.Forms.Button
$get_btn.text                    = "Get Users"
$get_btn.width                   = 80
$get_btn.height                  = 30
$get_btn.location                = New-Object System.Drawing.Point(25,20)
$get_btn.Font                    = 'Microsoft Sans Serif,10'

$list_box                        = New-Object system.Windows.Forms.ListBox
$list_box.text                   = "listBox"
$list_box.width                  = 350
$list_box.height                 = 100
$list_box.location               = New-Object System.Drawing.Point(25,65)

$select_user                     = New-Object system.Windows.Forms.Button
$select_user.text                = "Select"
$select_user.width               = 60
$select_user.height              = 30
$select_user.location            = New-Object System.Drawing.Point(25,175)
$select_user.Font                = 'Microsoft Sans Serif,10'

$NewADUser.controls.AddRange(@($get_btn,$list_box,$select_user))

$get_btn.Add_Click({ get-kbkgUser })
$select_user.Add_Click({ get-selected })



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

function get-kbkgUser{
    $users = Import-Excel -path $file -ErrorAction STOP | Select-Object -Last 10

    # foreach($user in $users){
    #     $list_box.Items.Add($user.'First Name:' + " " + $user.'Last Name:')
    #     Write-Host $user.'First Name:'
    # }

    foreach($user in $users){
        $list_box.Items.Add($user)
    }
}

function get-selected {
    param (
    )

    Write-Host $list_box.SelectedItem.'First Name:'
    
}

[void]$NewADUser.ShowDialog()