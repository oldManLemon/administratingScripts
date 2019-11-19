$CallEMS = ". '$env:ExchangeInstallPath\bin\RemoteExchange.ps1'; Connect-ExchangeServer -auto -ClientApplication:ManagementShell "
Invoke-Expression $CallEMS
Set-ADServerSettings -ViewEntireForest $true
$get_easusers = get-casmailbox -Identity "*" -Filter { ActiveSyncEnabled -eq $true } -Resultsize unlimited | Select Name, Displayname, samaccountname, primarysmtpaddress, guid, identity, distinguishedname, ActiveSyncenabled, Owaenabled, hasactivesyncdevicepartnership
$str_ret = "Name;Displayname;SamAccountName;PrimarySmtpAddress;Guid;Identity;DistinguishedName;ActiveSyncEnabled;OwaEnabled;HasActiveSyncDevicePartnership"
foreach ($user in $get_easusers) {
    $str_ret += "`r`n" + $user.Name + ";" + $user.displayname + ";" + $user.SamAccountName + ";" + $user.PrimarySmtpAddress + ";" + $user.Guid + ";" + $user.Identity + ";" + $user.DistinguishedName 
    $str_ret += ";" + $user.ActiveSyncEnabled + ";" + $user.OWAEnabled + ";" + $user.HasActiveSyncDevicePartnership
}
$str_ret | Out-File -FilePath "C:\temp\get-casmailbox_activesyncenabled.csv"

$get_mobiledevices = Get-MobileDevice -resultsize unlimited | select name, FriendlyName, DeviceID, DeviceIMEI, Devicemobileoperator, DeviceOS, DeviceOSLanguage, DeviceTelephoneNumber, DeviceType, DeviceUserAgent, DeviceModel, UserDisplayName, DeviceAccessState, DeviceAccessStateReason, DeviceAccessControlRule, guid, id, isvalid, FirstSyncTime
$str_ret = "Name;FriendlyName;DeviceID;DeviceIMEI;DeviceMobileOperator;DeviceOS;DeviceOSLanguage;DeviceTelephoneNumber;DeviceType;DeviceUserAgent;DeviceModel;UserDisplayName;DeviceAccessState;DeviceAccessStateReason;DeviceAccessControlRule;Guid;ID;isvalid;FirstSyncTime"
foreach ($mobiledevice in $get_mobiledevices) {
    $str_ret += "`r`n" + $mobiledevice.Name + ";" + $mobiledevice.FriendlyName + ";" + $mobiledevice.DeviceID + ";" + $mobiledevice.DeviceIMEI + ";" + $mobiledevice.Devicemobileoperator 
    $str_ret += ";" + $mobiledevice.DeviceOS + ";" + $mobiledevice.DeviceOSLanguage + ";" + $mobiledevice.DeviceTelephonenumber + ";" + $mobiledevice.DeviceType + ";" + $mobiledevice.DeviceUserAgent
    $str_ret += ";" + $mobiledevice.DeviceModel + ";" + $mobiledevice.userDisplayName + ";" + $mobiledevice.DeviceAccessState + ";" + $mobiledevice.DeviceAccessStateReason
    $str_ret += ";" + $mobiledevice.DeviceAccessControlRule + ";" + $mobiledevice.Guid + ";" + $mobiledevice.ID + ";" + $mobiledevice.isvalid + ";" + $mobiledevice.FirstSyncTime
}
$str_ret | Out-File -FilePath "C:\temp\get-mobiledevice.csv"