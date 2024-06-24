function Set-O365AzureUserSettings {
    <#
        .SYNOPSIS
        Configures user settings for Azure AD.
        .DESCRIPTION
        This function allows you to set various user settings for Azure AD.
        .PARAMETER Headers
        A dictionary containing the necessary headers for the API request, typically including authorization information.
        .PARAMETER UsersCanRegisterApps
        Specifies whether users can register apps.
        .PARAMETER RestrictNonAdminUsers
        Specifies whether to restrict non-admin users.
        .PARAMETER LinkedInAccountConnection
        Specifies whether to enable LinkedIn account connection.
        .PARAMETER LinkedInSelectedGroupObjectId
        The object ID of the selected LinkedIn group.
        .PARAMETER LinkedInSelectedGroupDisplayName
        The display name of the selected LinkedIn group.
        .EXAMPLE
        Set-O365UserSettings -RestrictNonAdminUsers $true -LinkedInAccountConnection $true -LinkedInSelectedGroupObjectId 'b6cdb9c3-d660-4558-bcfd-82c14a986b56'
        .EXAMPLE
        Set-O365UserSettings -RestrictNonAdminUsers $true -LinkedInAccountConnection $true -LinkedInSelectedGroupDisplayName 'All Users'
        .EXAMPLE
        Set-O365UserSettings -RestrictNonAdminUsers $true -LinkedInAccountConnection $false
        .EXAMPLE
        Set-O365UserSettings -RestrictNonAdminUsers $true
        .NOTES
        For more information, visit: https://portal.azure.com/#blade/Microsoft_AAD_IAM/ActiveDirectoryMenuBlade/UserSettings
    #>
    [cmdletbinding(SupportsShouldProcess)]
    param(
        [alias('Authorization')][System.Collections.IDictionary] $Headers,
        [nullable[bool]] $UsersCanRegisterApps,
        [nullable[bool]] $RestrictNonAdminUsers,
        [nullable[bool]] $LinkedInAccountConnection,
        [string] $LinkedInSelectedGroupObjectId,
        [string] $LinkedInSelectedGroupDisplayName
    )
    $Uri = "https://main.iam.ad.ext.azure.com/api/Directories/PropertiesV2"

    $Body = @{
        usersCanRegisterApps  = $UsersCanRegisterApps
        restrictNonAdminUsers = $RestrictNonAdminUsers
    }
    Remove-EmptyValue -Hashtable $Body

    if ($null -ne $LinkedInAccountConnection) {
        if ($LinkedInAccountConnection -eq $true -and $linkedInSelectedGroupObjectId) {
            $Body.enableLinkedInAppFamily = 4
            $Body.linkedInSelectedGroupObjectId = $linkedInSelectedGroupObjectId
        } elseif ($LinkedInAccountConnection -eq $true -and $LinkedInSelectedGroupDisplayName) {
            $Body.enableLinkedInAppFamily = 4
            $Body.linkedInSelectedGroupDisplayName = $LinkedInSelectedGroupDisplayName
        } elseif ($LinkedInAccountConnection -eq $true) {
            $Body.enableLinkedInAppFamily = 0
            $Body.linkedInSelectedGroupObjectId = $null
        } elseif ($LinkedInAccountConnection -eq $false) {
            $Body.enableLinkedInAppFamily = 1
            $Body.linkedInSelectedGroupObjectId = $null
        }
    }
    if ($Body.Keys.Count -gt 0) {
        $Output = Invoke-O365Admin -Uri $Uri -Headers $Headers -Method PUT -Body $Body
        # $Output
    }
}
