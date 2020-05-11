<# This form was created using POSHGUI.com  a free online gui designer for PowerShell
.NAME
    test_popup
#>

Add-Type -AssemblyName System.Windows.Forms
[System.Windows.Forms.Application]::EnableVisualStyles()

$Form                            = New-Object system.Windows.Forms.Form
$Form.ClientSize                 = '600,200'
$Form.text                       = "Form"
$Form.TopMost                    = $false

$Button1                         = New-Object system.Windows.Forms.Button
$Button1.text                    = "Prompt Box"
$Button1.width                   = 100
$Button1.height                  = 30
$Button1.location                = New-Object System.Drawing.Point(25,20)
$Button1.Font                    = 'Microsoft Sans Serif,10'

$output_lbl                      = New-Object system.Windows.Forms.Label
$output_lbl.text                 = "output_lbl"
$output_lbl.AutoSize             = $true
$output_lbl.width                = 300
$output_lbl.height               = 10
$output_lbl.location             = New-Object System.Drawing.Point(25,80)
$output_lbl.Font                 = 'Microsoft Sans Serif,10'

$Form.controls.AddRange(@($Button1,$output_lbl))

$Button1.Add_Click({ get-prompt })

function get-prompt { 
    $title = 'Demographics'
    $msg   = 'Enter your demographics:'

    $text = [Microsoft.VisualBasic.Interaction]::InputBox($msg, $title)

    $output_lbl.Text = $text
}


#Write your logic code here

[void][Reflection.Assembly]::LoadWithPartialName('Microsoft.VisualBasic')



[void]$Form.ShowDialog()
