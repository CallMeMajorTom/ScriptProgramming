Set-StrictMode -Version 1.0 ;
#Add server features
Add-WindowsFeature -Name Windows-Server-Backup -Restart:$false
#create a new backup policy
$Policy = New-WBPolicy
# Set the System state checkbox to true
$policy | Add-WBSystemState

$Date = Get-Date;
$Year = $Date.Year;
$Month = $Date.Month;
$WeekDay = $Date.DayOfWeek;
$HostName = Get-Host;
$HostName = $HostName.Name;
$BackupDestination = "\\DC01\Backup\$Year\$Month\$WeekDay";

Try {
    #create a file specification telling the backup job what to backup
    $fullDailyFiles = New-WBFileSpec -FileSpec "C:\Windows\SYSVOL\sysvol"
    #Adds the file specification created above to the policy
    Add-WBFileSpec -Policy $Policy -FileSpec $fullDailyFiles


    #Check Backup Destination path
    if (!(Test-Path $BackupDestination)) {
        New-Item -ItemType Directory -Force -Path $BackupDestination;
    }
    #Create a file specification telling the backup job where to backup
    $fullDailyTarget = New-WBBackupTarget -NetworkPath $BackupDestination
    #Adds the backup target created above to the policy
    Add-WBBackupTarget -Policy $policy -Target $fullDailyTarget


    if ($WeekDay -eq "Sunday") {
        if (Test-Path "$BackupDestination\*") {
           $MoveTo = "\\DC01\Backup\$Year\$Month\$HostName-$Year-$Month-$WeekDay";
           if (!(Test-Path $MoveTo)) { #if the path does not exist, create it
                 New-Item -ItemType Directory -Force -Path $MoveTo;
           }
           Move-Item -Path $BackupDestination\* -Destination $MoveTo;
        }
    }

    #Sets the backup policy to the one populated above
    #Set-WBPolicy -Policy $Policy
    #Starts the backup job
    Start-WBBackup -Policy $Policy

    if ([System.Diagnostics.EventLog]::SourceExists("C:\Users\Administrator\scriptprogramming\Backup.ps1") -eq $False) {
        New-EventLog -LogName "BackupStatus" -Source "C:\Users\Administrator\scriptprogramming\Backup.ps1"
    }
    Write-EventLog -LogName "BackupStatus" -Source  "C:\Users\Administrator\scriptprogramming\Backup.ps1" -EventID 3001 -EntryType SuccessAudit -Message "Backup($date) success"
} Catch {
   if ([System.Diagnostics.EventLog]::SourceExists("C:\Users\Administrator\scriptprogramming\Backup.ps1") -eq $false) {
        New-EventLog -LogName "BackupStatus" -Source "C:\Users\Administrator\scriptprogramming\Backup.ps1";
   }
   Write-EventLog -LogName "BackupStatus" -Source  "C:\Users\Administrator\scriptprogramming\Backup.ps1" -EventID 3001 -EntryType ERROR -Message "Backup($date) ERROR"
}

# SIG # Begin signature block
# MIII0AYJKoZIhvcNAQcCoIIIwTCCCL0CAQExCzAJBgUrDgMCGgUAMGkGCisGAQQB
# gjcCAQSgWzBZMDQGCisGAQQBgjcCAR4wJgIDAQAABBAfzDtgWUsITrck0sYpfvNR
# AgEAAgEAAgEAAgEAAgEAMCEwCQYFKw4DAhoFAAQUQL9rXcQ+0rQFIjfPpFVZfSuo
# KzOgggYMMIIGCDCCBPCgAwIBAgITHAAAAARSNbfE3NJhxAAAAAAABDANBgkqhkiG
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
# BgorBgEEAYI3AgELMQ4wDAYKKwYBBAGCNwIBFTAjBgkqhkiG9w0BCQQxFgQUFyDD
# /IyzASwYZgk9NARn4v44YJIwDQYJKoZIhvcNAQEBBQAEggEAE1jNtIuQM4UG8Tmu
# xv0UxF931C5RJjDGM9boBxlvCozlzKxX1iIqk8/K8wf4FiFBZ1zCOeQTsdjZVlWw
# VbebHcvXh4m0zzBlt3st4AaYHOdHT/q2hGaNQBVa5ueRxFxUD3ymv7HEtE2SDwJ0
# 63AqxdeNBr60EiBRxI5AUMctyJZEhEZ4ZNuvipBfu4JgyMpctEXY12Y5xFb5EFF2
# FXqXL0oRaVVr16WrhjPOmPYzSBuyKLiYWi18TWeNzAqxt3GfzqWjrexbrNy1KiAR
# r53kqwbPfHKdKO17iQGb7j8Ou/1JVlOoLHOcA6cHV+CpkBerKUGfb6Z96vWFoC6f
# NxxKTA==
# SIG # End signature block
