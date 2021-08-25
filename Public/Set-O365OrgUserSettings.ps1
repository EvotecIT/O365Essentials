function Set-O365OrgUserSettings {
    <#
    .SYNOPSIS
    Short description

    .DESCRIPTION
    Long description

    .PARAMETER Headers
    Parameter description

    .PARAMETER UsersCanRegisterApps
    Parameter description

    .PARAMETER RestrictNonAdminUsers
    Parameter description

    .PARAMETER LinkedInAccountConnection
    Parameter description

    .PARAMETER LinkedInSelectedGroupObjectId
    Parameter description

    .PARAMETER LinkedInSelectedGroupDisplayName
    Parameter description

    .EXAMPLE
    Set-O365UserSettings -RestrictNonAdminUsers $true -LinkedInAccountConnection $true -LinkedInSelectedGroupObjectId 'b6cdb9c3-d660-4558-bcfd-82c14a986b56'

    .EXAMPLE
    Set-O365UserSettings -RestrictNonAdminUsers $true -LinkedInAccountConnection $true -LinkedInSelectedGroupDisplayName 'All Users'

    .EXAMPLE
    Set-O365UserSettings -RestrictNonAdminUsers $true -LinkedInAccountConnection $false

    .EXAMPLE
    Set-O365UserSettings -RestrictNonAdminUsers $true

    .NOTES
    https://portal.azure.com/#blade/Microsoft_AAD_IAM/ActiveDirectoryMenuBlade/UserSettings
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