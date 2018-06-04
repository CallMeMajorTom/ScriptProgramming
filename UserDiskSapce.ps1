Set-StrictMode -Version 1.0 
$UserName = $env:USERNAME
$Size = (Get-ChildItem C:\Users\$UserName -Recurse | Measure-Object -Property Length -Sum).Sum/1MB
Write-Host "Your home directory $UserName is $Size MB"
