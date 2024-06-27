function Set-O365SearchIntelligenceItemInsights {
    <#
    .SYNOPSIS
    Configures the Item Insights feature for Office 365 Search Intelligence.

    .DESCRIPTION
    This function enables or disables Item Insights for Office 365 Search Intelligence. Item Insights provides users with relevant information about items, such as documents and emails, to enhance their productivity and collaboration.

    .PARAMETER Headers
    A dictionary containing the authorization headers required for the request. This includes tokens and expiration information. You can obtain these headers by using the Connect-O365Admin function.

    .PARAMETER AllowItemInsights
    A boolean value indicating whether to enable or disable Item Insights. Set to $true to enable or $false to disable.

    .PARAMETER DisableGroupName
    The display name of the group for which Item Insights should be disabled. This parameter is mutually exclusive with DisableGroupID.

    .PARAMETER DisableGroupID
    The ID of the group for which Item Insights should be disabled. This parameter is mutually exclusive with DisableGroupName.

    .EXAMPLE
    Set-O365SearchIntelligenceItemInsights -Headers $headers -AllowItemInsights $true
    This example enables Item Insights for Office 365 Search Intelligence using the provided headers.

    .EXAMPLE
    Set-O365SearchIntelligenceItemInsights -Headers $headers -AllowItemInsights $false -DisableGroupName "Marketing Team"
    This example disables Item Insights for the "Marketing Team" group using the provided headers.

    .EXAMPLE
    Set-O365SearchIntelligenceItemInsights -Headers $headers -AllowItemInsights $false -DisableGroupID "12345678-1234-1234-1234-123456789012"
    This example disables Item Insights for the group with the specified ID using the provided headers.

    .NOTES
    This function requires a valid connection to Office 365 and the necessary permissions to manage Search Intelligence settings. Ensure you have the appropriate credentials and authorization before running this function.
    #>
    [cmdletbinding(SupportsShouldProcess)]
    param(
        [alias('Authorization')][System.Collections.IDictionary] $Headers,
        [bool] $AllowItemInsights,
        [string] $DisableGroupName,
        [string] $DisableGroupID
    )
    $Uri = "https://admin.microsoft.com/fd/configgraphprivacy/ceb371f6-8745-4876-a040-69f2d10a9d1a/settings/ItemInsights"

    if ($PSBoundParameters.ContainsKey('AllowItemInsights')) {
        if ($DisableGroupID) {
            $GroupInformation = Get-O365Group -Id $DisableGroupID -Headers $Headers
        } elseif ($DisableGroupName) {
            $GroupInformation = Get-O365Group -DisplayName $DisableGroupName -Headers $Headers
        }
        if ($GroupInformation.id) {
            $DisabledForGroup = $GroupInformation.id
        } else {
            $DisabledForGroup = $null
        }
        $Body = @{
            isEnabledInOrganization = $AllowItemInsights
            disabledForGroup        = $DisabledForGroup
        }
        $Output = Invoke-O365Admin -Uri $Uri -Headers $Headers -Method PATCH -Body $Body
        $Output
    }
}