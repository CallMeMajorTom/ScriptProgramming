Set-StrictMode -Version 1.0 ;
#Set a default path
$path = "C:\Users\Administrator\Desktop\scriptprogramming\";
$FileName = "Clients_Inventory";

    $InputPath = $args[0]
    $InputFile = $args[1]
    if (Test-Path $args[0]) {
        $path = $InputPath;
    } else {
        Write-Host "There is no $InputPath";
        Exit 0
    }

    $TestPath = $InputPath+$InputFile

    if (Test-Path $TestPath) {
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
  if((Test-Connection -ComputerName $ComputerName)){
     $ComputerObject= Get-WmiObject -Computer $ComputerName -Class Win32_OperatingSystem
     #Get Operating System and version
     $os = $ComputerObject.Caption
     $version = $ComputerObject.Version

     #Get Last Update DATE
     $LastUpdateEntry = Get-WmiObject -ClassName win32_quickfixengineering | sort installedon -desc | select -First 1
     $lastUpdateDate = $LastUpdateEntry.InstalledOn

     #Get Space information
     $totalDiskSpace = 0
     $freeDiskSpace = 0
     Get-WmiObject -ClassName Win32_LogicalDisk -ComputerName $nameComputer | Select-Object -Property Size,FreeSpace | %{
       $totalDiskSpace += $_.Size
       $freeDiskSpace += $_.Size
     }
     [int]$totalDiskSpaceInt = $totalDiskSpace/1MB;
     [int]$freeDiskSpaceInt = $freeDiskSpace/1MB;

     cd $path;"$ComputerName,$os,$version,$lastUpdateDate,$totalDiskSpaceInt,$freeDiskSpaceInt" | Format-Table | Out-File -append "$FileName.csv";
  }
}
