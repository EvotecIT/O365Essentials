function Set-O365OrgVivaLearning {
    [cmdletbinding(SupportsShouldProcess)]
    param(
        [alias('Authorization')][System.Collections.IDictionary] $Headers,
        [bool] $LinkedInLearningEnabled,
        [bool] $MicrosoftLearnEnabled,
        [bool] $Microsoft365TrainingEnabled,
        [bool] $IsOptionalDiagnosticDataEnabled
    )

    # We need to get current settings because it always requires all parameters
    # If we would just provide one parameter it would reset everything else
    $CurrentSettings = Get-O365OrgVivaLearning -Headers $Headers
    $Body = [ordered] @{
        CornerstoneClientId                    = $CurrentSettings.CornerstoneClientId
        CornerstoneClientSecret                = $CurrentSettings.CornerstoneClientSecret
        CornerstoneDisplayName                 = $CurrentSettings.CornerstoneDisplayName
        CornerstoneEnabled                     = $CurrentSettings.CornerstoneEnabled
        CornerstoneExternalErrorCode           = $CurrentSettings.CornerstoneExternalErrorCode
        CornerstoneHostUrl                     = $CurrentSettings.CornerstoneHostUrl
        CornerstoneIngestionPipelineStatus     = $CurrentSettings.CornerstoneIngestionPipelineStatus
        CornerstoneLastIngestionProcessDate    = $CurrentSettings.CornerstoneLastIngestionProcessDate
        CourseraEnabled                        = $CurrentSettings.CourseraEnabled
        DefaultRegion                          = $CurrentSettings.DefaultRegion
        EdCastClientHostUrl                    = $CurrentSettings.EdCastClientHostUrl
        EdCastClientId                         = $CurrentSettings.EdCastClientId
        EdCastClientSecret                     = $CurrentSettings.EdCastClientSecret
        EdCastEnabled                          = $CurrentSettings.EdCastEnabled
        EdCastExternalErrorCode                = $CurrentSettings.EdCastExternalErrorCode
        EdCastIngestionPipelineStatus          = $CurrentSettings.EdCastIngestionPipelineStatus
        EdCastLastIngestionProcessDate         = $CurrentSettings.EdCastLastIngestionProcessDate
        EdCastUserEmail                        = $CurrentSettings.EdCastUserEmail
        EdXEnabled                             = $CurrentSettings.EdXEnabled
        Go1ClientHostUrl                       = $CurrentSettings.Go1ClientHostUrl
        Go1ClientId                            = $CurrentSettings.Go1ClientId
        Go1ClientSecret                        = $CurrentSettings.Go1ClientSecret
        Go1Enabled                             = $CurrentSettings.Go1Enabled
        Go1ExternalErrorCode                   = $CurrentSettings.Go1ExternalErrorCode
        Go1IngestionPipelineStatus             = $CurrentSettings.Go1IngestionPipelineStatus
        Go1LastIngestionProcessDate            = $CurrentSettings.Go1LastIngestionProcessDate
        InfosecEnabled                         = $CurrentSettings.InfosecEnabled
        Is3PLearningSourceEnabled              = $CurrentSettings.Is3PLearningSourceEnabled
        IsLMSLearningSourceEnabled             = $CurrentSettings.IsLMSLearningSourceEnabled
        IsMultiGeo                             = $CurrentSettings.IsMultiGeo
        IsOptionalDiagnosticDataEnabled        = $CurrentSettings.IsOptionalDiagnosticDataEnabled
        IsSharePointSourceEnabled              = $CurrentSettings.IsSharePointSourceEnabled
        IsSkillsoftEnabled                     = $CurrentSettings.IsSkillsoftEnabled
        IsTier13PsEnabled                      = $CurrentSettings.IsTier13PsEnabled
        JbaEnabled                             = $CurrentSettings.JbaEnabled
        LinkedInLearningEnabled                = $CurrentSettings.LinkedInLearningEnabled
        Microsoft365TrainingEnabled            = $CurrentSettings.Microsoft365TrainingEnabled
        MicrosoftLearnEnabled                  = $CurrentSettings.MicrosoftLearnEnabled
        PluralsightEnabled                     = $CurrentSettings.PluralsightEnabled
        SabaClientId                           = $CurrentSettings.SabaClientId
        SabaClientSecret                       = $CurrentSettings.SabaClientSecret
        SabaDisplayName                        = $CurrentSettings.SabaDisplayName
        SabaEnabled                            = $CurrentSettings.SabaEnabled
        SabaExternalErrorCode                  = $CurrentSettings.SabaExternalErrorCode
        SabaHostUrl                            = $CurrentSettings.SabaHostUrl
        SabaIngestionPipelineStatus            = $CurrentSettings.SabaIngestionPipelineStatus
        SabaLastIngestionProcessDate           = $CurrentSettings.SabaLastIngestionProcessDate
        SabaPassword                           = $CurrentSettings.SabaPassword
        SabaUsername                           = $CurrentSettings.SabaUsername
        SharePointEnabled                      = $CurrentSettings.SharePointEnabled
        SharePointUrl                          = $CurrentSettings.SharePointUrl
        SkillsoftEnabled                       = $CurrentSettings.SkillsoftEnabled
        SkillsoftExternalErrorCode             = $CurrentSettings.SkillsoftExternalErrorCode
        SkillsoftIngestionPipelineStatus       = $CurrentSettings.SkillsoftIngestionPipelineStatus
        SkillsoftLastIngestionProcessDate      = $CurrentSettings.SkillsoftLastIngestionProcessDate
        SkillsoftOrganizationId                = $CurrentSettings.SkillsoftOrganizationId
        SkillsoftServiceAccountKey             = $CurrentSettings.SkillsoftServiceAccountKey
        SuccessFactorsClientDestinationUrl     = $CurrentSettings.SuccessFactorsClientDestinationUrl
        SuccessFactorsClientHostUrl            = $CurrentSettings.SuccessFactorsClientHostUrl
        SuccessFactorsCompanyID                = $CurrentSettings.SuccessFactorsCompanyID
        SuccessFactorsDisplayName              = $CurrentSettings.SuccessFactorsDisplayName
        SuccessFactorsEnabled                  = $CurrentSettings.SuccessFactorsEnabled
        SuccessFactorsExternalErrorCode        = $CurrentSettings.SuccessFactorsExternalErrorCode
        SuccessFactorsFolderPath               = $CurrentSettings.SuccessFactorsFolderPath
        SuccessFactorsHostUrl                  = $CurrentSettings.SuccessFactorsHostUrl
        SuccessFactorsIngestionPipelineStatus  = $CurrentSettings.SuccessFactorsIngestionPipelineStatus
        SuccessFactorsLastIngestionProcessDate = $CurrentSettings.SuccessFactorsLastIngestionProcessDate
        SuccessFactorsPassword                 = $CurrentSettings.SuccessFactorsPassword
        SuccessFactorsPrivateKey               = $CurrentSettings.SuccessFactorsPrivateKey
        SuccessFactorsPrivateKeyPassphrase     = $CurrentSettings.SuccessFactorsPrivateKeyPassphrase
        SuccessFactorsUsername                 = $CurrentSettings.SuccessFactorsUsername
        TenantSpecificSkillsoftEnabled         = $CurrentSettings.TenantSpecificSkillsoftEnabled
        UdemyClientHostUrl                     = $CurrentSettings.UdemyClientHostUrl
        UdemyClientId                          = $CurrentSettings.UdemyClientId
        UdemyClientSecret                      = $CurrentSettings.UdemyClientSecret
        UdemyEnabled                           = $CurrentSettings.UdemyEnabled
        UdemyExternalErrorCode                 = $CurrentSettings.UdemyExternalErrorCode
        UdemyIngestionPipelineStatus           = $CurrentSettings.UdemyIngestionPipelineStatus
        UdemyLastIngestionProcessDate          = $CurrentSettings.UdemyLastIngestionProcessDate
        UdemyOrganizationId                    = $CurrentSettings.UdemyOrganizationId
    }
    if ($PSBoundParameters.ContainsKey('LinkedInLearningEnabled')) {
        $Body.LinkedInLearningEnabled = $LinkedInLearningEnabled
    }
    if ($PSBoundParameters.ContainsKey('MicrosoftLearnEnabled')) {
        $Body.MicrosoftLearnEnabled = $MicrosoftLearnEnabled
    }
    if ($PSBoundParameters.ContainsKey('Microsoft365TrainingEnabled')) {
        $Body.Microsoft365TrainingEnabled = $Microsoft365TrainingEnabled
    }
    if ($PSBoundParameters.ContainsKey('IsOptionalDiagnosticDataEnabled')) {
        $Body.IsOptionalDiagnosticDataEnabled = $IsOptionalDiagnosticDataEnabled
    }

    $Uri = "https://admin.microsoft.com/admin/api/settings/apps/learning"
    $Output = Invoke-O365Admin -Uri $Uri -Headers $Headers -Method POST -Body $Body
    $Output
}