CD C:\Shared
$cert = dir cert:\CurrentUser\my\ -CodeSigningCert
Set-AuthenticodeSignature \\DC01\Shared\UserDiskSapce.ps1 $cert