# $string = 'Andrew'
# $last = 'Hase'
# $fin = $string.Substring(0,2)+$last
# write-host $fin

# $string = '"Andrew Hase"'
# $string = $string.Trim('"')
# $string
# $firstName="Andrew"
# $lastName="Hase"
# $insertable ="ahase"
# $firstName="Robert"
# $lastName="Lampart"
# $filterForAdSearch = "givenName -like ""*$firstName*"" -and sn -like ""$lastName"""
# $test = Get-ADUser -Filter $filterForAdSearch -Properties "ProfilePath"
# $test.ProfilePath
# $test.SamAccountName
# $test.GetType().FullName

# if($test.ProfilePath){
#     $profilePathString = $test.ProfilePath
#     $profilePathString
#     "Clean Up or remove the user name and replace"
#     $firstpart,$secondPart=$profilePathString.Split("$")

#     $newSecondpart = '$\'+$insertable+'\profile'

#     $finalString = $firstpart+$newSecondpart
#     $finalString	


# $erp = Get-ADGroup -Filter 'Name -like "*ERP*"' -Properties 'Name'

# $erp.Name
$r = ("this","tes" )
$t = ("this","kjh" )


$g = ("CN=gl_DUSKP_Postfach,OU=Security Groups,OU=DUS,OU=Stations,OU=x,DC=intern,DC=ahs-de,DC=com","CN=User ERP \#AHS,OU=MailSecurityDistribution,OU=AHS-Groups,OU=x,DC=intern,DC=ahs-de,DC=com")
$h = ("CN=User ERP \#AHS,OU=MailSecurityDistribution,OU=AHS-Groups,OU=x,DC=intern,DC=ahs-de,DC=com","CN=RUS_ahs-de.com,OU=Empfaengerrichtlinien,DC=intern,DC=ahs-de,DC=com")

foreach($x in $h){
    if($g.Contains($x)){
        $x
    }
}