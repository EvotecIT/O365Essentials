function Set-O365Groups {
    [cmdletbinding()]
    param(
        [alias('Authorization')][System.Collections.IDictionary] $Headers,
        [nullable[bool]] $AllowGuestAccess,
        [nullable[bool]] $AllowGuestsAsMembers
    )
    $Uri = "https://admin.microsoft.com/admin/api/settings/security/o365guestuser"

    $CurrentSettings = Get-O365Groups -Headers $Headers
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