
$me = Get-ADUser -Identity euser -Properties *
$potter = Get-ADUser -Identity ahase -Properties "UserPrincipalName","MemberOf", "ProfilePath","CN", "City", "c","Country","l","mail","mailNickname","st","State","Department","Description"

# $me = Get-ADUser -Identity ahase -Properties "UserPrincipalName","MemberOf", "ProfilePath"
#$p = Get-ADUser -Identity hpotter -Properties "UserPrincipalName","MemberOf", "ProfilePath"
#,"Email"
# $me.GetType().FullName
# $me.UserPrincipalName
# $me.MemberOf
# $me.GivenName
# $s = $me.DistinguishedName

# $sectionOneGarbage, $sectionTwoGarbage, $sectionThree = $s.Split(',')
# $newPath
# $noComma = $sectionThree.Length
# $i = 1
# foreach($section in $sectionThree){
    
#     $newPath +=  $section
#     if($i -lt $noComma){
#         $newPath += ','
#     }
#     $i++
# }
# $newPath
# $me
#$potter.Title
$me.Title

