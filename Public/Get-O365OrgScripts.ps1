function Get-O365OrgScripts {
    [cmdletbinding()]
    param(
        [alias('Authorization')][System.Collections.IDictionary] $Headers
    )
    $Status = @{
        '0' = 'Disabled'
        '1' = 'Everyone'
        '2' = 'SpecificGroup'
    }
    $Uri = "https://admin.microsoft.com/admin/api/settings/apps/officescripts"
    $Output = Invoke-O365Admin -Uri $Uri -Headers $Headers
    if ($Output) {
        [PSCustomObject] @{
            # we don't show those options as they have no values
            # we also don't show them as there is no option in GUI
            #OfficeScriptsEnabled        = $Output.OfficeScriptsEnabled        # :
            #OfficeScriptsPreviewEnabled = $Output.OfficeScriptsPreviewEnabled # :
            EnabledOption         = $Status[$($Output.EnabledOption).ToString()]               # : 1
            EnabledGroup          = $Output.EnabledGroup                # :
            EnabledGroupDetail    = $Output.EnabledGroupDetail          # :
            ShareOption           = $Status[$($Output.ShareOption).ToString()]                 # : 1
            ShareGroup            = $Output.ShareGroup                  # :
            ShareGroupDetail      = $Output.ShareGroupDetail            # :
            UnattendedOption      = $Status[$($Output.UnattendedOption).ToString()]            # : 0
            UnattendedGroup       = $Output.UnattendedGroup             # :
            UnattendedGroupDetail = $Output.UnattendedGroupDetail       # :
            #TenantId                    = $Output.TenantId                    # :
        }
    }
}