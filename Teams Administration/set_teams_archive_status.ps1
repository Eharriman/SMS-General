<#
.AUTHOR
	Ethan Harriman (eharriman@spiritofmath.com)
.LOCATION
	Sys-Admin-Repo/Teams Administration
.Authentication
	Requires Teams Admin Credentials
.SYNOPSIS
   Archives Teams listed in imported .csv.
.DESCRIPTION
   Create a csv with header for AzureGroupID. These groups listed are to be designated in ana archive state. 
#>

# Grab Credentials
$creds = Get-Credential

# Connect to Microsoft Teams
Connect-MicrosoftTeams -Credential $creds

# Get CSV content
$CSVrecords = Import-Csv C:\temp\[] -Delimiter ";"

# Create array for skipped and failed
$skippedGroups = @()
$failedGroups = @()

# Function loop
foreach ($CSVrecord in $CSVrecords) {
    $groupID = $CSVrecord.AzureGroupID
    if ($groupID) {
        try {
            $groupID | Set-TeamArchivedState -GroupId $groupID -Archived $true -SetSpoSiteReadOnlyForMembers $true
            }
            catch {
                $failedGroups += $groupID
                Write-Warning "$groupID was found, but failed to update."
                }
            }
            else {
                $skippedGroups += $groupID
                Write-Warning "$groupID was not found and was skipped"
                }
            }
