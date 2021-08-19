function Get-O365Groups {
    [cmdletbinding()]
    param(
        [alias('Authorization')][System.Collections.IDictionary] $Headers
    )
    $Uri = "https://admin.microsoft.com/admin/api/settings/security/guestUserPolicy"
    $Output1 = Invoke-O365Admin -Uri $Uri -Headers $Headers


    $Uri = "https://admin.microsoft.com/admin/api/settings/security/o365guestuser"
    $Output2 = Invoke-O365Admin -Uri $Uri -Headers $Headers

    <# same/similar properties on both objects
    $Object = [ordered] @{}
    foreach ($O in $Output1, $Output2) {
        foreach ($Key in $O.PSObject.Properties.Name) {
            $Object[$Key] = $O.$Key
        }
    }
     [PSCustomObject] $Object
    #>

    [PSCustomObject] @{
        AllowGuestAccess      = $Output1.AllowGuestAccess
        AllowGuestInvitations = $Output1.AllowGuestInvitations
        SitesSharingEnabled   = $Output1.SitesSharingEnabled
        AllowGuestsAsMembers  = $Output2.AllowGuestsAsMembers
        AllowGuestAccessO365  = $Output2.AllowGuestAccess
    }
}