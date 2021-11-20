<#
.AUTHOR
	Ethan Harriman (eharriman@spiritofmath.com)
.LOCATION
	Sys-Admin-Repo/Teams Administration
.Authentication
	Teams Administrator
.SYNOPSIS
   Bulk Create Teams Classrooms and add users
.DESCRIPTION
   - Create a .csv for class information, which includes the following:

    - Class Name
    - ChannelName (if required)
    - Students (single cell per class, with user UPN)
    - Teachers (single cell per class, with user UPN)
    - Admins (single cell per class, with user UPN)
   
- Set import and export path in script
- Run
#>

Import-Module -Name MicrosoftTeams

$SkippedTeams = @()
$FailedTeams = @()

function Add-Users
{   
    param(   
             $Users,$GroupId,$CurrentUsername,$Role
          )   
    Process
    {
        
        try{
                $teamusers = $Users -split "; "
                if($teamusers)
                {
                    for($j =0; $j -le ($teamusers.count - 1) ; $j++)
                    {
                        if($teamusers[$j] -ne $CurrentUsername)
                        {
                            Add-TeamUser -GroupId $GroupId -User $teamusers[$j] -Role $Role
                        }
                    }
                }
            }
        Catch
            {
            }
        }
}

function Create-NewTeam
{
    param (
        $ImportPath
    )
    Process
    {
        Import-Module MicrosoftTeams
        $cred = Get-Credential
        $username = $cred.UserName
        Connect-MicrosoftTeams -Credential $cred
        $Teams = Import-Csv -Path $ImportPath
        foreach($team in $Teams)
        {
            $getteam = Get-Team | Where-Object{$_.displayname -eq "team.TeamsName"}
            If($getteam -eq $Null)
            {
                try {

                    Write-Host "Starting Teams Creation" $team.TeamsName
                    $group = New-Team -DisplayName $team.Class -Description "Teams classroom for online collaboration between teachers and students" -Template EDU_Class -Alias $team.Class
                    Write-Host "Creating Teams Classroom"
                    Create-Channel -ChannelName $team.ChannelName -GroupID $group.GroupId
                    Write-Host "Adding Students"
                    Add-Users -Users $team.Students -GroupId $group.GroupId -CurrentUsername $username -Role Member
                    Write-Host "Adding Teachers"
                    Add-Users -Users $team.Teachers -GroupId $group.GroupId -CurrentUsername $username -Role Owner
                    #Write-Host "Adding other Administrators"
                    #Add-Users -Users $team.Admins -GroupId $group.GroupID -CurrentUsername $username -Role Owner
                    Write-Host "The team creation has completed"
                    $team=$null
                }
                catch {
                    $FailedTeams += $getteam
                    Write-Warning  "$Class was found and failed"
                }
            }
            else {
                $SkippedTeams += $getteam
                Write-Warning "$getteam user not found and skipped"

            }
        }
    }

}

Create-NewTeam -ImportPath [] | Export-Csv []
