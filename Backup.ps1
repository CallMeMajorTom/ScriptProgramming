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
    Set-WBPolicy -Policy $Policy
    #Starts the backup job
    Start-WBBackup -Policy $Policy

    if ([System.Diagnostics.EventLog]::SourceExists("C:\Users\Administrator\Scriptprogramming\BackupEnvironment.ps1") -eq $False) {
        New-EventLog -LogName "BackupStatus" -Source "C:\Users\Administrator\Scriptprogramming\BackupEnvironment.ps1"
    }
    Write-EventLog -LogName "BackupStatus" -Source  "C:\Users\Administrator\Scriptprogramming\BackupEnvironment.ps1" -EventID 3001 -EntryType SuccessAudit -Message "Backup($date) success"
} Catch {
   if ([System.Diagnostics.EventLog]::SourceExists("C:\Users\Administrator\Scriptprogramming\BackupEnvironment.ps1") -eq $false) {
        New-EventLog -LogName "BackupStatus" -Source "C:\Users\Administrator\Scriptprogramming\BackupEnvironment.ps1";
   }
   Write-EventLog -LogName "BackupStatus" -Source  "C:\Users\Administrator\Scriptprogramming\BackupEnvironment.ps1" -EventID 3001 -EntryType SuccessAudit -Message "Backup($date) ERROR"
}
