function Set-O365SearchIntelligenceBingExtension {
    <#
    .SYNOPSIS
    Configures the Bing Extension feature for Office 365 Search Intelligence.

    .DESCRIPTION
    This function enables or disables the Bing Extension feature for Office 365 Search Intelligence. The Bing Extension enhances search results with Bing's web search capabilities. Additionally, it allows for limiting the extension to specific groups.

    .PARAMETER Headers
    A dictionary containing the authorization headers required for the request. This includes tokens and expiration information. You can obtain these headers by using the Connect-O365Admin function.

    .PARAMETER EnableExtension
    A boolean value indicating whether to enable or disable the Bing Extension feature. Set to $true to enable or $false to disable.

    .PARAMETER LimitGroupId
    An array of group IDs for which the Bing Extension should be limited. This parameter is used in conjunction with EnableExtension set to $true.

    .PARAMETER LimitGroupName
    An array of group display names for which the Bing Extension should be limited. This parameter is used in conjunction with EnableExtension set to $true.

    .EXAMPLE
    Set-O365SearchIntelligenceBingExtension -Headers $headers -EnableExtension $true
    This example enables the Bing Extension feature for Office 365 Search Intelligence using the provided headers.

    .EXAMPLE
    Set-O365SearchIntelligenceBingExtension -Headers $headers -EnableExtension $true -LimitGroupId "12345678-1234-1234-1234-123456789012"
    This example enables the Bing Extension feature and limits it to the specified group ID using the provided headers.

    .EXAMPLE
    Set-O365SearchIntelligenceBingExtension -Headers $headers -EnableExtension $true -LimitGroupName "Marketing Team"
    This example enables the Bing Extension feature and limits it to the group with the specified display name using the provided headers.

    .NOTES
    This function requires a valid connection to Office 365 and the necessary permissions to manage Search Intelligence settings. Ensure you have the appropriate credentials and authorization before running this function.
    #>
    [cmdletbinding(SupportsShouldProcess)]
    param(
        [alias('Authorization')][System.Collections.IDictionary] $Headers,
        [bool] $EnableExtension,
        [Array] $LimitGroupId,
        [Array] $LimitGroupName
    )
    $Uri = "https://admin.microsoft.com/fd/bfb/api/v3/office/switch/feature"

    if ($EnableExtension -eq $false) {
        $Body = @{
            Features = @(4, 7)
        }
        $null = Invoke-O365Admin -Uri $Uri -Headers $Headers -Method DELETE -Body $Body
    } elseif ($EnableExtension -eq $true -and ($LimitGroupID.Count -gt 0 -or $LimitGroupName.Count -gt 0)) {
        # We need to first disable extension and then enable it again
        Set-O365SearchIntelligenceBingExtension -EnableExtension $false -Headers $Headers
        Start-Sleep -Seconds 1
        [Array] $Groups = @(
            foreach ($Group in $LimitGroupID) {
                $GroupInformation = Get-O365Group -Id $Group -Headers $Headers
                if ($GroupInformation.id) {
                    $GroupInformation
                }
            }
            foreach ($Group in $LimitGroupName) {
                $GroupInformation = Get-O365Group -DisplayName $Group -Headers $Headers
                if ($GroupInformation.id) {
                    $GroupInformation
                }
            }
        )
        $Body = @{
            Features                    = @(4, 7 )
            BingDefaultsEnabledGroupIds = @(
                foreach ($Group in $Groups) {
                    $Group.id
                }
            )
            BingDefaultsEnabledGroups   = [ordered] @{}
            # @{b6cdb9c3-d660-4558-bcfd-82c14a986b56=All Users; 5f2910bc-d7a2-4529-bc66-c9d5181ab236=Graph}
        }
        foreach ($Group in $Groups) {
            $Body['BingDefaultsEnabledGroups'][$Group.id] = $Group.displayName
        }
        $null = Invoke-O365Admin -Uri $Uri -Headers $Headers -Method PUT -Body $Body
    } elseif ($EnableExtension -eq $true) {
        # We need to first disable extension and then enable it again
        Set-O365SearchIntelligenceBingExtension -EnableExtension $false -Headers $Headers
        Start-Sleep -Seconds 1
        $Body = @{
            Features = @(4)
        }
        $null = Invoke-O365Admin -Uri $Uri -Headers $Headers -Method PUT -Body $Body
    }
}