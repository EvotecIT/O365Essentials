Import-Module "$PSScriptRoot/../O365Essentials.psd1" -Force
. "$PSScriptRoot/../Private/Get-O365OAuthToken.ps1"

Describe 'Connect-O365Admin portal token' {
    It 'requests portal token using resource parameter' {
        $cred = New-Object System.Management.Automation.PSCredential('user',(ConvertTo-SecureString 'pass' -AsPlainText -Force))
        Mock -ModuleName O365Essentials Get-O365OAuthToken -MockWith {
            param($Tenant,$Scope,$Resource,$ClientId,$Credential,$RefreshToken,$Device,$ClientSecret,$Certificate,$CertificatePassword)
            [pscustomobject]@{access_token='tok'; refresh_token='ref'}
        }
        Connect-O365Admin -Credential $cred | Out-Null
        Assert-MockCalled Get-O365OAuthToken -ModuleName O365Essentials -ParameterFilter { $Resource -eq 'https://main.iam.ad.ext.azure.com' } -Exactly 1
    }
}
