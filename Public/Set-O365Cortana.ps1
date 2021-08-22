function Set-O365Cortana {
    <#
    .SYNOPSIS
    Short description

    .DESCRIPTION
    Long description

    .PARAMETER Headers
    Parameter description

    .PARAMETER Enabled
    Parameter description

    .EXAMPLE
    An example

    .NOTES
    General notes
    #>
    [cmdletbinding(SupportsShouldProcess)]
    param(
        [alias('Authorization')][System.Collections.IDictionary] $Headers,
        [bool] $Enabled
    )
    $Uri = "https://admin.microsoft.com/admin/api/services/apps/cortana"

    $Body = @{
        Enabled = $Enabled
    }
    $Output = Invoke-O365Admin -Uri $Uri -Headers $Headers -Method POST -Body $Body
    $Output
}