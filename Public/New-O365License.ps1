function New-O365License {
    <#
    .SYNOPSIS
    Helper cmdlet to create a new O365 license that is used in Set-O365AzureGroupLicenses cmdlet.

    .DESCRIPTION
    Helper cmdlet to create a new O365 license that is used in Set-O365AzureGroupLicenses cmdlet.

    .PARAMETER LicenseName
    LicenseName to assign. Can be used instead of LicenseSKUID

    .PARAMETER LicenseSKUID
    LicenseSKUID to assign. Can be used instead of LicenseName

    .PARAMETER EnabledServicesDisplayName
    Parameter description

    .PARAMETER EnabledServicesName
    Parameter description

    .PARAMETER DisabledServicesDisplayName
    Parameter description

    .PARAMETER DisabledServicesName
    Parameter description

    .EXAMPLE
    Set-O365GroupLicenses -GroupDisplayName 'Test-Group-TestEVOTECPL' -Licenses @(
        New-O365License -LicenseName 'Office 365 E3' -Verbose
        New-O365License -LicenseName 'Enterprise Mobility + Security E5' -Verbose
    ) -Verbose -WhatIf

    .EXAMPLE
    Set-O365GroupLicenses -GroupDisplayName 'Test-Group-TestEVOTECPL' -Licenses @(
        New-O365License -LicenseName 'Office 365 E3' -Verbose -DisabledServicesDisplayName 'Microsoft Kaizala Pro', 'Whiteboard (Plan 2)'
        New-O365License -LicenseName 'Enterprise Mobility + Security E5' -Verbose -EnabledServicesDisplayName 'Azure Information Protection Premium P2', 'Microsoft Defender for Identity'
    ) -Verbose -WhatIf

    .NOTES
    General notes
    #>
    [cmdletbinding(DefaultParameterSetName = 'ServiceDisplayNameEnable')]
    param(
        [string] $LicenseName,
        [string] $LicenseSKUID,
        [Parameter(ParameterSetName = 'ServiceDisplayNameEnable')][string[]] $EnabledServicesDisplayName,
        [Parameter(ParameterSetName = 'ServiceNameEnable')][string[]] $EnabledServicesName,
        [Parameter(ParameterSetName = 'ServiceDisplayNameDisable')][string[]] $DisabledServicesDisplayName,
        [Parameter(ParameterSetName = 'ServiceNameDisable')][string[]] $DisabledServicesName
    )

    if ($LicenseName) {
        $ServicePlans = Get-O365AzureLicenses -ServicePlans -IncludeLicenseDetails -LicenseName $LicenseName
    } elseif ($LicenseSKUID) {
        $ServicePlans = Get-O365AzureLicenses -ServicePlans -IncludeLicenseDetails -LicenseSKUID $LicenseSKUID
    } else {
        return
    }
    if ($ServicePlans) {
        if ($EnabledServicesDisplayName -or $EnabledServicesName -or $DisabledServicesDisplayName -or $DisabledServicesName) {
            [Array] $DisabledServicePlans = foreach ($Plan in $ServicePlans) {
                if ($EnabledServicesDisplayName) {
                    if ($Plan.ServiceDisplayName -notin $EnabledServicesDisplayName) {
                        $Plan.serviceName
                    }
                } elseif ($EnabledServicesName) {
                    if ($Plan.ServiceName -notin $EnabledServicesName) {
                        $Plan.serviceName
                    }
                } elseif ($DisabledServicesDisplayName) {
                    if ($Plan.ServiceDisplayName -in $DisabledServicesDisplayName) {
                        $Plan.serviceName
                    }
                } elseif ($DisabledServicesName) {
                    if ($Plan.ServiceName -in $DisabledServicesName) {
                        $Plan.serviceName
                    }
                }
            }
        } else {
            $DisabledServicePlans = @()
        }
        if ($ServicePlans[0].LicenseSKUID) {
            [ordered] @{
                accountSkuId         = $ServicePlans[0].LicenseSKUID
                disabledServicePlans = if ($DisabledServicePlans.Count -eq 0) { , @() } else { $DisabledServicePlans }
            }
        } else {
            Write-Warning "New-O365License - No LicenseSKUID found. Skipping"
        }
    }
}