Set-StrictMode -Version 1.0
#Set-ExecutionPolicy Unrestricted
Import-Module ActiveDirectory -ErrorAction Stop

#Default path
$path = "C:\Users\Administrator\scriptprogramming\"
$FilePath = $Path + $args[0]

if (!($args[0] -match ".*[.]csv$")) {
    Write-Host "[ERROR] Not a valid csv file"
    Exit 0
}if (! (Test-Path $FilePath)){
    Write-Host "There is no $FilePath"
    Exit 0
}

$Users = Import-CSV $FilePath

Foreach ($User in $Users)
{
  #Gather Information
  $FName = $User.Firstname
  $LName = $User.Lastname
  $Name = $FName+" "+$LName
  $Department = $User.Department
  $City = $User.City
  $Role = $User.Role
  $SamAccountName = ($FName.Substring(0,2) + $LName.Substring(0,2)).ToLower();
  $SamAccountName = $SamAccountName.Replace('é','e').Replace('ö','o').Replace('ä','a').Replace('è','e')

  #Test Whether there is same name or sAMAccountName
  #Name
  $BoolTestName = Get-ADUser -Filter {Name -eq $Name}
  if($BoolTestName){
    Remove-ADUser -Identity $SamAccountName -Confirm:$false
  }

  #sAMAccountName
  $BoolTestSamAccountName = Get-ADUser -Filter {sAMAccountName -eq $SamAccountName}
  if($BoolTestSamAccountName){Remove-ADUser -Identity $SamAccountName -Confirm:$false }
}
