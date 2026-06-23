Import-Module "$PSScriptRoot/../O365Essentials.psd1" -Force

Describe 'Set-O365OrgGraphDataConnect' {
    It 'does not submit enabled settings without a lockbox approver group' {
        Mock -ModuleName O365Essentials Get-O365OrgGraphDataConnect -MockWith {
            [pscustomobject]@{
                ServiceEnabled             = $true
                TenantLockBoxApproverGroup = ''
            }
        }
        Mock -ModuleName O365Essentials Invoke-O365Admin -MockWith { }
        Mock -ModuleName O365Essentials Write-Warning

        Set-O365OrgGraphDataConnect -Headers @{ HeadersO365 = @{ Authorization = 'Bearer token' } } -ServiceEnabled $true | Out-Null

        Assert-MockCalled Invoke-O365Admin -ModuleName O365Essentials -Exactly 0
        Assert-MockCalled Write-Warning -ModuleName O365Essentials -ParameterFilter {
            $Message -eq 'Set-O365OrgGraphDataConnect - TenantLockBoxApproverGroup is required when Graph Data Connect is enabled.'
        } -Exactly 1
    }

    It 'submits enabled settings when an approver group is supplied' {
        Mock -ModuleName O365Essentials Get-O365OrgGraphDataConnect -MockWith {
            [pscustomobject]@{
                ServiceEnabled             = $false
                TenantLockBoxApproverGroup = ''
            }
        }
        Mock -ModuleName O365Essentials Invoke-O365Admin -MockWith { }

        Set-O365OrgGraphDataConnect -Headers @{ HeadersO365 = @{ Authorization = 'Bearer token' } } -ServiceEnabled $true -TenantLockBoxApproverGroup 'approvers@contoso.com' | Out-Null

        Assert-MockCalled Invoke-O365Admin -ModuleName O365Essentials -ParameterFilter {
            $Uri -eq 'https://admin.microsoft.com/admin/api/settings/apps/o365dataplan' -and
            $Method -eq 'POST' -and
            $Body.ServiceEnabled -eq $true -and
            $Body.TenantLockBoxApproverGroup -eq 'approvers@contoso.com'
        } -Exactly 1
    }
}
