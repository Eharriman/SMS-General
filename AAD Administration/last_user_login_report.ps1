<# .AUTHOR
	Ethan Harriman (eharriman@spiritofmath.com)
.LOCATION
	Sys-Admin-Repo/AAD Administration
.DATE
    21-08-25
.Authentication
	Azure AD User Admin Credentials
.SYNOPSIS
   Generate report of last login dates for Azure AD users
.DESCRIPTION
   Searches for Azure AD and grabs the last login date of the user. Exports CSV of the report.
   
   Useful if trying to cull AAD of inactive users. 
#>

$cred = Get-Credential

Connect-AzureAD -Credential $cred

# Can scope the directory search if required using filters. By default, search is a global search
$AllUsers = Get-AzureADUser -All $true
$AllSigninLogs = Get-AzureADAuditSignInLogs -All $true

$results = @()
foreach($user in $AllUsers){
    $LoginRecord = $AllSigninLogs | Where-Object{ $_UserID -eq $user.ObjectId } | Sort-Object CreatedDateTime -Descending
    if ($LoginRecord.Count -gt 0){
        $lastLogin = $LoginRecord[0].CreatedDateTime
    }
    else{
        $lastLogin = 'no login record'
    }
    $item = @{
        userUPN = $user.UserPrincipalName
        userDisplayName = $user.DisplayName
        lastLogin = $lastLogin
        accountEnabled = $user.AccountEnabled
    }
    results += New-Object PSObject -Property $item
}

$results | Export-Csv -Path C:\temp\UserLogin.csv -NoTypeInformation
