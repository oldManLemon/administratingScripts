param(
[string]$Server
) 

if (!$Server)
{
    $Server = $env:computername 
}
#Store Data in AppData for access later
$appDataLocation = $env:LOCALAPPDATA+'\aviovaManagementApp\'
$testPath = Test-Path $appDataLocation
if(!$testPath){
    New-Item -Path $env:LOCALAPPDATA -Name "aviovaManagementApp" -ItemType "directory"

}
$userDataLocation = $appDataLocation+"usrData\"
$testPath = Test-Path $userDataLocation

if(!$testPath){
    New-Item -Path $appDataLocation -Name "usrData" -ItemType "directory"
}
#Get CSV with Full Display Names and account names
#Get-ADUser -Server $server -Filter '*' -Properties DisplayName, Samaccountname | select DisplayName, Samaccountname | Export-Csv $userDataLocation$server".csv"
#Get-ADUser -Server $server -Filter '*' -Properties DisplayName, Samaccountname | select DisplayName, Samaccountname | Out-File $userDataLocation$server".txt"
Get-ADUser -Server $server -Filter '*' -Properties DisplayName, Samaccountname | select DisplayName, Samaccountname | Format-List DisplayName, Samaccountname | Out-File $server".txt"

# $name,$sam = $user.DisplayName,$user.Samaccountname 
# $name.GetType().FullName
# for($i = 0 
# $i -le $sam.Count
# $i++){
#     $string = $user[$i] +":"+ $sam[$i]
#     Add-Content -Path $server".txt" -Encoding "utf8" -Value $string

# }




# param(
# [string]$Server
# ) 

# if (!$Server)
# {
#     $Server = $env:computername 
# }

# Get-ADUser -Server $server -Filter '*' -Properties DisplayName, Samaccountname | select DisplayName, Samaccountname | Export-Csv $server'.csv' 



# param(
# [string]$Server
# ) 

# if (!$Server)
# {
#     $Server = $env:computername 
# }

# $fileLocation = 'C:\Users\ahase\source\repos\poshScripts\userData\'+$server+'.csv' 



# Get-ADUser -Server $server -Filter '*' -Properties DisplayName, Samaccountname | select DisplayName, Samaccountname | Export-Csv $fileLocation




