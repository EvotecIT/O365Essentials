function Set-O365OrgSharePoint {
    <#
    .SYNOPSIS
    Configures the sharing settings for SharePoint in an Office 365 organization.

    .DESCRIPTION
    This function updates the sharing settings for SharePoint in an Office 365 organization. It allows setting the collaboration type to one of the following options:
    - OnlyPeopleInYourOrganization
    - ExistingGuestsOnly
    - NewAndExistingGuestsOnly
    - Anyone

    .PARAMETER Headers
    Specifies the headers for the API request. Typically includes authorization tokens.

    .PARAMETER CollaborationType
    Specifies the type of collaboration allowed. Must be one of the following values:
    - OnlyPeopleInYourOrganization
    - ExistingGuestsOnly
    - NewAndExistingGuestsOnly
    - Anyone

    .EXAMPLE
    $headers = @{Authorization = "Bearer your_token"}
    Set-O365OrgSharePoint -Headers $headers -CollaborationType 'Anyone'

    This example sets the SharePoint collaboration type to allow sharing with anyone.
    #>
    [cmdletbinding(SupportsShouldProcess)]
    param(
        [alias('Authorization')][System.Collections.IDictionary] $Headers,
        [Parameter(Mandatory)][ValidateSet('OnlyPeopleInYourOrganization', 'ExistingGuestsOnly', 'NewAndExistingGuestsOnly', 'Anyone')][string] $CollaborationType
    )
    $Uri = "https://admin.microsoft.com/admin/api/settings/apps/sitessharing"

    $ReverseTranslateCollaboration = @{
        'NewAndExistingGuestsOnly'     = 2
        'Anyone'                       = 16
        'ExistingGuestsOnly'           = 32
        'OnlyPeopleInYourOrganization' = 1
    }

    $Body = @{
        AllowSharing      = if ($CollaborationType -eq 'OnlyPeopleInYourOrganization') { $false } else { $true }
        CollaborationType = $ReverseTranslateCollaboration[$CollaborationType]
    }
    $null = Invoke-O365Admin -Uri $Uri -Headers $Headers -Method POST -Body $Body
}
