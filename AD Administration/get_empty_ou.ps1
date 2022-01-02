<#
.AUTHOR
	Ethan Harriman (eharriman@spiritofmath.com)
    Script originally from https://github.com/adbertram/Random-PowerShell-Work/blob/master/ActiveDirectory/Get-Empty-OUs.ps1
.DATE
    2020-11-05
.LOCATION
	Sys-Admin-Repo/AD Administration
.Authentication
	AD Domain Admin Credentials
.SYNOPSIS
   Lists and removes empty OU's
.DESCRIPTION
    Lists and removes empty OU's. Helpful for cleaning up your forrest. 
#>>

$ou_remove = $false

$retained_ou = @('UAP - PEAP TLS','UAP - PEAP TLS Only','Disabled Users')

$ad_items = Get-ADObject -Filter "ObjectClass -eq 'user' -or ObjectClass -eq 'computer' -or ObjectClass -eq 'group' -or ObjectClass -eq 'organizationalUnit'"

$aOuDns = @()

foreach ($o in $ad_items) {
    $sDN = $o.DistinguishedName
    if ($sDN -like '*OU' -and $sDN -notlike '*LostAndFound') {
        $sOuDn = $sDN.Substring($sDN.IndexOf('OU='))
        $aOuDns += $sOuDn
    }
}

$a0CountOus = $aOuDns | Group-Object | Where-Object { $_.Count -eq 1 } | ForEach-Object { $_.Name };
$empty_ous = 0;
$ous_remove = 0;
foreach ($sOu in $a0CountOus) {
	if (!(Get-ADObject -Filter "ObjectClass -eq 'organizationalUnit'" | where { $_.DistinguishedName -like "*$sOu*" -and $_.DistinguishedName -ne $sOu })) {
		$ou = Get-AdObject -Filter { DistinguishedName -eq $sOu };
		if ($retained_ou -notcontains $ou.Name) {
			if ($remove_ous) {
				Set-ADOrganizationalUnit -Identity $ou.DistinguishedName -ProtectedFromAccidentalDeletion $false -confirm:$false;
				Remove-AdOrganizationalUnit -Identity $ou.DistinguishedName -confirm:$false
				$ous_remove++
			}
			$ou
			$empty_ous++;
		}
	}
}
echo '-------------------'
echo "Total Empty OUs Removed: $ous_remove"
echo "Total Empty OUs: $empty_ous"

#still needs work