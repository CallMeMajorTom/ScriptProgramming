Set-StrictMode -Version 1.0 ;
Import-Module ActiveDirectory -ErrorAction Stop;
$Users = Get-ADUser -Filter *;
$OUs = Get-ADOrganizationalUnit -Filter *;

ForEach ($OU in $OUs) {
    $OUName = $OU.distinguishedName;
    [array]$OUNameSplit = $OUName -split ','
    if(($OUNameSplit[1] -eq "Accounts") -and ($OUNameSplit[1] -eq "Groups") -and ($OUNameSplit[0] -eq "Groups")){
      $ShadowGroupName = "SG_" + $OUNameSplit[0].Remove(0,3)

      foreach ($User in $Users)
      {
        $UserOUName = $User.DistinguishedName
        [array]$UserOUNameSplit = $UserOUName -split ','
        if($UserOUNameSplit[1] -like  $OUNameSplit[0]){
          Add-ADPrincipalGroupMembership -Identity $User.SamAccountName -MemberOf $ShadowGroupName}
      }

      $Memebers = Get-ADGroupMember -Identity $ShadowGroupName
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
