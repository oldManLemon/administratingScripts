#Simple Script that scans all Forests for all empty groups and places them in an array. 

$domains = Get-ADForest | select -ExpandProperty domains
$emptyGroups = @() #Array

foreach($domain in $domains){
    $groups = Get-ADGroup -Filter * -Server $domain
    foreach($group in $groups){
        $groupDetails = Get-ADGroup $group -Properties "Members" -Server $domain | select -ExpandProperty Members 
        if($groupDetails -eq $null){
            $emptyGroups +=$group
        }
    }
}
$emptyGroups | select name, distinguishedname | Export-Csv leereGruppen.csv