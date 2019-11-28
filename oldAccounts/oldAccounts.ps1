

Search-ADAccount -AccountDisabled -UsersOnly  |Sort-Object LastLogonDate
# Search-ADAccount -AccountDisabled -UsersOnly |where LastLogonDate |Sort-Object LastLogonDate |Select-Object Name,LastLogonDate |Export-Csv -Delimiter ";" -Path "./Oldaccounts.csv"