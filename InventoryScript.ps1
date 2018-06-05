Set-StrictMode -Version 1.0 ;
#Set a default path
$path = "C:\Users\Administrator\scriptprogramming\";
$FileName = "Clients_Inventory";

    $InputPath = $args[0]
    $InputFile = $args[1]
    if($InputPath -eq $null){
        Write-Host "There is no INPUT $InputPath";
        #Exit 0
    }
    elseif (Test-Path $InputPath) {
        $path = $InputPath
    } else {
        Write-Host "There is no $InputPath";
        Exit 0
    }

    $TestPath = $InputPath+$InputFile
    if($InputFile -eq $null){
        Write-Host "There is no INPUT $InputFile";
        #Exit 0
    }
    elseif(Test-Path $TestPath) {
        $FileName = $InputFile;
    } else {
      Write-Host "There is no $InputFile under $InputPath";
      Exit 0
    }


$Name = "Name";
$OS = "Operating System";
$Version = "Version";
$LastDateUpdate = "Last Date Update";
$TotalDiskSpace = "Total Disk Space";
$FreeDiskSpace = "Free Disk Space";
"$Name,$OS,$Version,$LastDateUpdate,$TotalDiskSpace,$FreeDiskSpace" | Format-Table | Out-File "$FileName.csv";

$Computers = Get-ADComputer -Filter *;

Foreach ($Computer in $Computers)
{
  $ComputerName = $Computer.Name
  if((Test-Connection -ComputerName $ComputerName -Quiet)){
     $ComputerObject= Get-WmiObject -Computer $ComputerName -Class Win32_OperatingSystem
     #Get Operating System and version
     $os = $ComputerObject.Caption
     $version = $ComputerObject.Version

     #Get Last Update DATE
     $LastUpdateEntry = Get-WmiObject -Computer $ComputerName -ClassName win32_quickfixengineering | sort installedon -desc | select -First 1
     $lastUpdateDate = $LastUpdateEntry.InstalledOn

     #Get Space information
     $totalDiskSpace = 0
     $freeDiskSpace = 0
     Get-WmiObject -ComputerName $ComputerName -ClassName Win32_LogicalDisk  | Select-Object -Property Size,FreeSpace | %{
       $totalDiskSpace += $_.Size
       $freeDiskSpace += $_.FreeSpace
     }
     [int]$totalDiskSpaceInt = $totalDiskSpace/1MB;
     [int]$freeDiskSpaceInt = $freeDiskSpace/1MB;

    cd $path;"$ComputerName,$os,$version,$lastUpdateDate,$totalDiskSpaceInt,$freeDiskSpaceInt" | Format-Table | Out-File -append "$FileName.csv";
  }
}

# SIG # Begin signature block
# MIII0AYJKoZIhvcNAQcCoIIIwTCCCL0CAQExCzAJBgUrDgMCGgUAMGkGCisGAQQB
# gjcCAQSgWzBZMDQGCisGAQQBgjcCAR4wJgIDAQAABBAfzDtgWUsITrck0sYpfvNR
# AgEAAgEAAgEAAgEAAgEAMCEwCQYFKw4DAhoFAAQUAyEdDCyqUjQLCdKexXLaj9fO
# wVmgggYMMIIGCDCCBPCgAwIBAgITHAAAAARSNbfE3NJhxAAAAAAABDANBgkqhkiG
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
# BgorBgEEAYI3AgELMQ4wDAYKKwYBBAGCNwIBFTAjBgkqhkiG9w0BCQQxFgQUuJpo
# wSDLx2IMzCfD5Hf/HbVevOQwDQYJKoZIhvcNAQEBBQAEggEAHeZfL0B17NwMjFlW
# i07vN9PCE74tAxaSqDRmVh2RjXUcsbU74RpFua3hhYfyehaYNdrmlC4x8LYsW6eR
# jOJpHRlhcZiYdw29klUdkp5NZOZBLltCa2aLP4PXUuhFNPU+N2dGmMH8QgTZE5IT
# OR2qFH9pJhU/4+SWqLP6l4+fa1S2v3VaU/Z50uYYIgbPage7OfVL9D0L2MwhALdz
# swkGNRHGH27F/jTqyrnHjzSreYPv5851GOyfKV4a6lTn7VTKH8DUUFSkJpDZmJ8v
# ZX4W0V0HaGJp1wxYBXx4uqcjvol/R2B+iNPsqLv7kAoPBT1QBRwso7frfgkingFQ
# zYvf2Q==
# SIG # End signature block
