function Get-O365InstallationOptions {
    [cmdletbinding()]
    param(
        [alias('Authorization')][System.Collections.IDictionary] $Headers
    )

    $Uri = "https://admin.microsoft.com/admin/api/settings/apps/usersoftware"
    $Output = Invoke-O365Admin -Uri $Uri -Headers $Headers
    $Output.UserSoftwareSettings

    # Fix me
    <#
    $Uri = "https://admin.microsoft.com/fd/oacms/api/ReleaseManagement/admin?tenantId=29c50a66"
    $Output1 = Invoke-O365Admin -Uri $Uri -Headers $Headers

    $Uri = "https://admin.microsoft.com/fd/oacms/api/MroDeviceManagement/TenantInfo?tenantId=29c50a66 "
    $Output2 = Invoke-O365Admin -Uri $Uri -Headers $Headers
    #>
    <#
    $Uri = "https://admin.microsoft.com/fd/oacms/api/mrodevicemanagement/?ffn=55336b82-a18d-4dd6-b5f6-9e5095c314a6"
    $Output3 = Invoke-O365Admin -Uri $Uri -Headers $Headers
    $Output3
    #>

    #‎Office‎ installation options
    # /fd/oacms/api/ReleaseManagement/admin?tenantId=ceb371f6
    # /fd/oacms/api/MroDeviceManagement/TenantInfo?tenantId=ceb371f6-
    # /fd/oacms/api/mrodevicemanagement/?ffn=55336b82-a18d-4dd6-b5f6-9e5095c314a6

}