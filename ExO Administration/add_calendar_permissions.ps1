<# .AUTHOR
	Ethan Harriman (eharriman@spiritofmath.com)
.LOCATION
	Sys-Admin-Repo/ExO Administration
.DATE
    21-08-25
.Authentication
	ExO Admin credentials
.SYNOPSIS
   Add mailbox calednar permissions to designated users in bulk
.DESCRIPTION
   Script imports a csv with two columns, one being user1 a column for users emals whose calendars need to
   be shared, and user2 a column of users who will inherit a set permission. A single row represents a
   single one to one permission access.
   user1 column must include the folder extension you wish to add permissions to. I.e. for calendar access,
   you'd have user1 as user@office.com:\calendar.
#>

#Retrieve Credentials
$cred = Get-Credential 

#New O365 ExO session
$Session = New-PSSession -ConfigurationName Microsoft.Exchange -ConnectionUri https://outlook.office365.com/powershell-liveid/ -Credential $cred -Authentication Basic –AllowRedirection

#Import PS session
Import-PSSession $Session -AllowClobber

#For loop for access
Import-Csv [] | ForEach-Object {Add-MailboxFolderPermission -Identity $_.user1 -User $_.user2 -AccessRights Reviewer}
