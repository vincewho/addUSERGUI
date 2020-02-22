<# 
.NAME
    Untitled
#>

function add_to_domain {
    Param(
        [String] $new_machine_name
    )
    Rename-Computer -NewName $new_machine_name

    # Add-Computer -Domainname corp.kbkg.com -Credential Get-Credential

    # Restart-Computer -Force
}

##############################################
#####################GUI START################
##############################################

Add-Type -AssemblyName System.Windows.Forms
[System.Windows.Forms.Application]::EnableVisualStyles()

$ADTest                          = New-Object system.Windows.Forms.Form
$ADTest.ClientSize               = '444,250'
$ADTest.text                     = "ADTest"
$ADTest.TopMost                  = $false

$submit_button                   = New-Object system.Windows.Forms.Button
$submit_button.text              = "Submit"
$submit_button.width             = 60
$submit_button.height            = 20
$submit_button.location          = New-Object System.Drawing.Point(350,35)
$submit_button.Font              = 'Microsoft Sans Serif,10'

$machine_name_box                = New-Object system.Windows.Forms.TextBox
$machine_name_box.multiline      = $false
$machine_name_box.width          = 150
$machine_name_box.height         = 20
$machine_name_box.location       = New-Object System.Drawing.Point(150,35)
$machine_name_box.Font           = 'Microsoft Sans Serif,10'

$machine_name_label              = New-Object system.Windows.Forms.Label
$machine_name_label.text         = "Machine Name"
$machine_name_label.AutoSize     = $true
$machine_name_label.width        = 25
$machine_name_label.height       = 20
$machine_name_label.location     = New-Object System.Drawing.Point(18,35)
$machine_name_label.Font         = 'Microsoft Sans Serif,10'

$ADTest.controls.AddRange(@($submit_button,$machine_name_box,$machine_name_label))

##################################################
##################### FORM EVENTS ################
##################################################


$submit_button.Add_Click({
    add_to_domain -new_machine_name $machine_name_box.text
})

##################################################
####################### END ######################
##################################################

$Null = $ADTest.ShowDialog()