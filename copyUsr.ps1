
$usrToCopy = Read-Host -Prompt 'Please enter the user you wish to copy here'
$firstName, $lastName = $usrToCopy.Split(' ')
$defaultPassword = ConvertTo-SecureString -String "Start#2019" -AsPlainText -Force
$filterForAdSearch = "givenName -like ""*$firstName*"" -and sn -like ""$lastName"""

$user = try {
    Get-ADUser -Filter $filterForAdSearch -Properties "UserPrincipalName","MemberOf", "ProfilePath","CN", "City", "c","Country","l","mail","mailNickname","st","State","Department","Description","Title"
    Write-Host 'User' $usrToCopy 'will now be your template'
}
catch {
    Write-Host "Please check again, user is not found. 'n Is this user in Stuttgart?"
}
if($user -is [array] ){
    Write-Host 'There is has being an err, your selected user to copy has showed up more than once, it is an array not an obj. Breaking'
    break
}
$userInstance = Get-ADUser -Identity $user.SamAccountName

function checkUsrSam {
    Param ([string]$samName, [string]$fName, [string]$lName, [int]$run)
    # write-host 'Here is account: '$samName 'Here is first name:' $fName 'Here is last name:' $lName
    
    $checkSam = try {
        Get-ADUser -Identity $samName
    }
    catch {
        write-host 'UserName Generated'
    }
       
    if ($checkSam) {

        $firstPart = $fName.Substring(0, $run)
        $samName = $firstPart + $lName
        $run = $run + 1
        #write-host 'Now the new name is ' $samName
        checkUsrSam -samName $samName -fName $fname -lName $lName -run $run
    }
   
    else {
        return $samName
    }

    
}


IF ($user) {
    Write-Host 'User Found to be copied'
    $newUsr = Read-Host -Prompt 'Enter name of new user'

    $newFirstName, $newLastName = $newUsr.Split()
    #Flip the user names to match all other users
    $newUsr = $newLastName+', '+$newFirstName
    #$newUsr
    #Create user login
    $newSamAccountName = ($newFirstName[0] + $newLastName).ToLower()
    #check to see if user login already exists and create a new version if exists
    #Example Tim Burton is tburton however if that exists it will create tiburton and timburton and so on and so fourth
    $newSamAccountName = checkUsrSam -samName $newSamAccountName -fName $newFirstName -lName $newLastName -run 1
    #keep user unmodified
    $stringMod = $user
    $frontGarbage, $endPrincipal = $stringMod.UserPrincipalName.Split('@')
    # Create a new principle name for login in modern Systems
    $newUsrPrincipalName = $newSamAccountName + '@' + $endPrincipal
    # $newUsrPrincipalName
    $s = $stringMod.DistinguishedName
    # Getting user into the correct OU by generating path
    $sectionOneGarbage, $sectionTwoGarbage, $sectionThree = $s.Split(',')
    $displayName = $newLastName+', '+$newFirstName
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
    
    $params = @{
        "Instance"=$userInstance
        "Name"=$newUsr
        "DisplayName"= $displayName
        "GivenName"=$newFirstName
        "SurName"=$newLastName
        "AccountPassword"=$defaultPassword
        "Enabled"=$enabled
        "ChangePasswordAtLogon"=$true
        "UserPrincipalName" = $newUsrPrincipalName
        #Here are the details
        "c" = $user.c
        "City" = $user.City
        "Country" = $user.Country
        "Department" = $user.Department
        "Discription" = $user.Discription


    }
    #$newPath

    
   #Create New User

   #New-ADUser $params -WhatIf
   
    

    # New-ADUser -Name $newUsr -SamAccountName $newSamAccountName -Path $newPath -ChangePasswordAtLogon $True -AccountPassword $defaultPassword -GivenName $newFirstName -Surname $newLastName -DisplayName $newLastName', '$newFirstName -UserPrincipalName $newUsrPrincipalName -Instance $userInstance -WhatIf
    # New-ADUser -Name $newUsr -SamAccountName $newSamAccountName -ChangePasswordAtLogon $True -AccountPassword $defaultPassword -Instance $user -WhatIf

}
else {
    Write-Host 'Please check again, user is not found is this user in Stuttgart?'
}

