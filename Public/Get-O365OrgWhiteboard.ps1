function Get-O365OrgWhiteboard {
    <#
        .SYNOPSIS
        Retrieves organization whiteboard settings.
        .DESCRIPTION
        This function retrieves organization whiteboard settings from the specified URI using the provided headers.
        .PARAMETER Headers
        Authentication token and additional information for the API request.
        .PARAMETER NoTranslation
        Switch to disable translation of telemetry data.
    #>
    [cmdletbinding()]
    param(
        [alias('Authorization')][System.Collections.IDictionary] $Headers,
        [switch] $NoTranslation
    )

    $TranslateTelemetry = @{
        '0' = 'Neither'
        '1' = 'Required'
        '2' = 'Optional'
    }
    $Uri = 'https://admin.microsoft.com/admin/api/settings/apps/whiteboard'

    $Output = Invoke-O365Admin -Uri $Uri -Headers $Headers
    if ($NoTranslation) {
        $Output
    } else {
        if ($Output) {
            [PSCustomObject] @{
                WhiteboardEnabled            = $Output.IsEnabled
                DiagnosticData               = $TranslateTelemetry[$Output.TelemetryPolicy.ToString()]
                OptionalConnectedExperiences = $Output.AreConnectedServicesEnabled
                BoardSharingEnabled          = $Output.IsClaimEnabled
                OneDriveStorageEnabled       = $Output.IsSharePointDefault
                # Not sure what this does
                NonTenantAccess              = $Output.NonTenantAccess
                #LearnMoreUrl                 = $Output.LearnMoreUrl
                #ProductUrl                   = $Output.ProductUrl
                #TermsOfUseUrl                = $Output.TermsOfUseUrl
            }
        }
    }
}
