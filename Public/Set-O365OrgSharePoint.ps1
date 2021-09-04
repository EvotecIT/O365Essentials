function Set-O365OrgSharePoint {
    [cmdletbinding(SupportsShouldProcess)]
    param(
        [alias('Authorization')][System.Collections.IDictionary] $Headers,
        [Parameter(Mandatory)][ValidateSet('OnlyPeopleInYourOrganization', 'ExistingGuestsOnly', 'NewAndExistingGuestsOnly', 'Anyone')][string] $CollaborationType
    )
    $Uri = "https://admin.microsoft.com/admin/api/settings/apps/sitessharing"

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