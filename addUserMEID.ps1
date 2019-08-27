<# This form was created using POSHGUI.com  a free online gui designer for PowerShell
.NAME
    Untitled
#>


function Get-OnePerson{
	Param (
		[Parameter(Mandatory=$true)] [string] $usermeid
		)
    # $output = $PSScriptRoot + '\output.csv'
    $output = '\\it14\scripts\id_card\output.csv'
	Get-ADUser -filter * -Server "mcccd.org"  -Properties EmployeeID,Created,whenChanged,Surname,GivenName,middleName,mccdLogonID,mccdEmployeeTypeDesc,mccdStudentID,Title,CanonicalName -SearchBase "OU=Employees,OU=MARICOPA,DC=mcccd,DC=org" | 
	Select-Object EmployeeID,Created,whenChanged,Surname,GivenName,middleName,mccdLogonID,mccdEmployeeTypeDesc,mccdStudentID,Title,CanonicalName | 
	Where-Object { $_.mccdLogonID -eq $usermeid } | 
	ConvertTo-Csv -NoTypeInformation | 
	% {$_.Replace('"','')} | 
	Out-File $output -Force
}

function Start-Job{
		$sqlserver = 'it14'
		$job = 'NewIDcardFeed'
		Start-DbaAgentJob -SqlInstance $sqlserver -Job $job
}

$on_click = { 
    # Get-OnePerson $meid_txtbox.Text
    # Start-Job
    $Form.Close()
}

##############################
# Creat the form
##############################

Add-Type -AssemblyName System.Windows.Forms
[System.Windows.Forms.Application]::EnableVisualStyles()

$Form                            = New-Object system.Windows.Forms.Form
$Form.ClientSize                 = '413,119'
$Form.text                       = "AddForm"
$Form.TopMost                    = $false

$meid_txtbox                     = New-Object system.Windows.Forms.TextBox
$meid_txtbox.multiline           = $false
$meid_txtbox.width               = 171
$meid_txtbox.height              = 20
$meid_txtbox.location            = New-Object System.Drawing.Point(141,24)
$meid_txtbox.Font                = 'Microsoft Sans Serif,10'

$add_btn                         = New-Object system.Windows.Forms.Button
$add_btn.text                    = "Add"
$add_btn.width                   = 60
$add_btn.height                  = 30
$add_btn.location                = New-Object System.Drawing.Point(186,80)
$add_btn.Font                    = 'Microsoft Sans Serif,10'

$meid_lbl                        = New-Object system.Windows.Forms.Label
$meid_lbl.text                   = "MEID"
$meid_lbl.AutoSize               = $true
$meid_lbl.width                  = 25
$meid_lbl.height                 = 10
$meid_lbl.location               = New-Object System.Drawing.Point(88,30)
$meid_lbl.Font                   = 'Microsoft Sans Serif,10'

$notice_lbl                      = New-Object system.Windows.Forms.Label
$notice_lbl.text                 = "There will be a delay of around 20 seconds before this box closes"
$notice_lbl.AutoSize             = $true
$notice_lbl.width                = 25
$notice_lbl.height               = 10
$notice_lbl.location             = New-Object System.Drawing.Point(14,56)
$notice_lbl.Font                 = 'Microsoft Sans Serif,10'

$Form.controls.AddRange(@($meid_txtbox,$add_btn,$meid_lbl,$notice_lbl))

##############################
# When Button is pressed
##############################

$add_btn.Add_Click($on_click)


[void]$Form.ShowDialog()