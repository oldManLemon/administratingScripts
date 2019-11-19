
function copyUser{
    Param ([string]$usrToCopy, [string]$newUsr)

    Write-Host "The Parameters"

   # Write-Host "User to copy" + $usrToCopy
   
    Write-Host "New User" + $newUsr

    #Turn into params
    $usrToCopy = $usrToCopy #Should eventually be a template user

    $firstName, $lastName = $usrToCopy.Split(' ')
    $defaultPassword = ConvertTo-SecureString -String "Start#2019" -AsPlainText -Force
    $filterForAdSearch = "givenName -like ""*$firstName*"" -and sn -like ""$lastName"""

    $user = try {
        Get-ADUser -Filter $filterForAdSearch -Properties "UserPrincipalName", "MemberOf", "ProfilePath", "CN", "City", "c", "Country", "l", "mail", "mailNickname", "st", "State", "Department", "Description", "Title"
        Write-Host 'User' $usrToCopy 'will now be your template'
    }
    catch {
        Write-Host "Please check again, user is not found. 'n Is this user in Stuttgart?"
    }
    if ($user -is [array] ) {
        Write-Host 'There is has being an err, your selected user to copy has showed up more than once, it is an array not an obj. Breaking'
        break
    }
    $userInstance = Get-ADUser -Identity $user.SamAccountName

    function checkUsrSam {
        Param ([string]$samName, [string]$fName, [string]$lName, [int]$run)

        



        $checkSam = try {
            Get-ADUser -Identity $samName
        }
        catch {
            write-host 'UserName Generated'
        }

        if ($checkSam) {
            #Should consider prompting here if you want to continue to run script

            $firstPart = $fName.Substring(0, $run)
            $samName = $firstPart + $lName
            $run = $run + 1
            checkUsrSam -samName $samName -fName $fname -lName $lName -run $run
        }
    
        else {
            return $samName
        }
    }

    IF ($user) {
        Write-Host 'User Found to be copied'
        $newUsr = $newUsr
        $newFirstName, $newLastName = $newUsr.Split()

        #Flip the user names to match all other users
        $newUsr = $newLastName + ', ' + $newFirstName
    
        #Create user login
        $newSamAccountName = ($newFirstName[0] + $newLastName).ToLower()

        #Check to see if user login already exists and create a new version if exists
        #Example Tim Burton is tburton however if that exists it will create tiburton and timburton and so on and so fourth
        $newSamAccountName = checkUsrSam -samName $newSamAccountName -fName $newFirstName -lName $newLastName -run 1 #Set Run to one as <= is not simple in Powershell

        #keep $user Unmodded
        $stringMod = $user
        $frontGarbage, $endPrincipal = $stringMod.UserPrincipalName.Split('@')

        # Create a new principle name for login in modern Systems
        $newUsrPrincipalName = $newSamAccountName + '@' + $endPrincipal

        # Getting user into the correct OU by generating path
        $s = $stringMod.DistinguishedName
        $sectionOneGarbage, $sectionTwoGarbage, $sectionThree = $s.Split(',')
        $displayName = $newLastName + ', ' + $newFirstName
        $newPath
        $noComma = $sectionThree.Length
        $i = 1
        foreach ($section in $sectionThree) {
        
            $newPath += $section
            if ($i -lt $noComma) {
                $newPath += ','
            }
            $i++
        }
    
        #Create New User --This is really long and i want to multiline it or place it in a var but it hasn't gone well
        try{New-ADUser -Name $newUsr -SamAccountName $newSamAccountName -Instance $userInstance -DisplayName $displayName -GivenName $newFirstName -Surname $newLastName -AccountPassword $defaultPassword -Enabled $enabled -ChangePasswordAtLogon $true -UserPrincipalName $newUsrPrincipalName -Path $newPath
        # New-ADUser -Name $newUsr -SamAccountName $newSamAccountName -Instance $userInstance -DisplayName $displayName -GivenName $newFirstName -Surname $newLastName -AccountPassword $defaultPassword -Enabled $enabled -ChangePasswordAtLogon $true -UserPrincipalName $newUsrPrincipalName -Path $newPath -Country $user.Country -Department $user.Department
        }catch{
            Write-Host 'Creation Failed, breaking operation now'
            Write-Host 'Most likely Permission denied/ Zugriff verweigert'
            break
        }
        #--------Now we have the new user we need to move on to filling out some details and the groups--------#


        #Mirror all the groups the original account was a member of
        $user.Memberof | % { Add-ADGroupMember $_ $newSamAccountName }

        #Add some properties to the new user
        Set-ADuser -Identity $newSamAccountName -Description $user.Description -Department $user.Department -Country $user.Country -City $user.City -State $user.State -Title $user.Title

    }
    else {
        Write-Host 'Please check, user is not found is this user in Stuttgart?'
        Write-Host 'Bitte überprüfen, Benutuzer nicht gefundet, ist dieser Benutzer in Stuttgart?'
    }
}#Everything is wraped in a function

<# This form was created using POSHGUI.com  a free online gui designer for PowerShell
.NAME
    Copy User
#>
Add-Type -AssemblyName System.Windows.Forms
[System.Windows.Forms.Application]::EnableVisualStyles()

$Form                            = New-Object system.Windows.Forms.Form
$Form.ClientSize                 = '400,400'
$Form.text                       = "Form"
$Form.TopMost                    = $false

$btn                             = New-Object system.Windows.Forms.Button
$btn.BackColor                   = "#3a39b3"
$btn.text                        = "Create User"
$btn.width                       = 150
$btn.height                      = 30
$btn.location                    = New-Object System.Drawing.Point(36,118)
$btn.Font                        = 'Microsoft Sans Serif,10'
$btn.ForeColor                   = "#ffffff"

$tempUsr                         = New-Object system.Windows.Forms.TextBox
$tempUsr.multiline               = $false
$tempUsr.width                   = 200
$tempUsr.height                  = 30
$tempUsr.location                = New-Object System.Drawing.Point(16,31)
$tempUsr.Font                    = 'Microsoft Sans Serif,10'

$newUsrToCreat                   = New-Object system.Windows.Forms.TextBox
$newUsrToCreat.multiline         = $false
$newUsrToCreat.width             = 200
$newUsrToCreat.height            = 30
$newUsrToCreat.location          = New-Object System.Drawing.Point(16,79)
$newUsrToCreat.Font              = 'Microsoft Sans Serif,10'

$template                        = New-Object system.Windows.Forms.Label
$template.text                   = "Template User"
$template.AutoSize               = $true
$template.width                  = 25
$template.height                 = 10
$template.location               = New-Object System.Drawing.Point(15,13)
$template.Font                   = 'Microsoft Sans Serif,10'

$Label2                          = New-Object system.Windows.Forms.Label
$Label2.text                     = "New User"
$Label2.AutoSize                 = $true
$Label2.width                    = 25
$Label2.height                   = 10
$Label2.location                 = New-Object System.Drawing.Point(16,65)
$Label2.Font                     = 'Microsoft Sans Serif,10'

$Form.controls.AddRange(@($btn,$tempUsr,$newUsrToCreat,$template,$Label2))


$btn.Add_Click({ copyUser($($tempUsr.text), $($newUsrToCreat))})
$Form.ShowDialog()

