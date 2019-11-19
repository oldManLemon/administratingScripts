#Taking German names and making them work as usernames for AD
#AD can have umlauts but best to keep them out of Usernames but can remain in Display names
#Ä does not work but should be fine as there are no First names with Ä that I can find and Rarly a Surname Problem.

#Same setup as in previous scipts
$demoName = "Ä"

# $firstName, $lastName = $demoName.Split(' ')

function Convert-Umlaut
{
  param
  (
    [Parameter(Mandatory)]
    [string]$name
  )
  Write-Host "Here" $name
  $output = $name.Replace('ö','oe').Replace('ä','ae').Replace('ü','ue').Replace('ß','ss').Replace('Ö','Oe').Replace('Ü','Ue').Replace('Ä','Ae')
  $isCapitalLetter = $name -ceq $name.toUpper()
  if ($isCapitalLetter) 
  { 
    $output = $output.toUpper() 
  }
  $output
}

Convert-Umlaut($demoName)