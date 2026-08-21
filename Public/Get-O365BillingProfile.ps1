function Get-O365BillingProfile {
    <#
    .SYNOPSIS
    Retrieves billing profiles for one or more billing accounts.

    .DESCRIPTION
    Lists billing profiles through the documented Microsoft.Billing Azure Resource
    Manager API. Billing profiles are supported for Microsoft Customer Agreement
    and Microsoft Partner Agreement billing accounts.

    When AccountId is omitted, the command discovers accessible billing accounts and
    queries the accounts whose agreement type supports billing profiles.

    .PARAMETER Headers
    A dictionary containing the necessary headers for the API request, typically including authorization information.

    .PARAMETER AccountId
    One or more billing account names. If omitted, the function discovers accessible
    billing accounts through Get-O365BillingAccounts.

    .EXAMPLE
    Get-O365BillingProfile -Headers $headers -AccountId '00000000-0000-0000-0000-000000000000'
    #>
    [cmdletbinding()]
    param(
        [alias('Authorization')][System.Collections.IDictionary] $Headers,
        [alias('BillingAccountName')][string[]] $AccountId
    )

    $AccountNames = [System.Collections.Generic.List[string]]::new()
    if ($PSBoundParameters.ContainsKey('AccountId')) {
        foreach ($Name in $AccountId) {
            if (-not [string]::IsNullOrWhiteSpace($Name) -and -not $AccountNames.Contains($Name)) {
                $AccountNames.Add($Name)
            }
        }
    } else {
        $Accounts = @(Get-O365BillingAccounts -Headers $Headers -ErrorAction Stop)
        foreach ($Account in $Accounts) {
            $AgreementType = $Account.properties.agreementType
            if ($AgreementType -and $AgreementType -notin 'MicrosoftCustomerAgreement', 'MicrosoftPartnerAgreement') {
                Write-Verbose -Message "Get-O365BillingProfile - Skipping billing account with unsupported agreement type '$AgreementType'."
                continue
            }

            $Name = $Account.name
            if ([string]::IsNullOrWhiteSpace($Name) -and -not [string]::IsNullOrWhiteSpace($Account.id)) {
                $Name = [uri]::UnescapeDataString(($Account.id -split '/')[-1])
            }
            if (-not [string]::IsNullOrWhiteSpace($Name) -and -not $AccountNames.Contains($Name)) {
                $AccountNames.Add($Name)
            }
        }
    }

    if ($AccountNames.Count -eq 0) {
        Write-Warning -Message 'Get-O365BillingProfile - No billing account that supports billing profiles could be resolved. Provide -AccountId or inspect Get-O365BillingAccounts output.'
        return
    }

    foreach ($Name in $AccountNames) {
        $EscapedName = [uri]::EscapeDataString($Name)
        $Uri = "https://management.azure.com/providers/Microsoft.Billing/billingAccounts/$EscapedName/billingProfiles"
        $QueryParameter = @{
            'api-version' = '2024-04-01'
        }
        Invoke-O365Admin -Uri $Uri -Headers $Headers -Method GET -QueryParameter $QueryParameter -ErrorAction Stop
    }
}
