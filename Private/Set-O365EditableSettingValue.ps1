function Set-O365EditableSettingValue {
    <#
    .SYNOPSIS
    Updates a Microsoft 365 admin setting wrapper when the setting is editable.
    #>
    [cmdletbinding()]
    param(
        [AllowNull()] $Setting,
        [Parameter(Mandatory)] $Value,
        [Parameter(Mandatory)][string] $Name
    )

    if (-not $Setting) {
        Write-Warning -Message "Set-O365EditableSettingValue - Setting '$Name' was not found."
        return $false
    }

    if ($Setting.PSObject.Properties.Name -contains 'EnableEditing' -and -not $Setting.EnableEditing) {
        Write-Warning -Message "Set-O365EditableSettingValue - Setting '$Name' is not editable in this tenant."
        return $false
    }

    if ($Setting.PSObject.Properties.Name -contains 'Value') {
        $Setting.Value = $Value
        return $true
    }

    Write-Warning -Message "Set-O365EditableSettingValue - Setting '$Name' does not expose a Value property."
    $false
}
