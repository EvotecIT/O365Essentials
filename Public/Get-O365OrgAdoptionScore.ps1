function Get-O365OrgAdoptionScore {
    <#
    .SYNOPSIS
    Retrieves the Organization Adoption Score for the organization.

    .DESCRIPTION
    This function queries the Microsoft Graph API to retrieve the Organization Adoption Score for the organization. The Organization Adoption Score is a feature that helps organizations measure and improve their adoption of Microsoft 365 services.

    .PARAMETER Headers
    A dictionary containing the necessary headers for the API request, typically including authorization information. This parameter is required to authenticate the request.

    .EXAMPLE
    Get-O365OrgAdoptionScore -Headers $headers
    This example retrieves the Organization Adoption Score for the organization using the provided headers for authentication.

    .NOTES
    This function requires a valid authentication token to be passed in the Headers parameter. The token should include the necessary permissions to access the Organization Adoption Score.
    #>
    [cmdletbinding()]
    param(
        [alias('Authorization')][System.Collections.IDictionary] $Headers
    )
    $Uri = "https://admin.microsoft.com/admin/api/reports/productivityScoreCustomerOption"
    $OutputSettings = Invoke-O365Admin -Uri $Uri -Headers $Headers -Method GET
    if ($OutputSettings) {
        if ($OutputSettings.Output) {
            try {
                $OutputSettings.Output | ConvertFrom-Json -ErrorAction Stop
            } catch {
                Write-Warning -Message "Get-O365OrgAdoptionScore - Unable to convert output from JSON $($_.Exception.Message)"
            }
        }
    }
}