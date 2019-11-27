######### .d8888. d88888b d888888b db    db d8888b.  ########
######### 88'  YP 88'     `~~88~~' 88    88 88  `8D  ########
######### `8bo.   88ooooo    88    88    88 88oodD'  ########
#########   `Y8b. 88~~~~~    88    88    88 88~~~    ########
######### db   8D 88.        88    88b  d88 88       ########
######### `8888Y' Y88888P    YP    ~Y8888P' 88       ########
                                          

#Turn into params
# $usrToCopy = Read-Host -Prompt 'Please enter the user you wish to copy here'
$usrToCopy = $args[0] #Probs should make this safer by being more verbose but for now testing
$firstName, $lastName = $usrToCopy.Split(' ')
$defaultPassword = ConvertTo-SecureString -String "Start#2019" -AsPlainText -Force
$filterForAdSearch = "givenName -like ""*$firstName*"" -and sn -like ""$lastName"""

#Get the user object
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

#Required for the copy of the user?
$userInstance = Get-ADUser -Identity $user.SamAccountName


# #     ______                 __  _                 
# #    / ____/_  ______  _____/ /_(_)___  ____  _____
# #   / /_  / / / / __ \/ ___/ __/ / __ \/ __ \/ ___/
# #  / __/ / /_/ / / / / /__/ /_/ / /_/ / / / (__  ) 
# # /_/    \__,_/_/ /_/\___/\__/_/\____/_/ /_/____/



function checkUsrSam {
    Param ([string]$samName, [string]$fName, [string]$lName, [int]$run)
    #Function Checks usee name to see if it is taken. Currently it will then add another letter from the first name 
    #It does this recursivly. Currently there is no catch for when we run out of letters. 
    
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
        #Recursive
        checkUsrSam -samName $samName -fName $fname -lName $lName -run $run
    }
    else {
        return $samName
    }
}
function userProfilePathModifier {
    Param([System.Object] $templateUser, [string]$newUserSam)
    #Creates a new profile path if needed for the new user based on their user name. 
    try {
        $firstpart, $secondPart = $templateUser.ProfilePath.Split("$")
        $newSecondpart = '$\' + $newUserSam + '\profile'

        $finalString = $firstpart + $newSecondpart
        return $finalString	
    }
    catch {
        return Write-Output "There was and Error with the Profile path please check manually"
    }

}

function addGroupMemeber {
    Param([string]$group, [Microsoft.ActiveDirectory.Management.ADAccount]$functionUser)
    #Adds the group to the memeber
    $groupObj = Get-ADGroup -Identity $group
    Add-ADGroupMember -Identity $groupObj -Members $functionUser
}


function Convert-Umlaut {
    param
    (
        [Parameter(Mandatory)]
        [string]$name
    )
    #Removes umlauts from stings. 
    Write-Host "Here" $name
    $output = $name.Replace('ö', 'oe').Replace('ä', 'ae').Replace('ü', 'ue').Replace('ß', 'ss').Replace('Ö', 'Oe').Replace('Ü', 'Ue').Replace('Ä', 'Ae')
    $isCapitalLetter = $name -ceq $name.toUpper()
    if ($isCapitalLetter) { 
        $output = $output.toUpper() 
    }
    $output
}


# # # # # __  __          _____ _   _    _____  _____ _____  _____ _____ _______   # # # # #
# # # # # |  \/  |   /\   |_   _| \ | |  / ____|/ ____|  __ \|_   _|  __ \__   __| # # # # #
# # # # # | \  / |  /  \    | | |  \| | | (___ | |    | |__) | | | | |__) | | |    # # # # # 
# # # # # | |\/| | / /\ \   | | | . ` |  \___ \| |    |  _  /  | | |  ___/  | |    # # # # # 
# # # # # | |  | |/ ____ \ _| |_| |\  |  ____) | |____| | \ \ _| |_| |      | |    # # # # # 
# # # # # |_|  |_/_/    \_\_____|_| \_| |_____/ \_____|_|  \_\_____|_|      |_|    # # # # #

If ($user) {
    Write-Host 'User Found to be copied'
    # $newUsr = Read-Host -Prompt 'Enter name of new user'
    $newUsr = $args[1]
    $newFirstName, $newLastName = $newUsr.Split()

    #Flip the user names to match all other users
    $newUsr = $newLastName + ', ' + $newFirstName
  
    #Create user login
    $newSamAccountName = ($newFirstName[0] + $newLastName).ToLower()
    $newSamAccountName = Convert-Umlaut -name $newSamAccountName

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
    try {
        New-ADUser -Name $newUsr -SamAccountName $newSamAccountName -Instance $userInstance -DisplayName $displayName -GivenName $newFirstName -Surname $newLastName -AccountPassword $defaultPassword -Enabled $enabled -ChangePasswordAtLogon $true -UserPrincipalName $newUsrPrincipalName -Path $newPath -WhatIf
    }
    catch {
        Write-Host "Couldn't create user, most likely permission error"
        break
    }
    
    # New-ADUser -Name $newUsr -SamAccountName $newSamAccountName -Instance $userInstance -DisplayName $displayName -GivenName $newFirstName -Surname $newLastName -AccountPassword $defaultPassword -Enabled $enabled -ChangePasswordAtLogon $true -UserPrincipalName $newUsrPrincipalName -Path $newPath -Country $user.Country -Department $user.Department
   
##########          .d8b.  d8888b. d8888b. d888888b d8b   db  d888b  
##########          d8' `8b 88  `8D 88  `8D   `88'   888o  88 88' Y8b 
##########          88ooo88 88   88 88   88    88    88V8o 88 88      
##########          88~~~88 88   88 88   88    88    88 V8o88 88  ooo 
##########          88   88 88  .8D 88  .8D   .88.   88  V888 88. ~8~ 
##########          YP   YP Y8888D' Y8888D' Y888888P VP   V8P  Y888P  
##########                                                            
##########                                                            
##########      d8b   db d88888b db   d8b   db   db    db .d8888. d88888b d8888b. 
##########      888o  88 88'     88   I8I   88   88    88 88'  YP 88'     88  `8D 
##########      88V8o 88 88ooooo 88   I8I   88   88    88 `8bo.   88ooooo 88oobY' 
##########      88 V8o88 88~~~~~ Y8   I8I   88   88    88   `Y8b. 88~~~~~ 88`8b   
##########      88  V888 88.     `8b d8'8b d8'   88b  d88 db   8D 88.     88 `88. 
##########      VP   V8P Y88888P  `8b8' `8d8'    ~Y8888P' `8888Y' Y88888P 88   YD 
##########                                                                    
##########                                                                    
##########      d8888b. d88888b d888888b  .d8b.  d888888b db      .d8888. 
##########      88  `8D 88'     `~~88~~' d8' `8b   `88'   88      88'  YP 
##########      88   88 88ooooo    88    88ooo88    88    88      `8bo.   
##########      88   88 88~~~~~    88    88~~~88    88    88        `Y8b. 
##########      88  .8D 88.        88    88   88   .88.   88booo. db   8D 
##########      Y8888D' Y88888P    YP    YP   YP Y888888P Y88888P `8888Y' 
                                                          
                                                          
    
    
    #Mirror all the groups the original account was a member of
    # $user.Memberof | % { Add-ADGroupMember $_ $newSamAccountName  }

    #-------------False postive Groups -----------------------------
    # CN=Exchange Enterprise Servers,CN=Users,DC=intern,DC=ahs-de,DC=com
    # CN=dl_berPublic_vz,OU=Security Groups,OU=BER,OU=Stations,OU=x,DC=intern,DC=ahs-de,DC=com
    # CN=gl_LW-L_berPublic,OU=Security Groups,OU=BER,OU=Stations,OU=x,DC=intern,DC=ahs-de,DC=com
    # CN=dl_berProjects_vz,OU=Security Groups,OU=BER,OU=Stations,OU=x,DC=intern,DC=ahs-de,DC=com
    # Get-ADGroup -Identity "CN=Exchange Enterprise Servers,CN=Users,DC=intern,DC=ahs-de,DC=com"
    # Get-ADGroup -Identity "CN=gl_LW-L_berPublic,OU=Security Groups,OU=BER,OU=Stations,OU=x,DC=intern,DC=ahs-de,DC=com"


    #Get new User Object here to save time
    try {
        #$newSamAccountName = 'dparton'
        $newUserInstance = Get-ADUser -Identity $newSamAccountName
        "found"
    }
    catch {
        Write-Output "New user was not created or found"
    }
    #Mirror all groups of the original account but do not copy ERP group Memeberships
    foreach ($group in $user.MemberOf) {
        if ($group.Contains("ERP")) {
            Write-Output "DISREGARD! "$group
           
        }
        elseif ($group.Contains("OU=BER")) {
            #See False postive Groups
            # Write-Output "INCLUDE! " $group 
            addGroupMemeber -group $group $newUserInstance
          
        }
        else {
            # Write-Output "INCLUDE! " $group
            addGroupMemeber -group $group $newUserInstance
            
        }
    }
    #Add some properties to the new user

    #IF user has profile path
    if ($user.ProfilePath) {
       
        $profilePath = userProfilePathModifier -templateUser $user -newUserSam $newSamAccountName
        $profilePath
        #Set-ADuser -Identity $newSamAccountName -Description $user.Description -Department $user.Department -Country $user.Country -City $user.City -State $user.State -Title $user.Title -ProfilePath $profilePath -WhatIf
        Write-Output "Achtung: Benutzerprofilpfad wurde als "$profilePath" hinzugefügt "
        Write-Output "Attention: User Profilepath was added "$profilePath
    }
    else {
        #Set-ADuser -Identity $newSamAccountName -Description $user.Description -Department $user.Department -Country $user.Country -City $user.City -State $user.State -Title $user.Title -WhatIf
    }
   

}

###### ______    _ _   __  __                                     
###### |  ____|  (_) | |  \/  |                                    
###### | |__ __ _ _| | | \  / | ___  ___ ___  __ _  __ _  ___  ___ 
###### |  __/ _` | | | | |\/| |/ _ \/ __/ __|/ _` |/ _` |/ _ \/ __|
###### | | | (_| | | | | |  | |  __/\__ \__ \ (_| | (_| |  __/\__ \
###### |_|  \__,_|_|_| |_|  |_|\___||___/___/\__,_|\__, |\___||___/
######                                              __/ |          
######                                             |___/   
###### 
else {
    Write-Host 'Please check, user is not found is this user in Stuttgart?'
    Write-Host 'Bitte überprüfen, Benutuzer nicht gefundet, ist dieser Benutzer in Stuttgart?'
}

 