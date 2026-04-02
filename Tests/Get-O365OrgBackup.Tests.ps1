Import-Module "$PSScriptRoot/../O365Essentials.psd1" -Force

Describe 'Get-O365OrgBackup' {
    It 'uses the billing feature endpoint' {
        Mock -ModuleName O365Essentials Get-O365PortalContextHeaders -MockWith { @{ Referer = 'https://admin.microsoft.com/' } }
        Mock -ModuleName O365Essentials Invoke-O365Admin -MockWith { }

        Get-O365OrgBackup -Name BillingFeature

        Assert-MockCalled Invoke-O365Admin -ModuleName O365Essentials -ParameterFilter {
            $Uri -eq "https://admin.microsoft.com/_api/v2.1/billingFeatures('M365Backup')"
        } -Exactly 1
    }

    It 'builds Azure subscription permissions from each subscription' {
        Mock -ModuleName O365Essentials Get-O365PortalContextHeaders -MockWith { @{ Referer = 'https://admin.microsoft.com/' } }
        Mock -ModuleName O365Essentials Invoke-O365Admin -MockWith {
            if ($Uri -eq 'https://admin.microsoft.com/admin/api/syntexbilling/azureSubscriptions') {
                @(
                    [pscustomobject] @{ subscriptionId = 'sub-1'; displayName = 'Subscription 1' }
                    [pscustomobject] @{ subscriptionId = 'sub-2'; displayName = 'Subscription 2' }
                )
            } elseif ($Uri -like 'https://admin.microsoft.com/admin/api/syntexbilling/azureSubscriptions/*/permissions') {
                [pscustomobject] @{ Uri = $Uri; Allowed = $true }
            }
        }

        $Result = Get-O365OrgBackup -Name AzureSubscriptionPermissions

        $Result.Count | Should -Be 2
        $Result[0].SubscriptionId | Should -Be 'sub-1'
        $Result[1].Permissions.Uri | Should -Be 'https://admin.microsoft.com/admin/api/syntexbilling/azureSubscriptions/sub-2/permissions'
    }

    It 'summarizes enhanced restore offboarding counts from the graph batch response' {
        Mock -ModuleName O365Essentials Get-O365PortalContextHeaders -MockWith { @{ Referer = 'https://admin.microsoft.com/'; 'x-adminapp-request' = '/Settings/enhancedRestore' } }
        Mock -ModuleName O365Essentials Invoke-O365Admin -MockWith {
            [pscustomobject] @{
                responses = @(
                    [pscustomobject] @{ id = 'GetOffboardingSiteProtectionUnits'; status = 200; body = '4' }
                    [pscustomobject] @{ id = 'GetOffboardingDriveProtectionUnits'; status = 200; body = '2' }
                    [pscustomobject] @{ id = 'GetOffboardingMailboxProtectionUnits'; status = 200; body = '1' }
                )
            }
        }

        $Result = Get-O365OrgBackup -Name EnhancedRestoreStatus

        $Result.SiteOffboardingCount | Should -Be 4
        $Result.DriveOffboardingCount | Should -Be 2
        $Result.MailboxOffboardingCount | Should -Be 1
        $Result.RawResponses.Count | Should -Be 3
        Assert-MockCalled Invoke-O365Admin -ModuleName O365Essentials -ParameterFilter {
            $Uri -eq 'https://graph.microsoft.com/beta/$batch' -and $Method -eq 'POST'
        } -Exactly 1
    }

    It 'returns a placeholder when billing feature data is unavailable' {
        Mock -ModuleName O365Essentials Get-O365PortalContextHeaders -MockWith { @{ Referer = 'https://admin.microsoft.com/' } }
        Mock -ModuleName O365Essentials Invoke-O365Admin -MockWith { $null }

        $Result = Get-O365OrgBackup -Name BillingFeature

        $Result.Name | Should -Be 'BillingFeature'
        $Result.DataBacked | Should -BeFalse
    }
}
