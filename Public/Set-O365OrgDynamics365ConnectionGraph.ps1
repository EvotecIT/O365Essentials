function Set-O365OrgDynamics365ConnectionGraph {
    <#
    .SYNOPSIS
    Configures the Dynamics 365 Connection Graph settings for an Office 365 organization.

    .DESCRIPTION
    This function allows you to enable or disable the Dynamics 365 Connection Graph service for your Office 365 organization.
    It sends a POST request to the Office 365 admin API with the specified settings.

    .PARAMETER Headers
    Specifies the headers for the API request. Typically includes authorization tokens.

    .PARAMETER ServiceEnabled
    Specifies whether the Dynamics 365 Connection Graph service should be enabled.

    .PARAMETER ConnectionGraphUsersExclusionGroup
    Specifies the group of users to be excluded from the Connection Graph.

    .EXAMPLE
    $headers = @{Authorization = "Bearer your_token"}
    Set-O365OrgDynamics365ConnectionGraph -Headers $headers -ServiceEnabled $true -ConnectionGraphUsersExclusionGroup "GroupID"

    This example enables the Dynamics 365 Connection Graph service for the Office 365 organization and excludes the specified group of users.

    .NOTES
    This function sends a POST request to the Office 365 admin API with the specified settings.
    #>
    [cmdletbinding(SupportsShouldProcess)]
    param(
        [alias('Authorization')][System.Collections.IDictionary] $Headers,
        [Parameter(Mandatory)][bool] $ServiceEnabled,
        [string] $ConnectionGraphUsersExclusionGroup
    )
    $Uri = "https://admin.microsoft.com/admin/api/settings/apps/dcg"

    $Body = @{
        ServiceEnabled                     = $ServiceEnabled
        ConnectionGraphUsersExclusionGroup = $ConnectionGraphUsersExclusionGroup
    }
    $Output = Invoke-O365Admin -Uri $Uri -Headers $Headers -Method POST -Body $Body
    $Output
}
