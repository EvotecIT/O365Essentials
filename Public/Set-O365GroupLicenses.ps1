function Set-O365GroupLicenses {
    <#
        .SYNOPSIS
        Sets Office 365 group licenses based on provided parameters.
        .DESCRIPTION
        This function assigns or removes licenses for an Office 365 group based on the provided parameters.
        .PARAMETER Headers
        A dictionary containing the necessary headers for the API request, typically including authorization information.
        .PARAMETER GroupID
        The ID of the Office 365 group to assign licenses to.
        .PARAMETER GroupDisplayName
        The display name of the Office 365 group to assign licenses to.
        .PARAMETER Licenses
        An array of licenses to assign to the group.
        .EXAMPLE
        Set-O365GroupLicenses -Headers $headers -GroupID "12345" -Licenses @($License1, $License2)
        .NOTES
        For more information, visit: https://docs.microsoft.com/en-us/office365/enterprise/office-365-service-descriptions
    #>
    [cmdletbinding(SupportsShouldProcess)]
    param(
        [alias('Authorization')][System.Collections.IDictionary] $Headers,
        [parameter()][string] $GroupID,
        [parameter()][alias('GroupName')][string] $GroupDisplayName,
        [Array] $Licenses
    )
    $Uri = "https://main.iam.ad.ext.azure.com/api/AccountSkus/assignUpdateRemove"

    if ($GroupID) {
        $Group = $GroupID
        #$GroupSearch = Get-O365Group -Id $GroupID
        #if ($GroupSearch.id) {
        #    $GroupName = $GroupSearch.displayName
        #}
    } elseif ($GroupDisplayName) {
        $GroupSearch = Get-O365Group -DisplayName $GroupDisplayName
        if ($GroupSearch.id) {
            $Group = $GroupSearch.id
            #$GroupName = $GroupSearch.displayName
        }
    }
    if ($Group) {
        $CurrentLicenses = Get-O365GroupLicenses -GroupID $Group -NoTranslation
        if ($CurrentLicenses.objectid) {
            # we cache it for better use of search
            $CacheLicenses = [ordered] @{}
            foreach ($License in $CurrentLicenses.licenses) {
                $CacheLicenses[$License.accountSkuId] = $License
            }

            <#
            accountSkuId                   disabledServicePlans                            hasErrors errorCount
            ------------                   --------------------                            --------- ----------
            evotecpoland:FLOW_FREE         {}                                                                 0
            evotecpoland:POWER_BI_STANDARD {}                                                                 0
            evotecpoland:POWER_BI_PRO      {}                                                                 0
            evotecpoland:ENTERPRISEPACK    {POWER_VIRTUAL_AGENTS_O365_P2, PROJECT_O365_P2}                    0
            #>
            $AddLicenses = [System.Collections.Generic.List[System.Collections.IDictionary]]::new()
            $RemoveLicenses = [System.Collections.Generic.List[string]]::new()
            $UpdateLicenses = [System.Collections.Generic.List[System.Collections.IDictionary]]::new()

            foreach ($License in $Licenses) {
                if ($CacheLicenses[$License.accountSkuId]) {
                    if (-not (Compare-Object -ReferenceObject $License.disabledServicePlans -DifferenceObject $CacheLicenses[$License.accountSkuId].disabledServicePlans)) {
                        # We do nothing, because the licenses have the same disabled service plans are the same
                    } else {
                        $UpdateLicenses.Add($License)
                    }
                } else {
                    $AddLicenses.Add($License)
                }
            }
            foreach ($License in $CurrentLicenses.licenses) {
                if ($License.accountSkuId -notin $Licenses.accountSkuId) {
                    #$PrepareForRemoval = New-O365License -DisabledServicesName $License.disabledServicePlans -LicenseSKUID $License.accountSkuId
                    #if ($PrepareForRemoval) {
                    $RemoveLicenses.Add($License.accountSkuId)
                    #}
                }
            }

            $Body = [ordered] @{
                assignments = @(
                    [ordered] @{
                        objectId       = $Group
                        #displayName    = $GroupName
                        isUser         = $false
                        addLicenses    = $AddLicenses
                        removeLicenses = $RemoveLicenses
                        updateLicenses = $UpdateLicenses
                    }
                )
            }
            $Output = Invoke-O365Admin -Uri $Uri -Headers $Headers -Method POST -Body $Body
            $Output

        } else {
            Write-Warning -Message "Set-O365GroupLicenses - Querying for current group licenses failed. Skipping."
        }
    } else {
        Write-Error -Message "Set-O365GroupLicenses - Couldn't find group. Skipping."
    }
}
