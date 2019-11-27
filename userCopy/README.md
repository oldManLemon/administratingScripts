# User Copy Tool

This powershell script is designed to copy a template user and create a new user in the same location. 
Reason: Instead of hunting down a user and finding their location then right clicking and selecting copy and filling out the users Name, Full name and password the script will do all of this for you. 

### Usage: 
Load up powershell, making sure it has access to AD functionality. It is also required that the user running the script has permissions. Best to run this on your AD server as an Admin

    .\copyUserCli.ps1 "Template User" "New User"

The above string assumes writing in a normal western style of "FirstName LastName" style and will take of things from there.


### Notes
Display Name will keep umlauts but the login will convert umlauts eg: Ö = Oe
ERP Groups are removed, there were some false positives which are put in an if statement, this should be checked or a better solution written in the future.

    #-------------False postive Groups -----------------------------
    # CN=Exchange Enterprise Servers,CN=Users,DC=intern,DC=ahs-de,DC=com
    # CN=dl_berPublic_vz,OU=Security Groups,OU=BER,OU=Stations,OU=x,DC=intern,DC=ahs-de,DC=com
    # CN=gl_LW-L_berPublic,OU=Security Groups,OU=BER,OU=Stations,OU=x,DC=intern,DC=ahs-de,DC=com
    # CN=dl_berProjects_vz,OU=Security Groups,OU=BER,OU=Stations,OU=x,DC=intern,DC=ahs-de,DC=com
    # Get-ADGroup -Identity "CN=Exchange Enterprise Servers,CN=Users,DC=intern,DC=ahs-de,DC=com"
    # Get-ADGroup -Identity "CN=gl_LW-L_berPublic,OU=Security Groups,OU=BER,OU=Stations,OU=x,DC=intern,DC=ahs-de,DC=com"


## New Features
- Write the email to send back with new user details
- Add option to give new user an email 

