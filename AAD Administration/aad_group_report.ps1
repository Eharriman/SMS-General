<#
.AUTHOR
	Ethan Harriman (eharriman@spiritofmath.com)
.DATE
    2019-10-03
.LOCATION
	Sys-Admin-Repo/AAD Administration
.Authentication
	Azure AD Group Admin Credentials
.SYNOPSIS
   Exports Azure AD Groups w/ membership to .csv
.DESCRIPTION
     Exports all Azure AD unified groups (these include M365 Groups (O365 Groups) and by extension Teams, Security Groups and Mail-Enabled
     security groups. If the group uses dynamic membership rules, membership will not be exported for the group.
.PARAMETER <paramName>
   [string] $CSVfilename: physical file location for export i.e. C:\Users\eharriman\Downloads\ThisIsAnExport.csv
.EXAMPLE
   Need to view memberships for all unified groups.
#>

param(
[Parameter(Mandatory=$True, HelpMessage='Please enter a filename for the .csv file to export')]$CSVFilename
)

#Get all Azure AD Groups
Write-Host -ForegroundColor Green "Grab all Azure AD Groups in tenant"
$Groups = Get-UnifiedGroup -ResultSize Unlimited

# For loop for groups
$GroupsCSV = @()
Write-Host -ForegroundColor Green "Analyzing the groups... Please standby"
foreach ($Group in $Groups)
{
    # Get the group membership
    $Members = Get-UnifiedGroupLinks -Identity $Group.Identity -LinkType Members -ResultSize Unlimited
    $MembersSMTP = @()
    foreach ($Member in $Members)
    {
        $MembersSMTP+=$Member.PrimarySmtpAddress
    }
    #Get the owners
    $Owners = Get-UnifiedGroupLinks -Identity $Group.Identity -LinkType Owners -ResultSize Unlimited
    $OwnersSMTP=@()
    foreach ($Owner in $Owners)
    {
        $OwnersSMTP+=$Owner.PrimarySmtpAddress
    }

    #Create a csv file
    $GroupRow = [pscustomobject]@{
                    GroupSMTPAddress = $Group.PrimarySmtpAddress
                    GroupIdentity = $Group.Identity
                    GroupDisplayName = $Group.GroupDisplayName
                    MembersSMTP = $MembersSMTP -join "`n"
                    OwnersSMTP = $OwnersSMTP -join "`n"
                    }
    #Add to export array
    $GroupsCSV+=$GroupsRow

}

<#Export to csv
-For -path use the file pathway, with the file name as the var $CSVFilename
i.e.  C:\temp\csv.csv
#>
Write-Host -ForegroundColor Green "Export report to a csv file"
$GroupsCSV | Export-Csv -NoTypeInformation -Path $CSVFilename
