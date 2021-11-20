<# .AUTHOR
	Ethan Harriman (eharriman@spiritofmath.com)
.LOCATION
	Sys-Admin-Repo/AAD Administration
.DATE
    21-08-25
.Authentication
	Azure AD User Admin Credentials
.SYNOPSIS
   Bulk update user attributes for Azure AD
.DESCRIPTION
   Create a CSV file with the desired user attributes (this can be standardized with a standard HCM/ERP export). Unique ID will be the UPN of the user.
   Add any headers required. You can find a full list of user attributes at: https://docs.microsoft.com/en-us/powershell/module/azuread/set-azureaduser?view=azureadps-2.0
   
   This script is helpful for standarizing user attributes in Azure AD (you can find a simliar script in the AD Admin folder). Useful if leveraging Dynamic User rules
   for Azure AD groups.
#>

# Get admin creds
$creds = Get-Credential

# Connect to Azure AD
Connect-AzureAD -Credential $creds

# Get CSV Content
$CSVrecords = Import-Csv C:\temp\[] -Delimiter ";"

# Create array for skipped/failed 
$SkippedUsers = @()
$FailedUsers = @()

# For loop for iteration
foreach ($CSVrecord in $CSVrecords) {
    $upn = $CSVrecord.UPN
    $user = Get-AzureADUser -Filter "userPrincipalName eq '$upn'"
    if ($user) {
        try {
            $user | Set-AzureADUser -JobTitle $CSVrecord.JobTitle
            }
            catch {
                $FailedUsers += $upn
                Write-Warning "$upn user found, but failed to update."
                }
            }
            else {
                $SkippedUsers += $upn
                Write-Warning "$upn user not found and skipped"
                }

            }
