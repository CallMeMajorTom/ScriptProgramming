Set-StrictMode -Version 1.0
Import-Module ActiveDirectory -ErrorAction Stop

#Default path
$path = "C:\Users\Administrator\scriptprogramming\"
$FilePath = $Path + $args[0]

if (!($args[0] -match ".*[.]csv$")) {
    Write-Host "[ERROR] Not a valid csv file"
    Exit 0
}if (Test-Path $FilePath){
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
  $SamAccountName = $SamAccountName.Replace('é','e').Replace('ö','o').Replace('ä','a').Replace('é','e')

  #Test Whether there is same name or sAMAccountName
  #Name
  $BoolTestName = Get-ADUser -Filter {Name -eq $Name}
  if($BoolTestName){
    for ($i = 2; $i -lt 10; $i++) { #second user end with 2
        $TestName = $Name+$i;
        if (!(Get-ADUser -Filter {Name -eq $TestName})){
            $Name = $TestName
            break;
        }
        if ($d -eq 10) { #no naming clash solving possibility was found, the alphabet letters are run out
            Write-Host "No avalible name for $Name"
            Exit 0
        }
    }
  }

  #sAMAccountName
  $BoolTestSamAccountName = Get-ADUser -Filter {sAMAccountName -eq $SamAccountName}
  if($BoolTestSamAccountName){
    for ($j = 3; $j -lt $LName.Length; $j++){
      $TestSamAccountName = ($FName.Substring(0,2) + $LName.Substring(0,$j)).ToLower();
      $TestSamAccountName = $TestSamAccountName.Replace('é','e').Replace('ö','o').Replace('ä','a').Replace('é','e')
      if(!(Get-ADUser -Filter {sAMAccountName -eq $SamAccountName})){
        $SamAccountName = $TestSamAccountName
        break
      }
      if ($d -eq $LName.Length) { #no naming clash solving possibility was found, the alphabet letters are run out
          Write-Host "No avalible SamAccountName for $Name"
          Exit 0
      }
    }
  }

  $UserPrincipalName = $SamAccountName + "@scripting.nsa.his.se";


  #Get Random characters
  function Get-RandomCharacters($length, $characters) {
    $random = 1..$length | ForEach-Object { Get-Random -Maximum $characters.length }
    $private:ofs=""
    return [String]$characters[$random]
  }

  #Generate random password
  $password = Get-RandomCharacters -length 1 -characters 'ABCDEFGHKLMNOPRSTUVWXYZ'
  $password += Get-RandomCharacters -length 2 -characters 'abcdefghiklmnoprstuvwxyz'
  $password += Get-RandomCharacters -length 1 -characters '!"§$%&/()=?}][{@#*+'
  $password += Get-RandomCharacters -length 3 -characters '1234567890'

  $SecurePass = ConvertTo-SecureString -AsPlainText $password -Force

  #Check the exist of OU
  if (!(Get-ADOrganizationalUnit -Filter {Name -like $Department})) { #department does not exist
      New-ADOrganizationalUnit -Name $Department -Path "OU=Accounts,DC=scripting,DC=nsa,DC=his,DC=se";
  }

  $OUPath = "OU=$Department,OU=Accounts,DC=scripting,DC=nsa,DC=his,DC=se"

  #Add new user
  New-ADUser -Name $Name -SamAccountName $SamAccountName -City $city -GivenName $FName -Surname $LName -Department $Department -Title $Role -EmailAddress $UserPrincipalName -UserPrincipalName $UserPrincipalName -Enabled $True -AccountPassword $SecurePass -ChangePasswordAtLogon $True -Path $OUPath
  cd $Path+"UserFile\";"Username = $SamAccountName; Password = $password" | out-file "$Name.txt"

  #Add user to Group
  #LocalGroup
  $LocalGroupName = $City
  if (!(Get-ADGroup -Filter {SamAccountName -like $LocalGroupName})){
      New-ADGroup -SamAccountName $LocalGroupName -Name $LocalGroupName -Path "OU=Roles,OU=Groups,OU=Accounts,DC=scripting,DC=nsa,DC=his,DC=se" -GroupScope Global; #
  }
  Add-ADGroupMember -Identity $LocalGroupName -Members $SamAccountName;
  #shadowGroup
  $shadowGroupName = "SG_"+$Department
  if (!(Get-ADGroup -Filter {SamAccountName -like $shadowGroupName})){
      New-ADGroup -SamAccountName $shadowGroupName -Name $shadowGroupName -Path "OU=Roles,OU=Groups,OU=Accounts,DC=scripting,DC=nsa,DC=his,DC=se" -GroupScope Global; #
  }
  Add-ADGroupMember -Identity $shadowGroupName -Members $SamAccountName;
}
