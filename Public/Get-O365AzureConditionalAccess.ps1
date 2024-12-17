function Get-O365AzureConditionalAccess {
    <#
    .SYNOPSIS
    Retrieves Azure Conditional Access policies.

    .DESCRIPTION
    This function retrieves Azure Conditional Access policies based on the provided headers. It returns a list of policies with their details, including policy ID, name, apply rule, state, use policy state, baseline type, creation date, and modification date. If the -Details switch is used, it retrieves detailed information about each policy.

    .PARAMETER Headers
    A dictionary containing the headers for the API request, typically including authorization information.

    .PARAMETER Details
    A switch parameter to indicate if detailed information about each policy is required.

    .EXAMPLE
    Get-O365AzureConditionalAccess -Headers $headers
    Get-O365AzureConditionalAccess -Headers $headers -Details

    .NOTES
    For more information, visit: https://docs.microsoft.com/en-us/azure/active-directory/conditional-access/overview
    #>
    [cmdletbinding()]
    param(
        [alias('Authorization')][System.Collections.IDictionary] $Headers,
        [switch] $Details
    )
    #$Uri = 'https://graph.microsoft.com/v1.0/identity/conditionalAccess/policies'
    # Need to figure out scopes and use graph instead. But till then...
    #$Uri = 'https://main.iam.ad.ext.azure.com/api/Policies/Policies?top=10&nextLink=null&appId=&includeBaseline=true'
    # "https://main.iam.ad.ext.azure.com/api/Policies/7eac83fb-856b-45bf-9896-4fc78ea686f1"

    # move it later on
    $Script:O365PolicyState = @{
        '2' = 'Report-only'
        '1' = 'Off'
        '0' = 'On' # i think
    }

    $QueryParameters = @{
        top             = 10
        nextLink        = $null
        #appID           = ''
        includeBaseline = $true
    }
    $Uri = 'https://main.iam.ad.ext.azure.com/api/Policies/Policies'

    $Output = Invoke-O365Admin -Uri $Uri -Headers $Headers -QueryParameter $QueryParameters
    if ($Output.items) {
        foreach ($Policy in $Output.items) {
            if (-not $Details) {
                [PSCustomObject] @{
                    PolicyId       = $Policy.policyId         #: 7eac83fb-856b-45bf-9896-4fc78ea686f1
                    PolicyName     = $Policy.policyName       #: Guest Access Policy 1
                    ApplyRule      = $Policy.applyRule        #: False
                    PolicyState    = $O365PolicyState[$Policy.policyState.ToString()]      #: 1
                    UsePolicyState = $Policy.usePolicyState   #: True
                    BaselineType   = $Policy.baselineType     #: 0
                    CreatedDate    = $Policy.createdDateTime  #: 11.09.2021 09:02:21
                    ModifiedDate   = $Policy.modifiedDateTime #: 11.09.2021 17:38:21
                }
            } else {
                $PolicyDetails = Get-O365AzureConditionalAccessPolicy -PolicyID $Policy.policyId
                if ($PolicyDetails) {
                    $PolicyDetails
                }
            }
        }
    }
}