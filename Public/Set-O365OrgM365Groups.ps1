function Set-O365OrgM365Groups {
    <#
    .SYNOPSIS
    Choose how guests from outside your organization can collaborate with your users in Microsoft 365 Groups. Learn more about guest access to Microsoft 365 Groups

    .DESCRIPTION
    Choose how guests from outside your organization can collaborate with your users in Microsoft 365 Groups. Learn more about guest access to Microsoft 365 Groups

    .PARAMETER Headers
    Parameter description

    .PARAMETER AllowGuestAccess
    PLet group owners add people outside your organization to Microsoft 365 Groups as guests

    .PARAMETER AllowGuestsAsMembers
    Let guest group members access group content

    .EXAMPLE
    An example

    .NOTES
    General notes
    #>
    [cmdletbinding(SupportsShouldProcess)]
    param(
        [alias('Authorization')][System.Collections.IDictionary] $Headers,
        [nullable[bool]] $AllowGuestAccess,
        [nullable[bool]] $AllowGuestsAsMembers
    )
    $Uri = "https://admin.microsoft.com/admin/api/settings/security/o365guestuser"

    $CurrentSettings = Get-O365OrgM365Groups -Headers $Headers
    $Body = [ordered] @{
        AllowGuestAccess     = $CurrentSettings.AllowGuestAccess
        AllowGuestsAsMembers = $CurrentSettings.AllowGuestsAsMembers
    }
    if ($null -ne $AllowGuestAccess) {
        $Body.AllowGuestAccess = $AllowGuestAccess
    }
    if ($null -ne $AllowGuestsAsMembers) {
        $Body.AllowGuestsAsMembers = $AllowGuestsAsMembers
    }
    $Output = Invoke-O365Admin -Uri $Uri -Headers $Headers -Method POST -Body $Body
    $Output
}