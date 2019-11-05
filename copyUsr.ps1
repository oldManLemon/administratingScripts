

$usrToCopy = Read-Host -Prompt 'Please enter the user you wish to copy here'
$firstName, $lastName = $usrToCopy.Split(' ')

#$defaultPassword = 'Start#2019' 
$defaultPassword = ConvertTo-SecureString -String "Start#2019" -AsPlainText -Force
#$defaultPassword=ConvertTo-SecureString 'MySuperSecretP@ssw0rd!'

# #For testing
# $firstName = 'Andrew'
# $lastName = 'Hase'

# Write-Host "You are searching firstname'$firstName'"

$filterForAdSearch = "givenName -like ""*$firstName*"" -and sn -like ""$lastName"""

$user = try {
    Get-ADUser -Filter $filterForAdSearch -Properties "MemberOf"
    Write-Host 'User' $usrToCopy 'will now be your template'
}
catch {
    Write-Host "Please check again, user is not found. 'n Is this user in Stuttgart?"
}

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
    #Create user login
    $newSamAccountName = ($newFirstName[0] + $newLastName).ToLower()
    #check to see if user login already exists and create a new version if exists
    #Example Tim Burton is tburton however if that exists it will create tiburton and timburton and so on and so fourth
    $newSamAccountName = checkUsrSam -samName $newSamAccountName -fName $newFirstName -lName $newLastName -run 1
    Write-Host $newSamAccountName
    
   
    

    New-ADUser -Name $newUsr -SamAccountName $newSamAccountName -ChangePasswordAtLogon $True -AccountPassword $defaultPassword -Instance $user 


}
else {
    Write-Host 'Please check again, user is not found is this user in Stuttgart?'
}

