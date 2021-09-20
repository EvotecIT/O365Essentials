Import-Module .\O365Essentials.psd1 -Force

if (-not $Credentials) {
    $Credentials = Get-Credential
}
# This makes a connection to Office 365 tenant
# since we don't want to save the data we null it out
# keep in mind that if there's an MFA you would be better left without Credentials and just let it prompt you
$null = Connect-O365Admin -Verbose -Credential $Credentials

Set-O365OrgPlanner -AllowCalendarSharing $true -WhatIf
Set-O365OrgForms -InOrgFormsPhishingScanEnabled $true -WhatIf
Set-O365OrgAzureSpeechServices -AllowTheOrganizationWideLanguageModel $false -WhatIf
Set-O365OrgBriefingEmail -SubscribeByDefault $false -WhatIf
Set-O365OrgCalendarSharing -SharingOption CalendarSharingFreeBusyReviewer -WhatIf
Set-O365OrgCortana -Enabled $false -WhatIf
Set-O365OrgDynamics365SalesInsights -ServiceEnabled $false -WhatIf
Set-O365OrgM365Groups -AllowGuestAccess $true -AllowGuestsAsMembers $true -WhatIf