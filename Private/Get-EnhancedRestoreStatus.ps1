function Get-EnhancedRestoreStatus {
    $BatchBody = @{
        requests = @(
            @{
                id     = 'GetOffboardingSiteProtectionUnits'
                method = 'GET'
                url    = 'solutions/backupRestore/protectionUnits/microsoft.graph.siteProtectionUnit/$count?$filter=offboardRequestedDateTime gt 0001-01-01'
            },
            @{
                id     = 'GetOffboardingDriveProtectionUnits'
                method = 'GET'
                url    = 'solutions/backupRestore/protectionUnits/microsoft.graph.driveProtectionUnit/$count?$filter=offboardRequestedDateTime gt 0001-01-01'
            },
            @{
                id     = 'GetOffboardingMailboxProtectionUnits'
                method = 'GET'
                url    = 'solutions/backupRestore/protectionUnits/microsoft.graph.mailboxProtectionUnit/$count?$filter=offboardRequestedDateTime gt 0001-01-01'
            }
        )
    }

    $Result = Invoke-O365SectionSafeResult -Section Backup -ResultName 'EnhancedRestoreStatus' -ScriptBlock { Invoke-O365Admin -Uri 'https://graph.microsoft.com/beta/$batch' -Headers $Headers -Method POST -Body $BatchBody -AdditionalHeaders $AdditionalHeaders }
    if (Test-O365UnavailableResult -InputObject $Result) {
        return $Result
    }

    $ResponsesById = @{}
    foreach ($Response in @($Result.responses)) {
        $ResponsesById[$Response.id] = $Response
    }

    [PSCustomObject] @{
        SiteOffboardingCount    = if ($ResponsesById['GetOffboardingSiteProtectionUnits'] -and $ResponsesById['GetOffboardingSiteProtectionUnits'].status -eq 200) { [int] $ResponsesById['GetOffboardingSiteProtectionUnits'].body } else { $null }
        DriveOffboardingCount   = if ($ResponsesById['GetOffboardingDriveProtectionUnits'] -and $ResponsesById['GetOffboardingDriveProtectionUnits'].status -eq 200) { [int] $ResponsesById['GetOffboardingDriveProtectionUnits'].body } else { $null }
        MailboxOffboardingCount = if ($ResponsesById['GetOffboardingMailboxProtectionUnits'] -and $ResponsesById['GetOffboardingMailboxProtectionUnits'].status -eq 200) { [int] $ResponsesById['GetOffboardingMailboxProtectionUnits'].body } else { $null }
        RawResponses            = @($Result.responses)
    }
}
