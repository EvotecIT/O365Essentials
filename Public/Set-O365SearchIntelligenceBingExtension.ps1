function Set-O365SearchIntelligenceBingExtension {
    [cmdletbinding(SupportsShouldProcess)]
    param(
        [alias('Authorization')][System.Collections.IDictionary] $Headers,
        [bool] $EnableExtension,
        [Array] $LimitGroupId,
        [Array] $LimitGroupName
    )
    $Uri = "https://admin.microsoft.com/fd/bfb/api/v3/office/switch/feature"

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