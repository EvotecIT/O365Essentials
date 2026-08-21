Import-Module O365Essentials -Force

# WAM is the recommended interactive sign-in path on Windows.
$Authorization = Connect-O365Admin -UseWam

# Read the current tenant-wide app settings. Choose the region used by the tenant:
# emea, amer, or apac.
Get-O365TeamsTenantWideAppsSettings -Headers $Authorization -Region emea | Format-List

# Preview a boolean-only update. The command reads and preserves the existing
# appSettingsList automatically, so this does not replace app assignments.
Set-O365TeamsTenantWideAppsSettings `
    -Headers $Authorization `
    -Region emea `
    -IsAppsPurchaseEnabled $false `
    -WhatIf

# Remove -WhatIf only after reviewing the proposed operation.
