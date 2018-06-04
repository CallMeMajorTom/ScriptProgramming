Set-StrictMode -Version 1.0 ;
#Get current username
$UserName = $env:UserName
$HomeDirectory = (Get-AdUser -filter {name -eq $UserName} -properties *).HomeDirectory
#$Size = (Get-ChildItem $UserName -Recurse | Measure-Object -Property Length -Sum).Sum/1MB
$Size = Get-ChildItem -Path $HomeDirectory | measure-object -property length -sum
$Size = $Size/1MB
Write-Host "Your home directory $username is $size MB"
