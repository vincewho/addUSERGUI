<# This form was created using POSHGUI.com  a free online gui designer for PowerShell
.NAME
    Untitled
#>

Add-Type -AssemblyName System.Windows.Forms
[System.Windows.Forms.Application]::EnableVisualStyles()

function Get-OnePerson{
	Param (
		[Parameter(Mandatory=$true)] [string] $usermeid
		)
    $output = $PSScriptRoot + '\output.csv'
	Get-ADUser -filter * -Server "mcccd.org"  -Properties EmployeeID,Created,whenChanged,Surname,GivenName,middleName,mccdLogonID,mccdEmployeeTypeDesc,mccdStudentID,Title,CanonicalName -SearchBase "OU=Employees,OU=MARICOPA,DC=mcccd,DC=org" | 
	Select-Object EmployeeID,Created,whenChanged,Surname,GivenName,middleName,mccdLogonID,mccdEmployeeTypeDesc,mccdStudentID,Title,CanonicalName | 
	Where-Object { $_.mccdLogonID -eq $usermeid } | 
	ConvertTo-Csv -NoTypeInformation | 
	% {$_.Replace('"','')} | 
	Out-File $output -Force
}

$on_click = { 
    Get-OnePerson $meid_txtbox.Text
    $Form.Close()
}

##############################
# Creat the form
##############################

$Form                            = New-Object system.Windows.Forms.Form
$Form.ClientSize                 = '355,125'
$Form.text                       = "Add User"
$Form.TopMost                    = $false

# Text to specify the input
$meid_lbl                        = New-Object system.Windows.Forms.Label
$meid_lbl.text                   = "Enter MEID:"
$meid_lbl.AutoSize               = $true
$meid_lbl.width                  = 25
$meid_lbl.height                 = 10
$meid_lbl.location               = New-Object System.Drawing.Point(47,28)
$meid_lbl.Font                   = 'Microsoft Sans Serif,10'

# area to input text
$meid_txtbox                     = New-Object system.Windows.Forms.TextBox
$meid_txtbox.multiline           = $false
$meid_txtbox.width               = 163
$meid_txtbox.height              = 20
$meid_txtbox.location            = New-Object System.Drawing.Point(135,24)
$meid_txtbox.Font                = 'Microsoft Sans Serif,10'

##############################
# Create Button
##############################
# Button to submit text
$add_btn                         = New-Object system.Windows.Forms.Button
$add_btn.text                    = "Add"
$add_btn.width                   = 60
$add_btn.height                  = 30
$add_btn.location                = New-Object System.Drawing.Point(135,64)
$add_btn.Font                    = 'Microsoft Sans Serif,10'

##############################
# When Button is pressed
##############################

$add_btn.Add_Click($on_click)

##############################
# Creating items in form
##############################

$Form.controls.AddRange(@($meid_lbl,$add_btn,$meid_txtbox))

[void]$Form.ShowDialog()
