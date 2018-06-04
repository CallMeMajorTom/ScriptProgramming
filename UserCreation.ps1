Set-StrictMode -Version 1.0
#Set-ExecutionPolicy Unrestricted
Import-Module ActiveDirectory -ErrorAction Stop

#Default path
$path = "C:\Users\Administrator\scriptprogramming\"
$FilePath = $Path + $args[0]

if (!($args[0] -match ".*[.]csv$")) {
    Write-Host "[ERROR] Not a valid csv file"
    Exit 0
}if (!(Test-Path $FilePath)){
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
  $SamAccountName = $SamAccountName.Replace('é','e').Replace('ö','o').Replace('ä','a').Replace('è','e').Replace('å','a')

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
        if ($i -eq 10) { #no naming clash solving possibility was found, the alphabet letters are run out
            Write-Host "No avalible name for $Name"
            Exit 0
        }
    }
  }

  #sAMAccountName
  $BoolTestSamAccountName = Get-ADUser -Filter {sAMAccountName -eq $SamAccountName}
  if($BoolTestSamAccountName){
    for ($j = 3; $j -lt $LName.Length;$j++){
      $TestSamAccountName = ($FName.Substring(0,2) + $LName.Substring(0,$j)).ToLower();
      $TestSamAccountName = $TestSamAccountName.Replace('Ã©','e').Replace('Ã¶','o').Replace('Ã¤','a').Replace('Ã©','e')
      if(!(Get-ADUser -Filter {sAMAccountName -eq $SamAccountName})){
        $SamAccountName = $TestSamAccountName
        break
      }
      if ($j -eq $LName.Length) { #no naming clash solving possibility was found, the alphabet letters are run out
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
  $password += Get-RandomCharacters -length 1 -characters '!"Â§$%&/()=?}][{@#*+'
  $password += Get-RandomCharacters -length 3 -characters '1234567890'

  $SecurePass = ConvertTo-SecureString -AsPlainText $password -Force

  #Check the exist of OU
  if (!(Get-ADOrganizationalUnit -Filter {Name -like $Department})) { #department does not exist
      New-ADOrganizationalUnit -Name $Department -Path "OU=Accounts,DC=scripting,DC=nsa,DC=his,DC=se";
  }

  $OUPath = "OU=$Department,OU=Accounts,DC=scripting,DC=nsa,DC=his,DC=se"

  #Add new user
  New-ADUser -Name $Name -SamAccountName $SamAccountName -City $city -GivenName $FName -Surname $LName -Department $Department -Title $Role -EmailAddress $UserPrincipalName -UserPrincipalName $UserPrincipalName -Enabled $True -AccountPassword $SecurePass -ChangePasswordAtLogon $True -Path $OUPath
  $UserPath = $Path + "UserFile\"
  cd $UserPath;"Username = $SamAccountName; Password = $password" | out-file "$Name.txt"

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

# SIG # Begin signature block
# MIII0AYJKoZIhvcNAQcCoIIIwTCCCL0CAQExCzAJBgUrDgMCGgUAMGkGCisGAQQB
# gjcCAQSgWzBZMDQGCisGAQQBgjcCAR4wJgIDAQAABBAfzDtgWUsITrck0sYpfvNR
# AgEAAgEAAgEAAgEAAgEAMCEwCQYFKw4DAhoFAAQUjr4BLoi/Cz+tp+/Zlj2imcCO
# RUOgggYMMIIGCDCCBPCgAwIBAgITHAAAAARSNbfE3NJhxAAAAAAABDANBgkqhkiG
# 9w0BAQ0FADB1MRIwEAYKCZImiZPyLGQBGRYCc2UxEzARBgoJkiaJk/IsZAEZFgNo
# aXMxEzARBgoJkiaJk/IsZAEZFgNuc2ExGTAXBgoJkiaJk/IsZAEZFglzY3JpcHRp
# bmcxGjAYBgNVBAMTEXNjcmlwdGluZy1EQzAxLUNBMB4XDTE4MDYwNDIwMzcwM1oX
# DTE5MDQwMjEyMDAyN1owgYExEjAQBgoJkiaJk/IsZAEZFgJzZTETMBEGCgmSJomT
# 8ixkARkWA2hpczETMBEGCgmSJomT8ixkARkWA25zYTEZMBcGCgmSJomT8ixkARkW
# CXNjcmlwdGluZzEOMAwGA1UEAxMFVXNlcnMxFjAUBgNVBAMTDUFkbWluaXN0cmF0
# b3IwggEiMA0GCSqGSIb3DQEBAQUAA4IBDwAwggEKAoIBAQC6hWT0zAFBJlzQzKXD
# sIDkwsWPIStiudUT9P8iDINhiq2rWO7WHdIzcUo8EB0Af6J2yBVijyGD3Rs9WwBv
# JEtmTjL8naC4eBwB8kWH8OfLzEbbmhnoVUuxkHZluqF+Hha+pgOfgqw63tIf+Vhm
# KqvHKJGkjJ99NpHCdHFcUVOzaQrwYDOA4Jk2nUTpuLR7x2I2YDZk3aBInJmkB5cy
# a8LgkG/++tT/rhih/9AeTXbcKv1N7L+mLOlUKhwMBFMQb0QByay+Z2FvynIhvj7k
# CP3jWm3Z+f2IH6hQrihY3OuqPm03nnMmf8KMUCNPIwlTsPFGyEOHOCw3015oI1/U
# uX2/AgMBAAGjggKCMIICfjAlBgkrBgEEAYI3FAIEGB4WAEMAbwBkAGUAUwBpAGcA
# bgBpAG4AZzATBgNVHSUEDDAKBggrBgEFBQcDAzAOBgNVHQ8BAf8EBAMCB4AwHQYD
# VR0OBBYEFDvdRHh/I+YgJ/WIuOEAqTBenXzbMB8GA1UdIwQYMBaAFNfXV0diulFJ
# 39Pm9qLpse+0u9c/MIHbBgNVHR8EgdMwgdAwgc2ggcqggceGgcRsZGFwOi8vL0NO
# PXNjcmlwdGluZy1EQzAxLUNBLENOPURDMDEsQ049Q0RQLENOPVB1YmxpYyUyMEtl
# eSUyMFNlcnZpY2VzLENOPVNlcnZpY2VzLENOPUNvbmZpZ3VyYXRpb24sREM9c2Ny
# aXB0aW5nLERDPW5zYSxEQz1oaXMsREM9c2U/Y2VydGlmaWNhdGVSZXZvY2F0aW9u
# TGlzdD9iYXNlP29iamVjdENsYXNzPWNSTERpc3RyaWJ1dGlvblBvaW50MIHSBggr
# BgEFBQcBAQSBxTCBwjCBvwYIKwYBBQUHMAKGgbJsZGFwOi8vL0NOPXNjcmlwdGlu
# Zy1EQzAxLUNBLENOPUFJQSxDTj1QdWJsaWMlMjBLZXklMjBTZXJ2aWNlcyxDTj1T
# ZXJ2aWNlcyxDTj1Db25maWd1cmF0aW9uLERDPXNjcmlwdGluZyxEQz1uc2EsREM9
# aGlzLERDPXNlP2NBQ2VydGlmaWNhdGU/YmFzZT9vYmplY3RDbGFzcz1jZXJ0aWZp
# Y2F0aW9uQXV0aG9yaXR5MD0GA1UdEQQ2MDSgMgYKKwYBBAGCNxQCA6AkDCJBZG1p
# bmlzdHJhdG9yQHNjcmlwdGluZy5uc2EuaGlzLnNlMA0GCSqGSIb3DQEBDQUAA4IB
# AQCqPZlCJkJMmX3bwlOAhsrxZzOuVGitWkaWCMDhborKSJipv2lIkbmDcV+0zLU5
# 5HXt7oD8I785XOQqNlmBolulG2AxQmaJAHNdySUuTJS5txYiQJnJhAEd5zTX2n4t
# Rt+4Zd/G1ArTR8ORuBLWMxy/fVy5m9Va0d2ZB0Qr0Vvhs48DKvKQPIiwQkz8HqiP
# EozDM8CKeTsXIUy8FWP7dtstZUYegFd1kYO30lPULtPtVVRtFo2RxotnGeVOzk3V
# 6420stElWhgxc9DRXSxF5OFUADw0+FkJlWulxrR/fn5I4Q3aMC9er8fGsnDj63E3
# S+9zxfSzRQa+T6IEuiOn2Yj/MYICLjCCAioCAQEwgYwwdTESMBAGCgmSJomT8ixk
# ARkWAnNlMRMwEQYKCZImiZPyLGQBGRYDaGlzMRMwEQYKCZImiZPyLGQBGRYDbnNh
# MRkwFwYKCZImiZPyLGQBGRYJc2NyaXB0aW5nMRowGAYDVQQDExFzY3JpcHRpbmct
# REMwMS1DQQITHAAAAARSNbfE3NJhxAAAAAAABDAJBgUrDgMCGgUAoHgwGAYKKwYB
# BAGCNwIBDDEKMAigAoAAoQKAADAZBgkqhkiG9w0BCQMxDAYKKwYBBAGCNwIBBDAc
# BgorBgEEAYI3AgELMQ4wDAYKKwYBBAGCNwIBFTAjBgkqhkiG9w0BCQQxFgQUy93c
# LJ6RANmKx76JYQkjJ2g9VMIwDQYJKoZIhvcNAQEBBQAEggEAj036m+kFbIlPdISG
# Z46Xq8Bi5vkO9D29XDtFW4O9X7ylvEOlCtmKH8U9hVm8gxVhZybh/2CE3LV6lxJR
# +9dMo01s/gW5zf36h9mgzrwf5JyriGFLx599LWipV8x9wdtAxX10wIznqzxSF9WU
# Rv5ihZneVl4CRl6ccIEXy37O4CO2lEpc8gBUA/8pZZL460TtrKQ1nhZBljmL5Rqk
# NMfWk0/+PtyNKUJ3xhek9FtnoRgvfocQAzGekNBX0ezVmvFsVJ8CAyBMff8AinkA
# GrSD41YzjzFmRBhDdJxvWM+jBtSZipE7PmuZkH+wOvPu7fzbQYyz49xbobuiVc85
# xmcfjA==
# SIG # End signature block
