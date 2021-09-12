function Get-O365AzureConditionalAccessPolicy {
    [cmdletbinding()]
    param(
        [parameter(ParameterSetName = 'PolicyID')]
        [parameter(ParameterSetName = 'PolicyName')]
        [alias('Authorization')][System.Collections.IDictionary] $Headers,

        [parameter(Mandatory, ParameterSetName = 'PolicyID')][string] $PolicyID,
        [parameter(Mandatory, ParameterSetName = 'PolicyName')][string] $PolicyName
    )
    # move it later on
    $Script:O365PolicyState = @{
        '2' = 'Report-only'
        '1' = 'Off'
        '0' = 'On' # i think
    }


    if ($PolicyID) {
        $Uri = "https://main.iam.ad.ext.azure.com/api/Policies/$PolicyID"
    } elseif ($PolicyName) {
        $FoundPolicy = $null
        $Policies = Get-O365AzureConditionalAccess -Headers $Headers
        foreach ($Policy in $Policies) {
            if ($Policy.policyName -eq $PolicyName) {
                $FoundPolicy = $Policy.policyId
                break
            }
        }
        if ($null -ne $FoundPolicy) {
            $Uri = "https://main.iam.ad.ext.azure.com/api/Policies/$FoundPolicy"
        } else {
            Write-Warning -Message "Get-O365AzureConditionalAccessPolicy - No policy with name $PolicyName"
            return
        }
    } else {
        Write-Warning -Message "Get-O365AzureConditionalAccessPolicy - No policy ID or name specified"
        return
    }

    $PolicyDetails = Invoke-O365Admin -Uri $Uri -Headers $Headers #-QueryParameter $QueryParameters
    if ($PolicyDetails) {
        [PSCustomObject] @{
            PolicyId               = $PolicyDetails.policyId         #: 7eac83fb-856b-45bf-9896-4fc78ea686f1
            PolicyName             = $PolicyDetails.policyName       #: Guest Access Policy 1
            ApplyRule              = $PolicyDetails.applyRule        #: False
            PolicyState            = $Script:O365PolicyState[$PolicyDetails.policyState.ToString()]      #: 1
            UsePolicyState         = $PolicyDetails.usePolicyState   #: True
            BaselineType           = $PolicyDetails.baselineType     #: 0
            CreatedDate            = $PolicyDetails.createdDateTime  #: 11.09.2021 09:02:21
            ModifiedDate           = $PolicyDetails.modifiedDateTime #: 11.09.2021 17:38:21
            users                  = $PolicyDetails.users                  #   # : @{allUsers=2; included=; excluded=}
            usersV2                = $PolicyDetails.usersV2                #   # : @{allUsers=2; included=; excluded=}
            servicePrincipals      = $PolicyDetails.servicePrincipals      #   # : @{allServicePrincipals=1; included=; excluded=; filter=; includeAllMicrosoftApps=False; excludeAllMicrosoftApps=False; userActions=; stepUpTags=}
            servicePrincipalsV2    = $PolicyDetails.servicePrincipalsV2    #   # : @{allServicePrincipals=1; included=; excluded=; filter=; includedAppContext=; shouldIncludeAppContext=False}
            controls               = $PolicyDetails.controls               #   # : @{controlsOr=True; blockAccess=False; challengeWithMfa=True; compliantDevice=False; domainJoinedDevice=False; approvedClientApp=False; claimProviderControlIds=System.Object[]; requireCompliantApp=False; requirePasswordChange=False; requiredFe
            #   #   deratedAuthMethod=0}
            sessionControls        = $PolicyDetails.sessionControls        #   # : @{appEnforced=False; cas=False; cloudAppSecuritySessionControlType=0; signInFrequencyTimeSpan=; signInFrequency=0; persistentBrowserSessionMode=0; continuousAccessEvaluation=0; resiliencyDefaults=0; secureSignIn=False}
            conditions             = $PolicyDetails.conditions             #   # : @{minUserRisk=; minSigninRisk=; devicePlatforms=; locations=; namedNetworks=; clientApps=; clientAppsV2=; time=; deviceState=}
            clientApplications     = $PolicyDetails.clientApplications     #   # : @{allServicePrincipals=0; filter=; includedServicePrincipals=; excludedServicePrincipals=}
            isAllProtocolsEnabled  = $PolicyDetails.isAllProtocolsEnabled  #   # : False
            isUsersGroupsV2Enabled = $PolicyDetails.isUsersGroupsV2Enabled #   # : False
            isCloudAppsV2Enabled   = $PolicyDetails.isCloudAppsV2Enabled   #   # : False
            version                = $PolicyDetails.version                #   # : 1
            isFallbackUsed         = $PolicyDetails.isFallbackUsed         #   # : False
        }
    }
}