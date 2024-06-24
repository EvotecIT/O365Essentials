function Set-O365OrgOrganizationInformation {
    <#
        .SYNOPSIS
        Updates the organization information for an Office 365 tenant.
        .DESCRIPTION
        This function allows you to update various details about your Office 365 organization, such as the name, address, city, state, postal code, phone number, and technical contact email. It retrieves the current settings and updates only the specified parameters.
        .PARAMETER Headers
        Specifies the headers for the API request. Typically includes authorization tokens.
        .PARAMETER Name
        Specifies the name of the organization.
        .PARAMETER StreetAddress
        Specifies the street address of the organization.
        .PARAMETER ApartmentOrSuite
        Specifies the apartment or suite number of the organization.
        .PARAMETER City
        Specifies the city where the organization is located.
        .PARAMETER State
        Specifies the state where the organization is located.
        .PARAMETER PostalCode
        Specifies the postal code of the organization.
        .PARAMETER PhoneNumber
        Specifies the phone number of the organization.
        .PARAMETER TechnicalContactEmail
        Specifies the technical contact email for the organization.
        .EXAMPLE
        $headers = @{Authorization = "Bearer your_token"}
        Set-O365OrgOrganizationInformation -Headers $headers -Name "Contoso Ltd." -StreetAddress "123 Main St" -City "Redmond" -State "WA" -PostalCode "98052" -PhoneNumber "123-456-7890" -TechnicalContactEmail "admin@contoso.com"

        This example updates the organization information for Contoso Ltd. with the specified address, city, state, postal code, phone number, and technical contact email.
    #>
    [cmdletbinding(SupportsShouldProcess)]
    param(
        [alias('Authorization')][System.Collections.IDictionary] $Headers,
        [string] $Name,
        [string] $StreetAddress,
        [string] $ApartmentOrSuite,
        [string] $City,
        [string] $State,
        [string] $PostalCode,
        #[string] $Country,
        #[string] $CountryCode,
        #[string] $PossibleStatesOrProvinces,
        [string] $PhoneNumber,
        [string] $TechnicalContactEmail
    )
    $Uri = "https://admin.microsoft.com/admin/api/Settings/company/profile"

    $CurrentSettings = Get-O365OrgOrganizationInformation -Headers $Headers
    if ($CurrentSettings) {
        $Body = @{
            Name                  = $CurrentSettings.Name                      ## : Evotec
            Address1              = $CurrentSettings.Address1                  ## :
            Address2              = $CurrentSettings.Address2                  ## :
            #Address3                  = $CurrentSettings.Address3                  ## :
            #Address4                  = $CurrentSettings.Address4                  ## :
            City                  = $CurrentSettings.City                      ## : KATOWICE
            State                 = $CurrentSettings.State                     ## : Śląskie
            PostalCode            = $CurrentSettings.PostalCode                ## : 40-
            Country               = $CurrentSettings.Country                   ## : Poland
            #CountryCode               = $CurrentSettings.CountryCode               ## : PL
            #PossibleStatesOrProvinces = $CurrentSettings.PossibleStatesOrProvinces ## :
            PhoneNumber           = $CurrentSettings.PhoneNumber               ## : +4
            TechnicalContactEmail = $CurrentSettings.TechnicalContactEmail     ## : p
            #DefaultDomain             = $CurrentSettings.DefaultDomain             ## :
            Language              = $CurrentSettings.Language                  ## : en
            #MSPPID                    = $CurrentSettings.MSPPID                    ## :
            #SupportUrl                = $CurrentSettings.SupportUrl                ## :
            #SupportEmail              = $CurrentSettings.SupportEmail              ## :
            #SupportPhone              = $CurrentSettings.SupportPhone              ## :
            SupportedLanguages    = $CurrentSettings.SupportedLanguages        ## : {@{ID=en; Name=English; Default=True; DefaultCulture=en-US; PluralFormRules=IsOne}, @{ID=pl; Name=polski; Default=False; DefaultCulture=pl-PL; PluralFormRules=IsOne,EndsInTwoThruFourNotTweleveThruFourteen}}
        }
        if ($PSBoundParameters.ContainsKey('Name')) {
            $Body.Name = $Name
        }
        if ($PSBoundParameters.ContainsKey('StreetAddress')) {
            $Body.Address1 = $StreetAddress
        }
        if ($PSBoundParameters.ContainsKey('ApartmentOrSuite')) {
            $Body.Address2 = $ApartmentOrSuite
        }
        if ($PSBoundParameters.ContainsKey('City')) {
            $Body.City = $City
        }
        if ($PSBoundParameters.ContainsKey('State')) {
            $Body.State = $State
        }
        if ($PSBoundParameters.ContainsKey('PostalCode')) {
            $Body.PostalCode = $PostalCode
        }
        #if ($PSBoundParameters.ContainsKey('Country')) {
        #    $Body.Country = $Country
        #}
        #if ($PSBoundParameters.ContainsKey('CountryCode')) {
        #    $Body.CountryCode = $CountryCode
        #}
        if ($PSBoundParameters.ContainsKey('PhoneNumber')) {
            $Body.PhoneNumber = $PhoneNumber
        }
        if ($PSBoundParameters.ContainsKey('TechnicalContactEmail')) {
            $Body.TechnicalContactEmail = $TechnicalContactEmail
        }

        $Output = Invoke-O365Admin -Uri $Uri -Headers $Headers -Method POST -Body $Body
        $Output
    }
}
