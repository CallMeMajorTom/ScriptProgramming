Set-StrictMode -Version 1.0 ;
Import-Module ActiveDirectory -ErrorAction Stop;
$Users = Get-ADUser -Filter *;
$OUs = Get-ADOrganizationalUnit -Filter *;

ForEach ($OU in $OUs) {
    $OUName = $OU.distinguishedName;
    [array]$OUNameSplit = $OUName -split ','
    
    if(($OUNameSplit[1] -eq "OU=Accounts") -and !($OUNameSplit[1] -eq "OU=Groups") -and !($OUNameSplit[0] -eq "OU=Groups") -and !($OUNameSplit[0] -eq "OU=Desktops")){
      $ShadowGroupName = "SG_" + $OUNameSplit[0].Remove(0,3)

      foreach ($User in $Users)
      {
        $UserOUName = $User.DistinguishedName
        [array]$UserOUNameSplit = $UserOUName -split ','
        if($UserOUNameSplit[1] -like  $OUNameSplit[0]){
          Add-ADPrincipalGroupMembership -Identity $User.SamAccountName -MemberOf $ShadowGroupName}
      }

      $Members = Get-ADGroupMember -Identity $ShadowGroupName
      foreach ($Member in $Members)
      {
        $MemberOUName = $Member.DistinguishedName
        [array]$MemberOUNameSplit = $MemberOUName -split ','
        if($MemberOUNameSplit[1] -notlike  $OUNameSplit[0]){
          Remove-ADPrincipalGroupMembership -Identity $Member -MemberOf $ShadowGroupName -Confirm:$false
        }
      }

    }
}

# SIG # Begin signature block
# MIII0AYJKoZIhvcNAQcCoIIIwTCCCL0CAQExCzAJBgUrDgMCGgUAMGkGCisGAQQB
# gjcCAQSgWzBZMDQGCisGAQQBgjcCAR4wJgIDAQAABBAfzDtgWUsITrck0sYpfvNR
# AgEAAgEAAgEAAgEAAgEAMCEwCQYFKw4DAhoFAAQUdfkhxquf47FqAniHFWTBKP+/
# H/mgggYMMIIGCDCCBPCgAwIBAgITHAAAAARSNbfE3NJhxAAAAAAABDANBgkqhkiG
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
# BgorBgEEAYI3AgELMQ4wDAYKKwYBBAGCNwIBFTAjBgkqhkiG9w0BCQQxFgQUYCgp
# MixWPUoyJ/EbmX0cHZS5j5EwDQYJKoZIhvcNAQEBBQAEggEAIX1lVeDdmWHj/f8y
# OHCnIDVHbDsBq/3RZMLvIs2zFDZAuii+OSrjHN6XSGJDjhyMCBjIEsEXaacNVOpl
# 456tNFVf2jKSM4KjbPCHv908Gm/4koRSf7w9vjNvJLrg2Kfp/XgBW1pe1CfHFUYj
# Lrl2Ol+WPEjI3JnpNGwmrzuJqaZJe6EeNHWPJrDaIOTdnch2+IkSX9e67ZCqDDM9
# nJdqwrPBkQCXc+dfRlfjj3c2CHv3KjqpDr0ecmdHSKFtEz/0H/mBUGUmnUeMurYS
# KJTajZkIpM28jmhULlGbHX1yfa0R7MdqSxzmELORrQ0Q2kSq8Vk6gjwM4hIlMcE3
# 3xpHzg==
# SIG # End signature block
