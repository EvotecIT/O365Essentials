function Set-O365OrgM365Groups {
    <#
        .SYNOPSIS
        Choose how guests from outside your organization can collaborate with your users in Microsoft 365 Groups. Learn more about guest access to Microsoft 365 Groups.
        .DESCRIPTION
        This function allows you to configure how guests from outside your organization can collaborate with your users in Microsoft 365 Groups. You can specify whether to 
        allow guest access and whether to allow guests as members.
        .PARAMETER Headers
        Specifies the headers for the API request. Typically includes authorization tokens.
        .PARAMETER AllowGuestAccess
        Specifies whether to let group owners add people outside your organization to Microsoft 365 Groups as guests.
        .PARAMETER AllowGuestsAsMembers
        Specifies whether to let guest group members access group content.
        .EXAMPLE
        $headers = @{Authorization = "Bearer your_token"}
        Set-O365OrgM365Groups -Headers $headers -AllowGuestAccess $true -AllowGuestsAsMembers $false

        This example allows group owners to add guests to Microsoft 365 Groups but does not allow guest members to access group content.
        .NOTES
        This function sends a POST request to the Office 365 admin API with the specified settings. It retrieves the current settings, updates them based on the provided 
        parameters, and then sends the updated settings back to the API.
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
