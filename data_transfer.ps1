# $machine = 'P-WS049'

# $machine = Read-Host -Prompt 'Input the old machine name'
# $new_machine = Read-Host -Prompt 'Input the new machine name'
# $username = Read-Host -Prompt 'Input the user name'

# write-host $username $machine

# Get-ChildItem \\$machine\c$\Users\$username\AppData\Local\Google
# Get-ChildItem \\$new_machine\c$\Users\$username\AppData\Local\Google

# Get-ChildItem $env:APPDATA\Adobe\Acrobat\2015\Security

function get_new_user{
    $user_fname = Read-Host "What is the user First Name?"
    $user_lname = Read-Host "What is the user Last name?"
    $dept = Read-Host "Are they KROST or KBKG?"
    return $user_fname, $user_lname, $dept
}
function copy_user{
        $new_user = get_new_user
        $temp_email = $new_user[0]+"."+$new_user[1]
        
        if ($new_user[2].tolower() -eq 'kbkg') {
            $official_email = $temp_email+'@kbkg.com'
        }elseif ($new_user[2].tolower() -eq 'krost') {
            $official_email = $temp_email+'@krostcpas.com'
        }else {
            Write-Host 'Try again, Sorry'
        }

        return $official_email
}

        # $template_user = Get-ADUser test.testingtonson
        # Write-Host $template_user.Name "is input"

function create_sDrive{

}

function Show-Menu {
    param (
        [string]$title = 'Menu'
    )
    Clear-Host
    Write-Host "================ $Title ================"

    Write-Host "1: Press '1' to add user to AD."
    Write-Host "2: Press '2' for this option."
    Write-Host "3: Press '3' for this option."
    Write-Host "Q: Press 'Q' to quit."
    
}

do{ 
   Show-Menu 
   $selected = Read-Host "Please make a selection"
   switch ($selected) {
       '1' { copy_user }
       Default { $selected = 'q' }
   }
   Pause
}
until ($selected -eq 'q')
