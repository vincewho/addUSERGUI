<# This form was created using POSHGUI.com  a free online gui designer for PowerShell
.NAME
    Untitled
#>

[void] [System.Reflection.Assembly]::LoadWithPartialName("System.Drawing") 
[void] [System.Reflection.Assembly]::LoadWithPartialName("System.Windows.Forms") 

function Get-OnePerson{
	Param (
		[Parameter(Mandatory=$false)] [string] $usermeid
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

function Find-Person {
	Param (
		[Parameter(Mandatory=$false)] [string] $usermeid
		)
	$sqlserver = 'it14'
	$db = 'idCard'
	$query = "Select * from dbo.EPI_PERSON where MEID = '$usermeid'"
	Invoke-DbaQuery -SqlInstance $sqlserver -Database $db -Query $query
}

$on_click = { 
    Get-OnePerson $meid_txtbox.Text
    Start-Job
    $Form.Close()
}

$chk_click = {
    $person = ""
    $person = Find-Person -usermeid $meid_txtbox.Text
    if ($person -ne $null ){
        [System.Windows.Forms.MessageBox]::Show("User is found" , "Find User")
    } else{
        [System.Windows.Forms.MessageBox]::Show("User cannot be found" , "Find User")
    }
}

##############################
# Creat the form
##############################

$Form                            = New-Object system.Windows.Forms.Form
$Form.ClientSize                 = '413,119'
$Form.text                       = "AddForm"
$Form.TopMost                    = $True
$Form.StartPosition              = "CenterScreen"

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
$add_btn.location                = New-Object System.Drawing.Point(200,80)
$add_btn.Font                    = 'Microsoft Sans Serif,10'

$check_btn                       = New-Object system.Windows.Forms.Button
$check_btn.text                  = "Check"
$check_btn.width                 = 60
$check_btn.height                = 30
$check_btn.location              = New-Object System.Drawing.Point(100,80)
$check_btn.Font                  = 'Microsoft Sans Serif,10'


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

##############################
# When Button is pressed
##############################

$add_btn.Add_Click($on_click)
$check_btn.Add_Click($chk_click)

$Form.controls.AddRange(@($meid_txtbox,$add_btn, $check_btn,$meid_lbl,$notice_lbl))

[void]$Form.ShowDialog()